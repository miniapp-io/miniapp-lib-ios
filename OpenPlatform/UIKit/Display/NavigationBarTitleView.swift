import Foundation
import UIKit

internal protocol NavigationBarTitleView {
    func animateLayoutTransition()
    
    func updateLayout(size: CGSize, clearBounds: CGRect, transition: ContainedViewLayoutTransition) -> CGRect
}
