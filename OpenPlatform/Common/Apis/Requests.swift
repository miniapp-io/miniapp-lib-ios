//
//  MiniAppRequests.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/8.
//

import Foundation

public struct InlineButtonCallbackParams: Codable {
    public let chatId: String
    public let botId: String
    public let messageId: String
    public let callbackData: String
    
    init(chatId: String, botId: String, messageId: String, callbackData: String) {
        self.chatId = chatId
        self.botId = botId
        self.messageId = messageId
        self.callbackData = callbackData
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case botId = "bot_id"
        case messageId = "message_id"
        case callbackData = "callback_data"
    }
}

internal struct InlineButtonCallbackResp: Codable {
    let ok: Bool
    let errorCode: Int?
    let error: String?
    
    init(ok: Bool, errorCode: Int?, error: String?) {
        self.ok = ok
        self.errorCode = errorCode
        self.error = error
    }
    
    private enum CodingKeys: String, CodingKey {
        case ok
        case errorCode = "error_code"
        case error
    }
}

public struct BotInfo: Codable {
    
    public let id: String?
    public let name: String?
    public let token: String?
    public let userId: String?
    public let provider: String?
    public let identifier: String?
    public let bio: String?
    public let avatarUrl: String?
    public let commands: [Command]?
    public let createdAt: String?
    public let updatedAt: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case token
        case userId = "user_id"
        case provider
        case identifier
        case bio
        case avatarUrl = "avatar_url"
        case commands
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: String, name: String, token: String, userId: String, provider: String, identifier: String, bio: String, avatarUrl: String, commands: [Command], createdAt: String, updatedAt: String) {
        self.id = id
        self.name = name
        self.token = token
        self.userId = userId
        self.provider = provider
        self.identifier = identifier
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.commands = commands
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom Codable conformance to handle metadata
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        provider = try container.decodeIfPresent(String.self, forKey: .provider)
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        commands = try container.decodeIfPresent([Command].self, forKey: .commands)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(provider, forKey: .provider)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encodeIfPresent(commands, forKey: .commands)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

public struct Command: Codable {
    public let command: String?
    public let type: String?
    public let description: String?
    public let options: [Option]?
    public let scope: Scope?
    public let languageCode: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case type
        case description
        case options
        case scope
        case languageCode = "language_code"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decodeIfPresent(String.self, forKey: .command)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        options = try container.decodeIfPresent([Option].self, forKey: .options)
        scope = try container.decodeIfPresent(Scope.self, forKey: .scope)
        languageCode = try container.decodeIfPresent(String.self, forKey: .languageCode)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(command, forKey: .command)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(scope, forKey: .scope)
        try container.encodeIfPresent(languageCode, forKey: .languageCode)
    }
}

public struct Option: Codable {
    public let name: String?
    public let type: String?
    public let required: Bool?
    public let description: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case required
        case description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        required = try container.decodeIfPresent(Bool.self, forKey: .required)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(required, forKey: .required)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

public struct Scope: Codable {
    public let type: String?
    public let chatId: String?
    public let userId: String?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
        case userId = "user_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        chatId = try container.decodeIfPresent(String.self, forKey: .chatId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(chatId, forKey: .chatId)
        try container.encodeIfPresent(userId, forKey: .userId)
    }
    
}

internal struct VerifierParams: Codable {
    let verifier: String
    let options: [String: String]
    
    init(verifier: String, options: [String : String]) {
        self.verifier = verifier
        self.options = options
    }
}

internal struct VerifierAppDto: Codable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

internal struct LaunchParams: Codable {
    let appId: String
    let url: String?
    let languageCode: String?
    let startParams: String?
    let themeParams: [String: String]?
    let peer: PeerParams?
    let platform: String
    let tgWebAppVersion: String = "8.0"
    
    init(url: String?, appId: String, languageCode: String, startParams: String?, themeParams: [String: String]?, peer:PeerParams?, platform: String) {
        self.url = url
        self.appId = appId
        self.languageCode = languageCode
        self.startParams = startParams
        self.themeParams = themeParams
        self.peer = peer
        self.platform = platform
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
        case appId = "app_id"
        case languageCode = "language_code"
        case startParams = "start_params"
        case themeParams = "theme_params"
        case peer
        case platform
        case tgWebAppVersion = "tg_webapp_version"
    }
}

internal struct ThemeParams: Codable {
    let data: [String: String]
    
    init(data: [String : String]) {
        self.data = data
    }
}

