import Foundation
import UIKit

internal let defaultDarkPresentationTheme = makeDefaultDarkPresentationTheme(preview: false)
internal let defaultDarkColorPresentationTheme = customizeDefaultDarkPresentationTheme(theme: defaultDarkPresentationTheme, editing: false, title: nil, accentColor: UIColor(rgb: 0x3e88f7), backgroundColors: [], bubbleColors: [], animateBubbleColors: false, baseColor: nil)

internal func customizeDefaultDarkPresentationTheme(theme: PresentationTheme, editing: Bool, title: String?, accentColor: UIColor?, backgroundColors: [UInt32], bubbleColors: [UInt32], animateBubbleColors: Bool?, baseColor: PresentationThemeBaseColor? = nil) -> PresentationTheme {
    if (theme.referenceTheme != .night) {
        return theme
    }
       
    var intro = theme.intro
    var rootController = theme.rootController
    var list = theme.list
    var actionSheet = theme.actionSheet
    
    var bubbleColors = bubbleColors
    var monochrome = false
    if bubbleColors.isEmpty, editing {
        let accentColor = accentColor ?? UIColor(rgb: 0xffffff)
        if accentColor.rgb == 0xffffff {
            monochrome = true
            bubbleColors = [UIColor(rgb: 0x313131).rgb, UIColor(rgb: 0x313131).rgb]
        } else if accentColor.rgb == 0x3e88f7 {
            bubbleColors = [
                0x0771ff,
                0x9047ff,
                0xa256bf,
            ].reversed()
        } else {
            bubbleColors = [accentColor.withMultiplied(hue: 0.966, saturation: 0.61, brightness: 0.98).rgb, accentColor.rgb]
        }
    } else {
        let accentColor = accentColor ?? UIColor(rgb: 0xffffff)
        if accentColor.rgb == 0xffffff {
            monochrome = true
        }
    }
    
    var badgeFillColor: UIColor?
    var badgeTextColor: UIColor?
    var secondaryBadgeTextColor: UIColor?
    
    var accentColor = accentColor
    if let initialAccentColor = accentColor {
        if monochrome {
            badgeFillColor = UIColor(rgb: 0xffffff)
            badgeTextColor = UIColor(rgb: 0x000000)
            secondaryBadgeTextColor = UIColor(rgb: 0x000000)
        } else {
            badgeFillColor = UIColor(rgb: 0xeb5545)
            badgeTextColor = UIColor(rgb: 0xffffff)
            if initialAccentColor.lightness > 0.735 {
                secondaryBadgeTextColor = UIColor(rgb: 0x000000)
            } else {
                secondaryBadgeTextColor = UIColor(rgb: 0xffffff)
                
                let hsb = initialAccentColor.hsb
                accentColor = UIColor(hue: hsb.0, saturation: hsb.1, brightness: max(hsb.2, 0.55), alpha: 1.0)
            }
        }
        
        intro = intro.withUpdated(accentTextColor: accentColor, startButtonColor: accentColor)
        rootController = rootController.withUpdated(
            tabBar: rootController.tabBar.withUpdated(selectedIconColor: accentColor, selectedTextColor: accentColor, badgeBackgroundColor: badgeFillColor, badgeTextColor: badgeTextColor),
            navigationBar: rootController.navigationBar.withUpdated(buttonColor: accentColor, accentTextColor: accentColor, badgeBackgroundColor: badgeFillColor, badgeTextColor: badgeTextColor),
            navigationSearchBar: rootController.navigationSearchBar.withUpdated(accentColor: accentColor)
        )
        list = list.withUpdated(
            itemAccentColor: accentColor,
            itemCheckColors: list.itemCheckColors.withUpdated(fillColor: accentColor, foregroundColor: secondaryBadgeTextColor),
            itemBarChart: list.itemBarChart.withUpdated(color1: accentColor)
        )
        actionSheet = actionSheet.withUpdated(
            standardActionTextColor: accentColor,
            controlAccentColor: accentColor,
            checkContentColor: secondaryBadgeTextColor
        )
    }
    
    return PresentationTheme(
        name: title.flatMap { .custom($0) } ?? theme.name,
        index: theme.index,
        referenceTheme: theme.referenceTheme,
        overallDarkAppearance: theme.overallDarkAppearance,
        intro: intro,
        passcode: theme.passcode,
        rootController: rootController,
        list: list,
        actionSheet: actionSheet,
        contextMenu: theme.contextMenu,
        inAppNotification: theme.inAppNotification,
        preview: theme.preview
    )
}

