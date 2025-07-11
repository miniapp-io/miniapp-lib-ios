import Foundation
import UIKit
import MiniAppUIKit

internal final class TextFieldNodeView: UITextField {
    public var didDeleteBackwardWhileEmpty: (() -> Void)?
    
    var fixOffset: Bool = true
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.integral
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.integral
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.editingRect(forBounds: bounds)
    }
    
    override public func deleteBackward() {
        if self.text == nil || self.text!.isEmpty {
            self.didDeleteBackwardWhileEmpty?()
        }
        super.deleteBackward()
    }
    
    override public var keyboardAppearance: UIKeyboardAppearance {
        get {
            return super.keyboardAppearance
        }
        set {
            guard newValue != self.keyboardAppearance else {
                return
            }
            let resigning = self.isFirstResponder
            if resigning {
                self.resignFirstResponder()
            }
            super.keyboardAppearance = newValue
            if resigning {
                self.becomeFirstResponder()
            }
        }
    }
}

internal class TextFieldNode: ASDisplayNode {
    public var textField: TextFieldNodeView {
        return self.view as! TextFieldNodeView
    }
    
    public var fixOffset: Bool = true {
        didSet {
            self.textField.fixOffset = self.fixOffset
        }
    }
    
    override public init() {
        super.init()
        
        self.setViewBlock({
            return TextFieldNodeView()
        })
    }
}
