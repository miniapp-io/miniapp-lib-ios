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
    
    private let _cacheKey = "__miniappx_openplatform_jwt"
    
    var isDev: Bool = false
    var apiHost: String? = nil
    
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
    
    override public func signIn(verifier: String,
                                isDev: Bool,
                                apiHost: String?,
                              idTokenProvider: @escaping () async -> String?,
                              onVerifierSuccess: @escaping () -> Void,
                              onVerifierFailure: @escaping (Int,String?) -> Void) {
        
        self.isDev = isDev
        self.apiHost = apiHost
        
        let verifierProcess: (String, (() -> Void)?, (() -> Void)?) -> Void = { token, refreshToken, complete in
            Task { [weak self] in
                
                self?.isRefreshing = true

                let result = await OpenServiceRepository.shared.auth(verifier: verifier, idToken: token)
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let dto):
                    SessionProvider.shared.token = SessionState(token: dto.accessToken.data(using: .utf8)!)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                        onVerifierSuccess()
                    })
                case .failure(let apiErr):
                    switch apiErr {
                    case let .requestFailed(statusCode, message):
                        if statusCode == 401 {
                            refreshToken?() ?? onVerifierFailure(statusCode, message)
                        } else {
                            onVerifierFailure(statusCode, message)
                        }
                    default:
                        onVerifierFailure(404, "Unknown Network Err")
                    }
                }
                
                strongSelf.isRefreshing = false
                
                complete?()
            }
        }
        
        let idTokenProcess : (@escaping (String,(() -> Void)?,(() -> Void)?) -> Void, (() -> Void)?) -> Void = { [weak self] nextStep, complete in
            guard let strongSelf = self else {
                self?.isRefreshing = false
                return
            }
            var cacheData:String? = loadCodableData(forKey: strongSelf._cacheKey)
            if let cacheToken = cacheData {
                print("MiniAppX: Use Jwt from cache!")
                nextStep(cacheToken, {
                    saveCodableData(nil, forKey: strongSelf._cacheKey)
                    Task {
                        if let token = await idTokenProvider() {
                            nextStep(token, nil, complete)
                            saveCodableData(token, forKey: strongSelf._cacheKey)
                        } else {
                            self?.isRefreshing = false
                        }
                    }
                }, complete)
            } else {
                Task {
                    if let token = await idTokenProvider() {
                        print("MiniAppX: Use Jwt fome provider!")
                        nextStep(token, nil, complete)
                        saveCodableData(token, forKey: strongSelf._cacheKey)
                    } else {
                        self?.isRefreshing = false
                    }
                }
            }
        }
        
        if SessionProvider.shared.refreshToken == nil {
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
                    saveCodableData(nil, forKey: weakSelf._cacheKey)
                    return await withCheckedContinuation { continuation in
                        idTokenProcess(verifierProcess) {
                            continuation.resume(returning: SessionProvider.shared.token)
                        }
                    }
                }
            }
        }
        
        if SessionProvider.shared.isAuth() {
            onVerifierSuccess()
            return
        }
        
        idTokenProcess(verifierProcess, nil)
        
    }
    
    override public func signOut() -> Void {
        SessionProvider.shared.token = nil
        saveCodableData(nil, forKey: self._cacheKey)
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
