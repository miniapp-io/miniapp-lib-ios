import Foundation
import UIKit
import MiniAppUIKit

internal class ASTransformLayer: CATransformLayer {
    override var contents: Any? {
        get {
            return nil
        } set(value) {
            
        }
    }
    
    override var backgroundColor: CGColor? {
        get {
            return nil
        } set(value) {
            
        }
    }
    
    override func setNeedsLayout() {
    }
    
    override func layoutSublayers() {
    }
}

internal class ASTransformView: UIView {
    override class var layerClass: AnyClass {
        return ASTransformLayer.self
    }
}

internal class ASTransformLayerNode: ASDisplayNode {
    public override init() {
        super.init()
        self.setLayerBlock({
            return ASTransformLayer()
        })
    }
}

internal class ASTransformViewNode: ASDisplayNode {
    public override init() {
        super.init()
        
        self.setViewBlock({
            return ASTransformView()
        })
    }
}

internal class ASTransformNode: ASDisplayNode {
    public init(layerBacked: Bool = true) {
        if layerBacked {
            super.init()
            self.setLayerBlock({
                return ASTransformLayer()
            })
        } else {
            super.init()
        
            self.setViewBlock({
                return ASTransformView()
            })
        }
    }
}
