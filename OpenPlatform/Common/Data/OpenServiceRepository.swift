//
//  OpenServiceDatasource.swift
//  MiniAppKit
//
//  Created by w3bili on 2024/6/4.
//

import Foundation


protocol OpenServiceDatasource {
    
    func auth(verifier: String, idToken: String) async -> Result<VerifierAppDto, ApiError>
    
    func getLaunchInfo(params: LaunchParams) async -> Result<LaunchMiniAppDto, ApiError>
    
    func get110LaunchInfo(url: String, id: String?) async -> Result<LaunchDAppDto, ApiError>
    
    func getMiniAppInfo(id: String) async -> Result<MiniAppDto, ApiError>
    
    func getMiniAppInfo(botIdOrName: String, appName: String) async -> Result<MiniAppDto, ApiError>
    
    func getDAppInfo(id: String) async -> Result<DAppDto, ApiError>
    
    func batchGetMiniApp(appIds: [String]) async -> Result<MiniAppResponse, ApiError>
    
    func getBotInfo(idOrName: String) async -> Result<BotInfo, ApiError>
    
    func inlineButtonCallback(params: InlineButtonCallbackParams) async -> Result<InlineButtonCallbackResp, ApiError>
    
    func invokeCustomMethods(params: CustomMethodParams) async -> Result<CustomMethodResp, ApiError>
    
    func getAICompleteData(params: AICompleteParams) async -> Result<LaunchMiniAppDto, ApiError>
    
}

internal class OpenServiceRepository : OpenServiceDatasource {
    
    static let shared: OpenServiceDatasource  = OpenServiceRepository()
    
    let PATH_AUTH = "/api/v1/users/auth"
    let PATH_COMPLETE =  "/api/v1/ai/complete"
    
    let PATH_BOT =  "/api/v1/bots"
    let PATH_BOT_INLINE_BUTTON_CALLBACK =  "/api/v1/callback/query"
    
    let PATH_MINIAPP = "/api/v1/miniapps"
    let PATH_DAPP = "/api/v1/dapps"
    
    let PATH_MENU = "/api/v1/menus"
    
    let PATH_CUSTOM_METHOD =  "/api/v1/custom_methods/invoke"
    let PATH_WEBPAGE_110 = "/api/v1/webpage/open"
    
    private init() {}
    
    let queue = DispatchQueue(label: "io.miniapp.networkQueue")
    
    private func getBaseHost() -> String {
        return OpenPlatformPluginImpl.getInstance().apiHost!
    }
    
    func auth(verifier: String, idToken: String) async -> Result<VerifierAppDto, ApiError> {
        let path = PATH_AUTH
        
        return await sendPostRequest(path: path, params: VerifierParams(verifier: verifier, options: ["id_token" : idToken]), withToken: false)
    }
    
    func getLaunchInfo(params: LaunchParams) async -> Result<LaunchMiniAppDto, ApiError> {
        let path = "\(PATH_MINIAPP)/launch"
        
        return await sendPostRequest(path: path, params: params)
    }
    
    func get110LaunchInfo(url: String, id: String?) async -> Result<LaunchDAppDto, ApiError> {
        let path = PATH_WEBPAGE_110
        
        var params = ["targetUrl": url]
        if let id = id {
            params["targetId"] = id
        }
        
        return await sendGetRequest(path: path, params: params)
    }
    
    func getMiniAppInfo(id: String) async -> Result<MiniAppDto, ApiError> {
        let cacheKey = "miniapp_\(id)"
        
        if let cachedData = LRUSharedPreferencesCache.shared.getValue(forKey: cacheKey) {
           
            do {
                let cachedMiniApp = try JSONDecoder().decode(MiniAppDto.self, from: Data(cachedData.utf8))
                
                Task {
                    let result = await updateMiniAppCache(id: id)
                    if case .failure(let error) = result {
                        switch(error) {
                        case .requestFailed(let code, let message):
                            if code == 460 {
                                LRUSharedPreferencesCache.shared.saveValue("", forKey: cacheKey)
                            }
                        default:
                            break
                        }
                    }
                }
                
                return .success(cachedMiniApp)
            } catch {
                return await updateMiniAppCache(id: id)
            }
        }
        
        return await updateMiniAppCache(id: id)
    }
    
