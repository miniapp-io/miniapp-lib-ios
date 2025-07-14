import Foundation
import MiniAppUIKit

internal protocol NavigationBarTitleTransitionNode {
    func makeTransitionMirrorNode() -> ASDisplayNode
}
