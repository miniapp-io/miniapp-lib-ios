import Foundation
import UIKit
import WebKit
import MiniAppUIKit

internal class BaseWebView: WKWebView {
    
    static var userAgentString: String? = nil
    
    var pageIcon: String?
    
    var pageMetaDatas: [String: String?]? = nil
    
    var backButtonVisible: Bool?
    
    var closeConfirm: Bool?
    
    var hasSettings: Bool?
    
    var isExpanded: Bool?
    
    var enalbeExpand: Bool?
    
    var showFullScreen: Bool?
    
    var headerColor: UIColor?
    
    var bgColor: UIColor?
    
    var isDismiss: Bool = false
    
    var refreshFlag: Bool = false
    
    var isPageLoaded: Bool = false
    
    var cacheData: String? = nil
    
    var expirationTimestamp: TimeInterval?
    
    var isExpired: Bool {
        guard let timestamp = expirationTimestamp else { return false }
        let currentTimestamp = Date().timeIntervalSince1970 * 1000.0
        return currentTimestamp > timestamp
    }
    
    var handleDismiss: (() -> Void)? = nil
    
    var canGoBackObseve: ((Bool) -> Void)? = nil
    
    var handleScriptMessage: ((WKScriptMessage) -> Void)? = nil
    
    var handleSchemeMessage: ((WKScriptMessage) -> Void)? = nil
    
    var lastTouchTimestamp: Double?
    
    var onFirstTouch: (() -> Void)? = {}
    
    var didTouchOnce = false
    
    var customInsets: UIEdgeInsets = .zero
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        self.lastTouchTimestamp = CACurrentMediaTime()
        if result != nil && !self.didTouchOnce {
            self.didTouchOnce = true
            self.onFirstTouch?()
        }
        return result
    }
    
    open override var inputAccessoryView: UIView? {
        return nil
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if #available(iOS 11.0, *) {
            let webScrollView = self.subviews.compactMap { $0 as? UIScrollView }.first
            Queue.mainQueue().after(0.1, {
                let contentView = webScrollView?.subviews.first(where: { $0.interactions.count > 1 })
                guard let dragInteraction = (contentView?.interactions.compactMap { $0 as? UIDragInteraction }.first) else {
                    return
                }
                contentView?.removeInteraction(dragInteraction)
            })
            
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    // MARK: - KVO
    
    private var canGoBackKV: NSKeyValueObservation?
    
    // MARK: - State
    
    func observeSomthings() {
        canGoBackKV?.invalidate()
        canGoBackKV = self.observe(\.canGoBack, options: .new) { [weak self] _, value in
            guard let canGoBack = value.newValue else { return }
            self?.canGoBackObseve?(canGoBack)
        }
    }
}


private let findActiveElementY = """
function getOffset(el) {
    const rect = el.getBoundingClientRect();
    return {
        left: rect.left + window.scrollX,
        top: rect.top + window.scrollY
    };
}
getOffset(document.activeElement).top;
"""

fileprivate var bundleVersionStr: String = ""

internal extension WKWebView {
    
    private func getBundleVersion() {
        if !bundleVersionStr.isEmpty {
            return
        }
        if let version = Bundle(for: BaseWebView.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            bundleVersionStr = version
        } else {
            bundleVersionStr = "undefine"
        }
    }
    
    func defaultUserAgent() -> String {
        getBundleVersion()
        
        return isIPhone() ? "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 MiniAppX IOS/\(bundleVersionStr)" : "Mozilla/5.0 (iPad; CPU OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 MiniAppX IOS/\(bundleVersionStr)"
    }
    
    func isIPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func transformUserAgent(originalUserAgent: String) -> String {
        
        getBundleVersion()
        
        do {
            // Parse iOS version (iPhone OS 18_1)
            let osSrc = isIPhone() ? "CPU iPhone OS" : "CPU OS"
            let osVersionPattern = "\(osSrc) (\\d+_\\d+)"
            let osVersionRegex = try NSRegularExpression(pattern: osVersionPattern, options: [])
            let osVersionRange = osVersionRegex.rangeOfFirstMatch(in: originalUserAgent, options: [], range: NSRange(location: 0, length: originalUserAgent.utf16.count))
            
            guard osVersionRange.location != NSNotFound, osVersionRange.location + osVersionRange.length <= originalUserAgent.utf16.count else {
                return originalUserAgent
            }
            let osVersionString = (originalUserAgent as NSString).substring(with: osVersionRange)
            
            // Replace iPhone OS 18_1 with Version/18.1
            let modifiedOsVersion = osVersionString.replacingOccurrences(of: "\(osSrc) ", with: "Version/").replacingOccurrences(of: "_", with: ".")
            
            // Extract dynamic part from Mobile/xxxxxx (e.g., Mobile/15E148)
            let mobilePattern = "Mobile/(\\w+)"
            let mobileRegex = try! NSRegularExpression(pattern: mobilePattern, options: [])
            let mobileRange = mobileRegex.rangeOfFirstMatch(in: originalUserAgent, options: [], range: NSRange(location: 0, length: originalUserAgent.utf16.count))
            
            // If Mobile part is not found, return original User-Agent
            guard mobileRange.location != NSNotFound, mobileRange.location + mobileRange.length <= originalUserAgent.utf16.count else {
                return defaultUserAgent()
            }
            
            let mobileId = (originalUserAgent as NSString).substring(with: mobileRange)
            
            // Insert Version/18.1 before Mobile/xxxxxx
            var newUserAgent = originalUserAgent
                .replacingOccurrences(of: mobileId, with: modifiedOsVersion + " " + mobileId) // Insert Version/18.1 before Mobile/xxxxxx
            
            let userAgentName = mobileId + " Safari/604.1 MiniAppX IOS/\(bundleVersionStr)"
            
            BaseWebView.userAgentString = userAgentName
            
            // Concatenate userAgentName after Mobile/xxxxxx
            newUserAgent = newUserAgent.replacingOccurrences(of: mobileId, with: userAgentName)
            
            return newUserAgent
            
        } catch {
            // Catch regex-related errors and print
            print("Error occurred while transforming User-Agent: \(error)")
            
            // If an exception occurs, return original User-Agent
            return defaultUserAgent()
        }
    }
    
    func goToHomePage() {
        guard let backList = backForwardList.backList.first else {
            return
        }
        go(to: backList)
    }
    
    func scrollToActiveElement(layout: ContainerViewLayout, completion: @escaping (CGPoint) -> Void, transition: ContainedViewLayoutTransition) {
        self.evaluateJavaScript(findActiveElementY, completionHandler: { result, _ in
            if let result = result as? CGFloat {
                Queue.mainQueue().async {
                    let convertedY = result - self.scrollView.contentOffset.y
                    let viewportHeight = self.frame.height - (layout.inputHeight ?? 0.0) + 26.0
                    if convertedY < 0.0 || (convertedY + 44.0) > viewportHeight {
                        let targetOffset: CGFloat
                        if convertedY < 0.0 {
                            targetOffset = max(0.0, result - 36.0)
                        } else {
                            targetOffset = max(0.0, result + 60.0 - viewportHeight)
                        }
                        let contentOffset = CGPoint(x: 0.0, y: targetOffset)
                        completion(contentOffset)
                        transition.animateView({
                            self.scrollView.contentOffset = contentOffset
                        })
                    }
                }
            }
        })
    }
}
