//
//  OpenPlatformPlugin.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/25.
//

import Foundation

public class OpenPlatformPlugin : Plugin {
    
   open func load() -> Bool {
        return false
    }
    
    open func unLoad() {
    }
    
    open func getName() -> String {
        return ""
    }
    
    open func signIn(verifier: String,
                     isDev: Bool = false,
                     apiHost: String? = nil,
                   idTokenProvider: @escaping () async -> String?,
                   onVerifierSuccess: @escaping () -> Void,
                   onVerifierFailure: @escaping (Int,String?) -> Void) {
    }
    
    open func signOut() -> Void {
        
    }
    
    open func isVerified() -> Bool {
        return false
    }
    
    open func getBotService() -> BotService? {
       return nil
    }
    
    open func getMiniAppService() -> MiniAppService? {
        return nil
    }
}

internal class OpenPlatformPluginImpl : OpenPlatformPlugin {
    
    private static let instance = OpenPlatformPluginImpl()
    
    public static func getInstance() -> OpenPlatformPluginImpl {
        return instance
    }
    
    private override init() {
        super.init()
        self.load()
    }
    
    private let _miniAppService = MiniAppServiceImpl.instance
    private let _botService = BotServiceImpl.shared
    private let _aiService = AIServiceImpl.shared
    private var isRefreshing = false
    
    private let _appJwtCacheKey = "__miniappx_openplatform_jwt"
    
    var isDev: Bool = false
    var apiHost: String? = nil
    
    // MARK: - SignIn
    private var _verifier: String = ""
    private var _idTokenProvider: (() async -> String?)? = nil
    
    override public func isVerified() -> Bool {
        return SessionProvider.shared.isAuth()
    }
    
    override public func load() -> Bool {
        return _botService.load() && _miniAppService.load() && _aiService.load()
    }
    
    override public func unLoad() {
        _miniAppService.unload()
        _botService.unload()
        _aiService.unLoad()
    }
    
    override public func getName() -> String {
        return PluginName.openPlatform.rawValue
    }
    
    // MARK: - Auth Process
    private func authProcess(
        token: String,
        refreshTokenAction: (() -> Void)?,
        complete: (() -> Void)?,
        onVerifierSuccess: (() -> Void)?,
        onVerifierFailure: ((Int, String?) -> Void)?
    ) {
        Task { [weak self] in
            self?.isRefreshing = true
            
            guard let strongSelf = self else {
                return
            }
            
            let result = await OpenServiceRepository.shared.auth(verifier: strongSelf._verifier, idToken: token)
            
            switch result {
            case .success(let dto):
                SessionProvider.shared.token = SessionState(token: dto.accessToken.data(using: .utf8)!)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    onVerifierSuccess?()
                })
            case .failure(let apiErr):
                switch apiErr {
                case let .requestFailed(statusCode, message):
                    if statusCode == 401 {
                        refreshTokenAction?() ?? onVerifierFailure?(statusCode, message)
                    } else {
                        onVerifierFailure?(statusCode, message)
                    }
                default:
                    onVerifierFailure?(404, "Unknown Network Err")
                }
            }
            
            if refreshTokenAction == nil {
                strongSelf.isRefreshing = false
                complete?()
            }
        }
    }
    
    // MARK: - Get IdToken Process
    private func getIdTokenProcess(
        complete: (() -> Void)?,
        onVerifierSuccess: (() -> Void)?,
        onVerifierFailure: ((Int, String?) -> Void)?
    ) {
        guard let idTokenProvider = self._idTokenProvider else {
            self.isRefreshing = false
            return
        }
        
        let cacheData: String? = loadCodableData(forKey: self._appJwtCacheKey)
        if let cacheToken = cacheData {
            print("MiniAppX: Use Jwt from cache!")
            authProcess(token: cacheToken, refreshTokenAction: { [weak self] in
                guard let strongSelf = self else { return }
                saveCodableData(nil, forKey: strongSelf._appJwtCacheKey)
                Task {
                    if let token = await idTokenProvider() {
                        saveCodableData(token, forKey: strongSelf._appJwtCacheKey)
                        strongSelf.authProcess(token: token, refreshTokenAction: nil, complete: complete, onVerifierSuccess: onVerifierSuccess, onVerifierFailure: onVerifierFailure)
                    } else {
                        strongSelf.isRefreshing = false
                        complete?()
                    }
                }
            }, complete: complete, onVerifierSuccess: onVerifierSuccess, onVerifierFailure: onVerifierFailure)
        } else {
            Task { [weak self] in
                guard let strongSelf = self else { return }
                if let token = await idTokenProvider() {
                    print("MiniAppX: Use Jwt from provider!")
                    saveCodableData(token, forKey: strongSelf._appJwtCacheKey)
                    strongSelf.authProcess(token: token, refreshTokenAction: nil, complete: complete, onVerifierSuccess: onVerifierSuccess, onVerifierFailure: onVerifierFailure)
                } else {
                    strongSelf.isRefreshing = false
                }
            }
        }
    }
    
    // MARK: - SignIn
    override public func signIn(verifier: String,
                                isDev: Bool,
                                apiHost: String?,
                              idTokenProvider: @escaping () async -> String?,
                              onVerifierSuccess: @escaping () -> Void,
                              onVerifierFailure: @escaping (Int,String?) -> Void) {
        
        self.isDev = isDev
        self.apiHost = apiHost
        self._verifier = verifier
        self._idTokenProvider = idTokenProvider
        
        saveCodableData(nil, forKey: self._appJwtCacheKey)
        
        SessionProvider.shared.refreshToken = { [weak self] in
            guard let weakSelf = self else {
                return SessionProvider.shared.token
            }
            if weakSelf.isRefreshing && SessionProvider.shared.token == nil {
                while weakSelf.isRefreshing && SessionProvider.shared.token == nil {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                }
                return SessionProvider.shared.token
            } else {
                weakSelf.isRefreshing = true
                saveCodableData(nil, forKey: weakSelf._appJwtCacheKey)
                return await withCheckedContinuation { continuation in
                    weakSelf.getIdTokenProcess(
                        complete: { continuation.resume(returning: SessionProvider.shared.token) },
                        onVerifierSuccess: nil,
                        onVerifierFailure: nil
                    )
                }
            }
        }
        
        getIdTokenProcess(
            complete: nil,
            onVerifierSuccess: onVerifierSuccess,
            onVerifierFailure: onVerifierFailure
        )
    }
    
    override public func signOut() -> Void {
        SessionProvider.shared.refreshToken = nil
        SessionProvider.shared.token = nil
        saveCodableData(nil, forKey: self._appJwtCacheKey)
        WebAppLruCache.removeAll()
        print("MiniAppX: signOut invoke!")
    }
    
    override public func getBotService() -> BotService? {
       return _botService
    }
    
    override public func getMiniAppService() -> MiniAppService? {
        return _miniAppService
    }
}
