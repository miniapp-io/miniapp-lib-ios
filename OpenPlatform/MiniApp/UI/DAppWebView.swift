import Foundation
import UIKit
import WebKit

internal final class DAppWebView: BaseWebView {
    
    init() {
        
        let configuration = WKWebViewConfiguration()
        //configuration.setURLSchemeHandler(CustomURLSchemeHandler(), forURLScheme: "https")
        
        if let userAgentString = BaseWebView.userAgentString {
            configuration.applicationNameForUserAgent = userAgentString
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        if #available(iOS 16.4, *) {
            // iOS 18+/26 may regress requestFullscreen in WKWebView; prefer legacy video fullscreen path.
            preferences.isElementFullscreenEnabled = false
        }
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        
        let selectionScript = WKUserScript(source: selectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(selectionScript)

        let fullscreenCompatScript = WKUserScript(source: fullscreenCompatSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(fullscreenCompatScript)

        let iframeFullscreenCompatScript = WKUserScript(source: iframeFullscreenCompatSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(iframeFullscreenCompatScript)

        configuration.userContentController = contentController
        
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = .audio
        } else {
            configuration.mediaPlaybackRequiresUserAction = true
        }
        
        super.init(frame: CGRect(), configuration: configuration)
        
        self.expirationTimestamp = Date().addingTimeInterval(3600).timeIntervalSince1970 * 1000.0
        
        // self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3 Safari/605.1.15 OpenService/1.0"
        // Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148
        
        // Use WKWebView to evaluate JavaScript to get User-Agent
        if let _ = BaseWebView.userAgentString {} else {
            evaluateJavaScript("navigator.userAgent") { (userAgent, error) in
                if let userAgent = userAgent as? String {
                    self.customUserAgent = self.transformUserAgent(originalUserAgent: userAgent)
                } else if let error = error {
                    print("Error getting User-Agent: \(error)")
                }
            }
            
        }

        self.disablesInteractiveKeyboardGestureRecognizer = true
        
        self.isOpaque = false
        self.backgroundColor = .clear
        if #available(iOS 9.0, *) {
            self.allowsLinkPreview = false
        }
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.interactiveTransitionGestureRecognizerTest = { point -> Bool in
            return point.x > 30.0
        }
        self.allowsBackForwardNavigationGestures = true
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        }

        self.observeSomthings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
