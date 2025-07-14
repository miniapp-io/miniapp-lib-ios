//
//  WebAppLruCache.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/7/5.
//

import Foundation

internal class WebAppLruCache {
    private static let DEFAULT_MAX_SIZE = 5
    
    private static let  webViewCache = LRUCache<String, BaseWebView>()
    
    static func resize(size: Int) {
        if webViewCache.countLimit != size {
            webViewCache.countLimit = size
        }
    }
    
    static func get(key: String) -> BaseWebView? {
        return webViewCache.value(forKey: key)
    }
    
    static func put(key: String, webView: BaseWebView) {
        webViewCache.setValue(webView, forKey: key)
        
        print("LRU put obj, key = \(key), cur size = \(webViewCache.count)")
    }
    
    static func remove(key: String) -> BaseWebView? {
        if let item = get(key: key) {
            webViewCache.removeValue(forKey: key)
            return item
        }
       return nil
    }
    
    static func removeAll() {
        webViewCache.removeAllValues()
    }
}
