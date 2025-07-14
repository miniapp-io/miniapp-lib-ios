import Foundation
import UIKit
import MiniAppUIKit

internal protocol AccessibilityFocusableNode {
    func accessibilityElementDidBecomeFocused()
}

internal final class AccessibilityAreaNode: ASDisplayNode {
    public var activate: (() -> Bool)?
    public var increment: (() -> Void)?
    public var decrement: (() -> Void)?
    public var focused: (() -> Void)?
    
    override public init() {
        super.init()
        
        self.isAccessibilityElement = true
    }
    
    override public func accessibilityActivate() -> Bool {
        return self.activate?() ?? false
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    override public func accessibilityElementDidBecomeFocused() {
        if let focused = self.focused {
            focused()
        } else {
            var supernode = self.supernode
            while true {
                if let supernodeValue = supernode {
                    if let listItemNode = supernodeValue as? AccessibilityFocusableNode {
                        listItemNode.accessibilityElementDidBecomeFocused()
                        break
                    } else {
                        supernode = supernodeValue.supernode
                    }
                } else {
                    break
                }
            }
        }
    }

    override public func accessibilityIncrement() {
        self.increment?()
    }
    
    override public func accessibilityDecrement() {
        self.decrement?()
    }
}
