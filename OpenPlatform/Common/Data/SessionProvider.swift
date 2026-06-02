//
//  SessionProvider.swift
//  MiniAppX
//
//  Created by w3bili on 2024/8/29.
//

import Foundation

internal class SessionProvider {
    
    private let queue = DispatchQueue(label: "com.miniappx.session", attributes: .concurrent)
    
    static let shared = SessionProvider()
    
    private static let tokenExpireSkewSeconds: Int64 = 30
    
    final let sessionKey = "$#_session"
    
    private var suppressPersist = false
    
    private var _token: SessionState? {
        didSet {
            if !suppressPersist {
                save()
            }
        }
    }
    
    var token: SessionState? {
        get {
            queue.sync {
                return _token
            }
        }
        set(value) {
            queue.async(flags: .barrier) {
                self._token = value
            }
        }
    }
    
    private init() {
        load()
    }
    
    func isAuth() -> Bool {
        queue.sync {
            guard let state = _token, !state.token.isEmpty else {
                return false
            }
            return !isTokenExpirationTimeUnlocked()
        }
    }
    
    func isTokenExpirationTime() -> Bool {
        queue.sync {
            isTokenExpirationTimeUnlocked()
        }
    }
    
    private func isTokenExpirationTimeUnlocked() -> Bool {
        let expiresAt = _token?.expiresAt ?? 0
        let expiresAtSeconds = expiresAt > 9_999_999_999 ? expiresAt / 1000 : expiresAt
        let nowSeconds = Int64(Date().timeIntervalSince1970)
        return expiresAtSeconds <= nowSeconds + Self.tokenExpireSkewSeconds
    }
    
    private func load() {
        queue.sync {
            suppressPersist = true
            _token = loadCodableData(forKey: sessionKey)
            suppressPersist = false
            
            if isTokenExpirationTimeUnlocked() {
                _token = nil
            }
        }
    }
    
    private func save() {
        queue.async(flags: .barrier) {
            saveCodableData(self._token, forKey: self.sessionKey)
        }
    }
}

internal struct SessionState: Codable, Equatable {
    public var token: Data
    public var expiresAt: Int64?
    
    public init(token: Data, expiresAt: Int64? = nil) {
        self.token = token
        self.expiresAt = expiresAt
    }
}
