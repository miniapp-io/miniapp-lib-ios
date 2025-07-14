import Foundation
import UIKit

private let defaultDarkTintedAccentColor = UIColor(rgb: 0x2ea6ff)
internal let defaultDarkTintedPresentationTheme = makeDefaultDarkTintedPresentationTheme(preview: false)

internal func customizeDefaultDarkTintedPresentationTheme(theme: PresentationTheme, editing: Bool, title: String?, accentColor: UIColor?, backgroundColors: [UInt32], bubbleColors: [UInt32], animateBubbleColors: Bool?, baseColor: PresentationThemeBaseColor? = nil) -> PresentationTheme {
    if (theme.referenceTheme != .nightAccent) {
        return theme
    }
    
    var accentColor = accentColor
    if accentColor == PresentationThemeBaseColor.blue.color {
        accentColor = defaultDarkTintedAccentColor
    }
    
    var intro = theme.intro
    var passcode = theme.passcode
    var rootController = theme.rootController
    var list = theme.list
    var actionSheet = theme.actionSheet
    var contextMenu = theme.contextMenu
    var inAppNotification = theme.inAppNotification
    
    var mainBackgroundColor: UIColor?
    var mainSelectionColor: UIColor?
    var additionalBackgroundColor: UIColor?
    var mainSeparatorColor: UIColor?
    var mainForegroundColor: UIColor?
    var mainSecondaryColor: UIColor?
    var mainSecondaryTextColor: UIColor?
    var mainFreeTextColor: UIColor?
    var secondaryBadgeTextColor: UIColor
    var mainInputColor: UIColor?
    
    var bubbleColors = bubbleColors
    if bubbleColors.isEmpty, editing {
        let accentColor = accentColor ?? defaultDarkTintedAccentColor
        let bottomColor = accentColor.withMultiplied(hue: 1.019, saturation: 0.731, brightness: 0.59)
        let topColor = bottomColor.withMultiplied(hue: 0.966, saturation: 0.61, brightness: 0.98)
        bubbleColors = [topColor.rgb, bottomColor.rgb]
    }
    
    if let initialAccentColor = accentColor {
        let hsb = initialAccentColor.hsb
        accentColor = UIColor(hue: hsb.0, saturation: hsb.1, brightness: max(hsb.2, 0.18), alpha: 1.0)
        
        if let lightness = accentColor?.lightness, lightness > 0.7 {
            secondaryBadgeTextColor = UIColor(rgb: 0x000000)
        } else {
            secondaryBadgeTextColor = UIColor(rgb: 0xffffff)
        }
        
        mainBackgroundColor = accentColor?.withMultiplied(hue: 1.024, saturation: 0.585, brightness: 0.25)
        mainSelectionColor = accentColor?.withMultiplied(hue: 1.03, saturation: 0.585, brightness: 0.12)
        additionalBackgroundColor = accentColor?.withMultiplied(hue: 1.024, saturation: 0.573, brightness: 0.18)
        mainSeparatorColor = accentColor?.withMultiplied(hue: 1.033, saturation: 0.426, brightness: 0.34)
        mainForegroundColor = accentColor?.withMultiplied(hue: 0.99, saturation: 0.256, brightness: 0.62)
        mainSecondaryColor = accentColor?.withMultiplied(hue: 1.019, saturation: 0.109, brightness: 0.59)
        mainSecondaryTextColor = accentColor?.withMultiplied(hue: 0.956, saturation: 0.17, brightness: 1.0)
        mainFreeTextColor = accentColor?.withMultiplied(hue: 1.019, saturation: 0.097, brightness: 0.56)
        mainInputColor = accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.19)
        
        intro = intro.withUpdated(
            accentTextColor: accentColor,
            disabledTextColor: accentColor?.withMultiplied(hue: 1.033, saturation: 0.219, brightness: 0.44),
            startButtonColor: accentColor,
            dotColor: mainSecondaryColor
        )
        passcode = passcode.withUpdated(backgroundColors: passcode.backgroundColors.withUpdated(topColor: accentColor?.withMultiplied(hue: 1.049, saturation: 0.573, brightness: 0.47), bottomColor: additionalBackgroundColor), buttonColor: mainBackgroundColor)
        rootController = rootController.withUpdated(
            tabBar: rootController.tabBar.withUpdated(
                backgroundColor: mainBackgroundColor?.withAlphaComponent(0.9),
                separatorColor: mainSeparatorColor,
                iconColor: mainForegroundColor,
                selectedIconColor: accentColor,
                textColor: mainForegroundColor,
                selectedTextColor: accentColor
            ),
            navigationBar: rootController.navigationBar.withUpdated(
                buttonColor: accentColor,
                disabledButtonColor: accentColor?.withMultiplied(hue: 1.033, saturation: 0.219, brightness: 0.44),
                secondaryTextColor: mainSecondaryColor,
                controlColor: mainSecondaryColor,
                accentTextColor: accentColor,
                blurredBackgroundColor: mainBackgroundColor?.withAlphaComponent(0.9),
                opaqueBackgroundColor: mainBackgroundColor,
                separatorColor: mainSeparatorColor,
                segmentedBackgroundColor: mainInputColor,
                segmentedForegroundColor: mainBackgroundColor,
                segmentedDividerColor: mainSecondaryTextColor?.withAlphaComponent(0.5)
            ),
            navigationSearchBar: rootController.navigationSearchBar.withUpdated(
                backgroundColor: mainBackgroundColor,
                accentColor: accentColor,
                inputFillColor: mainInputColor,
                inputPlaceholderTextColor: mainSecondaryColor,
                inputIconColor: mainSecondaryColor,
                inputClearButtonColor: mainSecondaryColor,
                separatorColor: additionalBackgroundColor
            )
        )
        list = list.withUpdated(
            blocksBackgroundColor: additionalBackgroundColor,
            plainBackgroundColor: additionalBackgroundColor,
            itemSecondaryTextColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
            itemDisabledTextColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
            itemAccentColor: accentColor,
            itemPlaceholderTextColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
            itemBlocksBackgroundColor: mainBackgroundColor,
            itemHighlightedBackgroundColor: mainSelectionColor,
            itemBlocksSeparatorColor: mainSeparatorColor,
            itemPlainSeparatorColor: mainSeparatorColor,
            disclosureArrowColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
            sectionHeaderTextColor: mainFreeTextColor,
            freeTextColor: mainFreeTextColor,
            freeMonoIconColor: mainFreeTextColor,
            itemSwitchColors: list.itemSwitchColors.withUpdated(
                frameColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
                contentColor: accentColor
            ),
            itemDisclosureActions: list.itemDisclosureActions.withUpdated(
                neutral1: list.itemDisclosureActions.neutral1.withUpdated(fillColor: accentColor),
                accent: list.itemDisclosureActions.accent.withUpdated(fillColor: accentColor),
                inactive: list.itemDisclosureActions.inactive.withUpdated(fillColor: accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.3))
            ),
            itemCheckColors: list.itemCheckColors.withUpdated(
                fillColor: accentColor,
                strokeColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
                foregroundColor: secondaryBadgeTextColor
            ),
            controlSecondaryColor: mainSecondaryTextColor?.withAlphaComponent(0.5),
            freeInputField: list.freeInputField.withUpdated(
                backgroundColor: accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
                strokeColor: accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12)
            ),
            freePlainInputField: list.freePlainInputField.withUpdated(
                backgroundColor: accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
                strokeColor: accentColor?.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12)
            ),
            mediaPlaceholderColor: UIColor(rgb: 0xffffff).mixedWith(mainBackgroundColor ?? list.itemBlocksBackgroundColor, alpha: 0.9),
            pageIndicatorInactiveColor: mainSecondaryTextColor?.withAlphaComponent(0.4),
            inputClearButtonColor: mainSecondaryColor,
            itemBarChart: list.itemBarChart.withUpdated(
                color1: accentColor,
                color2: mainSecondaryTextColor?.withAlphaComponent(0.5),
                color3: accentColor?.withMultiplied(hue: 1.038, saturation: 0.329, brightness: 0.33)
            )
        )
        actionSheet = actionSheet.withUpdated(
            opaqueItemBackgroundColor: mainBackgroundColor,
            itemBackgroundColor: mainBackgroundColor?.withAlphaComponent(0.8),
            opaqueItemHighlightedBackgroundColor: mainSelectionColor,
            itemHighlightedBackgroundColor: mainSelectionColor?.withAlphaComponent(0.2),
            opaqueItemSeparatorColor: additionalBackgroundColor,
            standardActionTextColor: accentColor,
            controlAccentColor: accentColor,
            inputBackgroundColor: mainInputColor,
            inputHollowBackgroundColor: mainInputColor,
            inputBorderColor: mainInputColor,
            inputPlaceholderColor: mainSecondaryColor,
            inputClearButtonColor: mainSecondaryColor,
            checkContentColor: secondaryBadgeTextColor
        )
        contextMenu = contextMenu.withUpdated(backgroundColor: mainBackgroundColor?.withAlphaComponent(0.78))
        inAppNotification = inAppNotification.withUpdated(
            fillColor: mainBackgroundColor,
            expandedNotification: inAppNotification.expandedNotification.withUpdated(navigationBar: inAppNotification.expandedNotification.navigationBar.withUpdated(
                backgroundColor: mainBackgroundColor,
                controlColor: accentColor,
                separatorColor: mainSeparatorColor)
            )
        )
    }
    
    return PresentationTheme(
        name: title.flatMap { .custom($0) } ?? theme.name,
        index: theme.index,
        referenceTheme: theme.referenceTheme,
        overallDarkAppearance: theme.overallDarkAppearance,
        intro: intro,
        passcode: passcode,
        rootController: rootController,
        list: list,
        actionSheet: actionSheet,
        contextMenu: contextMenu,
        inAppNotification: inAppNotification,
        preview: theme.preview
    )
}

