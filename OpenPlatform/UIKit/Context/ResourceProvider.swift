//
//  ResourceProvider.swift
//  MiniAppX
//
//  Created by w3bili on 2025/1/4.
//

import UIKit

public protocol IResourceProvider {
    func isDark() -> Bool
    
    func getString(key: String) -> String?
    
    func getString(key: String, withValues values: [CVarArg]) -> String
    
    func getColor(key: String) -> UIColor
    
    func getUserInterfaceStyle() -> UIUserInterfaceStyle
}
