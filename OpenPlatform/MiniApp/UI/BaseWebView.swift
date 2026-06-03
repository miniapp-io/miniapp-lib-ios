import Foundation
import UIKit
import WebKit
import MiniAppUIKit

internal let selectionSource = "var css = '*{-webkit-touch-callout:none;} :not(input):not(textarea):not([\"contenteditable\"=\"true\"]){-webkit-user-select:none;}';"
        + " var head = document.head || document.getElementsByTagName('head')[0];"
        + " var style = document.createElement('style'); style.type = 'text/css';" +
        " style.appendChild(document.createTextNode(css)); head.appendChild(style);"

internal let fullscreenCompatSource = """
(function() {
  if (window.__miniappxFullscreenCompatInstalled) {
    return;
  }
  window.__miniappxFullscreenCompatInstalled = true;

  function tryLegacyFullscreen(target) {
    if (!target) return false;
    if (typeof target.webkitEnterFullscreen === 'function') {
      try { target.webkitEnterFullscreen(); return true; } catch (e) {}
    }
    if (typeof target.webkitEnterFullScreen === 'function') {
      try { target.webkitEnterFullScreen(); return true; } catch (e) {}
    }
    if (target.querySelector) {
      var childVideo = target.querySelector('video');
      if (childVideo && typeof childVideo.webkitEnterFullscreen === 'function') {
        try { childVideo.webkitEnterFullscreen(); return true; } catch (e) {}
      }
      if (childVideo && typeof childVideo.webkitEnterFullScreen === 'function') {
        try { childVideo.webkitEnterFullScreen(); return true; } catch (e) {}
      }
    }
    return false;
  }

  var elementProto = window.Element && window.Element.prototype;
  if (elementProto) {
    var rawElementRequestFullscreen = elementProto.requestFullscreen;
    elementProto.requestFullscreen = function() {
      var args = arguments;
      try {
        if (typeof rawElementRequestFullscreen === 'function') {
          var result = rawElementRequestFullscreen.apply(this, args);
          if (result && typeof result.catch === 'function') {
            var self = this;
            result.catch(function() { tryLegacyFullscreen(self); });
          }
          return result;
        }
      } catch (e) {}
      if (tryLegacyFullscreen(this)) return Promise.resolve();
      return undefined;
    };

    var rawWebkitRequestFullscreen = elementProto.webkitRequestFullscreen;
    elementProto.webkitRequestFullscreen = function() {
      try {
        if (typeof rawWebkitRequestFullscreen === 'function') {
          return rawWebkitRequestFullscreen.apply(this, arguments);
        }
      } catch (e) {}
      if (tryLegacyFullscreen(this)) return Promise.resolve();
      return undefined;
    };

    var rawWebkitRequestFullScreen = elementProto.webkitRequestFullScreen;
    elementProto.webkitRequestFullScreen = function() {
      try {
        if (typeof rawWebkitRequestFullScreen === 'function') {
          return rawWebkitRequestFullScreen.apply(this, arguments);
        }
      } catch (e) {}
      if (tryLegacyFullscreen(this)) return Promise.resolve();
      return undefined;
    };
  }

  var videoProto = window.HTMLVideoElement && window.HTMLVideoElement.prototype;
  if (videoProto) {
    var rawVideoRequestFullscreen = videoProto.requestFullscreen;
    videoProto.requestFullscreen = function() {
      var args = arguments;
      try {
        if (typeof rawVideoRequestFullscreen === 'function') {
          var result = rawVideoRequestFullscreen.apply(this, args);
          if (result && typeof result.catch === 'function') {
            var self = this;
            result.catch(function() { tryLegacyFullscreen(self); });
          }
          return result;
        }
      } catch (e) {}
      if (tryLegacyFullscreen(this)) return Promise.resolve();
      return undefined;
    };
  }
})();
"""

