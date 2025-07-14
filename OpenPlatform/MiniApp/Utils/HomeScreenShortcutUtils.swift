//
//  HomeScreenShortcutUtils.swift
//  MiniAppX
//
//  Created by w3bili on 2024/11/21.
//

import UIKit
import Foundation


internal enum ApplicationShortcutItemType: String {
    case appIcon
}

internal struct ApplicationShortcutItem: Equatable {
    let type: ApplicationShortcutItemType
    let title: String
    let subtitle: String?
    let userInfo: [String : String]?
}

@available(iOS 9.1, *)
internal extension ApplicationShortcutItem {
    func shortcutItem() -> UIApplicationShortcutItem {
        let icon: UIApplicationShortcutIcon
        switch self.type {
            case .appIcon:
                icon = UIApplicationShortcutIcon(type: .favorite)
        }
        
        var secureCodingDict: [String: NSSecureCoding] = [:]
            
        if let userModel = self.userInfo {
            for (key, value) in userModel {
                secureCodingDict[key] = value as NSString
            }
        }
        
        return UIApplicationShortcutItem(type: self.type.rawValue, localizedTitle: self.title, localizedSubtitle: self.subtitle, icon: icon, userInfo: secureCodingDict)
    }
}

internal class HomeScreenShortcutUtils {

    static let SHORTCUT_ID = "miniappx_id"
    static let SHORTCUT_LINK = "miniappx_link"
    static let SHORTCUT_TYPE = "miniappx_type"

    static let SHORTCUT_MINIAPP = "MINIAPP"
    static let SHORTCUT_DAPP = "WEBPAGE"
    
    @available(iOS 13.0, *)
    private static func addDynamicShortcut(id: String, link: String, type: String, label: String) {
        
        let shortcutItem = ApplicationShortcutItem(type: .appIcon,
                                                   title: label,
                                                   subtitle: nil,
                                                   userInfo: [SHORTCUT_ID: id,
                                                            SHORTCUT_LINK: link,
                                                            SHORTCUT_TYPE: type])
        
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        shortcutItems.append(shortcutItem.shortcutItem())
        
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
    @available(iOS 13.0, *)
    static func isShortcutAdded(id: String, type: String) -> Bool {
        return UIApplication.shared.shortcutItems?.contains(where: { shortcut in
            guard let userInfo = shortcut.userInfo as? [String: String] else { return false }
            return (userInfo[SHORTCUT_ID] == id && userInfo[SHORTCUT_TYPE] == type)
        }) ?? false
    }
    
    static func createShortcutLink(id: String, link: String, type: String, label: String) {
        if #available(iOS 13.0, *) {
            addDynamicShortcut(id: id, link: link, type: type, label: label)
        }
    }
}

