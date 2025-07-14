import Foundation
import UIKit

private func decodeColor<Key>(_ values: KeyedDecodingContainer<Key>, _ key: Key, decoder: Decoder? = nil, fallbackKey: String? = nil) throws -> UIColor {
    if let decoder = decoder as? PresentationThemeDecoding, let fallbackKey = fallbackKey {
        var codingPath = decoder.codingPath.map { $0.stringValue }
        codingPath.append(key.stringValue)
        
        let key = codingPath.joined(separator: ".")
        decoder.fallbackKeys[key] = fallbackKey
    }
    
    let value = try values.decode(String.self, forKey: key)
    if value.lowercased() == "clear" {
        return UIColor.clear
    } else if let color = UIColor(hexString: value) {
        return color
    } else {
        throw PresentationThemeDecodingError.generic
    }
}

private func encodeColor<Key>(_ values: inout KeyedEncodingContainer<Key>, _ value: UIColor, _ key: Key) throws {
    if value == UIColor.clear {
        try values.encode("clear", forKey: key)
    } else if value.alpha < 1.0 {
        try values.encode(String(format: "%08x", value.argb), forKey: key)
    } else {
        try values.encode(String(format: "%06x", value.rgb), forKey: key)
    }
}

private func decodeColorList<Key>(_ values: KeyedDecodingContainer<Key>, _ key: Key) throws -> [UIColor] {
    let colorValues = try values.decode([String].self, forKey: key)

    var result: [UIColor] = []
    for value in colorValues {
        if value.lowercased() == "clear" {
            result.append(UIColor.clear)
        } else if let color = UIColor(hexString: value) {
            result.append(color)
        } else {
            throw PresentationThemeDecodingError.generic
        }
    }

    return result
}

private func encodeColorList<Key>(_ values: inout KeyedEncodingContainer<Key>, _ colors: [UIColor], _ key: Key) throws {
    var stringList: [String] = []
    for value in colors {
        if value == UIColor.clear {
            stringList.append("clear")
        } else if value.alpha < 1.0 {
            stringList.append(String(format: "%08x", value.argb))
        } else {
            stringList.append(String(format: "%06x", value.rgb))
        }
    }
    try values.encode(stringList, forKey: key)
}

extension PresentationThemeStatusBarStyle: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "black":
                    self = .black
                case "white":
                    self = .white
                default:
                    self = .black
            }
        } else {
            self = .black
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .black:
                try container.encode("black")
            case .white:
                try container.encode("white")
        }
    }
}

extension PresentationThemeActionSheetBackgroundType: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    self = .light
            }
        } else {
            self = .light
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .light:
                try container.encode("light")
            case .dark:
                try container.encode("dark")
        }
    }
}

extension PresentationThemeKeyboardColor: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    self = .light
            }
        } else {
            self = .light
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
            switch self {
                case .light:
                    try container.encode("light")
                case .dark:
                    try container.encode("dark")
        }
    }
}

extension PresentationThemeExpandedNotificationBackgroundType: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    self = .light
            }
        } else {
            self = .light
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .light:
                try container.encode("light")
            case .dark:
                try container.encode("dark")
        }
    }
}

extension PresentationThemeGradientColors: Codable {
    enum CodingKeys: String, CodingKey {
        case top
        case bottom
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(topColor: try decodeColor(values, .top),
                  bottomColor: try decodeColor(values, .bottom))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.topColor, .top)
        try encodeColor(&values, self.bottomColor, .bottom)
    }
}

extension PresentationThemeIntro: Codable {
    enum CodingKeys: String, CodingKey {
        case statusBar
        case primaryText
        case accentText
        case disabledText
        case startButton
        case dot
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(statusBarStyle: try values.decode(PresentationThemeStatusBarStyle.self, forKey: .statusBar),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  accentTextColor: try decodeColor(values, .accentText),
                  disabledTextColor: try decodeColor(values, .disabledText),
                  startButtonColor: try decodeColor(values, .startButton),
                  dotColor: try decodeColor(values, .dot))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.statusBarStyle, forKey: .statusBar)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.accentTextColor, .accentText)
        try encodeColor(&values, self.disabledTextColor, .disabledText)
        try encodeColor(&values, self.startButtonColor, .startButton)
        try encodeColor(&values, self.dotColor, .dot)
    }
}

extension PresentationThemePasscode: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case button
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColors: try values.decode(PresentationThemeGradientColors.self, forKey: .bg),
                  buttonColor: try decodeColor(values, .button))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundColors, forKey: .bg)
        try encodeColor(&values, self.buttonColor, .button)
    }
}

extension PresentationThemeRootTabBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case separator
        case icon
        case selectedIcon
        case text
        case selectedText
        case badgeBackground
        case badgeStroke
        case badgeText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  separatorColor: try decodeColor(values, .separator),
                  iconColor: try decodeColor(values, .icon),
                  selectedIconColor: try decodeColor(values, .selectedIcon),
                  textColor: try decodeColor(values, .text),
                  selectedTextColor: try decodeColor(values, .selectedText),
                  badgeBackgroundColor: try decodeColor(values, .badgeBackground),
                  badgeStrokeColor: try decodeColor(values, .badgeStroke),
                  badgeTextColor: try decodeColor(values, .badgeText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.separatorColor, .separator)
        try encodeColor(&values, self.iconColor, .icon)
        try encodeColor(&values, self.selectedIconColor, .selectedIcon)
        try encodeColor(&values, self.textColor, .text)
        try encodeColor(&values, self.selectedTextColor, .selectedText)
        try encodeColor(&values, self.badgeBackgroundColor, .badgeBackground)
        try encodeColor(&values, self.badgeStrokeColor, .badgeStroke)
        try encodeColor(&values, self.badgeTextColor, .badgeText)
    }
}

