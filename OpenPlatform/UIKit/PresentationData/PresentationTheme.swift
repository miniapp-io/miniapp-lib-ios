import Foundation
import UIKit

internal final class PresentationThemeGradientColors {
    public let topColor: UIColor
    public let bottomColor: UIColor
    
    public init(topColor: UIColor, bottomColor: UIColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
    }
    
    public var colors: (UIColor, UIColor) {
        return (self.topColor, self.bottomColor)
    }
    
    public var array: [UIColor] {
        return [self.topColor, self.bottomColor]
    }
    
    public func withUpdated(topColor: UIColor? = nil, bottomColor: UIColor? = nil) -> PresentationThemeGradientColors {
        return PresentationThemeGradientColors(topColor: topColor ?? self.topColor, bottomColor: bottomColor ?? self.bottomColor)
    }
}

internal final class PresentationThemeIntro {
    public let statusBarStyle: PresentationThemeStatusBarStyle
    public let primaryTextColor: UIColor
    public let accentTextColor: UIColor
    public let disabledTextColor: UIColor
    public let startButtonColor: UIColor
    public let dotColor: UIColor
    
    public init(statusBarStyle: PresentationThemeStatusBarStyle, primaryTextColor: UIColor, accentTextColor: UIColor, disabledTextColor: UIColor, startButtonColor: UIColor, dotColor: UIColor) {
        self.statusBarStyle = statusBarStyle
        self.primaryTextColor = primaryTextColor
        self.accentTextColor = accentTextColor
        self.disabledTextColor = disabledTextColor
        self.startButtonColor = startButtonColor
        self.dotColor = dotColor
    }
    
    public func withUpdated(statusBarStyle: PresentationThemeStatusBarStyle? = nil, primaryTextColor: UIColor? = nil, accentTextColor: UIColor? = nil, disabledTextColor: UIColor? = nil, startButtonColor: UIColor? = nil, dotColor: UIColor? = nil) -> PresentationThemeIntro {
        return PresentationThemeIntro(statusBarStyle: statusBarStyle ?? self.statusBarStyle, primaryTextColor: primaryTextColor ?? self.primaryTextColor, accentTextColor: accentTextColor ?? self.accentTextColor, disabledTextColor: disabledTextColor ?? self.disabledTextColor, startButtonColor: startButtonColor ?? self.startButtonColor, dotColor: dotColor ?? self.dotColor)
    }
}

internal final class PresentationThemePasscode {
    public let backgroundColors: PresentationThemeGradientColors
    public let buttonColor: UIColor
    
    public init(backgroundColors: PresentationThemeGradientColors, buttonColor: UIColor) {
        self.backgroundColors = backgroundColors
        self.buttonColor = buttonColor
    }
    
    public func withUpdated(backgroundColors: PresentationThemeGradientColors? = nil, buttonColor: UIColor? = nil) -> PresentationThemePasscode {
        return PresentationThemePasscode(backgroundColors: backgroundColors ?? self.backgroundColors, buttonColor: buttonColor ?? self.buttonColor)
    }
}

internal final class PresentationThemeRootTabBar {
    public let backgroundColor: UIColor
    public let separatorColor: UIColor
    public let iconColor: UIColor
    public let selectedIconColor: UIColor
    public let textColor: UIColor
    public let selectedTextColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeStrokeColor: UIColor
    public let badgeTextColor: UIColor
    
    public init(backgroundColor: UIColor, separatorColor: UIColor, iconColor: UIColor, selectedIconColor: UIColor, textColor: UIColor, selectedTextColor: UIColor, badgeBackgroundColor: UIColor, badgeStrokeColor: UIColor, badgeTextColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.iconColor = iconColor
        self.selectedIconColor = selectedIconColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeStrokeColor = badgeStrokeColor
        self.badgeTextColor = badgeTextColor
    }
    
    public func withUpdated(backgroundColor: UIColor? = nil, separatorColor: UIColor? = nil, iconColor: UIColor? = nil, selectedIconColor: UIColor? = nil, textColor: UIColor? = nil, selectedTextColor: UIColor? = nil, badgeBackgroundColor: UIColor? = nil, badgeStrokeColor: UIColor? = nil, badgeTextColor: UIColor? = nil) -> PresentationThemeRootTabBar {
        return PresentationThemeRootTabBar(backgroundColor: backgroundColor ?? self.backgroundColor, separatorColor: separatorColor ?? self.separatorColor, iconColor: iconColor ?? self.iconColor, selectedIconColor: selectedIconColor ?? self.selectedIconColor, textColor: textColor ?? self.textColor, selectedTextColor: selectedTextColor ?? self.selectedTextColor, badgeBackgroundColor: badgeBackgroundColor ?? self.badgeBackgroundColor, badgeStrokeColor: badgeStrokeColor ?? self.badgeStrokeColor, badgeTextColor: badgeTextColor ?? self.badgeTextColor)
    }
}

internal enum PresentationThemeStatusBarStyle: Int32 {
    case black = 0
    case white = 1
    
    init(_ style: StatusBarStyle) {
        switch style {
            case .White:
                self = .white
            default:
                self = .black
        }
    }
    
    public var style: StatusBarStyle {
        switch self {
            case .black:
                return .Black
            case .white:
                return .White
        }
    }
}

internal final class PresentationThemeRootNavigationBar {
    public let buttonColor: UIColor
    public let disabledButtonColor: UIColor
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let controlColor: UIColor
    public let accentTextColor: UIColor
    public let blurredBackgroundColor: UIColor
    public let opaqueBackgroundColor: UIColor
    public let separatorColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeStrokeColor: UIColor
    public let badgeTextColor: UIColor
    public let segmentedBackgroundColor: UIColor
    public let segmentedForegroundColor: UIColor
    public let segmentedTextColor: UIColor
    public let segmentedDividerColor: UIColor
    public let clearButtonBackgroundColor: UIColor
    public let clearButtonForegroundColor: UIColor
    
    public init(buttonColor: UIColor, disabledButtonColor: UIColor, primaryTextColor: UIColor, secondaryTextColor: UIColor, controlColor: UIColor, accentTextColor: UIColor, blurredBackgroundColor: UIColor, opaqueBackgroundColor: UIColor, separatorColor: UIColor, badgeBackgroundColor: UIColor, badgeStrokeColor: UIColor, badgeTextColor: UIColor, segmentedBackgroundColor: UIColor, segmentedForegroundColor: UIColor, segmentedTextColor: UIColor, segmentedDividerColor: UIColor, clearButtonBackgroundColor: UIColor, clearButtonForegroundColor: UIColor) {
        self.buttonColor = buttonColor
        self.disabledButtonColor = disabledButtonColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.controlColor = controlColor
        self.accentTextColor = accentTextColor
        self.blurredBackgroundColor = blurredBackgroundColor
        self.opaqueBackgroundColor = opaqueBackgroundColor
        self.separatorColor = separatorColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeStrokeColor = badgeStrokeColor
        self.badgeTextColor = badgeTextColor
        self.segmentedBackgroundColor = segmentedBackgroundColor
        self.segmentedForegroundColor = segmentedForegroundColor
        self.segmentedTextColor = segmentedTextColor
        self.segmentedDividerColor = segmentedDividerColor
        self.clearButtonBackgroundColor = clearButtonBackgroundColor
        self.clearButtonForegroundColor = clearButtonForegroundColor
    }
    
    public func withUpdated(buttonColor: UIColor? = nil, disabledButtonColor: UIColor? = nil, primaryTextColor: UIColor? = nil, secondaryTextColor: UIColor? = nil, controlColor: UIColor? = nil, accentTextColor: UIColor? = nil, blurredBackgroundColor: UIColor? = nil, opaqueBackgroundColor: UIColor? = nil, separatorColor: UIColor? = nil, badgeBackgroundColor: UIColor? = nil, badgeStrokeColor: UIColor? = nil, badgeTextColor: UIColor? = nil, segmentedBackgroundColor: UIColor? = nil, segmentedForegroundColor: UIColor? = nil, segmentedTextColor: UIColor? = nil, segmentedDividerColor: UIColor? = nil, clearButtonBackgroundColor: UIColor? = nil, clearButtonForegroundColor: UIColor? = nil) -> PresentationThemeRootNavigationBar {
        let resolvedClearButtonBackgroundColor = clearButtonBackgroundColor ?? self.clearButtonBackgroundColor
        let resolvedClearButtonForegroundColor = clearButtonForegroundColor ?? self.clearButtonForegroundColor
        return PresentationThemeRootNavigationBar(buttonColor: buttonColor ?? self.buttonColor, disabledButtonColor: disabledButtonColor ?? self.disabledButtonColor, primaryTextColor: primaryTextColor ?? self.primaryTextColor, secondaryTextColor: secondaryTextColor ?? self.secondaryTextColor, controlColor: controlColor ?? self.controlColor, accentTextColor: accentTextColor ?? self.accentTextColor, blurredBackgroundColor: blurredBackgroundColor ?? self.blurredBackgroundColor, opaqueBackgroundColor: opaqueBackgroundColor ?? self.opaqueBackgroundColor, separatorColor: separatorColor ?? self.separatorColor, badgeBackgroundColor: badgeBackgroundColor ?? self.badgeBackgroundColor, badgeStrokeColor: badgeStrokeColor ?? self.badgeStrokeColor, badgeTextColor: badgeTextColor ?? self.badgeTextColor, segmentedBackgroundColor: segmentedBackgroundColor ?? self.segmentedBackgroundColor, segmentedForegroundColor: segmentedForegroundColor ?? self.segmentedForegroundColor, segmentedTextColor: segmentedTextColor ?? self.segmentedTextColor, segmentedDividerColor: segmentedDividerColor ?? self.segmentedDividerColor, clearButtonBackgroundColor: resolvedClearButtonBackgroundColor, clearButtonForegroundColor: resolvedClearButtonForegroundColor)
    }
}