    func getDAppInfo(id: String) async -> Result<DAppDto, ApiError> {
        let cacheKey = "dapp_\(id)"
        
        if let cachedData = LRUSharedPreferencesCache.shared.getValue(forKey: cacheKey) {
            
            do {
                let cachedDApp = try JSONDecoder().decode(DAppDto.self, from: Data(cachedData.utf8))
                
                Task {
                    let result = await updateDAppCache(id: id)
                    if case .failure(let error) = result {
                        switch(error) {
                        case .requestFailed(let code, let message):
                            if code == 460 {
                                LRUSharedPreferencesCache.shared.saveValue("", forKey: cacheKey)
                            }
                        default:
                            break
                        }
                    }
                }
                
                return .success(cachedDApp)
                
            } catch {
                return await updateDAppCache(id: id)
            }
        }
        
        return await updateDAppCache(id: id)
    }
    
    private func updateDAppCache(id: String) async -> Result<DAppDto, ApiError> {
        let path = "\(PATH_DAPP)/\(id)"
        
        let result: Result<DAppDto, ApiError> = await sendGetRequest(path: path, params: nil)
        
        if case .success(let aApp) = result {
            if let encodedData = try? JSONEncoder().encode(aApp),
               let jsonString = String(data: encodedData, encoding: .utf8) {
                LRUSharedPreferencesCache.shared.saveValue(jsonString, forKey: "dapp_\(id)")
            }
        }
        
        return result
    }

    private func updateMiniAppCache(id: String) async -> Result<MiniAppDto, ApiError> {
        let path = "\(PATH_MINIAPP)/\(id)"
        
        let result: Result<MiniAppDto, ApiError> = await sendGetRequest(path: path, params: nil)
        
        if case .success(let miniApp) = result {
            if let encodedData = try? JSONEncoder().encode(miniApp),
               let jsonString = String(data: encodedData, encoding: .utf8) {
                LRUSharedPreferencesCache.shared.saveValue(id, forKey: "\(miniApp.botName)_\(miniApp.identifier)")
                LRUSharedPreferencesCache.shared.saveValue(jsonString, forKey: "miniapp_\(id)")
            }
        }
        
        return result
    }

    func getMiniAppInfo(botIdOrName: String, appName: String) async -> Result<MiniAppDto, ApiError> {
        let cacheKey = "\(botIdOrName)_\(appName)"
        
        if let cachedData = LRUSharedPreferencesCache.shared.getValue(forKey: cacheKey) {
            return await getMiniAppInfo(id: cachedData)
        }
        
        let path = "\(PATH_BOT)/\(botIdOrName)/miniapps/by-identifier/\(appName)"
        
        let result: Result<MiniAppDto, ApiError> = await sendGetRequest(path: path, params: nil)
        
        if case .success(let miniApp) = result {
            if let encodedData = try? JSONEncoder().encode(miniApp),
               let jsonString = String(data: encodedData, encoding: .utf8) {
                LRUSharedPreferencesCache.shared.saveValue(miniApp.id ?? "none", forKey: cacheKey)
                LRUSharedPreferencesCache.shared.saveValue(jsonString, forKey: "miniapp_\(miniApp.id)")
            }
        }
        
        return result
    }
    
    func batchGetMiniApp(appIds: [String]) async -> Result<MiniAppResponse, ApiError> {
        let path = "\(PATH_MINIAPP)/batch-get"
        
        let queryItems = appIds.map { URLQueryItem(name: "id", value: $0) }
        
        let result: Result<MiniAppResponse, ApiError> = await sendGetRequest(path: path, params: nil, queryItems: queryItems)
        if case .success(let miniAppResponse) = result {
            for miniApp in miniAppResponse.items ?? [] {
                if let encodedData = try? JSONEncoder().encode(miniApp),
                    let jsonString = String(data: encodedData, encoding: .utf8) {
                    LRUSharedPreferencesCache.shared.saveValue(miniApp.id, forKey: "\(miniApp.botName)_\(miniApp.identifier)")
                    LRUSharedPreferencesCache.shared.saveValue(jsonString, forKey: "miniapp_\(miniApp.id)")
                }
            }
        }
        
        return result
    }
    
    func getBotInfo(idOrName: String) async -> Result<BotInfo, ApiError> {
        let path = "\(PATH_BOT)/\(idOrName)"
        
        return await sendGetRequest(path: path, params: nil)
    }
    
    func inlineButtonCallback(params: InlineButtonCallbackParams) async -> Result<InlineButtonCallbackResp, ApiError> {
        let path = PATH_BOT_INLINE_BUTTON_CALLBACK
        
        return await sendPostRequest(path: path, params: params)
    }
    
