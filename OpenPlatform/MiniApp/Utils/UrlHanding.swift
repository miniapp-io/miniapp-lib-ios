//
//  UrlHanding.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/6/18.
//

import Foundation
import UIKit

internal struct ResolvedBotChoosePeerTypes: OptionSet {
    public var rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.rawValue = 0
    }
    
    public static let users = ResolvedBotChoosePeerTypes(rawValue: 1)
    public static let bots = ResolvedBotChoosePeerTypes(rawValue: 2)
    public static let groups = ResolvedBotChoosePeerTypes(rawValue: 4)
    public static let channels = ResolvedBotChoosePeerTypes(rawValue: 16)
}

internal enum ResolvedUrl {
    case externalUrl(String)
    case urlAuth(String)
    case inaccessiblePeer
    case botStart(peerId: String, payload: String)
    case gameStart(peerIdId: String, game: String)
    case proxy(host: String, port: Int32, username: String?, password: String?, secret: Data?)
    case join(String)
    case localization(String)
    case confirmationCode(Int)
    case cancelAccountReset(phone: String, hash: String)
    case share(url: String?, text: String?, to: String?)
    case theme(String)
    case importStickers
    case startAttach(peerId: String, payload: String?, choose: ResolvedBotChoosePeerTypes?)
    case premiumOffer(reference: String?)
    case chatFolder(slug: String)
    case premiumGiftCode(slug: String)
    case premiumMultiGift(reference: String?)
}

internal enum ResolveUrlResult {
    case progress
    case result(ResolvedUrl)
}

internal enum ParsedInternalPeerUrlParameter {
    case botStart(String)
    case attachBotStart(String, String?)
    case gameStart(String)
    case channelMessage(Int32, Double?)
    case replyThread(Int32, Int32)
    case voiceChat(String?)
    case appStart(String, String?,[String:String]?)
    case story(Int32)
    case boost
    case text(String)
}

internal enum ParsedInternalUrl {
    internal enum UrlPeerReference {
        case name(String)
    }
    
    case peer(UrlPeerReference, ParsedInternalPeerUrlParameter?)
    case app(String,String?,[String:String]?)
    case dapp(String,String?)
    case invoice(String)
    case join(String)
    case localization(String)
    case proxy(host: String, port: Int32, username: String?, password: String?, secret: Data?)
    case internalInstantView(url: String)
    case confirmationCode(Int)
    case cancelAccountReset(phone: String, hash: String)
    case share(url: String?, text: String?, to: String?)
    case theme(String)
    case phone(String, String?, String?, String?)
    case startAttach(String, String?, String?)
    case contactToken(String)
    case chatFolder(slug: String)
    case premiumGiftCode(slug: String)
    case externalUrl(url: String)
}

private enum ParsedUrl {
    case externalUrl(String)
    case internalUrl(ParsedInternalUrl)
}