internal final class PresentationThemeNavigationSearchBar {
    public let backgroundColor: UIColor
    public let accentColor: UIColor
    public let inputFillColor: UIColor
    public let inputTextColor: UIColor
    public let inputPlaceholderTextColor: UIColor
    public let inputIconColor: UIColor
    public let inputClearButtonColor: UIColor
    public let separatorColor: UIColor
    
    public init(backgroundColor: UIColor, accentColor: UIColor, inputFillColor: UIColor, inputTextColor: UIColor, inputPlaceholderTextColor: UIColor, inputIconColor: UIColor, inputClearButtonColor: UIColor, separatorColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.inputFillColor = inputFillColor
        self.inputTextColor = inputTextColor
        self.inputPlaceholderTextColor = inputPlaceholderTextColor
        self.inputIconColor = inputIconColor
        self.inputClearButtonColor = inputClearButtonColor
        self.separatorColor = separatorColor
    }
    
    public func withUpdated(backgroundColor: UIColor? = nil, accentColor: UIColor? = nil, inputFillColor: UIColor? = nil, inputTextColor: UIColor? = nil, inputPlaceholderTextColor: UIColor? = nil, inputIconColor: UIColor? = nil, inputClearButtonColor: UIColor? = nil, separatorColor: UIColor? = nil) -> PresentationThemeNavigationSearchBar {
        return PresentationThemeNavigationSearchBar(backgroundColor: backgroundColor ?? self.backgroundColor, accentColor: accentColor ?? self.accentColor, inputFillColor: inputFillColor ?? self.inputFillColor, inputTextColor: inputTextColor ?? self.inputTextColor, inputPlaceholderTextColor: inputPlaceholderTextColor ?? self.inputPlaceholderTextColor, inputIconColor: inputIconColor ?? self.inputIconColor, inputClearButtonColor: inputClearButtonColor ?? self.inputClearButtonColor, separatorColor: separatorColor ?? self.separatorColor)
    }
}

internal final class PresentationThemeRootController {
    public let statusBarStyle: PresentationThemeStatusBarStyle
    public let tabBar: PresentationThemeRootTabBar
    public let navigationBar: PresentationThemeRootNavigationBar
    public let navigationSearchBar: PresentationThemeNavigationSearchBar
    public let keyboardColor: PresentationThemeKeyboardColor
    
    public init(statusBarStyle: PresentationThemeStatusBarStyle, tabBar: PresentationThemeRootTabBar, navigationBar: PresentationThemeRootNavigationBar, navigationSearchBar: PresentationThemeNavigationSearchBar, keyboardColor: PresentationThemeKeyboardColor) {
        self.statusBarStyle = statusBarStyle
        self.tabBar = tabBar
        self.navigationBar = navigationBar
        self.navigationSearchBar = navigationSearchBar
        self.keyboardColor = keyboardColor
    }
    
    public func withUpdated(statusBarStyle: PresentationThemeStatusBarStyle? = nil, tabBar: PresentationThemeRootTabBar? = nil, navigationBar: PresentationThemeRootNavigationBar? = nil, navigationSearchBar: PresentationThemeNavigationSearchBar? = nil, keyboardColor: PresentationThemeKeyboardColor? = nil) -> PresentationThemeRootController {
        return PresentationThemeRootController(statusBarStyle: statusBarStyle ?? self.statusBarStyle, tabBar: tabBar ?? self.tabBar, navigationBar: navigationBar ?? self.navigationBar, navigationSearchBar: navigationSearchBar ?? self.navigationSearchBar, keyboardColor: keyboardColor ?? self.keyboardColor)
    }
}

internal enum PresentationThemeActionSheetBackgroundType: Int32 {
    case light
    case dark
}

internal final class PresentationThemeActionSheet {
    public let dimColor: UIColor
    public let backgroundType: PresentationThemeActionSheetBackgroundType
    public let opaqueItemBackgroundColor: UIColor
    public let itemBackgroundColor: UIColor
    public let opaqueItemHighlightedBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let opaqueItemSeparatorColor: UIColor
    public let standardActionTextColor: UIColor
    public let destructiveActionTextColor: UIColor
    public let disabledActionTextColor: UIColor
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let controlAccentColor: UIColor
    public let inputBackgroundColor: UIColor
    public let inputHollowBackgroundColor: UIColor
    public let inputBorderColor: UIColor
    public let inputPlaceholderColor: UIColor
    public let inputTextColor: UIColor
    public let inputClearButtonColor: UIColor
    public let checkContentColor: UIColor
    
    init(dimColor: UIColor, backgroundType: PresentationThemeActionSheetBackgroundType, opaqueItemBackgroundColor: UIColor, itemBackgroundColor: UIColor, opaqueItemHighlightedBackgroundColor: UIColor, itemHighlightedBackgroundColor: UIColor, opaqueItemSeparatorColor: UIColor, standardActionTextColor: UIColor, destructiveActionTextColor: UIColor, disabledActionTextColor: UIColor, primaryTextColor: UIColor, secondaryTextColor: UIColor, controlAccentColor: UIColor, inputBackgroundColor: UIColor, inputHollowBackgroundColor: UIColor, inputBorderColor: UIColor, inputPlaceholderColor: UIColor, inputTextColor: UIColor, inputClearButtonColor: UIColor, checkContentColor: UIColor) {
        self.dimColor = dimColor
        self.backgroundType = backgroundType
        self.opaqueItemBackgroundColor = opaqueItemBackgroundColor
        self.itemBackgroundColor = itemBackgroundColor
        self.opaqueItemHighlightedBackgroundColor = opaqueItemHighlightedBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.opaqueItemSeparatorColor = opaqueItemSeparatorColor
        self.standardActionTextColor = standardActionTextColor
        self.destructiveActionTextColor = destructiveActionTextColor
        self.disabledActionTextColor = disabledActionTextColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.controlAccentColor = controlAccentColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputHollowBackgroundColor = inputHollowBackgroundColor
        self.inputBorderColor = inputBorderColor
        self.inputPlaceholderColor = inputPlaceholderColor
        self.inputTextColor = inputTextColor
        self.inputClearButtonColor = inputClearButtonColor
        self.checkContentColor = checkContentColor
    }
    
    public func withUpdated(dimColor: UIColor? = nil, backgroundType: PresentationThemeActionSheetBackgroundType? = nil, opaqueItemBackgroundColor: UIColor? = nil, itemBackgroundColor: UIColor? = nil, opaqueItemHighlightedBackgroundColor: UIColor? = nil, itemHighlightedBackgroundColor: UIColor? = nil, opaqueItemSeparatorColor: UIColor? = nil, standardActionTextColor: UIColor? = nil, destructiveActionTextColor: UIColor? = nil, disabledActionTextColor: UIColor? = nil, primaryTextColor: UIColor? = nil, secondaryTextColor: UIColor? = nil, controlAccentColor: UIColor? = nil, inputBackgroundColor: UIColor? = nil, inputHollowBackgroundColor: UIColor? = nil, inputBorderColor: UIColor? = nil, inputPlaceholderColor: UIColor? = nil, inputTextColor: UIColor? = nil, inputClearButtonColor: UIColor? = nil, checkContentColor: UIColor? = nil) -> PresentationThemeActionSheet {
        return PresentationThemeActionSheet(dimColor: dimColor ?? self.dimColor, backgroundType: backgroundType ?? self.backgroundType, opaqueItemBackgroundColor: opaqueItemBackgroundColor ?? self.opaqueItemBackgroundColor, itemBackgroundColor: itemBackgroundColor ?? self.itemBackgroundColor, opaqueItemHighlightedBackgroundColor: opaqueItemHighlightedBackgroundColor ?? self.opaqueItemHighlightedBackgroundColor, itemHighlightedBackgroundColor: itemHighlightedBackgroundColor ?? self.itemHighlightedBackgroundColor, opaqueItemSeparatorColor: opaqueItemSeparatorColor ?? self.opaqueItemSeparatorColor, standardActionTextColor: standardActionTextColor ?? self.standardActionTextColor, destructiveActionTextColor: destructiveActionTextColor ?? self.destructiveActionTextColor, disabledActionTextColor: disabledActionTextColor ?? self.disabledActionTextColor, primaryTextColor: primaryTextColor ?? self.primaryTextColor, secondaryTextColor: secondaryTextColor ?? self.secondaryTextColor, controlAccentColor: controlAccentColor ?? self.controlAccentColor, inputBackgroundColor: inputBackgroundColor ?? self.inputBackgroundColor, inputHollowBackgroundColor: inputHollowBackgroundColor ?? self.inputHollowBackgroundColor, inputBorderColor: inputBorderColor ?? self.inputBorderColor, inputPlaceholderColor: inputPlaceholderColor ?? self.inputPlaceholderColor, inputTextColor: inputTextColor ?? self.inputTextColor, inputClearButtonColor: inputClearButtonColor ?? self.inputClearButtonColor, checkContentColor: checkContentColor ?? self.checkContentColor)
    }
}

