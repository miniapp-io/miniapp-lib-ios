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
    
    final let sessionKey = "$#_session"
    
    private var _token: SessionState? {
        didSet {
            save()
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
    
    var refreshToken: (() async -> SessionState?)? = nil
    
    private init() {
        load()
    }
    
    func isAuth() -> Bool {
        return _token?.token != nil
    }
    
    private func load() {
        queue.sync {
            _token = loadCodableData(forKey: sessionKey)
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
    
    public init(token: Data) {
        self.token = token
    }
}