extension PresentationThemeRootNavigationBar: Codable {
    enum CodingKeys: String, CodingKey {
        case button
        case disabledButton
        case primaryText
        case secondaryText
        case control
        case accentText
        case background
        case separator
        case badgeFill
        case badgeStroke
        case badgeText
        case segmentedBg
        case segmentedFg
        case segmentedText
        case segmentedDivider
        case clearButtonBackground
        case clearButtonForeground
        case opaqueBackground
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let blurredBackgroundColor = try decodeColor(values, .background)

        let opaqueBackgroundColor: UIColor
        if blurredBackgroundColor.alpha >= 0.99 {
            opaqueBackgroundColor = blurredBackgroundColor
        } else {
            opaqueBackgroundColor = (try? decodeColor(values, .opaqueBackground)) ?? blurredBackgroundColor
        }

        self.init(
            buttonColor: try decodeColor(values, .button),
            disabledButtonColor: try decodeColor(values, .disabledButton),
            primaryTextColor: try decodeColor(values, .primaryText),
            secondaryTextColor: try decodeColor(values, .secondaryText),
            controlColor: try decodeColor(values, .control),
            accentTextColor: try decodeColor(values, .accentText),
            blurredBackgroundColor: blurredBackgroundColor,
            opaqueBackgroundColor: opaqueBackgroundColor,
            separatorColor: try decodeColor(values, .separator),
            badgeBackgroundColor: try decodeColor(values, .badgeFill),
            badgeStrokeColor: try decodeColor(values, .badgeStroke),
            badgeTextColor: try decodeColor(values, .badgeText),
            segmentedBackgroundColor: try decodeColor(values, .segmentedBg, decoder: decoder, fallbackKey: "root.searchBar.inputFill"),
            segmentedForegroundColor: try decodeColor(values, .segmentedFg, decoder: decoder, fallbackKey: "root.navBar.background"),
            segmentedTextColor: try decodeColor(values, .segmentedText, decoder: decoder, fallbackKey: "root.navBar.primaryText"),
            segmentedDividerColor: try decodeColor(values, .segmentedDivider, decoder: decoder, fallbackKey: "list.freeInputField.stroke"),
            clearButtonBackgroundColor: try decodeColor(values, .clearButtonBackground, decoder: decoder, fallbackKey: "list.freeInputField.bg"),
            clearButtonForegroundColor: try decodeColor(values, .clearButtonForeground, decoder: decoder, fallbackKey: "list.freeInputField.primary")
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.buttonColor, .button)
        try encodeColor(&values, self.disabledButtonColor, .disabledButton)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.controlColor, .control)
        try encodeColor(&values, self.accentTextColor, .accentText)
        try encodeColor(&values, self.blurredBackgroundColor, .background)
        try encodeColor(&values, self.opaqueBackgroundColor, .opaqueBackground)
        try encodeColor(&values, self.separatorColor, .separator)
        try encodeColor(&values, self.badgeBackgroundColor, .badgeFill)
        try encodeColor(&values, self.badgeStrokeColor, .badgeStroke)
        try encodeColor(&values, self.badgeTextColor, .badgeText)
        try encodeColor(&values, self.segmentedBackgroundColor, .segmentedBg)
        try encodeColor(&values, self.segmentedForegroundColor, .segmentedFg)
        try encodeColor(&values, self.segmentedTextColor, .segmentedText)
        try encodeColor(&values, self.segmentedDividerColor, .segmentedDivider)
    }
}

extension PresentationThemeNavigationSearchBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case accent
        case inputFill
        case inputText
        case inputPlaceholderText
        case inputIcon
        case inputClearButton
        case separator
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  accentColor: try decodeColor(values, .accent),
                  inputFillColor: try decodeColor(values, .inputFill),
                  inputTextColor: try decodeColor(values, .inputText),
                  inputPlaceholderTextColor: try decodeColor(values, .inputPlaceholderText),
                  inputIconColor: try decodeColor(values, .inputIcon),
                  inputClearButtonColor: try decodeColor(values, .inputClearButton),
                  separatorColor: try decodeColor(values, .separator))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.accentColor, .accent)
        try encodeColor(&values, self.inputFillColor, .inputFill)
        try encodeColor(&values, self.inputTextColor, .inputText)
        try encodeColor(&values, self.inputPlaceholderTextColor, .inputPlaceholderText)
        try encodeColor(&values, self.inputIconColor, .inputIcon)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
        try encodeColor(&values, self.separatorColor, .separator)
    }
}

extension PresentationThemeRootController: Codable {
    enum CodingKeys: String, CodingKey {
        case statusBar
        case tabBar
        case navBar
        case searchBar
        case keyboard
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(statusBarStyle: try values.decode(PresentationThemeStatusBarStyle.self, forKey: .statusBar),
                  tabBar: try values.decode(PresentationThemeRootTabBar.self, forKey: .tabBar),
                  navigationBar: try values.decode(PresentationThemeRootNavigationBar.self, forKey: .navBar),
                  navigationSearchBar: try values.decode(PresentationThemeNavigationSearchBar.self, forKey: .searchBar),
                  keyboardColor: try values.decode(PresentationThemeKeyboardColor.self, forKey: .keyboard))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.statusBarStyle, forKey: .statusBar)
        try values.encode(self.tabBar, forKey: .tabBar)
        try values.encode(self.navigationBar, forKey: .navBar)
        try values.encode(self.navigationSearchBar, forKey: .searchBar)
        try values.encode(self.keyboardColor, forKey: .keyboard)
    }
}

