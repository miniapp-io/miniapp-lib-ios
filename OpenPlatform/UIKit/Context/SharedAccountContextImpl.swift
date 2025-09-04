//
//  SharedAccountContextImpl.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/6/6.
//
import UIKit

internal class DefaultResourceProvider : IResourceProvider {
    
    public static let shared = DefaultResourceProvider()

    private var languageCode: String = "en"
    private var userInterfaceStyle: UIUserInterfaceStyle = .light
    private var localizedStrings: [String:String] = [:]
    
    private init() {}
    
    public func initResouce(userInterfaceStyle: UIUserInterfaceStyle, languageCode: String) async {
        self.userInterfaceStyle = userInterfaceStyle
        if UIKitResourceManager.isLanguageSupported(language: languageCode) {
            self.languageCode = languageCode
        } else {
            self.languageCode = "en"
        }
        self.localizedStrings = UIKitResourceManager.localizedStrings(language: self.languageCode)
    }
    
    public func setUserInterfaceStyle(userInterfaceStyle: UIUserInterfaceStyle) {
        self.userInterfaceStyle = userInterfaceStyle
    }
    
    public func getLanguageCode() -> String {
        return self.languageCode
    }
    
    public func setLanguage(languageCode: String) async {
        if(self.languageCode == languageCode) {
            return
        }
        if UIKitResourceManager.isLanguageSupported(language: languageCode) {
            self.languageCode = languageCode
        } else {
            self.languageCode = "en"
        }
        self.localizedStrings = UIKitResourceManager.localizedStrings(language: self.languageCode)
    }
    
    public func setUserInterfaceStyle(_ userInterfaceStyle: UIUserInterfaceStyle) {
        self.userInterfaceStyle = userInterfaceStyle
    }
    
    public func isDark() -> Bool {
        return userInterfaceStyle == .dark
    }
    
    public func getString(key: String) -> String? {
        return localizedStrings[key]
    }
    
    public func getString(key: String, withValues values: [CVarArg]) -> String {
        return formatString(template: getString(key: key) ?? "", withValues: values)
    }
    
    public func getColor(key: String) -> UIColor {
        if(isDark()) {
            return ThemeColors.allColors[key]?.1 ?? .white
        }
        return ThemeColors.allColors[key]?.0 ?? .black
    }
    
    public func getUserInterfaceStyle() -> UIUserInterfaceStyle {
        return self.userInterfaceStyle
    }
    
    private func formatString(template: String, withValues values: [CVarArg]) -> String {
        return String(format: template, arguments: values)
    }
    
    private func formatString2(template: String, withValues values: [CVarArg]) -> String {
        if values.count >= 2 {
            return String(format: template, values[0], values[1])
        } else {
            return String(format: template, arguments: values)
        }
    }
    
    private func formatString3(template: String, withValues values: [CVarArg]) -> String {
        if values.count >= 3 {
            return String(format: template, values[0], values[1], values[2])
        } else {
            return String(format: template, arguments: values)
        }
    }
}

internal class SharedAccountContextImpl : AccountContext {
    
    public let appName: String
    
    public let mainWindow: Window1?
    
    public let mePaths: [String]
    
    public let resourceProvider: IResourceProvider
    
    public init(appName: String, 
         mePath: [String],
         mainWindow: Window1?,
         resourceProvider: IResourceProvider) {
        self.mePaths = mePath
        self.appName = appName
        self.mainWindow = mainWindow
        self.resourceProvider = resourceProvider
    }
}

internal class ApplicationStatusBarHost: StatusBarHost {
    private let application = UIApplication.shared
    
    public init(shouldChangeStatusBarStyle: ( (UIStatusBarStyle) -> Bool)? = nil) {
        self.shouldChangeStatusBarStyle = shouldChangeStatusBarStyle
    }
    
    public var isApplicationInForeground: Bool {
        switch self.application.applicationState {
        case .background:
            return false
        default:
            return true
        }
    }
    
    public var statusBarFrame: CGRect {
        return self.application.statusBarFrame
    }
    
    public var statusBarStyle: UIStatusBarStyle {
        get {
            return self.application.statusBarStyle
        } set(value) {
            self.setStatusBarStyle(value, animated: false)
        }
    }
    
    public func setStatusBarStyle(_ style: UIStatusBarStyle, animated: Bool) {
        if self.shouldChangeStatusBarStyle?(style) ?? true {
            self.application.internalSetStatusBarStyle(style, animated: animated)
        }
    }
    
    public var shouldChangeStatusBarStyle: ((UIStatusBarStyle) -> Bool)?
    
    public func setStatusBarHidden(_ value: Bool, animated: Bool) {
        self.application.internalSetStatusBarHidden(value, animation: animated ? .fade : .none)
    }
    
    public var keyboardWindow: UIWindow? {
        if #available(iOS 16.0, *) {
            return UIApplication.shared.internalGetKeyboard()
        }
        
        for window in UIApplication.shared.windows {
            if isKeyboardWindow(window: window) {
                return window
            }
        }
        return nil
    }
    
    public var keyboardView: UIView? {
        guard let keyboardWindow = self.keyboardWindow else {
            return nil
        }
        
        for view in keyboardWindow.subviews {
            if isKeyboardViewContainer(view: view) {
                for subview in view.subviews {
                    if isKeyboardView(view: subview) {
                        return subview
                    }
                }
            }
        }
        return nil
    }
}

private func isKeyboardWindow(window: NSObject) -> Bool {
    let typeName = NSStringFromClass(type(of: window))
    if #available(iOS 9.0, *) {
        if typeName.hasPrefix("UI") && typeName.hasSuffix("RemoteKeyboardWindow") {
            return true
        }
    } else {
        if typeName.hasPrefix("UI") && typeName.hasSuffix("TextEffectsWindow") {
            return true
        }
    }
    return false
}

private func isKeyboardView(view: NSObject) -> Bool {
    let typeName = NSStringFromClass(type(of: view))
    if typeName.hasPrefix("UI") && typeName.hasSuffix("InputSetHostView") {
        return true
    }
    return false
}

private func isKeyboardViewContainer(view: NSObject) -> Bool {
    let typeName = NSStringFromClass(type(of: view))
    if typeName.hasPrefix("UI") && typeName.hasSuffix("InputSetContainerView") {
        return true
    }
    return false
}
