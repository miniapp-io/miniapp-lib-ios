//
//  BotService.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/25.
//

import Foundation

public protocol BotService {
    
    func load() -> Bool
    
    func unload() -> Void
    
    func getBotInfo(botId: String) async ->  Result<BotInfo,ApiError>
    
    func inlineButtonCallback(_ params: InlineButtonCallbackParams) async ->  Result<Bool,ApiError>
}

internal class BotServiceImpl : BotService {
    
    
    static let shared = BotServiceImpl()

    private init() {
    }

    func load() -> Bool {
        return true
    }
    
    func unload() -> Void {
        
    }
    
    public func getBotInfo(botId: String) async -> Result<BotInfo,ApiError> {
        return await OpenServiceRepository.shared.getBotInfo(idOrName: botId)
    }
    
    public func inlineButtonCallback(_ params: InlineButtonCallbackParams) async -> Result<Bool, ApiError> {
        let result = await OpenServiceRepository.shared.inlineButtonCallback(params: params)
        switch(result) {
        case .success(let resp):
            if resp.ok {
                return Result.success(true)
            } else {
                return Result.failure(ApiError.requestFailed(statusCode: resp.errorCode ?? 400, message: resp.error))
            }
        case .failure(let error):
            return Result.failure(error)
        }
    }
}
