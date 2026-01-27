//
//  AuthManager.swift
//  Pods
//
//  Created by Zhibiao Chen on 2026/1/27.
//

import Foundation

internal actor AuthManager {
    static let shared = AuthManager()
    
    private let _cacheKey = "__open_platform_verifier_data"
    
    private var isInitialize = false
    private var isRefreshing = false
    private var currentRefreshTask: Task<String?, Error>?
    
    private var verifier: String?
    private var isDev: Bool = false
    private var idTokenProvider: (() async -> String?)?
    
    private init() {}
    
    func initialize(
        verifier: String,
        idTokenProvider: @escaping () async -> String?
    ) {
        if self.isInitialize {
            return
        }
        
        self.isInitialize = true
        self.verifier = verifier
        self.idTokenProvider = idTokenProvider
    }
    
    func signIn() async throws {
        if await isAuth() {
            return
        }
        
        try await authenticate()
    }
    
    private func authenticate(forceRefresh: Bool = false) async throws {
        guard let verifier = self.verifier else {
            throw AuthError.notInitialized
        }
        
        guard let idTokenProvider = self.idTokenProvider else {
            throw AuthError.noIdTokenProvider
        }
        
        let idToken: String
        if forceRefresh {
            saveCodableData(nil, forKey: _cacheKey)
            guard let token = await idTokenProvider() else {
                throw AuthError.idTokenUnavailable
            }
            idToken = token
            saveCodableData(token, forKey: _cacheKey)
        } else {
            if let cachedToken: String = loadCodableData(forKey: _cacheKey) {
                idToken = cachedToken
            } else {
                guard let token = await idTokenProvider() else {
                    throw AuthError.idTokenUnavailable
                }
                idToken = token
                saveCodableData(token, forKey: _cacheKey)
            }
        }
        
        do {
            let result = await OpenServiceRepository.shared.auth(
                verifier: verifier,
                idToken: idToken
            )
            
            switch result {
            case .success(let dto):
                let tokenData = dto.accessToken.data(using: .utf8)!
                SessionProvider.shared.token = SessionState(token: tokenData)
                
            case .failure(let apiErr):
                switch apiErr {
                case let .requestFailed(statusCode, message):
                    if statusCode == 401 && !forceRefresh {
                        // 清理缓存并重试
                        saveCodableData(nil, forKey: _cacheKey)
                        try await authenticate(forceRefresh: true)
                    } else {
                        throw AuthError.authFailed(statusCode: statusCode, message: message)
                    }
                default:
                    throw AuthError.unknownError
                }
            }
        } catch {
            throw error
        }
    }
    
    func refreshToken() async -> String? {
        // 如果有正在进行的刷新操作，等待它
        if isRefreshing, let existingTask = currentRefreshTask {
            return try? await existingTask.value
        }
        
        return await performRefreshToken()
    }
    
    private func performRefreshToken() async -> String? {
        guard let verifier = self.verifier,
              let idTokenProvider = self.idTokenProvider else {
            return nil
        }
        
        let task = Task<String?, Error> { [weak self] in
            guard let self = self else { return nil }
            
            // 清理缓存
            saveCodableData(nil, forKey: self._cacheKey)
            
            // 获取新的 ID Token
            guard let token = await idTokenProvider() else {
                return nil
            }
            
            saveCodableData(token, forKey: self._cacheKey)
            
            let result = await OpenServiceRepository.shared.auth(
                verifier: verifier,
                idToken: token
            )
            
            switch result {
            case .success(let dto):
                let tokenData = dto.accessToken.data(using: .utf8)!
                SessionProvider.shared.token = SessionState(token: tokenData)
                return dto.accessToken
                
            case .failure(let apiErr):
                switch apiErr {
                case let .requestFailed(statusCode, _):
                    throw AuthError.authFailed(statusCode: statusCode, message: nil)
                default:
                    throw AuthError.unknownError
                }
            }
        }
        
        // 保存当前刷新任务
        isRefreshing = true
        currentRefreshTask = task
        
        defer {
            isRefreshing = false
            currentRefreshTask = nil
        }
        
        do {
            let token = try await task.value
            return token
        } catch {
            return nil
        }
    }
    
    func isAuth() -> Bool {
        return SessionProvider.shared.isAuth()
    }
    
    func getToken() -> String? {
        guard let tokenData = SessionProvider.shared.token?.token,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        return token
    }
    
    func clearToken() {
        SessionProvider.shared.token = nil
    }
    
    func signOut() {
        clearToken()
        
        isRefreshing = false
        currentRefreshTask?.cancel()
        currentRefreshTask = nil
        
        saveCodableData(nil, forKey: _cacheKey)
    }
}

// MARK: - Supporting Types
internal enum AuthError: Error {
    case notInitialized
    case noIdTokenProvider
    case idTokenUnavailable
    case authFailed(statusCode: Int, message: String?)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .notInitialized:
            return "AuthManager not initialized"
        case .noIdTokenProvider:
            return "ID Token provider not configured"
        case .idTokenUnavailable:
            return "ID Token is unavailable"
        case .authFailed(let statusCode, let message):
            return "Authentication failed with status code \(statusCode): \(message ?? "No message")"
        case .unknownError:
            return "Unknown authentication error"
        }
    }
}


internal func errorToStatusAndMessage(_ error: Error) -> (Int, String?) {
    if let authError = error as? AuthError {
        switch authError {
        case .authFailed(let statusCode, let message):
            return (statusCode, message)
        case .notInitialized:
            return (400, "AuthManager not initialized")
        case .noIdTokenProvider:
            return (400, "ID Token provider not configured")
        case .idTokenUnavailable:
            return (400, "ID Token is unavailable")
        case .unknownError:
            return (500, "Unknown authentication error")
        }
    }
    return (500, error.localizedDescription)
}
