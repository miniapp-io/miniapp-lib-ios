import UIKit

internal enum ContextMenuActionContent {
    case text(title: String, accessibilityLabel: String)
    case icon(UIImage)
    case textWithIcon(title: String, icon: UIImage?)
}

internal struct ContextMenuAction {
    public let content: ContextMenuActionContent
    public let action: () -> Void
    
    public init(content: ContextMenuActionContent, action: @escaping () -> Void) {
        self.content = content
        self.action = action
    }
}
