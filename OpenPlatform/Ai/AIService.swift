//
//  AIPlugin.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/8.
//

import Foundation

public struct CompletionRequest {
    private let promptId: Int
    private let args: [String: String]
    
    private init(promptId: Int, args: [String: String]) {
        self.promptId = promptId
        self.args = args
    }
    
    public class Builder {
        private var promptId: Int = 0
        private var args: [String: String] = [:]
        
        public func promptId(_ promptId: Int) -> Builder {
            self.promptId = promptId
            return self
        }
        
        public func args(key: String, value: String) -> Builder {
            args[key] = value
            return self
        }
        
        public func build() -> CompletionRequest {
            return CompletionRequest(promptId: promptId, args: args)
        }
    }
}

public protocol AIService {
    
    func load() -> Bool
    
    func unLoad()
    
    func completion(_ req: CompletionRequest)
}

internal class AIServiceImpl : AIService {
    
    static let shared = AIServiceImpl()

    private init() {
    }
    
    public func load() -> Bool {
        return false
    }
    
    public  func unLoad() {
        
    }
    
    public  func completion(_ req: CompletionRequest) {
        
    }
}
