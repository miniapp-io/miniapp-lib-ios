//
//  FloatingWindowManager.swift
//  MiniAppX
//
//  Created by w3bili on 2024/9/19.
//

import UIKit
import WebKit

internal class FloatingWindowManager {
    
    static let shared = FloatingWindowManager()
    
    private var floatingWindow: UIWindow?
    private var floatingView: UIView?
    private var miniApp: IMiniApp?
    private var webView: WKWebView?
    private var frameWebView: CGRect?
    
    private init() {}
    
    func currentApp() -> IMiniApp? {
        return miniApp
    }
    
    func maximize() -> Void {
        imageTapped()
    }
    
    // Create and display floating window
    func showFloatingWindow(miniApp: IMiniApp, webView: WKWebView?, iconUrl: String?, width: CGFloat = 86.0, height: CGFloat = 128.0) {
        if miniApp.getVC() === self.miniApp?.getVC() {
            return
        }
        
        dismissFloatingWindow(force: true)
        
        guard floatingWindow == nil else { return }
        
        // Get current active UIWindowScene
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        self.miniApp = miniApp
        self.webView = webView
        self.frameWebView = webView?.frame
        
        let screenBounds = UIScreen.main.bounds
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        
        // Initialize UIWindow, set dimensions
        let windowWidth: CGFloat = width
        let windowHeight: CGFloat = height
        
        let floatingWindow = UIWindow(windowScene: scene)
        floatingWindow.frame = CGRect(x: screenBounds.width - windowWidth - 10, y: screenBounds.height - windowHeight - safeAreaInsets.bottom, width: windowWidth, height: windowHeight)
        floatingWindow.backgroundColor = .clear
        floatingWindow.windowLevel = UIWindow.Level.alert + 1 // Display above all content
        addShadowToWindow(floatingWindow)
        
        self.floatingWindow = floatingWindow
        
        // Create content view for floating window
        let floatingView = UIView(frame: floatingWindow.bounds)
        floatingView.backgroundColor = .clear
        floatingView.layer.cornerRadius = 10
        floatingView.clipsToBounds = true
        floatingWindow.addSubview(floatingView)
        
        self.floatingView = floatingView
        
        // Add UIImageView for loading network images
        let imageView = UIImageView(frame: floatingView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(rgb: 0xD9D9D9)
        floatingView.addSubview(imageView)
        
        // Load network image
        loadImage(from: iconUrl, into: imageView)
        
        if let webView = webView {
            webView.frame = CGRect(x: 0, y: 0, width: windowWidth * 5, height: windowHeight * 5)
            webView.layer.anchorPoint = CGPoint(x: 0, y: 0)
            webView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            webView.frame.origin = CGPoint(x: 0, y: 0)
            floatingView.clipsToBounds = true
            floatingView.addSubview(webView)
        }
        
        // Create transparent view
        let transparentView = UIView(frame: floatingWindow.bounds)
        transparentView.backgroundColor = UIColor.clear
        transparentView.isUserInteractionEnabled = true
        addGradientBackground(to: transparentView)
        floatingView.addSubview(transparentView)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: floatingView.bounds.width - 30, y: floatingView.bounds.height - 30, width: 30, height: 30)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(getImage(named: "icon_float_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeFloatingWindow), for: .touchUpInside)
        floatingView.addSubview(closeButton)
        
        // Add tap event to image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        transparentView.isUserInteractionEnabled = true
        transparentView.addGestureRecognizer(tapGesture)
        
        // Add drag gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        transparentView.addGestureRecognizer(panGesture)
        
        // Show window
        floatingWindow.makeKeyAndVisible()
    }
    
    func addShadowToWindow(_ window: UIWindow) {
        // Set shadow color (black)
        window.layer.shadowColor = UIColor.black.cgColor
        
        // Set shadow opacity (0 - 1, 1 means opaque)
        window.layer.shadowOpacity = 0.5
        
        // Set shadow offset (width is horizontal offset, height is vertical offset)
        window.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        // Set shadow blur radius
        window.layer.shadowRadius = 10
        
        // Optional: Set corner radius if you want the shadow to also have rounded corners
        window.layer.cornerRadius = 10
    }
    
    private func addGradientBackground(to view: UIView) {
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Set gradient layer size and position
        gradientLayer.frame = view.bounds
        
        // Gradient color array (gradient from top to bottom)
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,    // Top color
            UIColor.black.withAlphaComponent(5).cgColor,   // Bottom color
        ]
        
        // Set gradient start and end points, (0,0) is top-left, (1,1) is bottom-right
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.8)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        // Add gradient layer to UIImageView's layer, place at the bottom
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func getImage(named name: String) -> UIImage? {
        return UIKitResourceManager.image(named: name)
    }
    
    // Hide and destroy floating window
    func hideFloatingWindow() {
        floatingWindow?.isHidden = true
        floatingWindow?.removeFromSuperview()
        floatingWindow = nil
        floatingView = nil
        miniApp = nil
        webView = nil
    }
    
    // Hide and destroy floating window
    func dismissFloatingWindow(force: Bool) {
        if self.miniApp?.requestDismiss(force) ?? force {
            if let webView = self.webView, let frame = self.frameWebView {
                webView.removeFromSuperview()
                webView.transform = CGAffineTransform.identity
                webView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                webView.frame = frame
            }
            hideFloatingWindow()
        }
    }
    
    // Hide and destroy floating window
    @objc private func closeFloatingWindow() {
        dismissFloatingWindow(force: false)
    }
    
    // Image tap event handling
    @objc private func imageTapped() {
        if let webView = self.webView, let frame = self.frameWebView {
            webView.removeFromSuperview()
            webView.transform = CGAffineTransform.identity
            webView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            webView.frame = frame
        }
        self.miniApp?.maximize()
        self.hideFloatingWindow()
    }
    
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let floatingWindow = floatingWindow else { return }
        
        // Get drag offset
        let translation = gesture.translation(in: floatingWindow)
        
        // Handle drag based on gesture state
        switch gesture.state {
        case .began, .changed:
            // Update floatingWindow position
            let newCenterX = floatingWindow.center.x + translation.x
            let newCenterY = floatingWindow.center.y + translation.y
            
            // Get screen bounds and safe area
            let screenBounds = UIScreen.main.bounds
            let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
            
            // Limit drag range to not exceed screen bounds, considering safe area
            let minX = floatingWindow.bounds.width / 2 + 10 // Keep 10 points margin on the left
            let maxX = screenBounds.width - minX // Keep 10 points margin on the right
            let minY = safeAreaInsets.top + floatingWindow.bounds.height / 2 // Top safe area
            let maxY = screenBounds.height - safeAreaInsets.bottom - floatingWindow.bounds.height / 2 // Bottom safe area
            
            floatingWindow.center = CGPoint(x: min(max(newCenterX, minX), maxX),
                                            y: min(max(newCenterY, minY), maxY))
            
            // Reset gesture translation to avoid accumulation
            gesture.setTranslation(.zero, in: floatingWindow)
            
        case .ended:
            // When drag ends, add left-right snap functionality
            snapWindowToSides()
            
        case .cancelled, .failed:
            break
            
        default:
            break
        }
    }
    