extension PresentationThemeActionSheet: Codable {
    enum CodingKeys: String, CodingKey {
        case dim
        case bgType
        case opaqueItemBg
        case itemBg
        case opaqueItemHighlightedBg
        case itemHighlightedBg
        case opaqueItemSeparator
        case standardActionText
        case destructiveActionText
        case disabledActionText
        case primaryText
        case secondaryText
        case controlAccent
        case inputBg
        case inputHollowBg
        case inputBorder
        case inputPlaceholder
        case inputText
        case inputClearButton
        case checkContent
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(dimColor: try decodeColor(values, .dim),
                  backgroundType: try values.decode(PresentationThemeActionSheetBackgroundType.self, forKey: .bgType),
                  opaqueItemBackgroundColor: try decodeColor(values, .opaqueItemBg),
                  itemBackgroundColor: try decodeColor(values, .itemBg),
                  opaqueItemHighlightedBackgroundColor: try decodeColor(values, .opaqueItemHighlightedBg),
                  itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
                  opaqueItemSeparatorColor: try decodeColor(values, .opaqueItemSeparator),
                  standardActionTextColor: try decodeColor(values, .standardActionText),
                  destructiveActionTextColor: try decodeColor(values, .destructiveActionText),
                  disabledActionTextColor: try decodeColor(values, .disabledActionText),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  secondaryTextColor: try decodeColor(values, .secondaryText),
                  controlAccentColor: try decodeColor(values, .controlAccent),
                  inputBackgroundColor: try decodeColor(values, .inputBg),
                  inputHollowBackgroundColor: try decodeColor(values, .inputHollowBg),
                  inputBorderColor: try decodeColor(values, .inputBorder),
                  inputPlaceholderColor: try decodeColor(values, .inputPlaceholder),
                  inputTextColor: try decodeColor(values, .inputText),
                  inputClearButtonColor: try decodeColor(values, .inputClearButton),
                  checkContentColor: try decodeColor(values, .checkContent))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.dimColor, .dim)
        try values.encode(self.backgroundType, forKey: .bgType)
        try encodeColor(&values, self.opaqueItemBackgroundColor, .opaqueItemBg)
        try encodeColor(&values, self.itemBackgroundColor, .itemBg)
        try encodeColor(&values, self.opaqueItemHighlightedBackgroundColor, .opaqueItemHighlightedBg)
        try encodeColor(&values, self.itemHighlightedBackgroundColor, .itemHighlightedBg)
        try encodeColor(&values, self.opaqueItemSeparatorColor, .opaqueItemSeparator)
        try encodeColor(&values, self.standardActionTextColor, .standardActionText)
        try encodeColor(&values, self.destructiveActionTextColor, .destructiveActionText)
        try encodeColor(&values, self.disabledActionTextColor, .disabledActionText)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.controlAccentColor, .controlAccent)
        try encodeColor(&values, self.inputBackgroundColor, .inputBg)
        try encodeColor(&values, self.inputHollowBackgroundColor, .inputHollowBg)
        try encodeColor(&values, self.inputBorderColor, .inputBorder)
        try encodeColor(&values, self.inputPlaceholderColor, .inputPlaceholder)
        try encodeColor(&values, self.inputTextColor, .inputText)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
        try encodeColor(&values, self.checkContentColor, .checkContent)
    }
}

extension PresentationThemeSwitch: Codable {
    enum CodingKeys: String, CodingKey {
        case frame
        case handle
        case content
        case positive
        case negative
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(frameColor: try decodeColor(values, .frame),
                  handleColor: try decodeColor(values, .handle),
                  contentColor: try decodeColor(values, .content),
                  positiveColor: try decodeColor(values, .positive),
                  negativeColor: try decodeColor(values, .negative))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.frameColor, .frame)
        try encodeColor(&values, self.handleColor, .handle)
        try encodeColor(&values, self.contentColor, .content)
        try encodeColor(&values, self.positiveColor, .positive)
        try encodeColor(&values, self.negativeColor, .negative)
    }
}

extension PresentationThemeFillForeground: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case fg
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  foregroundColor: try decodeColor(values, .fg))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.foregroundColor, .fg)
    }
}

extension PresentationThemeItemDisclosureActions: Codable {
    enum CodingKeys: String, CodingKey {
        case neutral1
        case neutral2
        case destructive
        case constructive
        case accent
        case warning
        case inactive
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(neutral1: try values.decode(PresentationThemeFillForeground.self, forKey: .neutral1),
                  neutral2: try values.decode(PresentationThemeFillForeground.self, forKey: .neutral2),
                  destructive: try values.decode(PresentationThemeFillForeground.self, forKey: .destructive),
                  constructive: try values.decode(PresentationThemeFillForeground.self, forKey: .constructive),
                  accent: try values.decode(PresentationThemeFillForeground.self, forKey: .accent),
                  warning: try values.decode(PresentationThemeFillForeground.self, forKey: .warning),
                  inactive: try values.decode(PresentationThemeFillForeground.self, forKey: .inactive))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.neutral1, forKey: .neutral1)
        try values.encode(self.neutral2, forKey: .neutral2)
        try values.encode(self.destructive, forKey: .destructive)
        try values.encode(self.constructive, forKey: .constructive)
        try values.encode(self.accent, forKey: .accent)
        try values.encode(self.warning, forKey: .warning)
        try values.encode(self.inactive, forKey: .inactive)
    }
}


extension PresentationThemeItemBarChart: Codable {
    enum CodingKeys: String, CodingKey {
        case color1
        case color2
        case color3
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(color1: try decodeColor(values, .color1),
                  color2: try decodeColor(values, .color2),
                  color3: try decodeColor(values, .color3))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
         try encodeColor(&values, self.color1, .color1)
         try encodeColor(&values, self.color2, .color2)
         try encodeColor(&values, self.color3, .color3)
    }
}

extension PresentationThemeFillStrokeForeground: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case stroke
        case fg
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  strokeColor: try decodeColor(values, .stroke),
                  foregroundColor: try decodeColor(values, .fg))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.strokeColor, .stroke)
        try encodeColor(&values, self.foregroundColor, .fg)
    }
}

