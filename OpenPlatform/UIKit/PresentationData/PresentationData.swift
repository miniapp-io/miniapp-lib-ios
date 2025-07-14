import Foundation
import UIKit
import Contacts
import AddressBook
import MiniAppUIKit

internal struct PresentationDateTimeFormat: Equatable {
    public let timeFormat: PresentationTimeFormat
    public let dateFormat: PresentationDateFormat
    public let dateSeparator: String
    public let dateSuffix: String
    public let requiresFullYear: Bool
    public let decimalSeparator: String
    public let groupingSeparator: String
    
    public init() {
        self.timeFormat = .regular
        self.dateFormat = .monthFirst
        self.dateSeparator = "."
        self.dateSuffix = ""
        self.requiresFullYear = false
        self.decimalSeparator = "."
        self.groupingSeparator = "."
    }
    
    public init(timeFormat: PresentationTimeFormat, dateFormat: PresentationDateFormat, dateSeparator: String, dateSuffix: String, requiresFullYear: Bool, decimalSeparator: String, groupingSeparator: String) {
        self.timeFormat = timeFormat
        self.dateFormat = dateFormat
        self.dateSeparator = dateSeparator
        self.dateSuffix = dateSuffix
        self.requiresFullYear = requiresFullYear
        self.decimalSeparator = decimalSeparator
        self.groupingSeparator = groupingSeparator
    }
}

internal struct PresentationAppIcon: Equatable {
    public let name: String
    public let imageName: String
    public let isDefault: Bool
    public let isPremium: Bool
    
    public init(name: String, imageName: String, isDefault: Bool = false, isPremium: Bool = false) {
        self.name = name
        self.imageName = imageName
        self.isDefault = isDefault
        self.isPremium = isPremium
    }
}

internal enum PresentationTimeFormat {
    case regular
    case military
}

internal enum PresentationDateFormat {
    case monthFirst
    case dayFirst
}

internal struct PresentationChatBubbleCorners: Equatable, Hashable {
    public var mainRadius: CGFloat
    public var auxiliaryRadius: CGFloat
    public var mergeBubbleCorners: Bool
    
    public init(mainRadius: CGFloat, auxiliaryRadius: CGFloat, mergeBubbleCorners: Bool) {
        self.mainRadius = mainRadius
        self.auxiliaryRadius = auxiliaryRadius
        self.mergeBubbleCorners = mergeBubbleCorners
    }
}

internal final class PresentationData: Equatable {
    public let theme: PresentationTheme
    public let autoNightModeTriggered: Bool
    public let chatFontSize: PresentationFontSize
    public let chatBubbleCorners: PresentationChatBubbleCorners
    public let listsFontSize: PresentationFontSize
    public let dateTimeFormat: PresentationDateTimeFormat
    public let reduceMotion: Bool
    public let largeEmoji: Bool
    
    public init(theme: PresentationTheme, autoNightModeTriggered: Bool, chatFontSize: PresentationFontSize, chatBubbleCorners: PresentationChatBubbleCorners, listsFontSize: PresentationFontSize, dateTimeFormat: PresentationDateTimeFormat, reduceMotion: Bool, largeEmoji: Bool) {
        self.theme = theme
        self.autoNightModeTriggered = autoNightModeTriggered
        self.chatFontSize = chatFontSize
        self.chatBubbleCorners = chatBubbleCorners
        self.listsFontSize = listsFontSize
        self.dateTimeFormat = dateTimeFormat
        self.reduceMotion = reduceMotion
        self.largeEmoji = largeEmoji
    }
    
    public func withUpdated(theme: PresentationTheme) -> PresentationData {
        return PresentationData(theme: theme, autoNightModeTriggered: self.autoNightModeTriggered,chatFontSize: self.chatFontSize, chatBubbleCorners: self.chatBubbleCorners, listsFontSize: self.listsFontSize, dateTimeFormat: self.dateTimeFormat, reduceMotion: self.reduceMotion, largeEmoji: self.largeEmoji)
    }
    
