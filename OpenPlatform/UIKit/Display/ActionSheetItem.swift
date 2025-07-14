import Foundation

internal protocol ActionSheetItem {
    func node(theme: ActionSheetControllerTheme) -> ActionSheetItemNode
    func updateNode(_ node: ActionSheetItemNode) -> Void
}