extension PresentationInputFieldTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case stroke
        case placeholder
        case primary
        case control
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .bg),
                  strokeColor: try decodeColor(values, .stroke),
                  placeholderColor: try decodeColor(values, .placeholder),
                  primaryColor: try decodeColor(values, .primary),
                  controlColor: try decodeColor(values, .control))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .bg)
        try encodeColor(&values, self.strokeColor, .stroke)
        try encodeColor(&values, self.placeholderColor, .placeholder)
        try encodeColor(&values, self.primaryColor, .primary)
        try encodeColor(&values, self.controlColor, .control)
    }
}

extension PresentationThemeList.PaymentOption: Codable {
    enum CodingKeys: String, CodingKey {
        case inactiveFill
        case inactiveForeground
        case activeFill
        case activeForeground
    }

    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            inactiveFillColor: try decodeColor(values, .inactiveFill),
            inactiveForegroundColor: try decodeColor(values, .inactiveForeground),
            activeFillColor: try decodeColor(values, .activeFill),
            activeForegroundColor: try decodeColor(values, .activeForeground)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.activeFillColor, .inactiveFill)
        try encodeColor(&values, self.activeForegroundColor, .inactiveForeground)
        try encodeColor(&values, self.activeFillColor, .activeFill)
        try encodeColor(&values, self.activeForegroundColor, .activeForeground)
    }
}

extension PresentationThemeList: Codable {
    enum CodingKeys: String, CodingKey {
        case blocksBg
        case modalBlocksBg
        case plainBg
        case modalPlainBg
        case primaryText
        case secondaryText
        case disabledText
        case accent
        case highlighted
        case destructive
        case placeholderText
        case itemBlocksBg
        case itemModalBlocksBg
        case itemHighlightedBg
        case blocksSeparator
        case plainSeparator
        case disclosureArrow
        case sectionHeaderText
        case freeText
        case freeTextError
        case freeTextSuccess
        case freeMonoIcon
        case `switch`
        case disclosureActions
        case check
        case controlSecondary
        case freeInputField
        case freePlainInputField
        case mediaPlaceholder
        case scrollIndicator
        case pageIndicatorInactive
        case inputClearButton
        case itemBarChart
        case itemInputField
        case paymentOption
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let freePlainInputField: PresentationInputFieldTheme
        if let value = try? values.decode(PresentationInputFieldTheme.self, forKey: .freePlainInputField) {
            freePlainInputField = value
        } else {
            freePlainInputField = try values.decode(PresentationInputFieldTheme.self, forKey: .freeInputField)
        }

        let freeTextSuccessColor = try decodeColor(values, .freeTextSuccess)
        
        self.init(
            blocksBackgroundColor: try decodeColor(values, .blocksBg),
            modalBlocksBackgroundColor: try decodeColor(values, .modalBlocksBg, decoder: decoder, fallbackKey: "list.blocksBg"),
            plainBackgroundColor: try decodeColor(values, .plainBg),
            modalPlainBackgroundColor: try decodeColor(values, .modalPlainBg, decoder: decoder, fallbackKey: "list.plainBg"),
            itemPrimaryTextColor: try decodeColor(values, .primaryText),
            itemSecondaryTextColor: try decodeColor(values, .secondaryText),
            itemDisabledTextColor: try decodeColor(values, .disabledText),
            itemAccentColor: try decodeColor(values, .accent),
            itemHighlightedColor: try decodeColor(values, .highlighted),
            itemDestructiveColor: try decodeColor(values, .destructive),
            itemPlaceholderTextColor: try decodeColor(values, .placeholderText),
            itemBlocksBackgroundColor: try decodeColor(values, .itemBlocksBg),
            itemModalBlocksBackgroundColor: try decodeColor(values, .itemModalBlocksBg, decoder: decoder, fallbackKey: "list.itemBlocksBg"),
            itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
            itemBlocksSeparatorColor: try decodeColor(values, .blocksSeparator),
            itemPlainSeparatorColor: try decodeColor(values, .plainSeparator),
            disclosureArrowColor: try decodeColor(values, .disclosureArrow),
            sectionHeaderTextColor: try decodeColor(values, .sectionHeaderText),
            freeTextColor: try decodeColor(values, .freeText),
            freeTextErrorColor: try decodeColor(values, .freeTextError),
            freeTextSuccessColor: freeTextSuccessColor,
            freeMonoIconColor: try decodeColor(values, .freeMonoIcon),
            itemSwitchColors: try values.decode(PresentationThemeSwitch.self, forKey: .switch),
            itemDisclosureActions: try values.decode(PresentationThemeItemDisclosureActions.self, forKey: .disclosureActions),
            itemCheckColors: try values.decode(PresentationThemeFillStrokeForeground.self, forKey: .check),
            controlSecondaryColor: try decodeColor(values, .controlSecondary),
            freeInputField: try values.decode(PresentationInputFieldTheme.self, forKey: .freeInputField),
            freePlainInputField: freePlainInputField,
            mediaPlaceholderColor: try decodeColor(values, .mediaPlaceholder),
            scrollIndicatorColor: try decodeColor(values, .scrollIndicator),
            pageIndicatorInactiveColor: try decodeColor(values, .pageIndicatorInactive),
            inputClearButtonColor: try decodeColor(values, .inputClearButton),
            itemBarChart: try values.decode(PresentationThemeItemBarChart.self, forKey: .itemBarChart),
            itemInputField: try values.decode(PresentationInputFieldTheme.self, forKey: .itemInputField),
            paymentOption: (try? values.decode(PresentationThemeList.PaymentOption.self, forKey: .paymentOption)) ?? PresentationThemeList.PaymentOption(
                inactiveFillColor: freeTextSuccessColor.withMultipliedAlpha(0.3),
                inactiveForegroundColor: freeTextSuccessColor,
                activeFillColor: freeTextSuccessColor,
                activeForegroundColor: UIColor(rgb: 0xffffff)
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.blocksBackgroundColor, .blocksBg)
        try encodeColor(&values, self.plainBackgroundColor, .plainBg)
        try encodeColor(&values, self.itemPrimaryTextColor, .primaryText)
        try encodeColor(&values, self.itemSecondaryTextColor, .secondaryText)
        try encodeColor(&values, self.itemDisabledTextColor, .disabledText)
        try encodeColor(&values, self.itemAccentColor, .accent)
        try encodeColor(&values, self.itemHighlightedColor, .highlighted)
        try encodeColor(&values, self.itemDestructiveColor, .destructive)
        try encodeColor(&values, self.itemPlaceholderTextColor, .placeholderText)
        try encodeColor(&values, self.itemBlocksBackgroundColor, .itemBlocksBg)
        try encodeColor(&values, self.itemHighlightedBackgroundColor, .itemHighlightedBg)
        try encodeColor(&values, self.itemBlocksSeparatorColor, .blocksSeparator)
        try encodeColor(&values, self.itemPlainSeparatorColor, .plainSeparator)
        try encodeColor(&values, self.disclosureArrowColor, .disclosureArrow)
        try encodeColor(&values, self.sectionHeaderTextColor, .sectionHeaderText)
        try encodeColor(&values, self.freeTextColor, .freeText)
        try encodeColor(&values, self.freeTextErrorColor, .freeTextError)
        try encodeColor(&values, self.freeTextSuccessColor, .freeTextSuccess)
        try encodeColor(&values, self.freeMonoIconColor, .freeMonoIcon)
        try values.encode(self.itemSwitchColors, forKey: .`switch`)
        try values.encode(self.itemDisclosureActions, forKey: .disclosureActions)
        try values.encode(self.itemCheckColors, forKey: .check)
        try encodeColor(&values, self.controlSecondaryColor, .controlSecondary)
        try values.encode(self.freeInputField, forKey: .freeInputField)
        try encodeColor(&values, self.mediaPlaceholderColor, .mediaPlaceholder)
        try encodeColor(&values, self.scrollIndicatorColor, .scrollIndicator)
        try encodeColor(&values, self.pageIndicatorInactiveColor, .pageIndicatorInactive)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
        try values.encode(self.itemBarChart, forKey: .itemBarChart)
        try values.encode(self.itemInputField, forKey: .itemInputField)
    }
}

extension PresentationThemeArchiveAvatarColors: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case foreground
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColors: try values.decode(PresentationThemeGradientColors.self, forKey: .background),
                  foregroundColor: try decodeColor(values, .foreground))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundColors, forKey: .background)
        try encodeColor(&values, self.foregroundColor, .foreground)
    }
}