    public func withUpdated() -> PresentationData {
        return PresentationData(theme: self.theme, autoNightModeTriggered: self.autoNightModeTriggered, chatFontSize: self.chatFontSize, chatBubbleCorners: self.chatBubbleCorners, listsFontSize: self.listsFontSize, dateTimeFormat: self.dateTimeFormat, reduceMotion: self.reduceMotion, largeEmoji: self.largeEmoji)
    }
    
    public static func ==(lhs: PresentationData, rhs: PresentationData) -> Bool {
        return lhs.theme === rhs.theme && lhs.autoNightModeTriggered == rhs.autoNightModeTriggered && lhs.chatFontSize == rhs.chatFontSize && lhs.chatBubbleCorners == rhs.chatBubbleCorners && lhs.listsFontSize == rhs.listsFontSize && lhs.dateTimeFormat == rhs.dateTimeFormat && lhs.reduceMotion == rhs.reduceMotion && lhs.largeEmoji == rhs.largeEmoji
    }
}

internal func dictFromLocalization(_ value: Localization) -> [String: String] {
    var dict: [String: String] = [:]
    for entry in value.entries {
        switch entry {
            case let .string(key, value):
                dict[key] = value
            case let .pluralizedString(key, zero, one, two, few, many, other):
                if let zero = zero {
                    dict["\(key)_zero"] = zero
                }
                if let one = one {
                    dict["\(key)_1"] = one
                }
                if let two = two {
                    dict["\(key)_2"] = two
                }
                if let few = few {
                    dict["\(key)_3_10"] = few
                }
                if let many = many {
                    dict["\(key)_many"] = many
                }
                dict["\(key)_any"] = other
        }
    }
    return dict
}

private func currentDateTimeFormat() -> PresentationDateTimeFormat {
    let locale = Locale.current
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    dateFormatter.timeZone = TimeZone.current
    let dateString = dateFormatter.string(from: Date())
    
    let timeFormat: PresentationTimeFormat
    if dateString.contains(dateFormatter.amSymbol) || dateString.contains(dateFormatter.pmSymbol) {
        timeFormat = .regular
    } else {
        timeFormat = .military
    }
    
    let dateFormat: PresentationDateFormat
    var dateSeparator = "/"
    var dateSuffix = ""
    var requiresFullYear = false
    if let dateString = DateFormatter.dateFormat(fromTemplate: "MdY", options: 0, locale: locale) {
        for separator in [". ", ".", "/", "-", "/"] {
            if dateString.contains(separator) {
                if separator == ". " {
                    dateSuffix = "."
                    dateSeparator = "."
                    requiresFullYear = true
                } else {
                    dateSeparator = separator
                }
                break
            }
        }
        if dateString.contains("M\(dateSeparator)d") {
            dateFormat = .monthFirst
        } else {
            dateFormat = .dayFirst
        }
    } else {
        dateFormat = .dayFirst
    }

    let decimalSeparator = locale.decimalSeparator ?? "."
    let groupingSeparator = locale.groupingSeparator ?? ""
    return PresentationDateTimeFormat(timeFormat: timeFormat, dateFormat: dateFormat, dateSeparator: dateSeparator, dateSuffix: dateSuffix, requiresFullYear: requiresFullYear, decimalSeparator: decimalSeparator, groupingSeparator: groupingSeparator)
}

internal final class InitialPresentationDataAndSettings {
    public let presentationData: PresentationData
    
    
    public init(presentationData: PresentationData) {
        self.presentationData = presentationData
    }
}

