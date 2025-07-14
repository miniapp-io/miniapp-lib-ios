//
//  WebAppCancelButtonNode.swift
//  MiniAppX
//
//  Created by w3bili on 2025/1/4.
//

import Foundation
import MiniAppUIKit

internal class WebAppCancelButtonNode: ASDisplayNode {
    internal enum State {
        case cancel
        case back
    }
    
    public let buttonNode: HighlightTrackingButtonNode
    private let arrowNode: ASImageNode
    private let labelNode: ImmediateTextNode
    
    public var state: State = .cancel
    
    private var color: UIColor?
    
    private let resourceProvider: IResourceProvider
    
    private weak var colorSnapshotView: UIView?
    
    public func updateColor(_ color: UIColor?, transition: ContainedViewLayoutTransition) {
        let previousColor = self.color
        self.color = color
                
        if case let .animated(duration, curve) = transition, previousColor != color, !self.animatingStateChange {
            if let snapshotView = self.view.snapshotContentTree() {
                snapshotView.frame = self.bounds
                self.view.addSubview(snapshotView)
                self.colorSnapshotView = snapshotView
                
                snapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: duration, timingFunction: curve.timingFunction, removeOnCompletion: false, completion: { _ in
                    snapshotView.removeFromSuperview()
                })
                self.arrowNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: duration, timingFunction: curve.timingFunction)
                self.labelNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: duration, timingFunction: curve.timingFunction)
            }
        }
        self.setState(self.state, animated: false, animateScale: false, force: true)
    }
    
    public init(resourceProvider: IResourceProvider) {
        self.resourceProvider = resourceProvider
        
        self.buttonNode = HighlightTrackingButtonNode()
        
        self.arrowNode = ASImageNode()
        self.arrowNode.displaysAsynchronously = false
        
        self.labelNode = ImmediateTextNode()
        self.labelNode.displaysAsynchronously = false
        
        super.init()
        
        self.addSubnode(self.buttonNode)
        self.buttonNode.addSubnode(self.arrowNode)
        self.buttonNode.addSubnode(self.labelNode)
        
        self.buttonNode.highligthedChanged = { [weak self] highlighted in
            guard let strongSelf = self else {
                return
            }
            if highlighted {
                strongSelf.arrowNode.layer.removeAnimation(forKey: "opacity")
                strongSelf.arrowNode.alpha = 0.4
                strongSelf.labelNode.layer.removeAnimation(forKey: "opacity")
                strongSelf.labelNode.alpha = 0.4
            } else {
                strongSelf.arrowNode.alpha = 1.0
                strongSelf.arrowNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
                strongSelf.labelNode.alpha = 1.0
                strongSelf.labelNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
            }
        }
        
        self.setState(.cancel, animated: false, force: true)
    }
    
    private var animatingStateChange = false
    public func setState(_ state: State, animated: Bool, animateScale: Bool = true, force: Bool = false) {
        guard self.state != state || force else {
            return
        }
        self.state = state
        
        if let colorSnapshotView = self.colorSnapshotView {
            self.colorSnapshotView = nil
            colorSnapshotView.removeFromSuperview()
        }
        
        if animated, let snapshotView = self.buttonNode.view.snapshotContentTree() {
            self.animatingStateChange = true
            snapshotView.layer.sublayerTransform = self.buttonNode.subnodeTransform
            self.view.addSubview(snapshotView)
            
            let duration: Double = animateScale ? 0.25 : 0.3
            if animateScale {
                snapshotView.layer.animateScale(from: 1.0, to: 0.001, duration: 0.25, removeOnCompletion: false)
            }
            snapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: duration, removeOnCompletion: false, completion: { [weak snapshotView] _ in
                snapshotView?.removeFromSuperview()
                self.animatingStateChange = false
            })
            
            if animateScale {
                self.buttonNode.layer.animateScale(from: 0.001, to: 1.0, duration: 0.25)
            }
            self.buttonNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: duration)
        }
        
        let color = self.color ?? self.resourceProvider.getColor(key: KEY_ACCENT_TEXT_COLOR)
        
        self.arrowNode.isHidden = state == .cancel
        self.labelNode.attributedText = NSAttributedString(string: state == .cancel ? " " : self.resourceProvider.getString(key: "Common.Back")!, font: Font.regular(17.0), textColor: color)
        
        let labelSize = self.labelNode.updateLayout(CGSize(width: 120.0, height: 56.0))
        
        self.buttonNode.frame = CGRect(origin: .zero, size: CGSize(width: labelSize.width, height: self.buttonNode.frame.height))
        self.arrowNode.image = NavigationBarTheme.generateBackArrowImage(color: color)
        if let image = self.arrowNode.image {
            self.arrowNode.frame = CGRect(origin: self.arrowNode.frame.origin, size: image.size)
        }
        self.labelNode.frame = CGRect(origin: self.labelNode.frame.origin, size: labelSize)
        self.buttonNode.subnodeTransform = CATransform3DMakeTranslation(state == .back ? 11.0 : 0.0, 0.0, 0.0)
    }
    
    override public func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        self.buttonNode.frame = CGRect(origin: .zero, size: CGSize(width: self.buttonNode.frame.width, height: constrainedSize.height))
        self.arrowNode.frame = CGRect(origin: CGPoint(x: -19.0, y: floorToScreenPixels((constrainedSize.height - self.arrowNode.frame.size.height) / 2.0)), size: self.arrowNode.frame.size)
        self.labelNode.frame = CGRect(origin: CGPoint(x: 0.0, y: floorToScreenPixels((constrainedSize.height - self.labelNode.frame.size.height) / 2.0)), size: self.labelNode.frame.size)

        return CGSize(width: 70.0, height: 56.0)
    }
}
