import Foundation
import UIKit

internal final class AlertControllerContext {
    public let theme: AlertControllerTheme
    
    public init(theme: AlertControllerTheme) {
        self.theme = theme
    }
}

internal func textAlertController(alertContext: AlertControllerContext, title: String?, text: String, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, parseMarkdown: Bool = false, dismissOnOutsideTap: Bool = true) -> AlertController {
   
    let controller = standardTextAlertController(theme: alertContext.theme, title: title, text: text, actions: actions, actionLayout: actionLayout, allowInputInset: allowInputInset, parseMarkdown: parseMarkdown, dismissOnOutsideTap: dismissOnOutsideTap)
    
    return controller
}

internal func richTextAlertController(alertContext: AlertControllerContext, title: NSAttributedString?, text: NSAttributedString, actions: [TextAlertAction], actionLayout: TextAlertContentActionLayout = .horizontal, allowInputInset: Bool = true, dismissAutomatically: Bool = true) -> AlertController {
    let theme = alertContext.theme
    
    var dismissImpl: (() -> Void)?
    let controller = AlertController(theme: theme, contentNode: TextAlertContentNode(theme: theme, title: title, text: text, actions: actions.map { action in
        return TextAlertAction(type: action.type, title: action.title, action: {
            if dismissAutomatically {
                dismissImpl?()
            }
            action.action()
        })
    }, actionLayout: actionLayout, dismissOnOutsideTap: true), allowInputInset: allowInputInset)
    dismissImpl = { [weak controller] in
        controller?.dismissAnimated()
    }
    
    return controller
}
