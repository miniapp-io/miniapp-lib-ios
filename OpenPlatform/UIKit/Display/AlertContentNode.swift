import Foundation
import UIKit
import MiniAppUIKit

internal class AlertContentNode: ASDisplayNode {
    open var requestLayout: ((ContainedViewLayoutTransition) -> Void)?
    
    open var dismissOnOutsideTap: Bool {
        return true
    }
    
    open func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) -> CGSize {
        assertionFailure()
        
        return CGSize()
    }
    
    open func updateTheme(_ theme: AlertControllerTheme) {
        
    }
    
    open func performHighlightedAction() {
        
    }
    
    open func decreaseHighlightedIndex() {
        
    }
    
    open func increaseHighlightedIndex() {

    }
}