internal let defaultDarkWallpaperGradientColors: [UIColor] = [
    UIColor(rgb: 0x598bf6),
    UIColor(rgb: 0x7a5eef),
    UIColor(rgb: 0xd67cff),
    UIColor(rgb: 0xf38b58)
]

internal func makeDefaultDarkPresentationTheme(extendingThemeReference: PresentationThemeReference? = nil, preview: Bool) -> PresentationTheme {
    let rootNavigationBar = PresentationThemeRootNavigationBar(
        buttonColor: UIColor(rgb: 0xffffff),
        disabledButtonColor: UIColor(rgb: 0x525252),
        primaryTextColor: UIColor(rgb: 0xffffff),
        secondaryTextColor: UIColor(rgb: 0xffffff, alpha: 0.5),
        controlColor: UIColor(rgb: 0x767676),
        accentTextColor: UIColor(rgb: 0xffffff),
        blurredBackgroundColor: UIColor(rgb: 0x1d1d1d, alpha: 0.9),
        opaqueBackgroundColor: UIColor(rgb: 0x1d1d1d).mixedWith(UIColor(rgb: 0x000000), alpha: 0.1),
        separatorColor: UIColor(rgb: 0x545458, alpha: 0.55),
        badgeBackgroundColor:  UIColor(rgb: 0xffffff),
        badgeStrokeColor: UIColor(rgb: 0x1c1c1d),
        badgeTextColor:  UIColor(rgb: 0x000000),
        segmentedBackgroundColor: UIColor(rgb: 0x3a3b3d),
        segmentedForegroundColor: UIColor(rgb: 0x6f7075),
        segmentedTextColor: UIColor(rgb: 0xffffff),
        segmentedDividerColor: UIColor(rgb: 0x505155),
        clearButtonBackgroundColor: UIColor(rgb: 0xffffff, alpha: 0.1),
        clearButtonForegroundColor: UIColor(rgb: 0xffffff)
    )

    let rootTabBar = PresentationThemeRootTabBar(
        backgroundColor: rootNavigationBar.blurredBackgroundColor,
        separatorColor: UIColor(rgb: 0x545458, alpha: 0.55),
        iconColor: UIColor(rgb: 0x828282),
        selectedIconColor: UIColor(rgb: 0xffffff),
        textColor: UIColor(rgb: 0x828282),
        selectedTextColor: UIColor(rgb: 0xffffff),
        badgeBackgroundColor:  UIColor(rgb: 0xffffff),
        badgeStrokeColor: UIColor(rgb: 0x1c1c1d),
        badgeTextColor:  UIColor(rgb: 0x000000)
    )

    let navigationSearchBar = PresentationThemeNavigationSearchBar(
        backgroundColor: UIColor(rgb: 0x1c1c1d),
        accentColor: UIColor(rgb: 0xffffff),
        inputFillColor: UIColor(rgb: 0x0f0f0f),
        inputTextColor: UIColor(rgb: 0xffffff),
        inputPlaceholderTextColor: UIColor(rgb: 0x8f8f8f),
        inputIconColor: UIColor(rgb: 0x8f8f8f),
        inputClearButtonColor: UIColor(rgb: 0x8f8f8f),
        separatorColor: UIColor(rgb: 0x545458, alpha: 0.55)
    )

    let intro = PresentationThemeIntro(
        statusBarStyle: .white,
        primaryTextColor: UIColor(rgb: 0xffffff),
        accentTextColor: UIColor(rgb: 0xffffff),
        disabledTextColor: UIColor(rgb: 0x525252),
        startButtonColor: UIColor(rgb: 0xffffff),
        dotColor: UIColor(rgb: 0x5e5e5e)
    )

    let passcode = PresentationThemePasscode(
        backgroundColors: PresentationThemeGradientColors(topColor: UIColor(rgb: 0x000000), bottomColor: UIColor(rgb: 0x000000)),
        buttonColor: UIColor(rgb: 0x1c1c1d)
    )

    let rootController = PresentationThemeRootController(
        statusBarStyle: .white,
        tabBar: rootTabBar,
        navigationBar: rootNavigationBar,
        navigationSearchBar: navigationSearchBar,
        keyboardColor: .dark
    )

    let switchColors = PresentationThemeSwitch(
        frameColor: UIColor(rgb: 0x39393d),
        handleColor: UIColor(rgb: 0x121212),
        contentColor: UIColor(rgb: 0x67ce67),
        positiveColor: UIColor(rgb: 0x08a723),
        negativeColor: UIColor(rgb: 0xeb5545)
    )

    let list = PresentationThemeList(
        blocksBackgroundColor: UIColor(rgb: 0x000000),
        modalBlocksBackgroundColor: UIColor(rgb: 0x1c1c1d),
        plainBackgroundColor: UIColor(rgb: 0x000000),
        modalPlainBackgroundColor: UIColor(rgb: 0x1c1c1d),
        itemPrimaryTextColor: UIColor(rgb: 0xffffff),
        itemSecondaryTextColor: UIColor(rgb: 0x98989e),
        itemDisabledTextColor: UIColor(rgb: 0x8f8f8f),
        itemAccentColor: UIColor(rgb: 0xffffff),
        itemHighlightedColor: UIColor(rgb: 0x28b772),
        itemDestructiveColor: UIColor(rgb: 0xeb5545),
        itemPlaceholderTextColor: UIColor(rgb: 0x4d4d4d),
        itemBlocksBackgroundColor: UIColor(rgb: 0x1c1c1d),
        itemModalBlocksBackgroundColor: UIColor(rgb: 0x2c2c2e),
        itemHighlightedBackgroundColor: UIColor(rgb: 0x313135),
        itemBlocksSeparatorColor: UIColor(rgb: 0x545458, alpha: 0.55),
        itemPlainSeparatorColor: UIColor(rgb: 0x545458, alpha: 0.55),
        disclosureArrowColor: UIColor(rgb: 0xffffff, alpha: 0.28),
        sectionHeaderTextColor: UIColor(rgb: 0x8d8e93),
        freeTextColor: UIColor(rgb: 0x8d8e93),
        freeTextErrorColor: UIColor(rgb: 0xcf3030),
        freeTextSuccessColor: UIColor(rgb: 0x30cf30),
        freeMonoIconColor: UIColor(rgb: 0x8d8e93),
        itemSwitchColors: switchColors,
        itemDisclosureActions: PresentationThemeItemDisclosureActions(
            neutral1: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x666666), foregroundColor: UIColor(rgb: 0xffffff)),
            neutral2: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xcd7800), foregroundColor: UIColor(rgb: 0xffffff)),
            destructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xc70c0c), foregroundColor: UIColor(rgb: 0xffffff)),
            constructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x08a723), foregroundColor: UIColor(rgb: 0xffffff)),
            accent: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x666666), foregroundColor: UIColor(rgb: 0xffffff)),
            warning: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xcd7800), foregroundColor: UIColor(rgb: 0xffffff)),
            inactive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x666666), foregroundColor: UIColor(rgb: 0xffffff))
        ),
        itemCheckColors: PresentationThemeFillStrokeForeground(
            fillColor: UIColor(rgb: 0xffffff),
            strokeColor: UIColor(rgb: 0xffffff, alpha: 0.3),
            foregroundColor:  UIColor(rgb: 0x000000)
        ),
        controlSecondaryColor: UIColor(rgb: 0xffffff, alpha: 0.5),
        freeInputField: PresentationInputFieldTheme(
            backgroundColor: UIColor(rgb: 0x272728),
            strokeColor: UIColor(rgb: 0x272728),
            placeholderColor: UIColor(rgb: 0x98989e),
            primaryColor: UIColor(rgb: 0xffffff),
            controlColor: UIColor(rgb: 0x98989e)
        ),
        freePlainInputField: PresentationInputFieldTheme(
            backgroundColor: UIColor(rgb: 0x272728),
            strokeColor: UIColor(rgb: 0x272728),
            placeholderColor: UIColor(rgb: 0x98989e),
            primaryColor: UIColor(rgb: 0xffffff),
            controlColor: UIColor(rgb: 0x98989e)
        ),
        mediaPlaceholderColor: UIColor(rgb: 0xffffff).mixedWith(UIColor(rgb: 0x1c1c1d), alpha: 0.9),
        scrollIndicatorColor: UIColor(rgb: 0xffffff, alpha: 0.5),
        pageIndicatorInactiveColor: UIColor(white: 1.0, alpha: 0.3),
        inputClearButtonColor: UIColor(rgb: 0x8b9197),
        itemBarChart: PresentationThemeItemBarChart(color1: UIColor(rgb: 0xffffff), color2: UIColor(rgb: 0x929196), color3: UIColor(rgb: 0x333333)),
        itemInputField: PresentationInputFieldTheme(backgroundColor: UIColor(rgb: 0x0f0f0f), strokeColor: UIColor(rgb: 0x0f0f0f), placeholderColor: UIColor(rgb: 0x8f8f8f), primaryColor: UIColor(rgb: 0xffffff), controlColor: UIColor(rgb: 0x8f8f8f)),
        paymentOption: PresentationThemeList.PaymentOption(
            inactiveFillColor: UIColor(rgb: 0x00A650).withMultipliedAlpha(0.3),
            inactiveForegroundColor: UIColor(rgb: 0x00A650),
            activeFillColor: UIColor(rgb: 0x00A650),
            activeForegroundColor: UIColor(rgb: 0xffffff)
        )
    )

    let actionSheet = PresentationThemeActionSheet(
        dimColor: UIColor(white: 0.0, alpha: 0.5),
        backgroundType: .dark,
        opaqueItemBackgroundColor: UIColor(rgb: 0x1c1c1d),
        itemBackgroundColor: UIColor(rgb: 0x1c1c1d, alpha: 0.8),
        opaqueItemHighlightedBackgroundColor: UIColor(white: 0.0, alpha: 1.0),
        itemHighlightedBackgroundColor: UIColor(rgb: 0x000000, alpha: 0.5),
        opaqueItemSeparatorColor: UIColor(rgb: 0x545458, alpha: 0.55),
        standardActionTextColor: UIColor(rgb: 0xffffff),
        destructiveActionTextColor: UIColor(rgb: 0xeb5545),
        disabledActionTextColor: UIColor(rgb: 0x4d4d4d),
        primaryTextColor: UIColor(rgb: 0xffffff),
        secondaryTextColor: UIColor(rgb: 0x5e5e5e),
        controlAccentColor: UIColor(rgb: 0xffffff),
        inputBackgroundColor: UIColor(rgb: 0x0f0f0f),
        inputHollowBackgroundColor: UIColor(rgb: 0x0f0f0f),
        inputBorderColor: UIColor(rgb: 0x0f0f0f),
        inputPlaceholderColor: UIColor(rgb: 0x8f8f8f),
        inputTextColor: UIColor(rgb: 0xffffff),
        inputClearButtonColor: UIColor(rgb: 0x8f8f8f),
        checkContentColor:  UIColor(rgb: 0x000000)
    )
    
    let contextMenu = PresentationThemeContextMenu(
        dimColor: UIColor(rgb: 0x000000, alpha: 0.6),
        backgroundColor: UIColor(rgb: 0x252525, alpha: 0.78),
        itemSeparatorColor: UIColor(rgb: 0xffffff, alpha: 0.15),
        sectionSeparatorColor: UIColor(rgb: 0x000000, alpha: 0.2),
        itemBackgroundColor: UIColor(rgb: 0x000000, alpha: 0.0),
        itemHighlightedBackgroundColor: UIColor(rgb: 0xffffff, alpha: 0.15),
        primaryColor: UIColor(rgb: 0xffffff, alpha: 1.0),
        secondaryColor: UIColor(rgb: 0xffffff, alpha: 0.5),
        destructiveColor: UIColor(rgb: 0xeb5545),
        badgeFillColor: UIColor(rgb: 0xffffff),
        badgeForegroundColor: UIColor(rgb: 0x000000),
        badgeInactiveFillColor: UIColor(rgb: 0xffffff).withAlphaComponent(0.5),
        badgeInactiveForegroundColor: UIColor(rgb: 0x000000),
        extractedContentTintColor: UIColor(rgb: 0xffffff, alpha: 1.0)
    )

    let inAppNotification = PresentationThemeInAppNotification(
        fillColor: UIColor(rgb: 0x1c1c1d),
        primaryTextColor: UIColor(rgb: 0xffffff),
        expandedNotification: PresentationThemeExpandedNotification(
            backgroundType: .dark,
            navigationBar: PresentationThemeExpandedNotificationNavigationBar(
                backgroundColor: UIColor(rgb: 0x1c1c1d),
                primaryTextColor: UIColor(rgb: 0xffffff),
                controlColor: UIColor(rgb: 0xffffff),
                separatorColor: UIColor(rgb: 0x000000)
            )
        )
    )

    return PresentationTheme(
        name: extendingThemeReference?.name ?? .builtin(.night),
        index: extendingThemeReference?.index ?? PresentationThemeReference.builtin(.night).index,
        referenceTheme: .night,
        overallDarkAppearance: true,
        intro: intro,
        passcode: passcode,
        rootController: rootController,
        list: list,
        actionSheet: actionSheet,
        contextMenu: contextMenu,
        inAppNotification: inAppNotification,
        preview: preview
    )
}
