import Foundation
import UIKit
import MiniAppUIKit

internal enum TabBarItemSwipeDirection {
    case left
    case right
}

internal protocol TabBarController: ViewController {
    var currentController: ViewController? { get }
    var controllers: [ViewController] { get }
    var selectedIndex: Int { get set }
    
    var cameraItemAndAction: (item: UITabBarItem, action: () -> Void)? { get set }
    
    func setControllers(_ controllers: [ViewController], selectedIndex: Int?)
    
    func updateBackgroundAlpha(_ alpha: CGFloat, transition: ContainedViewLayoutTransition)
    
    func viewForCameraItem() -> UIView?
    func frameForControllerTab(controller: ViewController) -> CGRect?
    func isPointInsideContentArea(point: CGPoint) -> Bool
    func sourceNodesForController(at index: Int) -> [ASDisplayNode]?
    
    func updateIsTabBarEnabled(_ value: Bool, transition: ContainedViewLayoutTransition)
    func updateIsTabBarHidden(_ value: Bool, transition: ContainedViewLayoutTransition)
    func updateLayout(transition: ContainedViewLayoutTransition)
}
