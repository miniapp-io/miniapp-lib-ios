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
                     apiHost: String,
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
    
    var apiHost: String?
    var isDev: Bool = false
    
    private let _miniAppService = MiniAppServiceImpl.instance
    private let _botService = BotServiceImpl.shared
    private let _aiService = AIServiceImpl.shared
    
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
    
    // MARK: - SignIn
    override public func signIn(verifier: String,
                                isDev: Bool,
                                apiHost: String,
                              idTokenProvider: @escaping () async -> String?,
                              onVerifierSuccess: @escaping () -> Void,
                              onVerifierFailure: @escaping (Int,String?) -> Void) {
        
        self.apiHost = apiHost
        self.isDev = isDev

        
        Task {
            await AuthManager.shared.initialize(verifier: verifier, idTokenProvider: idTokenProvider)
            
            do {
                try await AuthManager.shared.signIn()
                DispatchQueue.main.async {
                    onVerifierSuccess()
                }
            } catch {
                let (statusCode, message) = errorToStatusAndMessage(error)
                DispatchQueue.main.async {
                    onVerifierFailure(statusCode, message)
                }
            }
        }
    }
    
    override public func signOut() -> Void {
        Task {
            await AuthManager.shared.signOut()
            WebAppLruCache.removeAll()
            print("MiniAppX: signOut invoke!")
        }
    }
    
    override public func getBotService() -> BotService? {
       return _botService
    }
    
    override public func getMiniAppService() -> MiniAppService? {
        return _miniAppService
    }
}