internal func parseInternalUrl(query: String, basePrefix: String) -> ParsedInternalUrl? {
    var query = query
    if query.hasPrefix("s/") {
        query = String(query[query.index(query.startIndex, offsetBy: 2)...])
    }
    if query.hasSuffix("/") {
        query.removeLast()
    }
    if let components = URLComponents(string: "/" + query) {
        var pathComponents = components.path.components(separatedBy: "/")
        if !pathComponents.isEmpty {
            pathComponents.removeFirst()
        }
        if let lastComponent = pathComponents.last, lastComponent.isEmpty {
            pathComponents.removeLast()
        }
        if !pathComponents.isEmpty && !pathComponents[0].isEmpty {
            let peerName: String = pathComponents[0]
            if pathComponents[0].hasPrefix("+") || pathComponents[0].hasPrefix("%20") {
                let component = pathComponents[0].replacingOccurrences(of: "%20", with: "+")
                if component.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789+").inverted) == nil {
                    var attach: String?
                    var startAttach: String?
                    var text: String?
                    if let queryItems = components.queryItems {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "attach" {
                                    attach = value
                                } else if queryItem.name == "startattach" {
                                    startAttach = value
                                } else if queryItem.name == "text" {
                                    text = value
                                }
                            }
                        }
                    }
                    
                    return .phone(component.replacingOccurrences(of: "+", with: ""), attach, startAttach, text)
                } else {
                    return .join(String(component.dropFirst()))
                }
            }
            
            if pathComponents.count == 1 {
                if let queryItems = components.queryItems {
                    if peerName == "socks" || peerName == "proxy" {
                        var server: String?
                        var port: String?
                        var user: String?
                        var pass: String?
                        var secret: Data?
                        if let queryItems = components.queryItems {
                            for queryItem in queryItems {
                                if let value = queryItem.value {
                                    if queryItem.name == "server" || queryItem.name == "proxy" {
                                        server = value
                                    } else if queryItem.name == "port" {
                                        port = value
                                    } else if queryItem.name == "user" {
                                        user = value
                                    } else if queryItem.name == "pass" {
                                        pass = value
                                    }
                                }
                            }
                        }
                        
                        if let server = server, !server.isEmpty, let port = port, let portValue = Int32(port) {
                            return .proxy(host: server, port: portValue, username: user, password: pass, secret: secret)
                        }
                    } else if peerName == "iv" {
                        var url: String?
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "url" {
                                    url = value
                                }
                            }
                        }
                        if let _ = url {
                            return .internalInstantView(url: "\(basePrefix)\(query)")
                        }
                    } else if peerName == "contact" {
                        var code: String?
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "code" {
                                    code = value
                                }
                            }
                        }
                        if let code = code, let codeValue = Int(code) {
                            return .confirmationCode(codeValue)
                        }
                    } else if peerName == "confirmphone" {
                        var phone: String?
                        var hash: String?
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "phone" {
                                    phone = value
                                } else if queryItem.name == "hash" {
                                    hash = value
                                }
                            }
                        }
                        if let phone = phone, let hash = hash {
                            return .cancelAccountReset(phone: phone, hash: hash)
                        }
                    } else if peerName == "msg" {
                        var url: String?
                        var text: String?
                        var to: String?
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "url" {
                                    url = value
                                } else if queryItem.name == "text" {
                                    text = value
                                } else if queryItem.name == "to" {
                                    to = value
                                }
                            }
                        }
                        return .share(url: url, text: text, to: to)
                    } else if peerName == "boost" {
        
                    } else {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "text" {
                                    return .peer(.name(peerName), .text(value))
                                } else if queryItem.name == "attach" {
                                    var startAttach: String?
                                    for queryItem in queryItems {
                                        if queryItem.name == "startattach", let value = queryItem.value {
                                            startAttach = value
                                            break
                                        }
                                    }
                                    return .peer(.name(peerName), .attachBotStart(value, startAttach))
                                } else if queryItem.name == "start" {
                                    return .peer(.name(peerName), .botStart(value))
                                } else if queryItem.name == "game" {
                                    return .peer(.name(peerName), .gameStart(value))
                                } else if ["voicechat", "videochat", "livestream"].contains(queryItem.name) {
                                    return .peer(.name(peerName), .voiceChat(value))
                                } else if queryItem.name == "startattach" {
                                    var choose: String?
                                    for queryItem in queryItems {
                                        if queryItem.name == "choose", let value = queryItem.value {
                                            choose = value
                                            break
                                        }
                                    }
                                    return .startAttach(peerName, value, choose)
                                } else if queryItem.name == "story" {
                                    if let id = Int32(value) {
                                        return .peer(.name(peerName), .story(id))
                                    }
                                }
                            } else if ["voicechat", "videochat", "livestream"].contains(queryItem.name)  {
                                return .peer(.name(peerName), .voiceChat(nil))
                            } else if queryItem.name == "startattach" {
                                var choose: String?
                                for queryItem in queryItems {
                                    if queryItem.name == "choose", let value = queryItem.value {
                                        choose = value
                                        break
                                    }
                                }
                                return .startAttach(peerName, nil, choose)
                            } else if queryItem.name == "boost" {
                                return .peer(.name(peerName), .boost)
                            }
                        }
                    }
                }  else if pathComponents[0].hasPrefix("$") || pathComponents[0].hasPrefix("%24") {
                    var component = pathComponents[0].replacingOccurrences(of: "%24", with: "$")
                    if component.hasPrefix("$") {
                        component = String(component[component.index(after: component.startIndex)...])
                    }
                    return .invoice(component)
                }
                return .peer(.name(peerName), nil)
            } else if (pathComponents.count >= 2 && pathComponents.count <= 4) {
                if pathComponents[0] == "apps" && pathComponents.count == 2  {
                    var startApp: String?
                    var params: [String:String]?
                    if let queryItems = components.queryItems {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "startapp" {
                                    startApp = value
                                }
                            }
                        }
                        params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
                            if let value = item.value, item.name != "startapp" {
                                return (item.name, value)
                            } else {
                                return nil
                            }
                        })
                    }
                    return .app(pathComponents[1], startApp, params)
                }
                else if pathComponents[0] == "dapp" && pathComponents.count == 2  {
                    var startApp: String?
                    if let queryItems = components.queryItems {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "startapp" {
                                    startApp = value
                                }
                            }
                        }
                    }
                    return .dapp(pathComponents[1], startApp)
                }
                else if pathComponents[0] == "invoice" {
                    return .invoice(pathComponents[1])
                } else if pathComponents[0] == "joinchat" || pathComponents[0] == "joinchannel" {
                    return .join(pathComponents[1])
                } else if pathComponents[0] == "setlanguage" {
                    return .localization(pathComponents[1])
                } else if pathComponents[0] == "login" {
                    if let code = Int(pathComponents[1]) {
                        return .confirmationCode(code)
                    }
                } else if peerName == "contact" {
                    return .contactToken(pathComponents[1])
                } else if pathComponents[0] == "share" && pathComponents[1] == "url" {
                    if let queryItems = components.queryItems {
                        var url: String?
                        var text: String?
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "url" {
                                    url = value
                                } else if queryItem.name == "text" {
                                    text = value
                                }
                            }
                        }
                        
                        if let url = url {
                            return .share(url: url, text: text, to: nil)
                        }
                    }
                    return nil
                } else if pathComponents[0] == "addtheme" {
                    return .theme(pathComponents[1])
                } else if pathComponents[0] == "addlist" || pathComponents[0] == "folder" || pathComponents[0] == "list" {
                    return .chatFolder(slug: pathComponents[1])
                } else if pathComponents[0] == "boost", pathComponents.count == 2 {
                    return .peer(.name(pathComponents[1]), .boost)
                } else if pathComponents[0] == "giftcode", pathComponents.count == 2 {
                    return .premiumGiftCode(slug: pathComponents[1])
                } else if pathComponents.count >= 3 && pathComponents[1] == "s" {
                    if let storyId = Int32(pathComponents[2]) {
                        return .peer(.name(pathComponents[0]), .story(storyId))
                    } else {
                        return nil
                    }
                } else if let value = Int32(pathComponents[1]) {
                    var threadId: Int32?
                    var commentId: Int32?
                    var timecode: Double?
                    if let queryItems = components.queryItems {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "thread" || queryItem.name == "topic" {
                                    if let intValue = Int32(value) {
                                        threadId = intValue
                                    }
                                } else if queryItem.name == "comment" {
                                    if let intValue = Int32(value) {
                                        commentId = intValue
                                    }
                                } else if queryItem.name == "t" {
                                    if let doubleValue = Double(value) {
                                        timecode = doubleValue
                                    }
                                }
                            }
                        }
                    }
                    
                    if pathComponents.count >= 3, let subMessageId = Int32(pathComponents[2]) {
                        return .peer(.name(peerName), .replyThread(value, subMessageId))
                    } else if let threadId = threadId {
                        return .peer(.name(peerName), .replyThread(threadId, value))
                    } else if let commentId = commentId {
                        return .peer(.name(peerName), .replyThread(value, commentId))
                    } else {
                        return .peer(.name(peerName), .channelMessage(value, timecode))
                    }
                } else if pathComponents.count == 2 {
                    let appName = pathComponents[1]
                    var startApp: String?
                    var params: [String:String]?
                    if let queryItems = components.queryItems {
                        for queryItem in queryItems {
                            if let value = queryItem.value {
                                if queryItem.name == "startapp" {
                                    startApp = value
                                }
                            }
                        }
                        params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
                            if let value = item.value, item.name != "startapp" {
                                return (item.name, value)
                            } else {
                                return nil
                            }
                        })
                    }
                    return .peer(.name(peerName), .appStart(appName, startApp, params))
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }
    return nil
}