internal final class PresentationThemeContextMenu {
    public let dimColor: UIColor
    public let backgroundColor: UIColor
    public let itemSeparatorColor: UIColor
    public let sectionSeparatorColor: UIColor
    public let itemBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let destructiveColor: UIColor
    public let badgeFillColor: UIColor
    public let badgeForegroundColor: UIColor
    public let badgeInactiveFillColor: UIColor
    public let badgeInactiveForegroundColor: UIColor
    public let extractedContentTintColor: UIColor
    
    init(dimColor: UIColor, backgroundColor: UIColor, itemSeparatorColor: UIColor, sectionSeparatorColor: UIColor, itemBackgroundColor: UIColor, itemHighlightedBackgroundColor: UIColor, primaryColor: UIColor, secondaryColor: UIColor, destructiveColor: UIColor, badgeFillColor: UIColor, badgeForegroundColor: UIColor, badgeInactiveFillColor: UIColor, badgeInactiveForegroundColor: UIColor, extractedContentTintColor: UIColor) {
        self.dimColor = dimColor
        self.backgroundColor = backgroundColor
        self.itemSeparatorColor = itemSeparatorColor
        self.sectionSeparatorColor = sectionSeparatorColor
        self.itemBackgroundColor = itemBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.destructiveColor = destructiveColor
        self.badgeFillColor = badgeFillColor
        self.badgeForegroundColor = badgeForegroundColor
        self.badgeInactiveFillColor = badgeInactiveFillColor
        self.badgeInactiveForegroundColor = badgeInactiveForegroundColor
        self.extractedContentTintColor = extractedContentTintColor
    }
    
    public func withUpdated(dimColor: UIColor? = nil, backgroundColor: UIColor? = nil, itemSeparatorColor: UIColor? = nil, sectionSeparatorColor: UIColor? = nil, itemBackgroundColor: UIColor? = nil, itemHighlightedBackgroundColor: UIColor? = nil, primaryColor: UIColor? = nil, secondaryColor: UIColor? = nil, destructiveColor: UIColor? = nil) -> PresentationThemeContextMenu {
        return PresentationThemeContextMenu(dimColor: dimColor ?? self.dimColor, backgroundColor: backgroundColor ?? self.backgroundColor, itemSeparatorColor: itemSeparatorColor ?? self.itemSeparatorColor, sectionSeparatorColor: sectionSeparatorColor ?? self.sectionSeparatorColor, itemBackgroundColor: itemBackgroundColor ?? self.itemBackgroundColor, itemHighlightedBackgroundColor: itemHighlightedBackgroundColor ?? self.itemHighlightedBackgroundColor, primaryColor: primaryColor ?? self.primaryColor, secondaryColor: secondaryColor ?? self.secondaryColor, destructiveColor: destructiveColor ?? self.destructiveColor, badgeFillColor: self.badgeFillColor, badgeForegroundColor: self.badgeForegroundColor, badgeInactiveFillColor: self.badgeInactiveFillColor, badgeInactiveForegroundColor: self.badgeInactiveForegroundColor, extractedContentTintColor: self.extractedContentTintColor)
    }
}

internal final class PresentationThemeSwitch {
    public let frameColor: UIColor
    public let handleColor: UIColor
    public let contentColor: UIColor
    public let positiveColor: UIColor
    public let negativeColor: UIColor
    
    public init(frameColor: UIColor, handleColor: UIColor, contentColor: UIColor, positiveColor: UIColor, negativeColor: UIColor) {
        self.frameColor = frameColor
        self.handleColor = handleColor
        self.contentColor = contentColor
        self.positiveColor = positiveColor
        self.negativeColor = negativeColor
    }
    
    public func withUpdated(frameColor: UIColor? = nil, handleColor: UIColor? = nil, contentColor: UIColor? = nil, positiveColor: UIColor? = nil, negativeColor: UIColor? = nil) -> PresentationThemeSwitch {
        return PresentationThemeSwitch(frameColor: frameColor ?? self.frameColor, handleColor: handleColor ?? self.handleColor, contentColor: contentColor ?? self.contentColor, positiveColor: positiveColor ?? self.positiveColor, negativeColor: negativeColor ?? self.negativeColor)
    }
}

internal final class PresentationThemeFillForeground {
    public let fillColor: UIColor
    public let foregroundColor: UIColor
    
    init(fillColor: UIColor, foregroundColor: UIColor) {
        self.fillColor = fillColor
        self.foregroundColor = foregroundColor
    }
    
    public func withUpdated(fillColor: UIColor? = nil, foregroundColor: UIColor? = nil) -> PresentationThemeFillForeground {
        return PresentationThemeFillForeground(fillColor: fillColor ?? self.fillColor, foregroundColor: foregroundColor ?? self.foregroundColor)
    }
}

internal final class PresentationThemeItemDisclosureActions {
    public let neutral1: PresentationThemeFillForeground
    public let neutral2: PresentationThemeFillForeground
    public let destructive: PresentationThemeFillForeground
    public let constructive: PresentationThemeFillForeground
    public let accent: PresentationThemeFillForeground
    public let warning: PresentationThemeFillForeground
    public let inactive: PresentationThemeFillForeground
    
    public init(neutral1: PresentationThemeFillForeground, neutral2: PresentationThemeFillForeground, destructive: PresentationThemeFillForeground, constructive: PresentationThemeFillForeground, accent: PresentationThemeFillForeground, warning: PresentationThemeFillForeground, inactive: PresentationThemeFillForeground) {
        self.neutral1 = neutral1
        self.neutral2 = neutral2
        self.destructive = destructive
        self.constructive = constructive
        self.accent = accent
        self.warning = warning
        self.inactive = inactive
    }
    
    public func withUpdated(neutral1: PresentationThemeFillForeground? = nil, neutral2: PresentationThemeFillForeground? = nil, destructive: PresentationThemeFillForeground? = nil, constructive: PresentationThemeFillForeground? = nil, accent: PresentationThemeFillForeground? = nil, warning: PresentationThemeFillForeground? = nil, inactive: PresentationThemeFillForeground? = nil) -> PresentationThemeItemDisclosureActions {
        return PresentationThemeItemDisclosureActions(neutral1: neutral1 ?? self.neutral1, neutral2: neutral2 ?? self.neutral2, destructive: destructive ?? self.destructive, constructive: constructive ?? self.constructive, accent: accent ?? self.accent, warning: warning ?? self.warning, inactive: inactive ?? self.inactive)
    }
}

internal final class PresentationThemeItemBarChart {
    public let color1: UIColor
    public let color2: UIColor
    public let color3: UIColor
    
    public init(color1: UIColor, color2: UIColor, color3: UIColor) {
        self.color1 = color1
        self.color2 = color2
        self.color3 = color3
    }
    
    public func withUpdated(color1: UIColor? = nil, color2: UIColor? = nil, color3: UIColor? = nil) -> PresentationThemeItemBarChart {
        return PresentationThemeItemBarChart(color1: color1 ?? self.color1, color2: color2 ?? self.color2, color3: color3 ?? self.color3)
    }
}

internal final class PresentationThemeFillStrokeForeground {
    public let fillColor: UIColor
    public let strokeColor: UIColor
    public let foregroundColor: UIColor
    
    init(fillColor: UIColor, strokeColor: UIColor, foregroundColor: UIColor) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.foregroundColor = foregroundColor
    }
    
    public func withUpdated(fillColor: UIColor? = nil, strokeColor: UIColor? = nil, foregroundColor: UIColor? = nil) -> PresentationThemeFillStrokeForeground {
        return PresentationThemeFillStrokeForeground(fillColor: fillColor ?? self.fillColor, strokeColor: strokeColor ?? self.strokeColor, foregroundColor: foregroundColor ?? self.foregroundColor)
    }
}