extension PresentationThemeVariableColor: Codable {
    enum CodingKeys: String, CodingKey {
        case withWp
        case withoutWp
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(withWallpaper: try decodeColor(values, .withWp),
                  withoutWallpaper: try decodeColor(values, .withoutWp))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.withWallpaper, .withWp)
        try encodeColor(&values, self.withoutWallpaper, .withoutWp)
    }
}


extension PresentationThemePartedColors: Codable {
    enum CodingKeys: String, CodingKey {
        case bubble
        case primaryText
        case secondaryText
        case linkText
        case linkHighlight
        case scam
        case textHighlight
        case accentText
        case accentControl
        case mediaActiveControl
        case mediaInactiveControl
        case mediaControlInnerBg
        case pendingActivity
        case fileTitle
        case fileDescription
        case fileDuration
        case mediaPlaceholder
        case polls
        case actionButtonsBg
        case actionButtonsStroke
        case actionButtonsText
        case textSelection
        case textSelectionKnob
        case accentControlDisabled
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let codingPath = decoder.codingPath.map { $0.stringValue }.joined(separator: ".")
        let accentControlColor = try decodeColor(values, .accentControl)
        self.init(
            primaryTextColor: try decodeColor(values, .primaryText),
            secondaryTextColor: try decodeColor(values, .secondaryText),
            linkTextColor: try decodeColor(values, .linkText),
            linkHighlightColor: try decodeColor(values, .linkHighlight),
            scamColor: try decodeColor(values, .scam),
            textHighlightColor: try decodeColor(values, .textHighlight),
            accentTextColor: try decodeColor(values, .accentText),
            accentControlColor: accentControlColor,
            accentControlDisabledColor: (try? decodeColor(values, .accentControlDisabled)) ?? accentControlColor.withAlphaComponent(0.5),
            mediaActiveControlColor: try decodeColor(values, .mediaActiveControl),
            mediaInactiveControlColor: try decodeColor(values, .mediaInactiveControl),
            mediaControlInnerBackgroundColor: try decodeColor(values, .mediaControlInnerBg, decoder: decoder, fallbackKey: "\(codingPath).bubble.withWp.bg"),
            pendingActivityColor: try decodeColor(values, .pendingActivity),
            fileTitleColor: try decodeColor(values, .fileTitle),
            fileDescriptionColor: try decodeColor(values, .fileDescription),
            fileDurationColor: try decodeColor(values, .fileDuration),
            mediaPlaceholderColor: try decodeColor(values, .mediaPlaceholder),
            actionButtonsFillColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsBg),
            actionButtonsStrokeColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsStroke),
            actionButtonsTextColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsText),
            textSelectionColor: try decodeColor(values, .textSelection),
            textSelectionKnobColor: try decodeColor(values, .textSelectionKnob)
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.linkTextColor, .linkText)
        try encodeColor(&values, self.linkHighlightColor, .linkHighlight)
        try encodeColor(&values, self.scamColor, .scam)
        try encodeColor(&values, self.textHighlightColor, .textHighlight)
        try encodeColor(&values, self.accentTextColor, .accentText)
        try encodeColor(&values, self.accentControlColor, .accentControl)
        try encodeColor(&values, self.mediaActiveControlColor, .mediaActiveControl)
        try encodeColor(&values, self.mediaInactiveControlColor, .mediaInactiveControl)
        try encodeColor(&values, self.mediaControlInnerBackgroundColor, .mediaControlInnerBg)
        try encodeColor(&values, self.pendingActivityColor, .pendingActivity)
        try encodeColor(&values, self.fileTitleColor, .fileTitle)
        try encodeColor(&values, self.fileDescriptionColor, .fileDescription)
        try encodeColor(&values, self.fileDurationColor, .fileDuration)
        try encodeColor(&values, self.mediaPlaceholderColor, .mediaPlaceholder)
        try values.encode(self.actionButtonsFillColor, forKey: .actionButtonsBg)
        try values.encode(self.actionButtonsStrokeColor, forKey: .actionButtonsStroke)
        try values.encode(self.actionButtonsTextColor, forKey: .actionButtonsText)
        try encodeColor(&values, self.textSelectionColor, .textSelection)
        try encodeColor(&values, self.textSelectionKnobColor, .textSelectionKnob)
    }
}

