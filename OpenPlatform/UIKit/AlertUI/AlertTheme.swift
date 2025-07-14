import Foundation

internal func textAlertController(context: AccountContext, title: String?, text: String, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, parseMarkdown: Bool = false, dismissOnOutsideTap: Bool = true) -> AlertController {
    return textAlertController(sharedContext: context, title: title, text: text, actions: actions, actionLayout: actionLayout, allowInputInset: allowInputInset, parseMarkdown: parseMarkdown, dismissOnOutsideTap: dismissOnOutsideTap)
}

internal func textAlertController(sharedContext: AccountContext, title: String?, text: String, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, parseMarkdown: Bool = false, dismissOnOutsideTap: Bool = true) -> AlertController {
    return textAlertController(alertContext: AlertControllerContext(theme: AlertControllerTheme(resourceProvider: sharedContext.resourceProvider, fontSize: .regular)), title: title, text: text, actions: actions, actionLayout: actionLayout, allowInputInset: allowInputInset, parseMarkdown: parseMarkdown, dismissOnOutsideTap: dismissOnOutsideTap)
}

internal func textAlertController(sharedContext: AccountContext, title: String?, text: String, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, dismissOnOutsideTap: Bool = true) -> AlertController {
    return textAlertController(alertContext: AlertControllerContext(theme: AlertControllerTheme(resourceProvider: sharedContext.resourceProvider, fontSize: .regular)), title: title, text: text, actions: actions, actionLayout: actionLayout, allowInputInset: allowInputInset, dismissOnOutsideTap: dismissOnOutsideTap)
}

internal func richTextAlertController(context: AccountContext, title: NSAttributedString?, text: NSAttributedString, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, dismissAutomatically: Bool = true) -> AlertController {
    return richTextAlertController(alertContext: AlertControllerContext(theme: AlertControllerTheme(resourceProvider: context.resourceProvider, fontSize: .regular)), title: title, text: text, actions: actions, actionLayout: actionLayout, allowInputInset: allowInputInset, dismissAutomatically: dismissAutomatically)
}