private enum ResolveInternalUrlResult {
    case progress
    case result(ResolvedUrl?)
}

internal func isLocalFile(_ url: String) -> Bool {
    return url.lowercased().starts(with: "file")
}

internal func isBlank(_ url: String) -> Bool {
    return url.lowercased().starts(with: "about")
}

internal func isHttpScheme(_ url: String) -> Bool {
    return url.lowercased().starts(with: "http")
}

internal func isBlobScheme(_ url: String) -> Bool {
    return url.lowercased().starts(with: "blob")
}

internal func isNormalScheme(_ url: String) -> Bool {
    return isHttpScheme(url) || isBlobScheme(url)
}

internal func isMeLink(_ url: String, baseMePaths: [String]) -> Bool {
    if !isHttpScheme(url) {
        return false
    }
    let schemes = ["http://", "https://", ""]
    for basePath in baseMePaths {
        for scheme in schemes {
            let basePrefix = scheme + basePath + "/"
            if url.lowercased().hasPrefix(basePrefix) {
                return true
            }
        }
    }
    return false
}


internal func resolveUrlImpl(url: String, basePaths:[String]) -> ParsedInternalUrl? {
    let schemes = ["http://", "https://", ""]
    
    var url = url
    if !url.contains("://") && !url.hasPrefix("tel:") && !url.hasPrefix("mailto:") && !url.hasPrefix("calshow:") {
        if !(url.hasPrefix("http") || url.hasPrefix("https")) {
            url = "http://\(url)"
        }
    }
    
    for basePath in basePaths {
        for scheme in schemes {
            let basePrefix = scheme + basePath + "/"
            var url = url
            let lowercasedUrl = url.lowercased()
            if (lowercasedUrl.hasPrefix(scheme) && (lowercasedUrl.hasSuffix(".\(basePath)") || lowercasedUrl.contains(".\(basePath)/") || lowercasedUrl.contains(".\(basePath)?"))) {
                url = basePrefix + String(url[scheme.endIndex...]).replacingOccurrences(of: ".\(basePath)/", with: "").replacingOccurrences(of: ".\(basePath)", with: "")
            }
            if url.lowercased().hasPrefix(basePrefix) {
                if let internalUrl = parseInternalUrl(query: String(url[basePrefix.endIndex...]), basePrefix: basePrefix) {
                    return internalUrl
                }
            }
        }
    }
    
    return .externalUrl(url: url)
}
