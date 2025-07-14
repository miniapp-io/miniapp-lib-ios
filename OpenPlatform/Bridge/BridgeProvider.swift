//
//  BridgeProvider.swift
//  MiniAppX
//
//  Created by w3bili on 2024/9/12.
//

import Foundation
import WebKit

public protocol BridgeProvider {
    
    func onWebViewCreated(_ webView: WKWebView, parentVC: UIViewController)
    
    func onWebViewDestroy(_ webView: WKWebView)
    
    func onWebPageLoaded(_ webView: WKWebView)
    
    func shouldOverrideUrlLoading(url: URL) -> Bool
    
    var navigationDelegate: () -> WKNavigationDelegate? {get set}
    
    var uIDelegate: () -> WKUIDelegate? {get set}
    
}

public protocol BridgeProviderFactory {
    
    func buildBridgeProvider(id: String?, type: String, url: String?) -> BridgeProvider?
    
}
