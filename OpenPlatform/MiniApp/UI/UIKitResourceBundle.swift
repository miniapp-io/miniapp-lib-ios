import Foundation
import UIKit

public extension Bundle {
    static var uikitResource: Bundle {
        if let bundle = Bundle.main.url(forResource: "MiniAppXResources", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundle) {
            return resourceBundle
        }
        if let bundle = Bundle(for: BaseWebView.self).url(forResource: "MiniAppXResources", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundle) {
            return resourceBundle
        }
        return Bundle.main
    }
}

public class UIKitResourceManager {
    public static func localizedString(for key: String, comment: String = "") -> String {
        return Bundle.uikitResource.localizedString(forKey: key, value: nil, table: nil)
    }
    
    public static func image(named name: String, _ alwaysTemplate: Bool = true) -> UIImage? {
        if alwaysTemplate {
            return UIImage(named: name, in: Bundle.uikitResource, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }
        return UIImage(named: name, in: Bundle.uikitResource, compatibleWith: nil)
    }
    
    public static func path(forResource name: String, ofType ext: String? = nil) -> String? {
        return Bundle.uikitResource.path(forResource: name, ofType: ext)
    }
    
    public static func supportedLanguages() -> [String] {
        return Bundle.uikitResource.localizations
    }

    public static func isLanguageSupported(language: String) -> Bool {
        return Bundle.uikitResource.localizations.contains(language)
    }
    
    public static func localizedStrings(language: String?) -> [String: String]  {
        guard let path = Bundle.uikitResource.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language) else {
            return [:]
        }
        
        if let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] {
            return dictionary
        }
        
        return [:]
    }
    
    public static func localizedString(for key: String, language: String?) -> String {
        guard let language = language else {
            return localizedString(for: key)
        }
        
        guard isLanguageSupported(language: language) else {
            return localizedString(for: key)
        }
        
        guard let path = Bundle.uikitResource.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language) else {
            return localizedString(for: key)
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
            return localizedString(for: key)
        }
        
        return dictionary[key] ?? localizedString(for: key)
    }
}

public extension UIKitResourceManager {
    static var closeIcon: UIImage? {
        return image(named: "icon_close")
    }
    
    static var floatCloseIcon: UIImage? {
        return image(named: "icon_float_close")
    }
    
    static var loadingIcon: UIImage? {
        return image(named: "icon_loading_default")
    }
    
    static var feedbackIcon: UIImage? {
        return image(named: "icon_menu_feedback")
    }
    
    static var privacyIcon: UIImage? {
        return image(named: "icon_menu_privacy")
    }
    
    static var reloadIcon: UIImage? {
        return image(named: "icon_menu_reload")
    }
    
    static var settingsIcon: UIImage? {
        return image(named: "icon_menu_settings")
    }
    
    static var shareIcon: UIImage? {
        return image(named: "icon_menu_share")
    }
    
    static var shortcutIcon: UIImage? {
        return image(named: "icon_menu_shortcut")
    }
    
    static var userAgreementIcon: UIImage? {
        return image(named: "icon_menu_user_agreement")
    }
    
    static var minimizationIcon: UIImage? {
        return image(named: "icon_minimization")
    }
    
    static var starIcon: UIImage? {
        return image(named: "icon_star")
    }
}