public struct PeerParams: Codable {

    public let userId: String?
    public let roomId: String?
    public let accessHash: String?

    public init(userId: String?, roomId: String?, accessHash: String?) {
        self.userId = userId
        self.roomId = roomId
        self.accessHash = accessHash
    }

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case roomId = "room_id"
        case accessHash = "access_hash"
    }
}

internal struct OpenServiceError: Codable {
    let code: Int
    let error: String?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case error
    }
}

internal struct LaunchMiniAppDto: Codable {
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case url
    }
}

internal struct LaunchDAppDto: Codable {
    let redirectUrl: String
    let isRisk: Bool
    
    private enum CodingKeys: String, CodingKey {
        case redirectUrl = "redirect_url"
        case isRisk = "is_risk"
    }
}

public struct DAppDto: Codable {
    public let id: String
    public let title: String?
    public let url: String?
    public let description: String?
    public let shortDescription: String?
    public let iconUrl: String?
    public let bannerUrl: String?
    public let createAt: Int?
    public let updateAt: Int?
    public let isShareEnable: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case description
        case shortDescription = "short_description"
        case iconUrl = "icon_url"
        case bannerUrl = "banner_url"
        case createAt = "create_at"
        case updateAt = "update_at"
        case isShareEnable = "is_share_enabled"
    }
}

public struct AppSettings: Codable {
    
    /**
     * Page style, defaults to default
     * default: Default full-screen mode
     * modal: Modal popup mode
     */
    let viewStyle: String?
    
    /**
     * Toolbar style (title, back button, background color), defaults to default
     * default: Default system toolbar, displays title, back button, with background color
     * custom: Web-side custom toolbar, hides toolbar, i.e., does not display title, back button, background
     */
    let navigationStyle: String?
    
    /**
     * Horizontal gesture switch, defaults to true
     * true: Allow horizontal gestures
     * false: Block horizontal gestures
     */
    let allowHorizontalSwipe: Bool?
    
    /**
     * Vertical gesture switch, defaults to true
     * true: Allow vertical gestures
     * false: Block vertical gestures
     * Web SDK supports controlling vertical gestures, priority is given to Web settings
     */
    let allowVerticalSwipe: Bool?
    
    
    private enum CodingKeys: String, CodingKey {
        case viewStyle = "view_style"
        case navigationStyle = "navigation_style"
        case allowHorizontalSwipe = "allow_horizontal_swipe"
        case allowVerticalSwipe = "allow_vertical_swipe"
    }
}


public struct MiniAppDto: Codable {
    public let id: String
    public let identifier: String?
    public let title: String?
    public let description: String?
    public let shortDescription: String?
    public let iconUrl: String?
    public let bannerUrl: String?
    public let botId: String?
    public let botName: String?
    public let createAt: Int?
    public let updateAt: Int?
    public let options: AppSettings?
    public let isShareEnable: Bool?

    private enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case title
        case description
        case shortDescription = "short_description"
        case iconUrl = "icon_url"
        case bannerUrl = "banner_url"
        case botId = "bot_id"
        case botName = "bot_identifier"
        case createAt = "create_at"
        case updateAt = "update_at"
        case options
        case isShareEnable = "is_share_enabled"
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}


struct AnyCodable: Codable {
    var value: Any
    init<T>(_ value: T?) { self.value = value as Any }

    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            value = int
        } else if let double = try? decoder.singleValueContainer().decode(Double.self) {
            value = double
        } else if let string = try? decoder.singleValueContainer().decode(String.self) {
            value = string
        } else if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            value = bool
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}



public struct MiniAppResponse: Codable {
    public let items: [MiniAppDto]?
    
    private enum CodingKeys: String, CodingKey {
        case items
    }
}


struct AICompleteParams: Codable {
    
    let promptId: Int
    let args: [String: String]
    
    init(promptId: Int, args: [String : String]) {
        self.promptId = promptId
        self.args = args
    }
    
    private enum CodingKeys: String, CodingKey {
        case promptId = "prompt_id"
        case args
    }
}

struct CustomMethodParams: Codable {
    
    let appId: String
    let method: String
    let params: String?
    
    init(appId: String, method: String, params: String?) {
        self.appId = appId
        self.method = method
        self.params = params
    }
    
    private enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case method
        case params
    }
}

struct CustomMethodResp: Codable {
    
    let result: String
    
    init(result: String) {
        self.result = result
    }
    
    private enum CodingKeys: String, CodingKey {
        case result
    }
}