extension PresentationThemeServiceMessageColorComponents: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case primaryText
        case linkHighlight
        case scam
        case dateFillStatic
        case dateFillFloat
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fill: try decodeColor(values, .bg),
                  primaryText: try decodeColor(values, .primaryText),
                  linkHighlight: try decodeColor(values, .linkHighlight),
                  scam: try decodeColor(values, .scam),
                  dateFillStatic: try decodeColor(values, .dateFillStatic),
                  dateFillFloating: try decodeColor(values, .dateFillFloat))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fill, .bg)
        try encodeColor(&values, self.primaryText, .primaryText)
        try encodeColor(&values, self.linkHighlight, .linkHighlight)
        try encodeColor(&values, self.scam, .scam)
        try encodeColor(&values, self.dateFillStatic, .dateFillStatic)
        try encodeColor(&values, self.dateFillFloating, .dateFillFloat)
    }
}

extension PresentationThemeInputMediaPanel: Codable {
    enum CodingKeys: String, CodingKey {
        case panelSeparator
        case panelIcon
        case panelHighlightedIconBg
        case panelHighlightedIcon
        case panelContentVibrantOverlay
        case panelContentControlVibrantOverlay
        case panelContentControlVibrantSelection
        case panelContentControlOpaqueOverlay
        case panelContentControlOpaqueSelection
        case stickersBg
        case stickersSectionText
        case stickersSearchBg
        case stickersSearchPlaceholder
        case stickersSearchPrimary
        case stickersSearchControl
        case gifsBg
        case bg
        case panelContentVibrantSearchOverlay
        case panelContentVibrantSearchOverlaySelected
        case panelContentVibrantSearchOverlayHighlight
        case panelContentOpaqueSearchOverlay
        case panelContentOpaqueSearchOverlaySelected
        case panelContentOpaqueSearchOverlayHighlight
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let backgroundColor: UIColor
        if let value = try? decodeColor(values, .bg) {
            backgroundColor = value
        } else {
            backgroundColor = try decodeColor(values, .gifsBg).withMultipliedAlpha(0.75)
        }
        
        let panelHighlightedIconColor: UIColor
        if let value = try? decodeColor(values, .panelHighlightedIcon) {
            panelHighlightedIconColor = value
        } else if let value = try? decodeColor(values, .panelHighlightedIcon, fallbackKey: "chat.inputPanel.inputText") {
            let defaultColor = try decodeColor(values, .panelIcon)
            panelHighlightedIconColor = defaultColor.mixedWith(value, alpha: 0.35)
        } else {
            panelHighlightedIconColor = try decodeColor(values, .panelIcon)
        }
        
        let codingPath = decoder.codingPath.map { $0.stringValue }.joined(separator: ".")
        