internal final class PresentationInputFieldTheme {
    public let backgroundColor: UIColor
    public let strokeColor: UIColor
    public let placeholderColor: UIColor
    public let primaryColor: UIColor
    public let controlColor: UIColor
    
    public init(backgroundColor: UIColor, strokeColor: UIColor, placeholderColor: UIColor, primaryColor: UIColor, controlColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.placeholderColor = placeholderColor
        self.primaryColor = primaryColor
        self.controlColor = controlColor
    }
    
    public func withUpdated(backgroundColor: UIColor? = nil, strokeColor: UIColor? = nil, placeholderColor: UIColor? = nil, primaryColor: UIColor? = nil, controlColor: UIColor? = nil) -> PresentationInputFieldTheme {
        return PresentationInputFieldTheme(backgroundColor: backgroundColor ?? self.backgroundColor, strokeColor: strokeColor ?? self.strokeColor, placeholderColor: placeholderColor ?? self.placeholderColor, primaryColor: primaryColor ?? self.primaryColor, controlColor: controlColor ?? self.controlColor)
    }
}

internal final class PresentationThemeList {
    internal  final class PaymentOption {
        public let inactiveFillColor: UIColor
        public let inactiveForegroundColor: UIColor
        public let activeFillColor: UIColor
        public let activeForegroundColor: UIColor

        public init(
            inactiveFillColor: UIColor,
            inactiveForegroundColor: UIColor,
            activeFillColor: UIColor,
            activeForegroundColor: UIColor
        ) {
            self.inactiveFillColor = inactiveFillColor
            self.inactiveForegroundColor = inactiveForegroundColor
            self.activeFillColor = activeFillColor
            self.activeForegroundColor = activeForegroundColor
        }
    }

    public let blocksBackgroundColor: UIColor
    public let modalBlocksBackgroundColor: UIColor
    public let plainBackgroundColor: UIColor
    public let modalPlainBackgroundColor: UIColor
    public let itemPrimaryTextColor: UIColor
    public let itemSecondaryTextColor: UIColor
    public let itemDisabledTextColor: UIColor
    public let itemAccentColor: UIColor
    public let itemHighlightedColor: UIColor
    public let itemDestructiveColor: UIColor
    public let itemPlaceholderTextColor: UIColor
    public let itemBlocksBackgroundColor: UIColor
    public let itemModalBlocksBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let itemBlocksSeparatorColor: UIColor
    public let itemPlainSeparatorColor: UIColor
    public let disclosureArrowColor: UIColor
    public let sectionHeaderTextColor: UIColor
    public let freeTextColor: UIColor
    public let freeTextErrorColor: UIColor
    public let freeTextSuccessColor: UIColor
    public let freeMonoIconColor: UIColor
    public let itemSwitchColors: PresentationThemeSwitch
    public let itemDisclosureActions: PresentationThemeItemDisclosureActions
    public let itemCheckColors: PresentationThemeFillStrokeForeground
    public let controlSecondaryColor: UIColor
    public let freeInputField: PresentationInputFieldTheme
    public let freePlainInputField: PresentationInputFieldTheme
    public let mediaPlaceholderColor: UIColor
    public let scrollIndicatorColor: UIColor
    public let pageIndicatorInactiveColor: UIColor
    public let inputClearButtonColor: UIColor
    public let itemBarChart: PresentationThemeItemBarChart
    public let itemInputField: PresentationInputFieldTheme
    public let paymentOption: PaymentOption
    
    public init(
        blocksBackgroundColor: UIColor,
        modalBlocksBackgroundColor: UIColor,
        plainBackgroundColor: UIColor,
        modalPlainBackgroundColor: UIColor,
        itemPrimaryTextColor: UIColor,
        itemSecondaryTextColor: UIColor,
        itemDisabledTextColor: UIColor,
        itemAccentColor: UIColor,
        itemHighlightedColor: UIColor,
        itemDestructiveColor: UIColor,
        itemPlaceholderTextColor: UIColor,
        itemBlocksBackgroundColor: UIColor,
        itemModalBlocksBackgroundColor: UIColor,
        itemHighlightedBackgroundColor: UIColor,
        itemBlocksSeparatorColor: UIColor,
        itemPlainSeparatorColor: UIColor,
        disclosureArrowColor: UIColor,
        sectionHeaderTextColor: UIColor,
        freeTextColor: UIColor,
        freeTextErrorColor: UIColor,
        freeTextSuccessColor: UIColor,
        freeMonoIconColor: UIColor,
        itemSwitchColors: PresentationThemeSwitch,
        itemDisclosureActions: PresentationThemeItemDisclosureActions,
        itemCheckColors: PresentationThemeFillStrokeForeground,
        controlSecondaryColor: UIColor,
        freeInputField: PresentationInputFieldTheme,
        freePlainInputField: PresentationInputFieldTheme,
        mediaPlaceholderColor: UIColor,
        scrollIndicatorColor: UIColor,
        pageIndicatorInactiveColor: UIColor,
        inputClearButtonColor: UIColor,
        itemBarChart: PresentationThemeItemBarChart,
        itemInputField: PresentationInputFieldTheme,
        paymentOption: PaymentOption
    ) {
        self.blocksBackgroundColor = blocksBackgroundColor
        self.modalBlocksBackgroundColor = modalBlocksBackgroundColor
        self.plainBackgroundColor = plainBackgroundColor
        self.modalPlainBackgroundColor = modalPlainBackgroundColor
        self.itemPrimaryTextColor = itemPrimaryTextColor
        self.itemSecondaryTextColor = itemSecondaryTextColor
        self.itemDisabledTextColor = itemDisabledTextColor
        self.itemAccentColor = itemAccentColor
        self.itemHighlightedColor = itemHighlightedColor
        self.itemDestructiveColor = itemDestructiveColor
        self.itemPlaceholderTextColor = itemPlaceholderTextColor
        self.itemBlocksBackgroundColor = itemBlocksBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.itemBlocksSeparatorColor = itemBlocksSeparatorColor
        self.itemModalBlocksBackgroundColor = itemModalBlocksBackgroundColor
        self.itemPlainSeparatorColor = itemPlainSeparatorColor
        self.disclosureArrowColor = disclosureArrowColor
        self.sectionHeaderTextColor = sectionHeaderTextColor
        self.freeTextColor = freeTextColor
        self.freeTextErrorColor = freeTextErrorColor
        self.freeTextSuccessColor = freeTextSuccessColor
        self.freeMonoIconColor = freeMonoIconColor
        self.itemSwitchColors = itemSwitchColors
        self.itemDisclosureActions = itemDisclosureActions
        self.itemCheckColors = itemCheckColors
        self.controlSecondaryColor = controlSecondaryColor
        self.freeInputField = freeInputField
        self.freePlainInputField = freePlainInputField
        self.mediaPlaceholderColor = mediaPlaceholderColor
        self.scrollIndicatorColor = scrollIndicatorColor
        self.pageIndicatorInactiveColor = pageIndicatorInactiveColor
        self.inputClearButtonColor = inputClearButtonColor
        self.itemBarChart = itemBarChart
        self.itemInputField = itemInputField
        self.paymentOption = paymentOption
    }
    