internal func currentPresentationDataAndSettings(queue: Queue, systemUserInterfaceStyle: WindowUserInterfaceStyle = WindowUserInterfaceStyle.light) -> Signal<InitialPresentationDataAndSettings, NoError> {
    
    return Signal { subscriber in
        queue.justDispatch {
            
            let themeSettings = PresentationThemeSettings(theme: .builtin(systemUserInterfaceStyle == .light ? .dayClassic : .night), themePreferredBaseTheme: [:], themeSpecificAccentColors: [:], useSystemFont: true, fontSize: .regular, listsFontSize: .regular, chatBubbleSettings: .default, automaticThemeSwitchSetting: AutomaticThemeSwitchSetting(force: false, trigger: .system, theme: .builtin(.night)), largeEmoji: true, reduceMotion: false)
            
            let effectiveTheme: PresentationThemeReference
            var preferredBaseTheme: TelegramBaseTheme?
            let parameters = AutomaticThemeSwitchParameters(settings: themeSettings.automaticThemeSwitchSetting)
            let autoNightModeTriggered: Bool
            if automaticThemeShouldSwitchNow(parameters, systemUserInterfaceStyle: systemUserInterfaceStyle) {
                effectiveTheme = themeSettings.automaticThemeSwitchSetting.theme
                autoNightModeTriggered = true
                
                if let baseTheme = themeSettings.themePreferredBaseTheme[effectiveTheme.index], [.night, .tinted].contains(baseTheme) {
                    preferredBaseTheme = baseTheme
                } else {
                    preferredBaseTheme = .night
                }
            } else {
                effectiveTheme = themeSettings.theme
                autoNightModeTriggered = false
                
                if let baseTheme = themeSettings.themePreferredBaseTheme[effectiveTheme.index], [.classic, .day].contains(baseTheme) {
                    preferredBaseTheme = baseTheme
                }
            }
            
            let effectiveColors = themeSettings.themeSpecificAccentColors[effectiveTheme.index]
            let theme = makePresentationTheme(themeReference: effectiveTheme, baseTheme: preferredBaseTheme, accentColor: effectiveColors?.colorFor(baseTheme: preferredBaseTheme ?? .day), bubbleColors: effectiveColors?.customBubbleColors ?? [], baseColor: effectiveColors?.baseColor) ?? defaultPresentationTheme
            
            let (chatFontSize, listsFontSize) = resolveFontSize(settings: themeSettings)
            
            let chatBubbleCorners = PresentationChatBubbleCorners(mainRadius: CGFloat(themeSettings.chatBubbleSettings.mainRadius), auxiliaryRadius: CGFloat(themeSettings.chatBubbleSettings.auxiliaryRadius), mergeBubbleCorners: themeSettings.chatBubbleSettings.mergeBubbleCorners)
            
            let dateTimeFormat = currentDateTimeFormat()
            
            let initData = InitialPresentationDataAndSettings(presentationData: PresentationData(theme: theme, autoNightModeTriggered: autoNightModeTriggered, chatFontSize: chatFontSize, chatBubbleCorners: chatBubbleCorners, listsFontSize: listsFontSize, dateTimeFormat: dateTimeFormat, reduceMotion: themeSettings.reduceMotion, largeEmoji: themeSettings.largeEmoji))
            
            subscriber.putNext(initData)
            subscriber.putCompletion()
        }
        return EmptyDisposable
    }
}

private var first = true

private func roundTimeToDay(_ timestamp: Int32) -> Int32 {
    let calendar = Calendar.current
    let offset = 0
    let components = calendar.dateComponents([.hour, .minute, .second], from: Date(timeIntervalSince1970: Double(timestamp + Int32(offset))))
    return Int32(components.hour! * 60 * 60 + components.minute! * 60 + components.second!)
}

private enum PreparedAutomaticThemeSwitchTrigger {
    case explicitNone
    case explicitForce
    case system
    case time(fromSeconds: Int32, toSeconds: Int32)
    case brightness(threshold: Double)
}

private struct AutomaticThemeSwitchParameters {
    let trigger: PreparedAutomaticThemeSwitchTrigger
    let theme: PresentationThemeReference
    
    init(settings: AutomaticThemeSwitchSetting) {
        let trigger: PreparedAutomaticThemeSwitchTrigger
        if settings.force {
            trigger = .explicitForce
        } else {
            switch settings.trigger {
                case .system:
                    trigger = .system
                case .explicitNone:
                    trigger = .explicitNone
                case let .timeBased(setting):
                    let fromValue: Int32
                    let toValue: Int32
                    switch setting {
                        case let .automatic(latitude, longitude, _):
                            let calculator = EDSunriseSet(date: Date(), timezone: TimeZone.current, latitude: latitude, longitude: longitude)!
                            fromValue = roundTimeToDay(Int32(calculator.sunset.timeIntervalSince1970))
                            toValue = roundTimeToDay(Int32(calculator.sunrise.timeIntervalSince1970))
                        case let .manual(fromSeconds, toSeconds):
                            fromValue = fromSeconds
                            toValue = toSeconds
                    }
                    trigger = .time(fromSeconds: fromValue, toSeconds: toValue)
                case let .brightness(threshold):
                    trigger = .brightness(threshold: threshold)
            }
        }
        self.trigger = trigger
        self.theme = settings.theme
    }
}

