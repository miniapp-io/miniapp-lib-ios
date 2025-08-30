import Foundation
import UIKit
import WebKit

private let selectionSource = "var css = '*{-webkit-touch-callout:none;} :not(input):not(textarea):not([\"contenteditable\"=\"true\"]){-webkit-user-select:none;}';"
        + " var head = document.head || document.getElementsByTagName('head')[0];"
        + " var style = document.createElement('style'); style.type = 'text/css';" +
        " style.appendChild(document.createTextNode(css)); head.appendChild(style);"

private let videoSource = """
function disableWebkitEnterFullscreen(videoElement) {
  if (videoElement && videoElement.webkitEnterFullscreen) {
    Object.defineProperty(videoElement, 'webkitEnterFullscreen', {
      value: undefined
    });
  }
}

function disableFullscreenOnExistingVideos() {
  document.querySelectorAll('video').forEach(disableWebkitEnterFullscreen);
}

function handleMutations(mutations) {
  mutations.forEach((mutation) => {
    if (mutation.addedNodes && mutation.addedNodes.length > 0) {
      mutation.addedNodes.forEach((newNode) => {
        if (newNode.tagName === 'VIDEO') {
          disableWebkitEnterFullscreen(newNode);
        }
        if (newNode.querySelectorAll) {
          newNode.querySelectorAll('video').forEach(disableWebkitEnterFullscreen);
        }
      });
    }
  });
}

disableFullscreenOnExistingVideos();

const observer = new MutationObserver(handleMutations);

observer.observe(document.body, {
  childList: true,
  subtree: true
});

function disconnectObserver() {
  observer.disconnect();
}
"""

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
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        
        let selectionScript = WKUserScript(source: selectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(selectionScript)
        
        let videoScript = WKUserScript(source: videoSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(videoScript)
        
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