        self.init(panelSeparatorColor: try decodeColor(values, .panelSeparator),
                  panelIconColor: try decodeColor(values, .panelIcon),
                  panelHighlightedIconBackgroundColor: try decodeColor(values, .panelHighlightedIconBg),
                  panelHighlightedIconColor: panelHighlightedIconColor,
                  panelContentVibrantOverlayColor: try decodeColor(values, .panelContentVibrantOverlay, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentControlVibrantOverlayColor: try decodeColor(values, .panelContentControlVibrantOverlay, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentControlVibrantSelectionColor: try decodeColor(values, .panelContentControlVibrantSelection, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentControlOpaqueOverlayColor: try decodeColor(values, .panelContentControlOpaqueOverlay, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentControlOpaqueSelectionColor: try decodeColor(values, .panelContentControlOpaqueSelection, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentVibrantSearchOverlayColor: try decodeColor(values, .panelContentVibrantSearchOverlay, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentVibrantSearchOverlaySelectedColor: try decodeColor(values, .panelContentVibrantSearchOverlaySelected, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentVibrantSearchOverlayHighlightColor: try decodeColor(values, .panelContentVibrantSearchOverlayHighlight, fallbackKey: "\(codingPath).panelHighlightedIconBg"),
                  panelContentOpaqueSearchOverlayColor: try decodeColor(values, .panelContentOpaqueSearchOverlay, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentOpaqueSearchOverlaySelectedColor: try decodeColor(values, .panelContentOpaqueSearchOverlaySelected, fallbackKey: "\(codingPath).stickersSectionText"),
                  panelContentOpaqueSearchOverlayHighlightColor: try decodeColor(values, .panelContentOpaqueSearchOverlayHighlight, fallbackKey: "\(codingPath).panelHighlightedIconBg"),
                  stickersBackgroundColor: try decodeColor(values, .stickersBg),
                  stickersSectionTextColor: try decodeColor(values, .stickersSectionText),
                  stickersSearchBackgroundColor: try decodeColor(values, .stickersSearchBg),
                  stickersSearchPlaceholderColor: try decodeColor(values, .stickersSearchPlaceholder),
                  stickersSearchPrimaryColor: try decodeColor(values, .stickersSearchPrimary),
                  stickersSearchControlColor: try decodeColor(values, .stickersSearchControl),
                  gifsBackgroundColor: try decodeColor(values, .gifsBg), backgroundColor: backgroundColor)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.panelSeparatorColor, .panelSeparator)
        try encodeColor(&values, self.panelIconColor, .panelIcon)
        try encodeColor(&values, self.panelHighlightedIconBackgroundColor, .panelHighlightedIconBg)
        try encodeColor(&values, self.panelHighlightedIconColor, .panelHighlightedIcon)
        try encodeColor(&values, self.panelContentVibrantOverlayColor, .panelContentVibrantOverlay)
        try encodeColor(&values, self.panelContentControlVibrantOverlayColor, .panelContentControlVibrantOverlay)
        try encodeColor(&values, self.panelContentControlVibrantSelectionColor, .panelContentControlVibrantSelection)
        try encodeColor(&values, self.panelContentControlOpaqueOverlayColor, .panelContentControlOpaqueOverlay)
        try encodeColor(&values, self.panelContentControlOpaqueSelectionColor, .panelContentControlOpaqueSelection)
        
        try encodeColor(&values, self.panelContentVibrantSearchOverlayColor, .panelContentVibrantSearchOverlay)
        try encodeColor(&values, self.panelContentVibrantSearchOverlaySelectedColor, .panelContentVibrantSearchOverlaySelected)
        try encodeColor(&values, self.panelContentVibrantSearchOverlayHighlightColor, .panelContentVibrantSearchOverlayHighlight)
        try encodeColor(&values, self.panelContentOpaqueSearchOverlayColor, .panelContentOpaqueSearchOverlay)
        try encodeColor(&values, self.panelContentOpaqueSearchOverlaySelectedColor, .panelContentOpaqueSearchOverlaySelected)
        try encodeColor(&values, self.panelContentOpaqueSearchOverlayHighlightColor, .panelContentOpaqueSearchOverlayHighlight)
        
        try encodeColor(&values, self.stickersBackgroundColor, .stickersBg)
        try encodeColor(&values, self.stickersSectionTextColor, .stickersSectionText)
        try encodeColor(&values, self.stickersSearchBackgroundColor, .stickersSearchBg)
        try encodeColor(&values, self.stickersSearchPlaceholderColor, .stickersSearchPlaceholder)
        try encodeColor(&values, self.stickersSearchPrimaryColor, .stickersSearchPrimary)
        try encodeColor(&values, self.stickersSearchControlColor, .stickersSearchControl)
        try encodeColor(&values, self.gifsBackgroundColor, .gifsBg)
        try encodeColor(&values, self.backgroundColor, .bg)
    }
}

extension PresentationThemeInputButtonPanel: Codable {
    enum CodingKeys: String, CodingKey {
        case panelBg
        case panelSeparator
        case buttonBg
        case buttonHighlight
        case buttonStroke
        case buttonHighlightedBg
        case buttonHighlightedStroke
        case buttonText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(panelSeparatorColor: try decodeColor(values, .panelSeparator),
                  panelBackgroundColor: try decodeColor(values, .panelBg),
                  buttonFillColor: try decodeColor(values, .buttonBg),
                  buttonHighlightColor: try decodeColor(values, .buttonHighlight),
                  buttonStrokeColor: try decodeColor(values, .buttonStroke),
                  buttonHighlightedFillColor: try decodeColor(values, .buttonHighlightedBg),
                  buttonHighlightedStrokeColor: try decodeColor(values, .buttonHighlightedStroke),
                  buttonTextColor: try decodeColor(values, .buttonText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.panelBackgroundColor, .panelBg)
        try encodeColor(&values, self.panelSeparatorColor, .panelSeparator)
        try encodeColor(&values, self.buttonFillColor, .buttonBg)
        try encodeColor(&values, self.buttonHighlightColor, .buttonHighlight)
        try encodeColor(&values, self.buttonStrokeColor, .buttonStroke)
        try encodeColor(&values, self.buttonHighlightedFillColor, .buttonHighlightedBg)
        try encodeColor(&values, self.buttonHighlightedStrokeColor, .buttonHighlightedStroke)
        try encodeColor(&values, self.buttonTextColor, .buttonText)
    }
}

extension PresentationThemeExpandedNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case bgType
        case navBar
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundType: try values.decode(PresentationThemeExpandedNotificationBackgroundType.self, forKey: .bgType),
                  navigationBar: try values.decode(PresentationThemeExpandedNotificationNavigationBar.self, forKey: .navBar))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundType, forKey: .bgType)
        try values.encode(self.navigationBar, forKey: .navBar)
    }
}

extension PresentationThemeContextMenu: Codable {
    enum CodingKeys: String, CodingKey {
        case dim
        case background
        case itemSeparator
        case sectionSeparator
        case itemBg
        case itemHighlightedBg
        case primary
        case secondary
        case destructive
        case badgeFill
        case badgeForeground
        case badgeInactiveFill
        case badgeInactiveForeground
        case extractedTint
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let destructiveColor = try decodeColor(values, .destructive)
        let backgroundColor = try decodeColor(values, .background)
        self.init(
            dimColor: try decodeColor(values, .dim),
            backgroundColor: backgroundColor,
            itemSeparatorColor: try decodeColor(values, .itemSeparator),
            sectionSeparatorColor: try decodeColor(values, .sectionSeparator),
            itemBackgroundColor: try decodeColor(values, .itemBg),
            itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
            primaryColor: try decodeColor(values, .primary),
            secondaryColor: try decodeColor(values, .secondary),
            destructiveColor: destructiveColor,
            badgeFillColor: (try? decodeColor(values, .badgeFill)) ?? destructiveColor,
            badgeForegroundColor: (try? decodeColor(values, .badgeForeground)) ?? backgroundColor,
            badgeInactiveFillColor: (try? decodeColor(values, .badgeInactiveFill)) ?? destructiveColor,
            badgeInactiveForegroundColor: (try? decodeColor(values, .badgeInactiveForeground)) ?? backgroundColor,
            extractedContentTintColor: (try? decodeColor(values, .extractedTint)) ?? backgroundColor
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.dimColor, .dim)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.itemSeparatorColor, .itemSeparator)
        try encodeColor(&values, self.sectionSeparatorColor, .sectionSeparator)
        try encodeColor(&values, self.itemBackgroundColor, .itemBg)
        try encodeColor(&values, self.itemHighlightedBackgroundColor, .itemHighlightedBg)
        try encodeColor(&values, self.primaryColor, .primary)
        try encodeColor(&values, self.secondaryColor, .secondary)
        try encodeColor(&values, self.destructiveColor, .destructive)
    }
}

extension PresentationThemeInAppNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case primaryText
        case expanded
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  expandedNotification: try values.decode(PresentationThemeExpandedNotification.self, forKey: .expanded))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try values.encode(self.expandedNotification, forKey: .expanded)
    }
}