    public func withUpdated(blocksBackgroundColor: UIColor? = nil, modalBlocksBackgroundColor: UIColor? = nil, plainBackgroundColor: UIColor? = nil, modalPlainBackgroundColor: UIColor? = nil, itemPrimaryTextColor: UIColor? = nil, itemSecondaryTextColor: UIColor? = nil, itemDisabledTextColor: UIColor? = nil, itemAccentColor: UIColor? = nil, itemHighlightedColor: UIColor? = nil, itemDestructiveColor: UIColor? = nil, itemPlaceholderTextColor: UIColor? = nil, itemBlocksBackgroundColor: UIColor? = nil, itemModalBlocksBackgroundColor: UIColor? = nil, itemHighlightedBackgroundColor: UIColor? = nil, itemBlocksSeparatorColor: UIColor? = nil, itemPlainSeparatorColor: UIColor? = nil, disclosureArrowColor: UIColor? = nil, sectionHeaderTextColor: UIColor? = nil, freeTextColor: UIColor? = nil, freeTextErrorColor: UIColor? = nil, freeTextSuccessColor: UIColor? = nil, freeMonoIconColor: UIColor? = nil, itemSwitchColors: PresentationThemeSwitch? = nil, itemDisclosureActions: PresentationThemeItemDisclosureActions? = nil, itemCheckColors: PresentationThemeFillStrokeForeground? = nil, controlSecondaryColor: UIColor? = nil, freeInputField: PresentationInputFieldTheme? = nil, freePlainInputField: PresentationInputFieldTheme? = nil, mediaPlaceholderColor: UIColor? = nil, scrollIndicatorColor: UIColor? = nil, pageIndicatorInactiveColor: UIColor? = nil, inputClearButtonColor: UIColor? = nil, itemBarChart: PresentationThemeItemBarChart? = nil, itemInputField: PresentationInputFieldTheme? = nil, paymentOption: PaymentOption? = nil) -> PresentationThemeList {
        return PresentationThemeList(blocksBackgroundColor: blocksBackgroundColor ?? self.blocksBackgroundColor, modalBlocksBackgroundColor: modalBlocksBackgroundColor ?? self.modalBlocksBackgroundColor, plainBackgroundColor: plainBackgroundColor ?? self.plainBackgroundColor, modalPlainBackgroundColor: modalPlainBackgroundColor ?? self.modalPlainBackgroundColor, itemPrimaryTextColor: itemPrimaryTextColor ?? self.itemPrimaryTextColor, itemSecondaryTextColor: itemSecondaryTextColor ?? self.itemSecondaryTextColor, itemDisabledTextColor: itemDisabledTextColor ?? self.itemDisabledTextColor, itemAccentColor: itemAccentColor ?? self.itemAccentColor, itemHighlightedColor: itemHighlightedColor ?? self.itemHighlightedColor, itemDestructiveColor: itemDestructiveColor ?? self.itemDestructiveColor, itemPlaceholderTextColor: itemPlaceholderTextColor ?? self.itemPlaceholderTextColor, itemBlocksBackgroundColor: itemBlocksBackgroundColor ?? self.itemBlocksBackgroundColor, itemModalBlocksBackgroundColor: itemModalBlocksBackgroundColor ?? self.itemModalBlocksBackgroundColor, itemHighlightedBackgroundColor: itemHighlightedBackgroundColor ?? self.itemHighlightedBackgroundColor, itemBlocksSeparatorColor: itemBlocksSeparatorColor ?? self.itemBlocksSeparatorColor, itemPlainSeparatorColor: itemPlainSeparatorColor ?? self.itemPlainSeparatorColor, disclosureArrowColor: disclosureArrowColor ?? self.disclosureArrowColor, sectionHeaderTextColor: sectionHeaderTextColor ?? self.sectionHeaderTextColor, freeTextColor: freeTextColor ?? self.freeTextColor, freeTextErrorColor: freeTextErrorColor ?? self.freeTextErrorColor, freeTextSuccessColor: freeTextSuccessColor ?? self.freeTextSuccessColor, freeMonoIconColor: freeMonoIconColor ?? self.freeMonoIconColor, itemSwitchColors: itemSwitchColors ?? self.itemSwitchColors, itemDisclosureActions: itemDisclosureActions ?? self.itemDisclosureActions, itemCheckColors: itemCheckColors ?? self.itemCheckColors, controlSecondaryColor: controlSecondaryColor ?? self.controlSecondaryColor, freeInputField: freeInputField ?? self.freeInputField, freePlainInputField: freePlainInputField ?? self.freePlainInputField, mediaPlaceholderColor: mediaPlaceholderColor ?? self.mediaPlaceholderColor, scrollIndicatorColor: scrollIndicatorColor ?? self.scrollIndicatorColor, pageIndicatorInactiveColor: pageIndicatorInactiveColor ?? self.pageIndicatorInactiveColor, inputClearButtonColor: inputClearButtonColor ?? self.inputClearButtonColor, itemBarChart: itemBarChart ?? self.itemBarChart, itemInputField: itemInputField ?? self.itemInputField, paymentOption: paymentOption ?? self.paymentOption)
    }
}

internal final class PresentationThemeArchiveAvatarColors {
    public let backgroundColors: PresentationThemeGradientColors
    public let foregroundColor: UIColor
    
    public init(backgroundColors: PresentationThemeGradientColors, foregroundColor: UIColor) {
        self.backgroundColors = backgroundColors
        self.foregroundColor = foregroundColor
    }
    
    public func withUpdated(backgroundColors: PresentationThemeGradientColors? = nil, foregroundColor: UIColor? = nil) -> PresentationThemeArchiveAvatarColors {
        return PresentationThemeArchiveAvatarColors(backgroundColors: backgroundColors ?? self.backgroundColors, foregroundColor: foregroundColor ?? self.foregroundColor)
    }
}

internal final class PresentationThemeVariableColor {
    public let withWallpaper: UIColor
    public let withoutWallpaper: UIColor
    
    public init(withWallpaper: UIColor, withoutWallpaper: UIColor) {
        self.withWallpaper = withWallpaper
        self.withoutWallpaper = withoutWallpaper
    }
    
    public init(color: UIColor) {
        self.withWallpaper = color
        self.withoutWallpaper = color
    }
    
    public func withUpdated(withWallpaper: UIColor? = nil, withoutWallpaper: UIColor? = nil) -> PresentationThemeVariableColor {
        return PresentationThemeVariableColor(withWallpaper: withWallpaper ?? self.withWallpaper, withoutWallpaper: withoutWallpaper ?? self.withoutWallpaper)
    }
}


internal final class PresentationThemePartedColors {
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let linkTextColor: UIColor
    public let linkHighlightColor: UIColor
    public let scamColor: UIColor
    public let textHighlightColor: UIColor
    public let accentTextColor: UIColor
    public let accentControlColor: UIColor
    public let accentControlDisabledColor: UIColor
    public let mediaActiveControlColor: UIColor
    public let mediaInactiveControlColor: UIColor
    public let mediaControlInnerBackgroundColor: UIColor
    public let pendingActivityColor: UIColor
    public let fileTitleColor: UIColor
    public let fileDescriptionColor: UIColor
    public let fileDurationColor: UIColor
    public let mediaPlaceholderColor: UIColor
    public let actionButtonsFillColor: PresentationThemeVariableColor
    public let actionButtonsStrokeColor: PresentationThemeVariableColor
    public let actionButtonsTextColor: PresentationThemeVariableColor
    public let textSelectionColor: UIColor
    public let textSelectionKnobColor: UIColor
    
    public init(primaryTextColor: UIColor, secondaryTextColor: UIColor, linkTextColor: UIColor, linkHighlightColor: UIColor, scamColor: UIColor, textHighlightColor: UIColor, accentTextColor: UIColor, accentControlColor: UIColor, accentControlDisabledColor: UIColor, mediaActiveControlColor: UIColor, mediaInactiveControlColor: UIColor, mediaControlInnerBackgroundColor: UIColor, pendingActivityColor: UIColor, fileTitleColor: UIColor, fileDescriptionColor: UIColor, fileDurationColor: UIColor, mediaPlaceholderColor: UIColor, actionButtonsFillColor: PresentationThemeVariableColor, actionButtonsStrokeColor: PresentationThemeVariableColor, actionButtonsTextColor: PresentationThemeVariableColor, textSelectionColor: UIColor, textSelectionKnobColor: UIColor) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.linkTextColor = linkTextColor
        self.linkHighlightColor = linkHighlightColor
        self.scamColor = scamColor
        self.textHighlightColor = textHighlightColor
        self.accentTextColor = accentTextColor
        self.accentControlColor = accentControlColor
        self.accentControlDisabledColor = accentControlDisabledColor
        self.mediaActiveControlColor = mediaActiveControlColor
        self.mediaInactiveControlColor = mediaInactiveControlColor
        self.mediaControlInnerBackgroundColor = mediaControlInnerBackgroundColor
        self.pendingActivityColor = pendingActivityColor
        self.fileTitleColor = fileTitleColor
        self.fileDescriptionColor = fileDescriptionColor
        self.fileDurationColor = fileDurationColor
        self.mediaPlaceholderColor = mediaPlaceholderColor
        self.actionButtonsFillColor = actionButtonsFillColor
        self.actionButtonsStrokeColor = actionButtonsStrokeColor
        self.actionButtonsTextColor = actionButtonsTextColor
        self.textSelectionColor = textSelectionColor
        self.textSelectionKnobColor = textSelectionKnobColor
    }
    
    public func withUpdated(primaryTextColor: UIColor? = nil, secondaryTextColor: UIColor? = nil, linkTextColor: UIColor? = nil, linkHighlightColor: UIColor? = nil, scamColor: UIColor? = nil, textHighlightColor: UIColor? = nil, accentTextColor: UIColor? = nil, accentControlColor: UIColor? = nil, accentControlDisabledColor: UIColor? = nil, mediaActiveControlColor: UIColor? = nil, mediaInactiveControlColor: UIColor? = nil, mediaControlInnerBackgroundColor: UIColor? = nil, pendingActivityColor: UIColor? = nil, fileTitleColor: UIColor? = nil, fileDescriptionColor: UIColor? = nil, fileDurationColor: UIColor? = nil, mediaPlaceholderColor: UIColor? = nil, actionButtonsFillColor: PresentationThemeVariableColor? = nil, actionButtonsStrokeColor: PresentationThemeVariableColor? = nil, actionButtonsTextColor: PresentationThemeVariableColor? = nil, textSelectionColor: UIColor? = nil, textSelectionKnobColor: UIColor? = nil) -> PresentationThemePartedColors {
        return PresentationThemePartedColors(primaryTextColor: primaryTextColor ?? self.primaryTextColor, secondaryTextColor: secondaryTextColor ?? self.secondaryTextColor, linkTextColor: linkTextColor ?? self.linkTextColor, linkHighlightColor: linkHighlightColor ?? self.linkHighlightColor, scamColor: scamColor ?? self.scamColor, textHighlightColor: textHighlightColor ?? self.textHighlightColor, accentTextColor: accentTextColor ?? self.accentTextColor, accentControlColor: accentControlColor ?? self.accentControlColor, accentControlDisabledColor: accentControlDisabledColor ?? self.accentControlDisabledColor, mediaActiveControlColor: mediaActiveControlColor ?? self.mediaActiveControlColor, mediaInactiveControlColor: mediaInactiveControlColor ?? self.mediaInactiveControlColor, mediaControlInnerBackgroundColor: mediaControlInnerBackgroundColor ?? self.mediaControlInnerBackgroundColor, pendingActivityColor: pendingActivityColor ?? self.pendingActivityColor, fileTitleColor: fileTitleColor ?? self.fileTitleColor, fileDescriptionColor: fileDescriptionColor ?? self.fileDescriptionColor, fileDurationColor: fileDurationColor ?? self.fileDurationColor, mediaPlaceholderColor: mediaPlaceholderColor ?? self.mediaPlaceholderColor, actionButtonsFillColor: actionButtonsFillColor ?? self.actionButtonsFillColor, actionButtonsStrokeColor: actionButtonsStrokeColor ?? self.actionButtonsStrokeColor, actionButtonsTextColor: actionButtonsTextColor ?? self.actionButtonsTextColor, textSelectionColor: textSelectionColor ?? self.textSelectionColor, textSelectionKnobColor: textSelectionKnobColor ?? self.textSelectionKnobColor)
    }
}