    private func snapWindowToSides() {
        guard let floatingWindow = floatingWindow else { return }
        
        // Get screen bounds and safe area
        let screenBounds = UIScreen.main.bounds
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        
        // Calculate distance from floating window center point to left and right edges of screen
        let leftDistance = floatingWindow.frame.minX
        let rightDistance = screenBounds.width - floatingWindow.frame.maxX
        
        // Custom margin to keep when snapping left or right
        let margin: CGFloat = 10.0
        
        // Determine whether to snap to left or right
        let targetX: CGFloat
        if leftDistance < rightDistance {
            // Snap to left, keep margin
            targetX = margin + floatingWindow.bounds.width / 2
        } else {
            // Snap to right, keep margin
            targetX = screenBounds.width - margin - floatingWindow.bounds.width / 2
        }
        
        // Get top and bottom safe areas
        let minY = safeAreaInsets.top + floatingWindow.bounds.height / 2
        let maxY = screenBounds.height - safeAreaInsets.bottom - floatingWindow.bounds.height / 2
        
        // Limit Y-axis position
        var targetY = floatingWindow.center.y
        targetY = min(max(targetY, minY), maxY)
        
        // Use animation for snapping
        UIView.animate(withDuration: 0.3) {
            floatingWindow.center = CGPoint(x: targetX, y: targetY)
        }
    }
    
    // Load image, show placeholder if failed
    private func loadImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.image = UIImage(named: "placeholder") // Load local placeholder image
            return
        }
        
        // Asynchronously load network image
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder") // Load local placeholder image
                }
            }
        }
    }
}