private func automaticThemeShouldSwitchNow(_ parameters: AutomaticThemeSwitchParameters, systemUserInterfaceStyle: WindowUserInterfaceStyle) -> Bool {
    switch parameters.trigger {
        case .explicitNone:
            return false
        case .explicitForce:
            return true
        case .system:
            return systemUserInterfaceStyle == .dark
        case let .time(fromValue, toValue):
            let roundedTimestamp = roundTimeToDay(Int32(Date().timeIntervalSince1970))
            if roundedTimestamp >= fromValue || roundedTimestamp <= toValue {
                return true
            } else {
                return false
            }
        case let .brightness(threshold):
            return UIScreen.main.brightness <= CGFloat(threshold)
    }
}

internal func automaticThemeShouldSwitchNow(settings: AutomaticThemeSwitchSetting, systemUserInterfaceStyle: WindowUserInterfaceStyle) -> Bool {
    let parameters = AutomaticThemeSwitchParameters(settings: settings)
    return automaticThemeShouldSwitchNow(parameters, systemUserInterfaceStyle: systemUserInterfaceStyle)
}

private func automaticThemeShouldSwitch(_ settings: AutomaticThemeSwitchSetting, systemUserInterfaceStyle: WindowUserInterfaceStyle) -> Signal<Bool, NoError> {
    if settings.force {
        return .single(true)
    } else if case .explicitNone = settings.trigger {
        return .single(false)
    } else {
        return Signal<Bool, NoError> { subscriber in
            let parameters = AutomaticThemeSwitchParameters(settings: settings)
            subscriber.putNext(automaticThemeShouldSwitchNow(parameters, systemUserInterfaceStyle: systemUserInterfaceStyle))
            
            let timer = SignalTimer(timeout: 1.0, repeat: true, completion: {
                subscriber.putNext(automaticThemeShouldSwitchNow(parameters, systemUserInterfaceStyle: systemUserInterfaceStyle))
            }, queue: Queue.mainQueue())
            timer.start()
            
            return ActionDisposable {
                timer.invalidate()
            }
        }
        |> runOn(Queue.mainQueue())
        |> distinctUntilChanged
    }
}

internal func averageColor(from image: UIImage) -> UIColor {
    let context = DrawingContext(size: CGSize(width: 1.0, height: 1.0), scale: 1.0, clear: false)!
    context.withFlippedContext({ context in
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        }
    })
    return context.colorAt(CGPoint())
}

internal func serviceColor(from image: Signal<UIImage?, NoError>) -> Signal<UIColor, NoError> {
    return image
    |> mapToSignal { image -> Signal<UIColor, NoError> in
        if let image = image {
            return .single(serviceColor(with: averageColor(from: image)))
        }
        return .complete()
    }
}

internal func serviceColor(with color: UIColor) -> UIColor {
    var hue:  CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        if saturation > 0.0 {
            saturation = min(1.0, saturation + 0.05 + 0.1 * (1.0 - saturation))
        }
        brightness = max(0.0, brightness * 0.65)
        alpha = 0.4
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    return color
}

private func resolveFontSize(settings: PresentationThemeSettings) -> (chat: PresentationFontSize, lists: PresentationFontSize) {
    let fontSize: PresentationFontSize
    let listsFontSize: PresentationFontSize
    if settings.useSystemFont {
        let pointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
        fontSize = PresentationFontSize(systemFontSize: pointSize)
        listsFontSize = fontSize
    } else {
        fontSize = settings.fontSize
        listsFontSize = settings.listsFontSize
    }
    return (fontSize, listsFontSize)
}