internal final class PresentationThemeServiceMessageColorComponents {
    public let fill: UIColor
    public let primaryText: UIColor
    public let linkHighlight: UIColor
    public let scam: UIColor
    
    public let dateFillStatic: UIColor
    public let dateFillFloating: UIColor
    
    public init(fill: UIColor, primaryText: UIColor, linkHighlight: UIColor, scam: UIColor, dateFillStatic: UIColor, dateFillFloating: UIColor) {
        self.fill = fill
        self.primaryText = primaryText
        self.linkHighlight = linkHighlight
        self.scam = scam
        self.dateFillStatic = dateFillStatic
        self.dateFillFloating = dateFillFloating
    }
    
    public func withUpdated(fill: UIColor? = nil, primaryText: UIColor? = nil, linkHighlight: UIColor? = nil, scam: UIColor? = nil, dateFillStatic: UIColor? = nil, dateFillFloating: UIColor? = nil) -> PresentationThemeServiceMessageColorComponents {
        return PresentationThemeServiceMessageColorComponents(fill: fill ?? self.fill, primaryText: primaryText ?? self.primaryText, linkHighlight: linkHighlight ?? self.linkHighlight, scam: scam ?? self.scam, dateFillStatic: dateFillStatic ?? self.dateFillStatic, dateFillFloating: dateFillFloating ?? self.dateFillFloating)
    }
}


internal enum PresentationThemeKeyboardColor: Int32 {
    case light = 0
    case dark = 1
    
    public var keyboardAppearance: UIKeyboardAppearance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

internal final class PresentationThemeInputMediaPanel {
    public let panelSeparatorColor: UIColor
    public let panelIconColor: UIColor
    public let panelHighlightedIconBackgroundColor: UIColor
    public let panelHighlightedIconColor: UIColor
    public let panelContentVibrantOverlayColor: UIColor
    public let panelContentControlVibrantOverlayColor: UIColor
    public let panelContentControlVibrantSelectionColor: UIColor
    public let panelContentControlOpaqueOverlayColor: UIColor
    public let panelContentControlOpaqueSelectionColor: UIColor
    public let panelContentVibrantSearchOverlayColor: UIColor
    public let panelContentVibrantSearchOverlaySelectedColor: UIColor
    public let panelContentVibrantSearchOverlayHighlightColor: UIColor
    public let panelContentOpaqueSearchOverlayColor: UIColor
    public let panelContentOpaqueSearchOverlaySelectedColor: UIColor
    public let panelContentOpaqueSearchOverlayHighlightColor: UIColor
    public let stickersBackgroundColor: UIColor
    public let stickersSectionTextColor: UIColor
    public let stickersSearchBackgroundColor: UIColor
    public let stickersSearchPlaceholderColor: UIColor
    public let stickersSearchPrimaryColor: UIColor
    public let stickersSearchControlColor: UIColor
    public let gifsBackgroundColor: UIColor
    public let backgroundColor: UIColor
    
    public init(
        panelSeparatorColor: UIColor,
        panelIconColor: UIColor,
        panelHighlightedIconBackgroundColor: UIColor,
        panelHighlightedIconColor: UIColor,
        panelContentVibrantOverlayColor: UIColor,
        panelContentControlVibrantOverlayColor: UIColor,
        panelContentControlVibrantSelectionColor: UIColor,
        panelContentControlOpaqueOverlayColor: UIColor,
        panelContentControlOpaqueSelectionColor: UIColor,
        panelContentVibrantSearchOverlayColor: UIColor,
        panelContentVibrantSearchOverlaySelectedColor: UIColor,
        panelContentVibrantSearchOverlayHighlightColor: UIColor,
        panelContentOpaqueSearchOverlayColor: UIColor,
        panelContentOpaqueSearchOverlaySelectedColor: UIColor,
        panelContentOpaqueSearchOverlayHighlightColor: UIColor,
        stickersBackgroundColor: UIColor,
        stickersSectionTextColor: UIColor,
        stickersSearchBackgroundColor: UIColor,
        stickersSearchPlaceholderColor: UIColor,
        stickersSearchPrimaryColor: UIColor,
        stickersSearchControlColor: UIColor,
        gifsBackgroundColor: UIColor,
        backgroundColor: UIColor
    ) {
        self.panelSeparatorColor = panelSeparatorColor
        self.panelIconColor = panelIconColor
        self.panelHighlightedIconBackgroundColor = panelHighlightedIconBackgroundColor
        self.panelHighlightedIconColor = panelHighlightedIconColor
        self.panelContentVibrantOverlayColor = panelContentVibrantOverlayColor
        self.panelContentControlVibrantOverlayColor = panelContentControlVibrantOverlayColor
        self.panelContentControlVibrantSelectionColor = panelContentControlVibrantSelectionColor
        self.panelContentControlOpaqueOverlayColor = panelContentControlOpaqueOverlayColor
        self.panelContentControlOpaqueSelectionColor = panelContentControlOpaqueSelectionColor
        self.panelContentVibrantSearchOverlayColor = panelContentVibrantSearchOverlayColor
        self.panelContentVibrantSearchOverlaySelectedColor = panelContentVibrantSearchOverlaySelectedColor
        self.panelContentVibrantSearchOverlayHighlightColor = panelContentVibrantSearchOverlayHighlightColor
        self.panelContentOpaqueSearchOverlayColor = panelContentOpaqueSearchOverlayColor
        self.panelContentOpaqueSearchOverlaySelectedColor = panelContentOpaqueSearchOverlaySelectedColor
        self.panelContentOpaqueSearchOverlayHighlightColor = panelContentOpaqueSearchOverlayHighlightColor
        self.stickersBackgroundColor = stickersBackgroundColor
        self.stickersSectionTextColor = stickersSectionTextColor
        self.stickersSearchBackgroundColor = stickersSearchBackgroundColor
        self.stickersSearchPlaceholderColor = stickersSearchPlaceholderColor
        self.stickersSearchPrimaryColor = stickersSearchPrimaryColor
        self.stickersSearchControlColor = stickersSearchControlColor
        self.gifsBackgroundColor = gifsBackgroundColor
        self.backgroundColor = backgroundColor
    }
    