    func invokeCustomMethods(params: CustomMethodParams) async -> Result<CustomMethodResp, ApiError> {
        let path = PATH_CUSTOM_METHOD
        
        return await sendPostRequest(path: path, params: params)
    }
    
    func getAICompleteData(params: AICompleteParams) async -> Result<LaunchMiniAppDto, ApiError> {
        let path = PATH_COMPLETE
        
        return await sendPostRequest(path: path, params: params)
    }
    
    private func sendGetRequest<T: Decodable>(path: String, params: [String: Any]?, headers: [String: String]? = nil, queryItems: [URLQueryItem]? = nil, withToken: Bool = true) async -> Result<T, ApiError>  {
        let fullPath = "\(self.getBaseHost())\(path)"
        
        var urlComponents = URLComponents(string: fullPath)
        if let params = params {
            urlComponents?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            return .failure(ApiError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return await sendRequest(request: request, withToken: withToken)
    }
    
    private func sendPostRequest<T: Decodable>(path: String, params: Encodable?, headers: [String: String]? = nil, withToken: Bool = true) async -> Result<T, ApiError>  {
        let fullPath = "\(self.getBaseHost())\(path)"
        
        guard let url = URL(string: fullPath) else {
            return .failure(ApiError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let params = params {
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(params)
                request.httpBody = jsonData
            } catch {
                return .failure(ApiError.encodingFailed)
            }
        }
        
        return await sendRequest(request: request, withToken: withToken)
    }
    
    func sendRequest<T: Decodable>(request: URLRequest, withToken: Bool, retryCount: Int = 1) async -> Result<T, ApiError> {
        
        return await withCheckedContinuation { continuation in
            Task {
                do {
                    var modifiedRequest = request
                    
                    // Add Authorization Header
                    if withToken, let tokenData = SessionProvider.shared.token?.token, let token = String(data: tokenData, encoding: .utf8) {
                        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    }
                    
                #if DEBUG
                    // Print CURL command
                    var curlCommand = "curl -X \(modifiedRequest.httpMethod ?? "GET")"
                    if let headers = modifiedRequest.allHTTPHeaderFields {
                        for (key, value) in headers {
                            curlCommand += " -H '\(key): \(value)'"
                        }
                    }
                    if let body = modifiedRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                        curlCommand += " -d '\(bodyString)'"
                    }
                    if let url = modifiedRequest.url?.absoluteString {
                        curlCommand += " '\(url)'"
                    }
                    print("\(curlCommand)\n")
                #endif
                    
                    // Create custom URLSessionConfiguration
                    let configuration = URLSessionConfiguration.default
                        
                            // Set request timeout (in seconds)
        configuration.timeoutIntervalForRequest = 30  // Single request timeout
        configuration.timeoutIntervalForResource = 60  // Total resource timeout
                    
                    let session = URLSession(configuration: configuration)
                    
                    let (data, response) = try await session.data(for: modifiedRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.resume(returning: .failure(.invalidResponse))
                        return
                    }
                    
    #if DEBUG
                    // Print response
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response status code: \(httpResponse.statusCode)")
                        print("Response: \(responseString)")
                    }
    #endif
                    
                    // Check HTTP status code
                    if httpResponse.statusCode == 401 && withToken {
                        SessionProvider.shared.token = nil
                        if retryCount > 0, let refreshToken = SessionProvider.shared.refreshToken, let _ = try await refreshToken() {
                            return continuation.resume(returning: await sendRequest(request: request, withToken: withToken, retryCount: retryCount - 1))
                        }
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        continuation.resume(returning: .failure(.requestFailed(statusCode: httpResponse.statusCode, message: httpResponse.description)))
                        return
                    }
                    
                    // JSON decoding
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        continuation.resume(returning: .success(responseObject))
                    } catch {
                        do {
                            let openServiceError = try JSONDecoder().decode(OpenServiceError.self, from: data)
                            continuation.resume(returning: .failure(.requestFailed(statusCode: openServiceError.code, message: openServiceError.error)))
                        } catch {
                            continuation.resume(returning: .failure(.decodingFailed))
                        }
                    }
                } catch {
                    // Network error handling
                    continuation.resume(returning: .failure(.requestFailed(
                        statusCode: 404,
                        message: (request.url?.absoluteString ?? "Unknown URL") + " *** " + error.localizedDescription
                    )))
                }
            }
        }
    }

}
