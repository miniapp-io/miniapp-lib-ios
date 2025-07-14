import Foundation
import UIKit
import MiniAppUIKit

internal enum NavigationBarContentMode {
    case replacement
    case expansion
}

internal class NavigationBarContentNode: ASDisplayNode {
    open var requestContainerLayout: (ContainedViewLayoutTransition) -> Void = { _ in }
    
    open var height: CGFloat {
        return self.nominalHeight
    }
    
    open var clippedHeight: CGFloat {
        return self.nominalHeight
    }
    
    open var nominalHeight: CGFloat {
        return 44.0
    }
    
    open var mode: NavigationBarContentMode {
        return .replacement
    }
    
    open func updateLayout(size: CGSize, leftInset: CGFloat, rightInset: CGFloat, transition: ContainedViewLayoutTransition) {
    }
}