    public func withUpdated(
        panelSeparatorColor: UIColor? = nil,
        panelIconColor: UIColor? = nil,
        panelHighlightedIconBackgroundColor: UIColor? = nil,
        panelHighlightedIconColor: UIColor? = nil,
        panelContentVibrantOverlayColor: UIColor? = nil,
        panelContentControlVibrantOverlayColor: UIColor? = nil,
        panelContentControlVibrantSelectionColor: UIColor? = nil,
        panelContentControlOpaqueOverlayColor: UIColor? = nil,
        panelContentControlOpaqueSelectionColor: UIColor? = nil,
        panelContentVibrantSearchOverlayColor: UIColor? = nil,
        panelContentVibrantSearchOverlaySelectedColor: UIColor? = nil,
        panelContentVibrantSearchOverlayHighlightColor: UIColor? = nil,
        panelContentOpaqueSearchOverlayColor: UIColor? = nil,
        panelContentOpaqueSearchOverlaySelectedColor: UIColor? = nil,
        panelContentOpaqueSearchOverlayHighlightColor: UIColor? = nil,
        stickersBackgroundColor: UIColor? = nil,
        stickersSectionTextColor: UIColor? = nil,
        stickersSearchBackgroundColor: UIColor? = nil,
        stickersSearchPlaceholderColor: UIColor? = nil,
        stickersSearchPrimaryColor: UIColor? = nil,
        stickersSearchControlColor: UIColor? = nil,
        gifsBackgroundColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) -> PresentationThemeInputMediaPanel {
        return PresentationThemeInputMediaPanel(
            panelSeparatorColor: panelSeparatorColor ?? self.panelSeparatorColor,
            panelIconColor: panelIconColor ?? self.panelIconColor,
            panelHighlightedIconBackgroundColor: panelHighlightedIconBackgroundColor ?? self.panelHighlightedIconBackgroundColor,
            panelHighlightedIconColor: panelHighlightedIconColor ?? self.panelHighlightedIconColor,
            panelContentVibrantOverlayColor: panelContentVibrantOverlayColor ?? self.panelContentVibrantOverlayColor,
            panelContentControlVibrantOverlayColor: panelContentControlVibrantOverlayColor ?? self.panelContentControlVibrantOverlayColor,
            panelContentControlVibrantSelectionColor: panelContentControlVibrantSelectionColor ?? self.panelContentControlVibrantSelectionColor,
            panelContentControlOpaqueOverlayColor: panelContentControlOpaqueOverlayColor ?? self.panelContentControlOpaqueOverlayColor,
            panelContentControlOpaqueSelectionColor: panelContentControlOpaqueSelectionColor ?? self.panelContentControlOpaqueSelectionColor,
            panelContentVibrantSearchOverlayColor: panelContentVibrantSearchOverlayColor ?? self.panelContentVibrantSearchOverlayColor,
            panelContentVibrantSearchOverlaySelectedColor: panelContentVibrantSearchOverlaySelectedColor ?? self.panelContentVibrantSearchOverlaySelectedColor,
            panelContentVibrantSearchOverlayHighlightColor: panelContentVibrantSearchOverlayHighlightColor ?? self.panelContentVibrantSearchOverlayHighlightColor,
            panelContentOpaqueSearchOverlayColor: panelContentOpaqueSearchOverlayColor ?? self.panelContentOpaqueSearchOverlayColor,
            panelContentOpaqueSearchOverlaySelectedColor: panelContentOpaqueSearchOverlaySelectedColor ?? self.panelContentOpaqueSearchOverlaySelectedColor,
            panelContentOpaqueSearchOverlayHighlightColor: panelContentOpaqueSearchOverlayHighlightColor ?? self.panelContentOpaqueSearchOverlayHighlightColor,
            stickersBackgroundColor: stickersBackgroundColor ?? self.stickersBackgroundColor,
            stickersSectionTextColor: stickersSectionTextColor ?? self.stickersSectionTextColor,
            stickersSearchBackgroundColor: stickersSearchBackgroundColor ?? self.stickersSearchBackgroundColor,
            stickersSearchPlaceholderColor: stickersSearchPlaceholderColor ?? self.stickersSearchPlaceholderColor,
            stickersSearchPrimaryColor: stickersSearchPrimaryColor ?? self.stickersSearchPrimaryColor, stickersSearchControlColor: stickersSearchControlColor ?? self.stickersSearchControlColor,
            gifsBackgroundColor: gifsBackgroundColor ?? self.gifsBackgroundColor,
            backgroundColor: backgroundColor ?? self.backgroundColor
        )
    }
}

internal final class PresentationThemeInputButtonPanel {
    public let panelSeparatorColor: UIColor
    public let panelBackgroundColor: UIColor
    public let buttonFillColor: UIColor
    public let buttonHighlightColor: UIColor
    public let buttonStrokeColor: UIColor
    public let buttonHighlightedFillColor: UIColor
    public let buttonHighlightedStrokeColor: UIColor
    public let buttonTextColor: UIColor
    
    public init(panelSeparatorColor: UIColor, panelBackgroundColor: UIColor, buttonFillColor: UIColor, buttonHighlightColor: UIColor, buttonStrokeColor: UIColor, buttonHighlightedFillColor: UIColor, buttonHighlightedStrokeColor: UIColor, buttonTextColor: UIColor) {
        self.panelSeparatorColor = panelSeparatorColor
        self.panelBackgroundColor = panelBackgroundColor
        self.buttonFillColor = buttonFillColor
        self.buttonHighlightColor = buttonHighlightColor
        self.buttonStrokeColor = buttonStrokeColor
        self.buttonHighlightedFillColor = buttonHighlightedFillColor
        self.buttonHighlightedStrokeColor = buttonHighlightedStrokeColor
        self.buttonTextColor = buttonTextColor
    }
    
    public func withUpdated(panelSeparatorColor: UIColor? = nil, panelBackgroundColor: UIColor? = nil, buttonFillColor: UIColor? = nil, buttonHighlightColor: UIColor? = nil, buttonStrokeColor: UIColor? = nil, buttonHighlightedFillColor: UIColor? = nil, buttonHighlightedStrokeColor: UIColor? = nil, buttonTextColor: UIColor? = nil) -> PresentationThemeInputButtonPanel {
        return PresentationThemeInputButtonPanel(panelSeparatorColor: panelSeparatorColor ?? self.panelSeparatorColor, panelBackgroundColor: panelBackgroundColor ?? self.panelBackgroundColor, buttonFillColor: buttonFillColor ?? self.buttonFillColor, buttonHighlightColor: buttonHighlightColor ?? self.buttonHighlightColor, buttonStrokeColor: buttonStrokeColor ?? self.buttonStrokeColor, buttonHighlightedFillColor: buttonHighlightedFillColor ?? self.buttonHighlightedFillColor, buttonHighlightedStrokeColor: buttonHighlightedStrokeColor ?? self.buttonHighlightedStrokeColor, buttonTextColor: buttonTextColor ?? self.buttonTextColor)
    }
}

internal enum PresentationThemeExpandedNotificationBackgroundType: Int32 {
    case light
    case dark
}

internal final class PresentationThemeExpandedNotificationNavigationBar {
    public let backgroundColor: UIColor
    public let primaryTextColor: UIColor
    public let controlColor: UIColor
    public let separatorColor: UIColor
    
    init(backgroundColor: UIColor, primaryTextColor: UIColor, controlColor: UIColor, separatorColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
        self.controlColor = controlColor
        self.separatorColor = separatorColor
    }
    
    public func withUpdated(backgroundColor: UIColor? = nil, primaryTextColor: UIColor? = nil, controlColor: UIColor? = nil, separatorColor: UIColor? = nil) -> PresentationThemeExpandedNotificationNavigationBar {
        return PresentationThemeExpandedNotificationNavigationBar(backgroundColor: backgroundColor ?? self.backgroundColor, primaryTextColor: primaryTextColor ?? self.primaryTextColor, controlColor: controlColor ?? self.controlColor, separatorColor: separatorColor ?? self.separatorColor)
    }
}

internal final class PresentationThemeExpandedNotification {
    public let backgroundType: PresentationThemeExpandedNotificationBackgroundType
    public let navigationBar: PresentationThemeExpandedNotificationNavigationBar
    
    public init(backgroundType: PresentationThemeExpandedNotificationBackgroundType, navigationBar: PresentationThemeExpandedNotificationNavigationBar) {
        self.backgroundType = backgroundType
        self.navigationBar = navigationBar
    }
    
    public func withUpdated(backgroundType: PresentationThemeExpandedNotificationBackgroundType? = nil, navigationBar: PresentationThemeExpandedNotificationNavigationBar? = nil) -> PresentationThemeExpandedNotification {
        return PresentationThemeExpandedNotification(backgroundType: backgroundType ?? self.backgroundType, navigationBar: navigationBar ?? self.navigationBar)
    }
}

internal final class PresentationThemeInAppNotification {
    public let fillColor: UIColor
    public let primaryTextColor: UIColor
    
    public let expandedNotification: PresentationThemeExpandedNotification
    
    public init(fillColor: UIColor, primaryTextColor: UIColor, expandedNotification: PresentationThemeExpandedNotification) {
        self.fillColor = fillColor
        self.primaryTextColor = primaryTextColor
        self.expandedNotification = expandedNotification
    }
    
