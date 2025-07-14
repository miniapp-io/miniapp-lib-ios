import Foundation
import UIKit

internal extension PresentationFontSize {
    init(systemFontSize: CGFloat) {
        var closestIndex = 0
        let allSizes = PresentationFontSize.allCases
        for i in 0 ..< allSizes.count {
            if abs(allSizes[i].baseDisplaySize - systemFontSize) < abs(allSizes[closestIndex].baseDisplaySize - systemFontSize) {
                closestIndex = i
            }
        }
        self = allSizes[closestIndex]
    }
}

internal extension PresentationFontSize {
    var baseDisplaySize: CGFloat {
        switch self {
        case .extraSmall:
            return 14.0
        case .small:
            return 15.0
        case .medium:
            return 16.0
        case .regular:
            return 17.0
        case .large:
            return 19.0
        case .extraLarge:
            return 23.0
        case .extraLargeX2:
            return 26.0
        }
    }
}

internal extension ToolbarTheme {
    convenience init(rootControllerTheme: PresentationTheme) {
        let theme = rootControllerTheme.rootController.tabBar
        self.init(barBackgroundColor: theme.backgroundColor, barSeparatorColor: theme.separatorColor, barTextColor: theme.textColor, barSelectedTextColor: theme.selectedTextColor)
    }
}

internal extension NavigationBarTheme {
    convenience init(resourceProvider: IResourceProvider, enableBackgroundBlur: Bool = true, hideBackground: Bool = false, hideBadge: Bool = false, hideSeparator: Bool = false) {
        self.init(buttonColor: resourceProvider.getColor(key: KEY_NAVIGATION_BAR_BUTTON_COLOR),
                  disabledButtonColor: resourceProvider.getColor(key: KEY_NAVIGATION_BAR_DISABLED_BUTTON_COLOR),
                  primaryTextColor: resourceProvider.getColor(key: KEY_NAVIGATION_BAR_PRIMARY_TEXT_COLOR),
                  backgroundColor: hideBackground ? .clear : resourceProvider.getColor(key: KEY_NAVIGATION_BAR_BLURRED_BACKGROUND_COLOR),
                  enableBackgroundBlur: enableBackgroundBlur,
                  separatorColor: hideBackground || hideSeparator ? .clear : resourceProvider.getColor(key: KEY_NAVIGATION_BAR_SEPARATOR_COLOR),
                  badgeBackgroundColor: hideBadge ? .clear : resourceProvider.getColor(key: KEY_NAVIGATION_BAR_BADGE_BACKGROUND_COLOR),
                  badgeStrokeColor: hideBadge ? .clear : resourceProvider.getColor(key: KEY_NAVIGATION_BAR_BADGE_STROKE_COLOR),
                  badgeTextColor: hideBadge ? .clear : resourceProvider.getColor(key: KEY_NAVIGATION_BAR_BADGE_TEXT_COLOR))
    }
}

internal extension NavigationBarStrings {
    convenience init(resourceProvider: IResourceProvider) {
        self.init(back: resourceProvider.getString(key: "Common.Back") ?? "", close: resourceProvider.getString(key: "Common.Close") ?? "")
    }
}

internal extension NavigationBarPresentationData {
    convenience init(presentationData: PresentationData, resourceProvider: IResourceProvider) {
        self.init(resourceProvider: resourceProvider, strings: NavigationBarStrings(resourceProvider: resourceProvider))
    }
}

internal extension ActionSheetControllerTheme {
    
    convenience init(resourceProvider: IResourceProvider, fontSize: PresentationFontSize) {
        self.init(dimColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_DIM_COLOR),
                  backgroundType: resourceProvider.isDark() ? .dark : .light,
                  itemBackgroundColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_ITEM_BACKGROUND_COLOR),
                  itemHighlightedBackgroundColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_ITEM_HIGHLIGHTED_BACKGROUND_COLOR),
                  standardActionTextColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_STANDARD_ACTION_TEXT_COLOR),
                  destructiveActionTextColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_DESTRUCTIVE_ACTION_TEXT_COLOR),
                  disabledActionTextColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_DISABLED_ACTION_TEXT_COLOR),
                  primaryTextColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_PRIMARY_TEXT_COLOR),
                  secondaryTextColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_SECONDARY_TEXT_COLOR),
                  controlAccentColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_CONTROL_ACCENT_COLOR),
                  controlColor: resourceProvider.getColor(key: KEY_ITEM_CHECK_DISCLOSURE_ARROW_COLOR),
                  switchFrameColor: resourceProvider.getColor(key: KEY_ITEM_SWITCH_FRAME_COLOR),
                  switchContentColor: resourceProvider.getColor(key: KEY_ITEM_SWITCH_CONTENT_COLOR),
                  switchHandleColor: resourceProvider.getColor(key: KEY_ITEM_SWITCH_HANDLE_COLOR),
                  baseFontSize: fontSize.baseDisplaySize)
    }
}

internal extension ActionSheetController {
    convenience init(resourceProvider: IResourceProvider, allowInputInset: Bool = false) {
        self.init(theme: ActionSheetControllerTheme(resourceProvider: resourceProvider, fontSize: .regular), allowInputInset: allowInputInset)
    }
}

internal extension AlertControllerTheme {
    convenience init(resourceProvider: IResourceProvider, fontSize: PresentationFontSize) {
        self.init(backgroundType: resourceProvider.isDark() ? .dark : .light,
                  backgroundColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_ITEM_BACKGROUND_COLOR),
                  separatorColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_ITEM_HIGHLIGHTED_BACKGROUND_COLOR),
                  highlightedItemColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_ITEM_HIGHLIGHTED_BACKGROUND_COLOR),
                  primaryColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_PRIMARY_TEXT_COLOR),
                  secondaryColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_SECONDARY_TEXT_COLOR),
                  accentColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_CONTROL_ACCENT_COLOR),
                  contrastColor: resourceProvider.getColor(key: KEY_BUTTON_TEXT_COLOR),
                  destructiveColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_DESTRUCTIVE_ACTION_TEXT_COLOR),
                  disabledColor: resourceProvider.getColor(key: KEY_ACTION_SHEET_DISABLED_ACTION_TEXT_COLOR),
                  controlBorderColor: resourceProvider.getColor(key: KEY_ITEM_CHECK_STROKE_COLOR),
                  baseFontSize: fontSize.baseDisplaySize)
    }
}

internal extension NavigationControllerTheme {
    convenience init(resourceProvider: IResourceProvider) {
        self.init(statusBar: resourceProvider.isDark() ? .black : .white, navigationBar: NavigationBarTheme(resourceProvider: resourceProvider), emptyAreaColor: resourceProvider.getColor(key: KEY_BG_COLOR))
    }
}