internal let iframeFullscreenCompatSource = """
(function() {
  if (window.__miniappxIframeFullscreenCompatInstalled) {
    return;
  }
  window.__miniappxIframeFullscreenCompatInstalled = true;

  function patchIframe(iframe) {
    if (!iframe) return;
    try {
      iframe.allowFullscreen = true;
      iframe.setAttribute('allowfullscreen', '');
      iframe.setAttribute('webkitallowfullscreen', '');

      var allow = iframe.getAttribute('allow') || '';
      if (!/\\bfullscreen\\b/i.test(allow)) {
        allow = allow ? (allow + '; fullscreen *') : 'fullscreen *';
      }
      if (!/\\bautoplay\\b/i.test(allow)) {
        allow = allow ? (allow + '; autoplay *') : 'autoplay *';
      }
      iframe.setAttribute('allow', allow);
    } catch (e) {}
  }

  function patchAllIframes(root) {
    try {
      var scope = root || document;
      if (scope.querySelectorAll) {
        scope.querySelectorAll('iframe').forEach(patchIframe);
      }
    } catch (e) {}
  }

  patchAllIframes(document);

  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (!mutation.addedNodes) return;
      mutation.addedNodes.forEach(function(node) {
        if (!node) return;
        if (node.tagName === 'IFRAME') {
          patchIframe(node);
          return;
        }
        patchAllIframes(node);
      });
    });
  });

  document.addEventListener('DOMContentLoaded', function() {
    if (document.body) {
      observer.observe(document.body, { childList: true, subtree: true });
    }
    patchAllIframes(document);
  });
})();
"""

internal let fullscreenDebugSource = """
(function() {
  if (window.__miniappxFullscreenDebugInstalled) return;
  window.__miniappxFullscreenDebugInstalled = true;

  function post(type, payload) {
    try {
      var isTop = false;
      try { isTop = (window.top === window); } catch (e) {}
      window.webkit.messageHandlers.miniappxFullscreenDebug.postMessage({
        type: type,
        href: String(location.href || ''),
        isTop: isTop,
        payload: payload || {}
      });
    } catch (e) {}
  }

  function wrapCall(proto, name) {
    if (!proto) return;
    var raw = proto[name];
    if (typeof raw !== 'function') return;
    proto[name] = function() {
      var tag = this && this.tagName ? String(this.tagName) : '';
      post('call_' + name, { tag: tag });
      try {
        var result = raw.apply(this, arguments);
        if (result && typeof result.then === 'function') {
          result.then(function() { post('resolve_' + name, { tag: tag }); })
            .catch(function(err) { post('reject_' + name, { tag: tag, error: String(err) }); });
        }
        return result;
      } catch (err) {
        post('throw_' + name, { tag: tag, error: String(err) });
        throw err;
      }
    };
  }

  post('diag_boot', {
    hasElementRequestFullscreen: !!(window.Element && Element.prototype && Element.prototype.requestFullscreen),
    hasVideoRequestFullscreen: !!(window.HTMLVideoElement && HTMLVideoElement.prototype && HTMLVideoElement.prototype.requestFullscreen),
    hasVideoWebkitEnterFullscreen: !!(window.HTMLVideoElement && HTMLVideoElement.prototype && HTMLVideoElement.prototype.webkitEnterFullscreen),
    hasVideoWebkitEnterFullScreen: !!(window.HTMLVideoElement && HTMLVideoElement.prototype && HTMLVideoElement.prototype.webkitEnterFullScreen)
  });

  ['fullscreenchange', 'webkitfullscreenchange', 'webkitbeginfullscreen', 'webkitendfullscreen'].forEach(function(evt) {
    document.addEventListener(evt, function(e) {
      var t = e && e.target;
      post('event_' + evt, {
        tag: t && t.tagName ? String(t.tagName) : '',
        className: t && t.className ? String(t.className) : ''
      });
    }, true);
  });

  wrapCall(window.Element && Element.prototype, 'requestFullscreen');
  wrapCall(window.Element && Element.prototype, 'webkitRequestFullscreen');
  wrapCall(window.Element && Element.prototype, 'webkitRequestFullScreen');
  wrapCall(window.HTMLVideoElement && HTMLVideoElement.prototype, 'requestFullscreen');
  wrapCall(window.HTMLVideoElement && HTMLVideoElement.prototype, 'webkitEnterFullscreen');
  wrapCall(window.HTMLVideoElement && HTMLVideoElement.prototype, 'webkitEnterFullScreen');
})();
"""