    public func withUpdated(fillColor: UIColor? = nil, primaryTextColor: UIColor? = nil, expandedNotification: PresentationThemeExpandedNotification? = nil) -> PresentationThemeInAppNotification {
        return PresentationThemeInAppNotification(fillColor: fillColor ?? self.fillColor, primaryTextColor: primaryTextColor ?? self.primaryTextColor, expandedNotification: expandedNotification ?? self.expandedNotification)
    }
}

internal final class PresentationThemeChart {
    public let labelsColor: UIColor
    public let helperLinesColor: UIColor
    public let strongLinesColor: UIColor
    public let barStrongLinesColor: UIColor
    public let detailsTextColor: UIColor
    public let detailsArrowColor: UIColor
    public let detailsViewColor: UIColor
    public let rangeViewFrameColor: UIColor
    public let rangeViewMarkerColor: UIColor
    
    public init(labelsColor: UIColor, helperLinesColor: UIColor, strongLinesColor: UIColor, barStrongLinesColor: UIColor, detailsTextColor: UIColor, detailsArrowColor: UIColor, detailsViewColor: UIColor, rangeViewFrameColor: UIColor, rangeViewMarkerColor: UIColor) {
        self.labelsColor = labelsColor
        self.helperLinesColor = helperLinesColor
        self.strongLinesColor = strongLinesColor
        self.barStrongLinesColor = barStrongLinesColor
        self.detailsTextColor = detailsTextColor
        self.detailsArrowColor = detailsArrowColor
        self.detailsViewColor = detailsViewColor
        self.rangeViewFrameColor = rangeViewFrameColor
        self.rangeViewMarkerColor = rangeViewMarkerColor
    }
    
    public func withUpdated(labelsColor: UIColor? = nil, helperLinesColor: UIColor? = nil, strongLinesColor: UIColor? = nil, barStrongLinesColor: UIColor? = nil, detailsTextColor: UIColor? = nil, detailsArrowColor: UIColor? = nil, detailsViewColor: UIColor? = nil, rangeViewFrameColor: UIColor? = nil, rangeViewMarkerColor: UIColor? = nil) -> PresentationThemeChart {
        return PresentationThemeChart(labelsColor: labelsColor ?? self.labelsColor, helperLinesColor: helperLinesColor ?? self.helperLinesColor, strongLinesColor: strongLinesColor ?? self.strongLinesColor, barStrongLinesColor: barStrongLinesColor ?? self.barStrongLinesColor, detailsTextColor: detailsTextColor ?? self.detailsTextColor, detailsArrowColor: detailsArrowColor ?? self.detailsArrowColor, detailsViewColor: detailsViewColor ?? self.detailsViewColor, rangeViewFrameColor: rangeViewFrameColor ?? self.rangeViewFrameColor, rangeViewMarkerColor: rangeViewMarkerColor ?? self.rangeViewMarkerColor)
    }
}

internal enum PresentationThemeBuiltinName {
    case dayClassic
    case day
    case night
    case nightAccent
    
    public var reference: PresentationBuiltinThemeReference {
        switch self {
            case .dayClassic:
                return .dayClassic
            case .day:
                return .day
            case .night:
                return .night
            case .nightAccent:
                return .nightAccent
        }
    }
}

internal enum PresentationThemeName: Equatable {
    case builtin(PresentationThemeBuiltinName)
    case custom(String)
    
    public static func ==(lhs: PresentationThemeName, rhs: PresentationThemeName) -> Bool {
        switch lhs {
            case let .builtin(name):
                if case .builtin(name) = rhs {
                    return true
                } else {
                    return false
                }
            case let .custom(name):
                if case .custom(name) = rhs {
                    return true
                } else {
                    return false
                }
        }
    }
    
    public var string: String {
        switch self {
            case let .builtin(name):
                switch name {
                    case .day:
                        return "Day"
                    case .dayClassic:
                        return "Classic"
                    case .night:
                        return "Night"
                    case .nightAccent:
                        return "Tinted Night"
                }
            case let .custom(name):
                return name
        }
    }
}

internal extension PresentationThemeReference {
    var name: PresentationThemeName {
        switch self {
            case let .builtin(theme):
                switch theme {
                    case .day:
                        return .builtin(.day)
                    case .dayClassic:
                        return .builtin(.dayClassic)
                    case .night:
                        return .builtin(.night)
                    case .nightAccent:
                        return .builtin(.nightAccent)
                }
            default:
                return .custom("")
        }
    }
}

internal final class PresentationTheme: Equatable {
    public let name: PresentationThemeName
    public let index: Int64
    public let referenceTheme: PresentationBuiltinThemeReference
    public let overallDarkAppearance: Bool
    public let intro: PresentationThemeIntro
    public let passcode: PresentationThemePasscode
    public let rootController: PresentationThemeRootController
    public let list: PresentationThemeList
    public let actionSheet: PresentationThemeActionSheet
    public let contextMenu: PresentationThemeContextMenu
    public let inAppNotification: PresentationThemeInAppNotification
    public let preview: Bool
    public var forceSync: Bool = false
    
    public let resourceCache: PresentationsResourceCache = PresentationsResourceCache()
    
    public init(name: PresentationThemeName, index: Int64, referenceTheme: PresentationBuiltinThemeReference, overallDarkAppearance: Bool, intro: PresentationThemeIntro, passcode: PresentationThemePasscode, rootController: PresentationThemeRootController, list: PresentationThemeList, actionSheet: PresentationThemeActionSheet, contextMenu: PresentationThemeContextMenu, inAppNotification: PresentationThemeInAppNotification, preview: Bool = false) {
        var overallDarkAppearance = overallDarkAppearance
        if [.night, .tinted].contains(referenceTheme.baseTheme) {
            overallDarkAppearance = true
        }
        
        self.name = name
        self.index = index
        self.referenceTheme = referenceTheme
        self.overallDarkAppearance = overallDarkAppearance
        self.intro = intro
        self.passcode = passcode
        self.rootController = rootController
        self.list = list
        self.actionSheet = actionSheet
        self.contextMenu = contextMenu
        self.inAppNotification = inAppNotification
        self.preview = preview
    }
    
    public func image(_ key: Int32, _ generate: (PresentationTheme) -> UIImage?) -> UIImage? {
        return self.resourceCache.image(key, self, generate)
    }
    
    public func image(_ key: PresentationResourceParameterKey, _ generate: (PresentationTheme) -> UIImage?) -> UIImage? {
        return self.resourceCache.parameterImage(key, self, generate)
    }
    
    public func object(_ key: Int32, _ generate: (PresentationTheme) -> AnyObject?) -> AnyObject? {
        return self.resourceCache.object(key, self, generate)
    }
    
    public func object(_ key: PresentationResourceParameterKey, _ generate: (PresentationTheme) -> AnyObject?) -> AnyObject? {
        return self.resourceCache.parameterObject(key, self, generate)
    }
    
    public static func ==(lhs: PresentationTheme, rhs: PresentationTheme) -> Bool {
        return lhs === rhs
    }
    
    public func withUpdated(name: String?) -> PresentationTheme {
        return PresentationTheme(name: name.flatMap(PresentationThemeName.custom) ?? .custom(self.name.string), index: self.index, referenceTheme: self.referenceTheme, overallDarkAppearance: self.overallDarkAppearance, intro: self.intro, passcode: self.passcode, rootController: self.rootController, list: self.list, actionSheet: self.actionSheet, contextMenu: self.contextMenu, inAppNotification: self.inAppNotification, preview: self.preview)
    }
    
    public func withUpdated(referenceTheme: PresentationBuiltinThemeReference) -> PresentationTheme {
        return PresentationTheme(name: self.name, index: self.index, referenceTheme: referenceTheme, overallDarkAppearance: self.overallDarkAppearance, intro: self.intro, passcode: self.passcode, rootController: self.rootController, list: self.list,actionSheet: self.actionSheet, contextMenu: self.contextMenu, inAppNotification: self.inAppNotification, preview: self.preview)
    }
    
    public func withUpdated(preview: Bool) -> PresentationTheme {
        return PresentationTheme(name: self.name, index: self.index, referenceTheme: self.referenceTheme, overallDarkAppearance: self.overallDarkAppearance, intro: self.intro, passcode: self.passcode, rootController: self.rootController, list: self.list, actionSheet: self.actionSheet, contextMenu: self.contextMenu, inAppNotification: self.inAppNotification, preview: preview)
    }
    
    public func withModalBlocksBackground() -> PresentationTheme {
        if self.list.blocksBackgroundColor.rgb == self.list.plainBackgroundColor.rgb {
            let list = self.list.withUpdated(blocksBackgroundColor: self.list.modalBlocksBackgroundColor, itemBlocksBackgroundColor: self.list.itemModalBlocksBackgroundColor)
            return PresentationTheme(name: self.name, index: self.index, referenceTheme: self.referenceTheme, overallDarkAppearance: self.overallDarkAppearance, intro: self.intro, passcode: self.passcode, rootController: self.rootController, list: list, actionSheet: self.actionSheet, contextMenu: self.contextMenu, inAppNotification: self.inAppNotification, preview: self.preview)
        } else {
            return self
        }
    }
}
