import Foundation
import UIKit
import WebKit

private class WeakGameScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private let f: (WKScriptMessage) -> ()
    
    init(_ f: @escaping (WKScriptMessage) -> ()) {
        self.f = f
        
        super.init()
    }
    
    func userContentController(_ controller: WKUserContentController, didReceive scriptMessage: WKScriptMessage) {
        self.f(scriptMessage)
    }
}

private class WebViewTouchGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .began
    }
}

private var defaultEventProxySource: (String) -> String = { webappName in 
    return "var \(webappName)WebviewProxyProto = function() {}; " +
    "\(webappName)WebviewProxyProto.prototype.postEvent = function(eventName, eventData) { " +
    "window.webkit.messageHandlers.perform\(webappName)Action.postMessage({'eventName': eventName, 'eventData': eventData}); " +
    "}; " +
    "\(webappName)WebviewProxyProto.prototype.sayHello = function() { " +
    "window.webkit.messageHandlers.perform\(webappName)Action.postMessage({'eventName': 'web_app_say_hello', 'eventData': ''}); " +
    "}; " +
    "var \(webappName)WebviewProxy = new \(webappName)WebviewProxyProto();"
}

private let tgEventProxySource = "var TelegramWebviewProxyProto = function() {}; " +
    "TelegramWebviewProxyProto.prototype.postEvent = function(eventName, eventData) { " +
    "window.webkit.messageHandlers.performAction.postMessage({'eventName': eventName, 'eventData': eventData}); " +
    "}; " +
"var TelegramWebviewProxy = new TelegramWebviewProxyProto();"


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

internal final class WebAppWebView: BaseWebView {

    var isTelegramWebApp: Bool = false
    
    let webAppName: String
    
    init(accountId: String, webAppName: String) {
        
        self.webAppName = webAppName
        
        let configuration = WKWebViewConfiguration()
        //configuration.setURLSchemeHandler(CustomURLSchemeHandler(), forURLScheme: "https")
        
        if let userAgentString = BaseWebView.userAgentString {
            configuration.applicationNameForUserAgent = userAgentString
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
                
        if #available(iOS 17.0, *) {
            var uuid: UUID?
            if let current = LRUSharedPreferencesCache.shared.getValue(forKey: "\(webAppName)WebStoreUUID_\(accountId)") {
                uuid = UUID(uuidString: current)!
            } else {
                let mainAccountId: String
                if let current = LRUSharedPreferencesCache.shared.getValue(forKey: "\(webAppName)WebStoreMainAccountId") {
                    mainAccountId = current
                } else {
                    mainAccountId = accountId
                    LRUSharedPreferencesCache.shared.saveValue(mainAccountId, forKey: "\(webAppName)WebStoreMainAccountId")
                }
                
                if accountId != mainAccountId {
                    uuid = UUID()
                    LRUSharedPreferencesCache.shared.saveValue(uuid!.uuidString, forKey: "\(webAppName)WebStoreUUID_\(accountId)")
                }
            }
            
            if let uuid {
                configuration.websiteDataStore = WKWebsiteDataStore(forIdentifier: uuid)
            }
        }
        
        let contentController = WKUserContentController()
        
           
        // JSBridget for open web3
        var handleDefaultScriptMessageImpl: ((WKScriptMessage) -> Void)?
        let defaultEventProxySource = WKUserScript(source: defaultEventProxySource(webAppName), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(defaultEventProxySource)
        contentController.add(WeakGameScriptMessageHandler { message in
            handleDefaultScriptMessageImpl?(message)
        }, name: "performDefaultAction")
        
        // JSBridget for Telegram
        var handleTelegramScriptMessageImpl: ((WKScriptMessage) -> Void)?
        let telegramEventProxySource = WKUserScript(source: tgEventProxySource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(telegramEventProxySource)
        contentController.add(WeakGameScriptMessageHandler { message in
            handleTelegramScriptMessageImpl?(message)
        }, name: "performAction")
        
        let selectionScript = WKUserScript(source: selectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(selectionScript)
        
        let videoScript = WKUserScript(source: videoSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(videoScript)
        
        var handleSchemeScriptMessageImpl: ((WKScriptMessage) -> Void)?
        contentController.add(WeakGameScriptMessageHandler { message in
            handleSchemeScriptMessageImpl?(message)
        }, name: "performSchemeAction")
        
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
        
        handleDefaultScriptMessageImpl = { [weak self] message in
            if let strongSelf = self {
                strongSelf.isTelegramWebApp = false
                strongSelf.handleInnerScriptMessage(message)
            }
        }
        
        handleTelegramScriptMessageImpl = { [weak self] message in
            if let strongSelf = self {
                strongSelf.isTelegramWebApp = true
                strongSelf.handleInnerScriptMessage(message)
            }
        }
        
        handleSchemeScriptMessageImpl = { [weak self] message in
            if let strongSelf = self {
                strongSelf.handleSchemeMessage?(message)
            }
        }
        
        self.observeSomthings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func sendEvent(name: String, data: String?) {
        if(isTelegramWebApp) {
            sendTgEvent(name: name, data: data)
        } else {
            sendDefaultEvent(name: name, data: data)
        }
    }
    
    private func sendTgEvent(name: String, data: String?) {
        let script = "window.TelegramGameProxy.receiveEvent(\"\(name)\", \(data ?? "null"))"
        self.evaluateJavaScript(script, completionHandler: { _, _ in
        })
    }
    
    private func sendDefaultEvent(name: String, data: String?) {
        let script = "window.\(self.webAppName)GameProxy.receiveEvent(\"\(name)\", \(data ?? "null"))"
        self.evaluateJavaScript(script, completionHandler: { _, _ in
        })
    }
}


internal extension WebAppWebView {
    
    private func handleInnerScriptMessage(_ message: WKScriptMessage) {
        self.handleScriptMessage?(message)
        
        guard let body = message.body as? [String: Any] else {
            return
        }
        guard let eventName = body["eventName"] as? String else {
            return
        }
        
        let eventData = (body["eventData"] as? String)?.data(using: .utf8)
        let json = try? JSONSerialization.jsonObject(with: eventData ?? Data(), options: []) as? [String: Any]
        
        switch eventName {
            case "web_app_expand":
                self.isExpanded = true
            
            case "web_app_setup_closing_behavior":
                if let json = json, let needConfirmation = json["need_confirmation"] as? Bool {
                    self.closeConfirm = needConfirmation
                }
            case "web_app_setup_swipe_behavior":
                if let json = json, let canExpand = json["allow_vertical_swipe"] as? Bool {
                    self.enalbeExpand = canExpand
                }
            case "web_app_request_fullscreen":
                self.showFullScreen = true
            
            case "web_app_setup_settings_button":
                if let json = json, let isVisible = json["is_visible"] as? Bool {
                    self.hasSettings = isVisible
                }
            default:
                break
        }
    }
}
