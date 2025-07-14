import Foundation
import UIKit
import MiniAppUIKit

internal struct CounterControllerTitle: Equatable {
    public var title: String
    public var counter: String
    
    public init(title: String, counter: String) {
        self.title = title
        self.counter = counter
    }
}

internal final class CounterControllerTitleView: UIView {
    
    
    private var resourceProvider: IResourceProvider {
        didSet {
            self.update()
        }
    }
    
    private let titleNode: ImmediateTextNode
    private let subtitleNode: ImmediateTextNode
    
    public var title: CounterControllerTitle = CounterControllerTitle(title: "", counter: "") {
        didSet {
            if self.title != oldValue {
                self.update()
            }
        }
    }
    
    private var primaryTextColor: UIColor?
    private var secondaryTextColor: UIColor?
    
    public func updateTextColors(primary: UIColor?, secondary: UIColor?, transition: ContainedViewLayoutTransition) {
        self.primaryTextColor = primary
        self.secondaryTextColor = secondary
        
        if case let .animated(duration, curve) = transition {
            if let snapshotView = self.snapshotContentTree() {
                snapshotView.frame = self.bounds
                self.addSubview(snapshotView)
                
                snapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: duration, timingFunction: curve.timingFunction, removeOnCompletion: false, completion: { _ in
                    snapshotView.removeFromSuperview()
                })
                self.titleNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: duration, timingFunction: curve.timingFunction)
                self.subtitleNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: duration, timingFunction: curve.timingFunction)
            }
        }
        
        self.update()
    }
    
    private func update() {
        let primaryTextColor = self.primaryTextColor ?? self.resourceProvider.getColor(key: KEY_NAVIGATION_BAR_PRIMARY_TEXT_COLOR)
        let secondaryTextColor = self.secondaryTextColor ?? self.resourceProvider.getColor(key: KEY_NAVIGATION_BAR_SECONDARY_TEXT_COLOR)
        
        self.titleNode.attributedText = NSAttributedString(string: self.title.title, font: Font.semibold(17.0), textColor: primaryTextColor)
        self.subtitleNode.attributedText = NSAttributedString(string: self.title.counter, font: Font.regular(13.0), textColor: secondaryTextColor)
        
        self.accessibilityLabel = self.title.title
        self.accessibilityValue = self.title.counter
        
        self.setNeedsLayout()
    }
    
    public init(resourceProvider: IResourceProvider) {
        self.resourceProvider = resourceProvider
        
        self.titleNode = ImmediateTextNode()
        self.titleNode.displaysAsynchronously = false
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationType = .end
        self.titleNode.isOpaque = false
        
        self.subtitleNode = ImmediateTextNode()
        self.subtitleNode.displaysAsynchronously = false
        self.subtitleNode.maximumNumberOfLines = 1
        self.subtitleNode.truncationType = .end
        self.subtitleNode.isOpaque = false
        
        super.init(frame: CGRect())
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = .header
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.subtitleNode)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.bounds.size
        let spacing: CGFloat = 0.0
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: max(1.0, size.width), height: size.height))
        let subtitleSize = self.subtitleNode.updateLayout(CGSize(width: max(1.0, size.width), height: size.height))
        let combinedHeight = titleSize.height + subtitleSize.height + spacing
        
        let titleFrame = CGRect(origin: CGPoint(x: floor((size.width - titleSize.width) / 2.0), y: floor((size.height - combinedHeight) / 2.0)), size: titleSize)
        self.titleNode.frame = titleFrame
        
        let subtitleFrame = CGRect(origin: CGPoint(x: floor((size.width - subtitleSize.width) / 2.0), y: floor((size.height - combinedHeight) / 2.0) + titleSize.height + spacing), size: subtitleSize)
        self.subtitleNode.frame = subtitleFrame
    }
}