internal func makeDefaultDarkTintedPresentationTheme(extendingThemeReference: PresentationThemeReference? = nil, preview: Bool) -> PresentationTheme {
    let accentColor = defaultDarkTintedAccentColor
    
    let secondaryBadgeTextColor: UIColor
    let lightness = accentColor.lightness
    if lightness > 0.7 {
        secondaryBadgeTextColor = .black
    } else {
        secondaryBadgeTextColor = .white
    }
    
    let mainBackgroundColor = accentColor.withMultiplied(hue: 1.024, saturation: 0.585, brightness: 0.25)
    let mainSelectionColor = accentColor.withMultiplied(hue: 1.03, saturation: 0.585, brightness: 0.12)
    let additionalBackgroundColor = accentColor.withMultiplied(hue: 1.024, saturation: 0.573, brightness: 0.18)
    let mainSeparatorColor = accentColor.withMultiplied(hue: 1.033, saturation: 0.426, brightness: 0.34)
    let mainForegroundColor = accentColor.withMultiplied(hue: 0.99, saturation: 0.256, brightness: 0.62)
    let mainSecondaryColor = accentColor.withMultiplied(hue: 1.019, saturation: 0.109, brightness: 0.59)
    let mainSecondaryTextColor = accentColor.withMultiplied(hue: 0.956, saturation: 0.17, brightness: 1.0)
    let mainFreeTextColor = accentColor.withMultiplied(hue: 1.019, saturation: 0.097, brightness: 0.56)
    
    let mainInputColor = accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.19)

    let rootTabBar = PresentationThemeRootTabBar(
        backgroundColor: mainBackgroundColor,
        separatorColor: mainSeparatorColor,
        iconColor: mainForegroundColor,
        selectedIconColor: accentColor,
        textColor: mainForegroundColor,
        selectedTextColor: accentColor,
        badgeBackgroundColor: UIColor(rgb: 0xef5b5b),
        badgeStrokeColor: UIColor(rgb: 0xef5b5b),
        badgeTextColor: UIColor(rgb: 0xffffff)
    )

    let rootNavigationBar = PresentationThemeRootNavigationBar(
        buttonColor: accentColor,
        disabledButtonColor: accentColor.withMultiplied(hue: 1.033, saturation: 0.219, brightness: 0.44),
        primaryTextColor: .white,
        secondaryTextColor: mainSecondaryColor,
        controlColor: mainSecondaryColor,
        accentTextColor: accentColor,
        blurredBackgroundColor: mainBackgroundColor.withAlphaComponent(0.9),
        opaqueBackgroundColor: mainBackgroundColor,
        separatorColor: mainSeparatorColor,
        badgeBackgroundColor: UIColor(rgb: 0xef5b5b),
        badgeStrokeColor: UIColor(rgb: 0xef5b5b),
        badgeTextColor: UIColor(rgb: 0xffffff),
        segmentedBackgroundColor: mainInputColor,
        segmentedForegroundColor: mainBackgroundColor,
        segmentedTextColor: UIColor(rgb: 0xffffff),
        segmentedDividerColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        clearButtonBackgroundColor: UIColor(rgb: 0xffffff, alpha: 0.1),
        clearButtonForegroundColor: UIColor(rgb: 0xffffff)
    )

    let navigationSearchBar = PresentationThemeNavigationSearchBar(
        backgroundColor: mainBackgroundColor,
        accentColor: accentColor,
        inputFillColor: mainInputColor,
        inputTextColor: UIColor(rgb: 0xffffff),
        inputPlaceholderTextColor: mainSecondaryColor,
        inputIconColor: mainSecondaryColor,
        inputClearButtonColor: mainSecondaryColor,
        separatorColor: additionalBackgroundColor
    )

    let intro = PresentationThemeIntro(
        statusBarStyle: .white,
        primaryTextColor: .white,
        accentTextColor: accentColor,
        disabledTextColor: accentColor.withMultiplied(hue: 1.033, saturation: 0.219, brightness: 0.44),
        startButtonColor: accentColor,
        dotColor: mainSecondaryColor
    )

    let passcode = PresentationThemePasscode(
        backgroundColors: PresentationThemeGradientColors(topColor: accentColor.withMultiplied(hue: 1.049, saturation: 0.573, brightness: 0.47), bottomColor: additionalBackgroundColor),
        buttonColor: mainBackgroundColor
    )

    let rootController = PresentationThemeRootController(
        statusBarStyle: .white,
        tabBar: rootTabBar,
        navigationBar: rootNavigationBar,
        navigationSearchBar: navigationSearchBar,
        keyboardColor: .dark
    )

    let switchColors = PresentationThemeSwitch(
        frameColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        handleColor: UIColor(rgb: 0x121212),
        contentColor: accentColor,
        positiveColor: UIColor(rgb: 0x08a723),
        negativeColor: UIColor(rgb: 0xff6767)
    )

    let list = PresentationThemeList(
        blocksBackgroundColor: additionalBackgroundColor,
        modalBlocksBackgroundColor: additionalBackgroundColor,
        plainBackgroundColor: additionalBackgroundColor,
        modalPlainBackgroundColor: mainBackgroundColor,
        itemPrimaryTextColor: UIColor(rgb: 0xffffff),
        itemSecondaryTextColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        itemDisabledTextColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        itemAccentColor: accentColor,
        itemHighlightedColor: UIColor(rgb: 0x28b772),
        itemDestructiveColor: UIColor(rgb: 0xff6767),
        itemPlaceholderTextColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        itemBlocksBackgroundColor: mainBackgroundColor,
        itemModalBlocksBackgroundColor: mainBackgroundColor,
        itemHighlightedBackgroundColor: mainSelectionColor,
        itemBlocksSeparatorColor: mainSeparatorColor,
        itemPlainSeparatorColor: mainSeparatorColor,
        disclosureArrowColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        sectionHeaderTextColor: mainFreeTextColor,
        freeTextColor: mainFreeTextColor,
        freeTextErrorColor: UIColor(rgb: 0xff6767),
        freeTextSuccessColor: UIColor(rgb: 0x30cf30),
        freeMonoIconColor: mainFreeTextColor,
        itemSwitchColors: switchColors,
        itemDisclosureActions: PresentationThemeItemDisclosureActions(
            neutral1: PresentationThemeFillForeground(fillColor: accentColor, foregroundColor: .white),
            neutral2: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xcd7800), foregroundColor: .white),
            destructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xc70c0c), foregroundColor: .white),
            constructive: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0x08a723), foregroundColor: .white),
            accent: PresentationThemeFillForeground(fillColor: accentColor, foregroundColor: .white),
            warning: PresentationThemeFillForeground(fillColor: UIColor(rgb: 0xcd7800), foregroundColor: .white),
            inactive: PresentationThemeFillForeground(fillColor: accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.3), foregroundColor: .white)
        ),
        itemCheckColors: PresentationThemeFillStrokeForeground(
            fillColor: accentColor,
            strokeColor: mainSecondaryTextColor.withAlphaComponent(0.5),
            foregroundColor: secondaryBadgeTextColor
        ),
        controlSecondaryColor: mainSecondaryTextColor.withAlphaComponent(0.5),
        freeInputField: PresentationInputFieldTheme(
            backgroundColor: accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
            strokeColor: accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
            placeholderColor: mainSecondaryTextColor.withAlphaComponent(0.5),
            primaryColor: .white,
            controlColor: mainSecondaryTextColor.withAlphaComponent(0.5)
        ),
        freePlainInputField: PresentationInputFieldTheme(
            backgroundColor: accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
            strokeColor: accentColor.withMultiplied(hue: 1.029, saturation: 0.609, brightness: 0.12),
            placeholderColor: mainSecondaryTextColor.withAlphaComponent(0.5),
            primaryColor: .white,
            controlColor: mainSecondaryTextColor.withAlphaComponent(0.5)
        ),
        mediaPlaceholderColor: UIColor(rgb: 0xffffff).mixedWith(mainBackgroundColor, alpha: 0.9),
        scrollIndicatorColor: UIColor(white: 1.0, alpha: 0.5),
        pageIndicatorInactiveColor: mainSecondaryTextColor.withAlphaComponent(0.4),
        inputClearButtonColor: mainSecondaryColor,
        itemBarChart: PresentationThemeItemBarChart(color1: accentColor, color2: mainSecondaryTextColor.withAlphaComponent(0.5), color3: accentColor.withMultiplied(hue: 1.038, saturation: 0.329, brightness: 0.33)),
        itemInputField: PresentationInputFieldTheme(backgroundColor: mainInputColor, strokeColor: mainInputColor, placeholderColor: mainSecondaryColor, primaryColor: UIColor(rgb: 0xffffff), controlColor: mainSecondaryColor),
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
        opaqueItemBackgroundColor: mainBackgroundColor,
        itemBackgroundColor: mainBackgroundColor.withAlphaComponent(0.8),
        opaqueItemHighlightedBackgroundColor: mainSelectionColor,
        itemHighlightedBackgroundColor: mainSelectionColor.withAlphaComponent(0.2),
        opaqueItemSeparatorColor: additionalBackgroundColor,
        standardActionTextColor: accentColor,
        destructiveActionTextColor: UIColor(rgb: 0xff6767),
        disabledActionTextColor: UIColor(white: 1.0, alpha: 0.5),
        primaryTextColor: .white,
        secondaryTextColor: UIColor(white: 1.0, alpha: 0.5),
        controlAccentColor: accentColor,
        inputBackgroundColor: mainInputColor,
        inputHollowBackgroundColor: mainInputColor,
        inputBorderColor: mainInputColor,
        inputPlaceholderColor: mainSecondaryColor,
        inputTextColor: .white,
        inputClearButtonColor: mainSecondaryColor,
        checkContentColor: secondaryBadgeTextColor
    )
    
    let contextMenu = PresentationThemeContextMenu(
        dimColor: UIColor(rgb: 0x000000, alpha: 0.6),
        backgroundColor: rootNavigationBar.opaqueBackgroundColor.withAlphaComponent(0.78),
        itemSeparatorColor: UIColor(rgb: 0xffffff, alpha: 0.15),
        sectionSeparatorColor: UIColor(rgb: 0x000000, alpha: 0.2),
        itemBackgroundColor: UIColor(rgb: 0x000000, alpha: 0.0),
        itemHighlightedBackgroundColor: UIColor(rgb: 0xffffff, alpha: 0.15),
        primaryColor: UIColor(rgb: 0xffffff, alpha: 1.0),
        secondaryColor: UIColor(rgb: 0xffffff, alpha: 0.5),
        destructiveColor: UIColor(rgb: 0xff6767),
        badgeFillColor: accentColor,
        badgeForegroundColor: secondaryBadgeTextColor,
        badgeInactiveFillColor: mainSecondaryTextColor.withAlphaComponent(0.4),
        badgeInactiveForegroundColor: secondaryBadgeTextColor,
        extractedContentTintColor: UIColor(rgb: 0xffffff, alpha: 1.0)
    )

    let inAppNotification = PresentationThemeInAppNotification(
        fillColor: mainBackgroundColor,
        primaryTextColor: .white,
        expandedNotification: PresentationThemeExpandedNotification(
            backgroundType: .dark,
            navigationBar: PresentationThemeExpandedNotificationNavigationBar(
                backgroundColor: mainBackgroundColor,
                primaryTextColor: UIColor(rgb: 0xffffff),
                controlColor: accentColor,
                separatorColor: mainSeparatorColor
            )
        )
    )

    return PresentationTheme(
        name: extendingThemeReference?.name ?? .builtin(.nightAccent),
        index: extendingThemeReference?.index ?? PresentationThemeReference.builtin(.nightAccent).index,
        referenceTheme: .nightAccent,
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