internal let fetchReadableStreamUploadCompatSource = """
(function() {
  if (window.__miniappxFetchUploadCompatInstalled) {
    return;
  }

  console.log('fetchReadableStreamUploadCompatSource');
  
  window.__miniappxFetchUploadCompatInstalled = true;

  function supportsReadableStreamUpload() {
    try {
      if (typeof ReadableStream !== 'function' || typeof Request !== 'function') {
        return false;
      }
      var stream = new ReadableStream({
        start: function(controller) {
          controller.close();
        }
      });
      var request = new Request('about:blank', {
        method: 'POST',
        body: stream,
        duplex: 'half'
      });
      return !!request.body;
    } catch (e) {
      return false;
    }
  }

  // NOTE:
  // In WKWebView, capability probing via `new Request(...ReadableStream...)`
  // can report "supported", but real network upload may still fail at runtime.
  // So we intentionally DO NOT short-circuit on probe result here.

  if (typeof fetch !== 'function') {
    return;
  }

  function isReadableStreamBody(body) {
    if (!body) return false;
    if (typeof ReadableStream === 'function' && body instanceof ReadableStream) {
      return true;
    }
    return typeof body.getReader === 'function';
  }

  // Some clients (e.g. ky with onUploadProgress) fail before fetch():
  // new Request(existingRequest, { duplex: 'half', body: ReadableStream(...) }).
  // In WKWebView this throws "ReadableStream uploading is not supported".
  // We patch Request to fall back to the original request body in that case.
  if (typeof Request === 'function') {
    var NativeRequest = Request;
    var PatchedRequest = function(input, init) {
      if (!(this instanceof PatchedRequest)) {
        return new PatchedRequest(input, init);
      }

      var finalInit = init;
      try {
        if (finalInit && isReadableStreamBody(finalInit.body)) {
          var inputIsRequest = (typeof NativeRequest === 'function') && (input instanceof NativeRequest);
          if (inputIsRequest) {
            var sanitized = {};
            for (var k in finalInit) {
              if (Object.prototype.hasOwnProperty.call(finalInit, k)) {
                sanitized[k] = finalInit[k];
              }
            }
            // Keep headers/method/etc, but drop unsupported stream upload fields.
            try { delete sanitized.body; } catch (e) {}
            try { delete sanitized.duplex; } catch (e) {}
            finalInit = sanitized;
          }
        }
      } catch (e) {}
      try {
        return new NativeRequest(input, finalInit);
      } catch (e) {
        // Last-resort fallback: strip stream/duplex and retry.
        try {
          var fallback = {};
          if (finalInit) {
            for (var key in finalInit) {
              if (Object.prototype.hasOwnProperty.call(finalInit, key)) {
                fallback[key] = finalInit[key];
              }
            }
          }
          try { delete fallback.body; } catch (_) {}
          try { delete fallback.duplex; } catch (_) {}
          return new NativeRequest(input, fallback);
        } catch (_) {
          throw e;
        }
      }
    };
    PatchedRequest.prototype = NativeRequest.prototype;
    try { Object.setPrototypeOf(PatchedRequest, NativeRequest); } catch (e) {}
    window.Request = PatchedRequest;
    try { globalThis.Request = PatchedRequest; } catch (e) {}
  }

  function cloneInit(init) {
    if (!init) return {};
    var next = {};
    for (var key in init) {
      if (Object.prototype.hasOwnProperty.call(init, key)) {
        next[key] = init[key];
      }
    }
    if (Object.prototype.hasOwnProperty.call(next, 'duplex')) {
      try {
        delete next.duplex;
      } catch (e) {}
    }
    return next;
  }

  var rawFetch = fetch;
  window.fetch = function(input, init) {
    var sourceInit = init || {};
    var bodyFromInit = Object.prototype.hasOwnProperty.call(sourceInit, 'body') ? sourceInit.body : undefined;
    var body = bodyFromInit;
    if (body === undefined && typeof Request === 'function' && input instanceof Request) {
      body = input.body;
    }

    if (!isReadableStreamBody(body)) {
      return rawFetch.call(this, input, init);
    }

    var nextInit = cloneInit(sourceInit);
    return Promise.resolve(new Response(body).blob()).then(function(blob) {
      nextInit.body = blob;
      return rawFetch.call(window, input, nextInit);
    });
  };
  try { globalThis.fetch = window.fetch; } catch (e) {}
})();
"""

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
    
    var isWebAppReady: Bool = false
    
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
    
    weak var miniApp: IMiniApp? = nil
    
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

fileprivate var bundleVersionStr: String = "1.0.44"

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