extension PresentationThemeChart: Codable {
    enum CodingKeys: String, CodingKey {
        case labels
        case helperLines
        case strongLines
        case barStrongLines
        case detailsText
        case detailsArrow
        case detailsView
        case rangeViewFrame
        case rangeViewMarker
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(labelsColor: try decodeColor(values, .labels), helperLinesColor: try decodeColor(values, .helperLines), strongLinesColor: try decodeColor(values, .strongLines), barStrongLinesColor: try decodeColor(values, .barStrongLines), detailsTextColor: try decodeColor(values, .detailsText), detailsArrowColor: try decodeColor(values, .detailsArrow), detailsViewColor: try decodeColor(values, .detailsView), rangeViewFrameColor: try decodeColor(values, .rangeViewFrame), rangeViewMarkerColor: try decodeColor(values, .rangeViewMarker))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try encodeColor(&values, self.labelsColor, .labels)
        try encodeColor(&values, self.helperLinesColor, .helperLines)
        try encodeColor(&values, self.strongLinesColor, .strongLines)
        try encodeColor(&values, self.barStrongLinesColor, .barStrongLines)
        try encodeColor(&values, self.detailsTextColor, .detailsText)
        try encodeColor(&values, self.detailsArrowColor, .detailsArrow)
        try encodeColor(&values, self.detailsViewColor, .detailsView)
        try encodeColor(&values, self.rangeViewFrameColor, .rangeViewFrame)
        try encodeColor(&values, self.rangeViewMarkerColor, .rangeViewMarker)
    }
}

extension PresentationThemeName: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        self = .custom(try value.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .builtin(name):
                switch name {
                    case .day:
                        try container.encode("Day")
                    case .dayClassic:
                        try container.encode("Classic")
                    case .nightAccent:
                        try container.encode("Night Tinted")
                    case .night:
                        try container.encode("Night")
                }
            case let .custom(name):
                try container.encode(name)
        }
    }
}

extension PresentationBuiltinThemeReference: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "day":
                    self = .day
                case "classic":
                    self = .dayClassic
                case "nighttinted":
                    self = .nightAccent
                case "night":
                    self = .night
                default:
                    self = .dayClassic
            }
        } else {
            self = .dayClassic
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .day:
                try container.encode("day")
            case .dayClassic:
                try container.encode("classic")
            case .nightAccent:
                try container.encode("nighttinted")
            case .night:
                try container.encode("night")
        }
    }
}

extension PresentationTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case basedOn
        case dark
        case intro
        case passcode
        case root
        case list
        case chatList
        case chat
        case actionSheet
        case contextMenu
        case notification
        case chart
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let referenceTheme: PresentationBuiltinThemeReference
        if let theme = try? values.decode(PresentationBuiltinThemeReference.self, forKey: .basedOn) {
            referenceTheme = theme
        } else {
            referenceTheme = .dayClassic
        }
        
        let index: Int64
        if let decoder = decoder as? PresentationThemeDecoding {
            let serviceBackgroundColor = decoder.serviceBackgroundColor ?? defaultServiceBackgroundColor
            decoder.referenceTheme = makeDefaultPresentationTheme(reference: referenceTheme, serviceBackgroundColor: serviceBackgroundColor)
            index = decoder.reference?.index ?? Int64.random(in: Int64.min ... Int64.max)
        } else {
            index = Int64.random(in: Int64.min ... Int64.max)
        }
        
        self.init(name: (try? values.decode(PresentationThemeName.self, forKey: .name)) ?? .custom("Untitled"),
                  index: index,
                  referenceTheme: referenceTheme,
                  overallDarkAppearance: (try? values.decode(Bool.self, forKey: .dark)) ?? false,
                  intro: try values.decode(PresentationThemeIntro.self, forKey: .intro),
                  passcode: try values.decode(PresentationThemePasscode.self, forKey: .passcode),
                  rootController: try values.decode(PresentationThemeRootController.self, forKey: .root),
                  list: try values.decode(PresentationThemeList.self, forKey: .list),
                  actionSheet: try values.decode(PresentationThemeActionSheet.self, forKey: .actionSheet),
                  contextMenu: try values.decode(PresentationThemeContextMenu.self, forKey: .contextMenu),
                  inAppNotification: try values.decode(PresentationThemeInAppNotification.self, forKey: .notification)
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.referenceTheme, forKey: .basedOn)
        try container.encode(self.overallDarkAppearance, forKey: .dark)
        try container.encode(self.intro, forKey: .intro)
        try container.encode(self.passcode, forKey: .passcode)
        try container.encode(self.rootController, forKey: .root)
        try container.encode(self.list, forKey: .list)
        try container.encode(self.actionSheet, forKey: .actionSheet)
        try container.encode(self.contextMenu, forKey: .contextMenu)
        try container.encode(self.inAppNotification, forKey: .notification)
    }
}

extension PresentationThemeExpandedNotificationNavigationBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case primaryText
        case control
        case separator
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  controlColor: try decodeColor(values, .control),
                  separatorColor: try decodeColor(values, .separator))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.controlColor, .control)
        try encodeColor(&values, self.separatorColor, .separator)
    }
}
