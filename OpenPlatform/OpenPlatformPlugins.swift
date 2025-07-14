//
//  OpenPlatformPlugins.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/6.
//

import Foundation

public enum PluginName: String {
    case openPlatform = "PLUGIN_OPEN_PLATFORM"
}

public class PluginsManager {
    
    private static let instance = PluginsManager()
    
    public static func getInstance() -> PluginsManager {
        return instance
    }
    
    private init() {
        registerPlugin(OpenPlatformPluginImpl.getInstance())
    }
    
    private var plugins: [String: Plugin] = [:]
    
    public func registerPlugin(_ plugin: Plugin) {
        plugins[plugin.getName()] = plugin
    }
    
    public func unregisterPlugin(_ pluginName: String) {
        plugins.removeValue(forKey: pluginName)
    }
    
    public func getPlugin<T: Plugin>(_ pluginName: String) -> T? {
        return plugins[pluginName] as? T
    }
    
    public func auth(verifier: String, idTokenProvider: (String) -> Void) {
        
    }
}

public protocol Plugin {
    func load() -> Bool
    func unLoad() -> Void
    func getName() -> String
}
