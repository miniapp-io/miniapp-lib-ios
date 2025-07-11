import UIKit

internal final class NullActionClass: NSObject, CAAction {
    @objc public func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
    }
}

internal let nullAction = NullActionClass()

internal class SimpleLayer: CALayer {
    public var didEnterHierarchy: (() -> Void)?
    public var didExitHierarchy: (() -> Void)?
    public private(set) var isInHierarchy: Bool = false
    
    override open func action(forKey event: String) -> CAAction? {
        if event == kCAOnOrderIn {
            self.isInHierarchy = true
            self.didEnterHierarchy?()
        } else if event == kCAOnOrderOut {
            self.isInHierarchy = false
            self.didExitHierarchy?()
        }
        return nullAction
    }
    
    override public init() {
        super.init()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal class SimpleShapeLayer: CAShapeLayer {
    public var didEnterHierarchy: (() -> Void)?
    public var didExitHierarchy: (() -> Void)?
    
    override open func action(forKey event: String) -> CAAction? {
        if event == kCAOnOrderIn {
            self.didEnterHierarchy?()
        } else if event == kCAOnOrderOut {
            self.didExitHierarchy?()
        }
        return nullAction
    }
    
    override public init() {
        super.init()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal class SimpleGradientLayer: CAGradientLayer {
    public var didEnterHierarchy: (() -> Void)?
    public var didExitHierarchy: (() -> Void)?
    
    override open func action(forKey event: String) -> CAAction? {
        if event == kCAOnOrderIn {
            self.didEnterHierarchy?()
        } else if event == kCAOnOrderOut {
            self.didExitHierarchy?()
        }
        return nullAction
    }
    
    override public init() {
        super.init()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal class SimpleTransformLayer: CATransformLayer {
    public var didEnterHierarchy: (() -> Void)?
    public var didExitHierarchy: (() -> Void)?
    public private(set) var isInHierarchy: Bool = false
    
    override open func action(forKey event: String) -> CAAction? {
        if event == kCAOnOrderIn {
            self.isInHierarchy = true
            self.didEnterHierarchy?()
        } else if event == kCAOnOrderOut {
            self.isInHierarchy = false
            self.didExitHierarchy?()
        }
        return nullAction
    }
    
    override public init() {
        super.init()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
