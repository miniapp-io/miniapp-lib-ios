import Foundation
import UIKit

internal func dateFillNeedsBlur(theme: PresentationTheme) -> Bool {
    if !DeviceMetrics.performance.isGraphicallyCapable {
        return false
    }
    return true
}

internal let defaultServiceBackgroundColor = UIColor(rgb: 0x000000, alpha: 0.2)
internal let defaultPresentationTheme = makeDefaultDayPresentationTheme(serviceBackgroundColor: defaultServiceBackgroundColor, day: false, preview: false)
internal let defaultDayAccentColor = UIColor(rgb: 0x007aff)

internal func customizeDefaultDayTheme(theme: PresentationTheme, editing: Bool, title: String?, accentColor: UIColor?, outgoingAccentColor: UIColor?, backgroundColors: [UInt32], bubbleColors: [UInt32], animateBubbleColors: Bool?, serviceBackgroundColor: UIColor?) -> PresentationTheme {
    if (theme.referenceTheme != .day && theme.referenceTheme != .dayClassic) {
        return theme
    }
    
    var intro = theme.intro
    var rootController = theme.rootController
    var list = theme.list
    var actionSheet = theme.actionSheet
    
    var accentColor = accentColor
    if let initialAccentColor = accentColor, initialAccentColor.lightness > 0.705 {
        let hsb = initialAccentColor.hsb
        accentColor = UIColor(hue: hsb.0, saturation: min(1.0, hsb.1 * 1.1), brightness: min(hsb.2, 0.6), alpha: 1.0)
    }
    
    if let accentColor = accentColor {
        intro = intro.withUpdated(accentTextColor: accentColor)
        rootController = rootController.withUpdated(
            tabBar: rootController.tabBar.withUpdated(selectedIconColor: accentColor, selectedTextColor: accentColor),
            navigationBar: rootController.navigationBar.withUpdated(buttonColor: accentColor, accentTextColor: accentColor),
            navigationSearchBar: rootController.navigationSearchBar.withUpdated(accentColor: accentColor)
        )
        list = list.withUpdated(
            itemAccentColor: accentColor,
            itemDisclosureActions: list.itemDisclosureActions.withUpdated(accent: list.itemDisclosureActions.accent.withUpdated(fillColor: accentColor)),
            itemCheckColors: list.itemCheckColors.withUpdated(fillColor: accentColor),
            itemBarChart: list.itemBarChart.withUpdated(color1: accentColor)
        )
        actionSheet = actionSheet.withUpdated(
            standardActionTextColor: accentColor,
            controlAccentColor: accentColor
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

internal func makeDefaultDayPresentationTheme(extendingThemeReference: PresentationThemeReference? = nil, serviceBackgroundColor: UIColor?, day: Bool, preview: Bool) -> PresentationTheme {
    
    let intro = PresentationThemeIntro(
        statusBarStyle: .black,
        primaryTextColor: UIColor(rgb: 0x000000),
        accentTextColor: defaultDayAccentColor,
        disabledTextColor: UIColor(rgb: 0xd0d0d0),
        startButtonColor: UIColor(rgb: 0x2ca5e0),
        dotColor: UIColor(rgb: 0xd9d9d9)
    )
    
    let passcode = PresentationThemePasscode(
        backgroundColors: PresentationThemeGradientColors(topColor: UIColor(rgb: 0x46739e), bottomColor: UIColor(rgb: 0x2a5982)),
        buttonColor: .clear
    )
    
    let rootNavigationBar = PresentationThemeRootNavigationBar(
        buttonColor: defaultDayAccentColor,
        disabledButtonColor: UIColor(rgb: 0xd0d0d0),
        primaryTextColor: UIColor(rgb: 0x000000),
        secondaryTextColor: UIColor(rgb: 0x787878),
        controlColor: UIColor(rgb: 0x7e8791),
        accentTextColor: defaultDayAccentColor,
        blurredBackgroundColor: UIColor(rgb: 0xf2f2f2, alpha: 0.9),
        opaqueBackgroundColor: UIColor(rgb: 0xf7f7f7).mixedWith(.white, alpha: 0.14),
        separatorColor: UIColor(rgb: 0xc8c7cc),
        badgeBackgroundColor: UIColor(rgb: 0xff3b30),
        badgeStrokeColor: UIColor(rgb: 0xff3b30),
        badgeTextColor: UIColor(rgb: 0xffffff),
        segmentedBackgroundColor: UIColor(rgb: 0x000000, alpha: 0.06),
        segmentedForegroundColor: UIColor(rgb: 0xf7f7f7),
        segmentedTextColor: UIColor(rgb: 0x000000),
        segmentedDividerColor: UIColor(rgb: 0xd6d6dc),
        clearButtonBackgroundColor: UIColor(rgb: 0xE3E3E3, alpha: 0.78),
        clearButtonForegroundColor: UIColor(rgb: 0x7f7f7f)
    )

    let rootTabBar = PresentationThemeRootTabBar(
        backgroundColor: rootNavigationBar.blurredBackgroundColor,
        separatorColor: UIColor(rgb: 0xb2b2b2),
        iconColor: UIColor(rgb: 0x959595),
        selectedIconColor: defaultDayAccentColor,
        textColor: UIColor(rgb: 0x959595),
        selectedTextColor: defaultDayAccentColor,
        badgeBackgroundColor: UIColor(rgb: 0xff3b30),
        badgeStrokeColor: UIColor(rgb: 0xff3b30),
        badgeTextColor: UIColor(rgb: 0xffffff)
    )
    
    let navigationSearchBar = PresentationThemeNavigationSearchBar(
        backgroundColor: UIColor(rgb: 0xffffff),
        accentColor: defaultDayAccentColor,
        inputFillColor: UIColor(rgb: 0x000000, alpha: 0.06),
        inputTextColor: UIColor(rgb: 0x000000),
        inputPlaceholderTextColor: UIColor(rgb: 0x8e8e93),
        inputIconColor: UIColor(rgb: 0x8e8e93),
        inputClearButtonColor: UIColor(rgb: 0x7b7b81),
        separatorColor: UIColor(rgb: 0xc8c7cc)
    )
        
    let rootController = PresentationThemeRootController(
        statusBarStyle: .black,
        tabBar: rootTabBar,
        navigationBar: rootNavigationBar,
        navigationSearchBar: navigationSearchBar,
        keyboardColor: .light
    )
    
    let switchColors = PresentationThemeSwitch(
        frameColor: UIColor(rgb: 0xe9e9ea),
        handleColor: UIColor(rgb: 0xffffff),
        contentColor: UIColor(rgb: 0x35c759),
        positiveColor: UIColor(rgb: 0x00c900),
        negativeColor: UIColor(rgb: 0xff3b30)
    )
    
    let list = PresentationThemeList(
        blocksBackgroundColor: UIColor(rgb: 0xefeff4),
        modalBlocksBackgroundColor: UIColor(rgb: 0xefeff4),
        plainBackgroundColor: UIColor(rgb: 0xffffff),
        modalPlainBackgroundColor: UIColor(rgb: 0xffffff),
        itemPrimaryTextColor: UIColor(rgb: 0x000000),
        itemSecondaryTextColor: UIColor(rgb: 0x8e8e93),
        itemDisabledTextColor: UIColor(rgb: 0x8e8e93),
        itemAccentColor: defaultDayAccentColor,
        itemHighlightedColor: UIColor(rgb: 0x00b12c),
        itemDestructiveColor: UIColor(rgb: 0xff3b30),
        itemPlaceholderTextColor: UIColor(rgb: 0xc8c8ce),
        itemBlocksBackgroundColor: UIColor(rgb: 0xffffff),
        itemModalBlocksBackgroundColor: UIColor(rgb: 0xffffff),
        itemHighlightedBackgroundColor: UIColor(rgb: 0xe5e5ea),
        itemBlocksSeparatorColor: UIColor(rgb: 0xc8c7cc),
        itemPlainSeparatorColor: UIColor(rgb: 0xc8c7cc),
        disclosureArrowColor: UIColor(rgb: 0xbab9be),
        sectionHeaderTextColor: UIColor(rgb: 0x6d6d72),
        freeTextColor: UIColor(rgb: 0x6d6d72),
        freeTextErrorColor: UIColor(rgb: 0xcf3030),
        freeTextSuccessColor: UIColor(rgb: 0x26972c),
        freeMonoIconColor: UIColor(rgb: 0x7e7e87),
        itemSwitchColors: switchColors,
        itemDisclosureActions: PresentationThemeItemDisclosureActions(
            neutral1: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x4892f2), foregroundColor: UIColor(rgb: 0xffffff)),
            neutral2: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xf09a37), foregroundColor: UIColor(rgb: 0xffffff)),
            destructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xff3824), foregroundColor: UIColor(rgb: 0xffffff)),
            constructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x00c900), foregroundColor: UIColor(rgb: 0xffffff)),
            accent: PresentationThemeFillForeground(fillColor: defaultDayAccentColor, foregroundColor: UIColor(rgb: 0xffffff)),
            warning: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xff9500), foregroundColor: UIColor(rgb: 0xffffff)),
            inactive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xbcbcc3), foregroundColor: UIColor(rgb: 0xffffff))
        ),
        itemCheckColors: PresentationThemeFillStrokeForeground(
            fillColor: defaultDayAccentColor,
            strokeColor: UIColor(rgb: 0xc7c7cc),
            foregroundColor: UIColor(rgb: 0xffffff)
        ),
        controlSecondaryColor: UIColor(rgb: 0xdedede),
        freeInputField: PresentationInputFieldTheme(
            backgroundColor: UIColor(rgb: 0xd6d6dc),
            strokeColor: UIColor(rgb: 0xd6d6dc),
            placeholderColor: UIColor(rgb: 0x96979d),
            primaryColor: UIColor(rgb: 0x000000),
            controlColor: UIColor(rgb: 0x96979d)
        ),
        freePlainInputField: PresentationInputFieldTheme(
            backgroundColor: UIColor(rgb: 0xe9e9e9),
            strokeColor: UIColor(rgb: 0xe9e9e9),
            placeholderColor: UIColor(rgb: 0x8e8d92),
            primaryColor: UIColor(rgb: 0x000000),
            controlColor: UIColor(rgb: 0xbcbcc0)
        ),
        mediaPlaceholderColor: UIColor(rgb: 0xEFEFF4),
        scrollIndicatorColor: UIColor(white: 0.0, alpha: 0.3),
        pageIndicatorInactiveColor: UIColor(rgb: 0xe3e3e7),
        inputClearButtonColor: UIColor(rgb: 0xcccccc),
        itemBarChart: PresentationThemeItemBarChart(color1: defaultDayAccentColor, color2: UIColor(rgb: 0xc8c7cc), color3: UIColor(rgb: 0xf2f1f7)),
        itemInputField: PresentationInputFieldTheme(backgroundColor: UIColor(rgb: 0xf2f2f7), strokeColor: UIColor(rgb: 0xf2f2f7), placeholderColor: UIColor(rgb: 0xb6b6bb), primaryColor: UIColor(rgb: 0x000000), controlColor: UIColor(rgb: 0xb6b6bb)),
        paymentOption: PresentationThemeList.PaymentOption(
            inactiveFillColor: UIColor(rgb: 0x00A650).withMultipliedAlpha(0.1),
            inactiveForegroundColor: UIColor(rgb: 0x00A650),
            activeFillColor: UIColor(rgb: 0x00A650),
            activeForegroundColor: UIColor(rgb: 0xffffff)
        )
    )
    
    let actionSheet = PresentationThemeActionSheet(
        dimColor: UIColor(white: 0.0, alpha: 0.4),
        backgroundType: .light,
        opaqueItemBackgroundColor: UIColor(rgb: 0xffffff),
        itemBackgroundColor: UIColor(white: 1.0, alpha: 0.8),
        opaqueItemHighlightedBackgroundColor: UIColor(white: 0.9, alpha: 1.0),
        itemHighlightedBackgroundColor: UIColor(white: 0.9, alpha: 0.7),
        opaqueItemSeparatorColor: UIColor(white: 0.9, alpha: 1.0),
        standardActionTextColor: defaultDayAccentColor,
        destructiveActionTextColor: UIColor(rgb: 0xff3b30),
        disabledActionTextColor: UIColor(rgb: 0xb3b3b3),
        primaryTextColor: UIColor(rgb: 0x000000),
        secondaryTextColor: UIColor(rgb: 0x8e8e93),
        controlAccentColor: defaultDayAccentColor,
        inputBackgroundColor: UIColor(rgb: 0xe9e9e9),
        inputHollowBackgroundColor: UIColor(rgb: 0xffffff),
        inputBorderColor: UIColor(rgb: 0xe4e4e6),
        inputPlaceholderColor: UIColor(rgb: 0x8e8d92),
        inputTextColor: UIColor(rgb: 0x000000),
        inputClearButtonColor: UIColor(rgb: 0x9e9ea1),
        checkContentColor: UIColor(rgb: 0xffffff)
    )
    
    let contextMenu = PresentationThemeContextMenu(
        dimColor: UIColor(rgb: 0x000a26, alpha: 0.2),
        backgroundColor: UIColor(rgb: 0xf9f9f9, alpha: 0.78),
        itemSeparatorColor: UIColor(rgb: 0x3c3c43, alpha: 0.2),
        sectionSeparatorColor: UIColor(rgb: 0x8a8a8a, alpha: 0.2),
        itemBackgroundColor: UIColor(rgb: 0x000000, alpha: 0.0),
        itemHighlightedBackgroundColor: UIColor(rgb: 0x3c3c43, alpha: 0.2),
        primaryColor: UIColor(rgb: 0x000000),
        secondaryColor: UIColor(rgb: 0x000000, alpha: 0.5),
        destructiveColor: UIColor(rgb: 0xff3b30),
        badgeFillColor: defaultDayAccentColor,
        badgeForegroundColor: UIColor(rgb: 0xffffff),
        badgeInactiveFillColor: UIColor(rgb: 0xb6b6bb),
        badgeInactiveForegroundColor: UIColor(rgb: 0xffffff),
        extractedContentTintColor: .white
    )
    
    let inAppNotification = PresentationThemeInAppNotification(
        fillColor: UIColor(rgb: 0xffffff),
        primaryTextColor: UIColor(rgb: 0x000000),
        expandedNotification: PresentationThemeExpandedNotification(
            backgroundType: .light,
            navigationBar: PresentationThemeExpandedNotificationNavigationBar(
                backgroundColor: UIColor(rgb: 0xffffff),
                primaryTextColor: UIColor(rgb: 0x000000),
                controlColor: UIColor(rgb: 0x7e8791),
                separatorColor: UIColor(rgb: 0xc8c7cc)
            )
        )
    )
    
    return PresentationTheme(
        name: extendingThemeReference?.name ?? .builtin(day ? .day : .dayClassic),
        index: extendingThemeReference?.index ?? PresentationThemeReference.builtin(day ? .day : .dayClassic).index,
        referenceTheme: day ? .day : .dayClassic,
        overallDarkAppearance: false,
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

internal let legacyBuiltinWallpaperGradientColors: [UIColor] = [
    UIColor(rgb: 0xd6e2ee)
]

internal let defaultBuiltinWallpaperGradientColors: [UIColor] = [
    UIColor(rgb: 0xdbddbb),
    UIColor(rgb: 0x6ba587),
    UIColor(rgb: 0xd5d88d),
    UIColor(rgb: 0x88b884)
]
