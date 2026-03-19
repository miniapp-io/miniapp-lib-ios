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


/// Measures focused control after scrollIntoView; uses visualViewport when available (closer to visible area above keyboard in WKWebView).
private let activeElementViewportRectJSON = """
(function() {
  var el = document.activeElement;
  if (!el) return null;
  var tag = el.tagName;
  if (tag !== 'INPUT' && tag !== 'TEXTAREA' && tag !== 'SELECT' && !el.isContentEditable) return null;
  if (tag === 'BODY' || tag === 'HTML') return null;
  try {
    el.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'auto' });
  } catch (e) {
    try { el.scrollIntoView(true); } catch (e2) {}
  }
  var r = el.getBoundingClientRect();
  var vv = window.visualViewport;
  var vTop = vv ? vv.offsetTop : 0;
  var vHeight = vv ? vv.height : (window.innerHeight || document.documentElement.clientHeight || 0);
  return JSON.stringify({ top: r.top, bottom: r.bottom, height: r.height, viewTop: vTop, viewHeight: vHeight });
})()
"""

fileprivate var bundleVersionStr: String = "1.0.35"

internal extension WKWebView {
    
    func defaultUserAgent() -> String {
        return isIPhone() ? "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 MiniAppX IOS/\(bundleVersionStr)" : "Mozilla/5.0 (iPad; CPU OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 MiniAppX IOS/\(bundleVersionStr)"
    }
    
    func isIPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func transformUserAgent(originalUserAgent: String) -> String {
        
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
    
    /// Scrolls the focused input above the soft keyboard. Uses `keyboardBottomObstruction` when layout pipeline omits `inputHeight`.
    func scrollToActiveElement(
        layout: ContainerViewLayout,
        keyboardBottomObstruction: CGFloat,
        completion: @escaping (CGPoint) -> Void,
        transition: ContainedViewLayoutTransition
    ) {
        self.evaluateJavaScript(activeElementViewportRectJSON, completionHandler: { result, _ in
            guard let json = result as? String,
                  let data = json.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let top = (obj["top"] as? NSNumber)?.doubleValue,
                  let bottom = (obj["bottom"] as? NSNumber)?.doubleValue else {
                return
            }
            let viewHeightJS = (obj["viewHeight"] as? NSNumber)?.doubleValue
            let viewTopJS = (obj["viewTop"] as? NSNumber)?.doubleValue ?? 0.0
            Queue.mainQueue().async {
                let scrollView = self.scrollView
                let insetBottom = Double(scrollView.contentInset.bottom)
                let layoutKb = Double(layout.inputHeight ?? 0.0)
                let obstruction = max(insetBottom, layoutKb, Double(keyboardBottomObstruction))
                var visibleHeight = Double(scrollView.bounds.height) - obstruction
                if let vh = viewHeightJS, vh > 80 {
                    visibleHeight = min(visibleHeight, vh - viewTopJS)
                }
                guard visibleHeight > 80 else {
                    return
                }
                let marginTop: Double = 8.0
                let marginBottom: Double = 20.0
                var deltaY: Double = 0.0
                if bottom > visibleHeight - marginBottom {
                    deltaY = bottom - (visibleHeight - marginBottom)
                } else if top < marginTop {
                    deltaY = top - marginTop
                }
                guard abs(deltaY) > 0.5 else {
                    return
                }
                let curY = Double(scrollView.contentOffset.y)
                var newY = curY + deltaY
                let maxOffsetY = max(
                    0.0,
                    Double(scrollView.contentSize.height) - Double(scrollView.bounds.height) + insetBottom
                )
                newY = min(max(0.0, newY), maxOffsetY)
                let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: CGFloat(newY))
                completion(contentOffset)
                let animated = transition.isAnimated
                scrollView.setContentOffset(contentOffset, animated: animated)
            }
        })
    }
}
