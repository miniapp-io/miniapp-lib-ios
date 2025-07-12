import Foundation
import UIKit
import MiniAppUIKit

private let buttonSize = CGSize(width: 88.0, height: 49.0)
private let smallButtonWidth: CGFloat = 69.0
private let iconSize = CGSize(width: 30.0, height: 30.0)
private let sideInset: CGFloat = 3.0


internal final class AttachButtonComponent: CombinedComponent {
    let context: AccountContext
    let type: AttachmentButtonType
    let isSelected: Bool
    let theme: PresentationTheme
    let action: () -> Void
    let longPressAction: () -> Void
    
    init(
        context: AccountContext,
        type: AttachmentButtonType,
        isSelected: Bool,
        theme: PresentationTheme,
        action: @escaping () -> Void,
        longPressAction: @escaping () -> Void
    ) {
        self.context = context
        self.type = type
        self.isSelected = isSelected
        self.theme = theme
        self.action = action
        self.longPressAction = longPressAction
    }

    static func ==(lhs: AttachButtonComponent, rhs: AttachButtonComponent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.type != rhs.type {
            return false
        }
        if lhs.isSelected != rhs.isSelected {
            return false
        }
        if lhs.theme !== rhs.theme {
            return false
        }
        return true
    }
    
    static var body: Body {
        return { context in
            return context.availableSize
        }
    }
}

internal final class LoadingProgressNode: ASDisplayNode {
    var color: UIColor {
        didSet {
            self.foregroundNode.backgroundColor = self.color
        }
    }
    
    private let foregroundNode: ASDisplayNode
    
    init(color: UIColor) {
        self.color = color
        
        self.foregroundNode = ASDisplayNode()
        self.foregroundNode.backgroundColor = color
        
        super.init()
        
        self.addSubnode(self.foregroundNode)
    }
        
    private var _progress: CGFloat = 0.0
    func updateProgress(_ progress: CGFloat, animated: Bool = false) {
        if self._progress == progress && animated {
            return
        }
        
        var animated = animated
        if (progress < self._progress && animated) {
            animated = false
        }
        
        let size = self.bounds.size
        
        self._progress = progress
        
        let transition: ContainedViewLayoutTransition
        if animated && progress > 0.0 {
            transition = .animated(duration: 0.7, curve: .spring)
        } else {
            transition = .immediate
        }
        
        let alpaTransition: ContainedViewLayoutTransition
        if animated {
            alpaTransition = .animated(duration: 0.3, curve: .easeInOut)
        } else {
            alpaTransition = .immediate
        }
        
        transition.updateFrame(node: self.foregroundNode, frame: CGRect(x: -2.0, y: 0.0, width: (size.width + 4.0) * progress, height: size.height))
        
        let alpha: CGFloat = progress < 0.001 || progress > 0.999 ? 0.0 : 1.0
        alpaTransition.updateAlpha(node: self.foregroundNode, alpha: alpha)
    }
    
    override func layout() {
        super.layout()
        
        self.foregroundNode.cornerRadius = self.frame.height / 2.0
    }
}

internal final class MainButtonNode: HighlightTrackingButtonNode {
    private var state: AttachmentMainButtonState
    private var size: CGSize?
    
    private let backgroundAnimationNode: ASImageNode
    fileprivate let textNode: ImmediateTextNode
   // private let statusNode: SemanticStatusNode
    private var progressNode: ASImageNode?
        
    //private var shimmerView: ShimmerEffectForegroundView?
    private var borderView: UIView?
    private var borderMaskView: UIView?
    //private var borderShimmerView: ShimmerEffectForegroundView?
    
    override init(pointerStyle: PointerStyle? = nil) {
        self.state = AttachmentMainButtonState.initial
        
        self.backgroundAnimationNode = ASImageNode()
        self.backgroundAnimationNode.displaysAsynchronously = false
        
        self.textNode = ImmediateTextNode()
        self.textNode.textAlignment = .center
        self.textNode.displaysAsynchronously = false
        
        //self.statusNode = SemanticStatusNode(backgroundNodeColor: .clear, foregroundNodeColor: .white)
        
        super.init(pointerStyle: pointerStyle)
        
        self.isExclusiveTouch = true
        self.clipsToBounds = true
                
        self.addSubnode(self.backgroundAnimationNode)
        self.addSubnode(self.textNode)
        //self.addSubnode(self.statusNode)
        
        self.highligthedChanged = { [weak self] highlighted in
            if let strongSelf = self, strongSelf.state.isEnabled {
                if highlighted {
                    strongSelf.layer.removeAnimation(forKey: "opacity")
                    strongSelf.alpha = 0.65
                } else {
                    strongSelf.alpha = 1.0
                    strongSelf.layer.animateAlpha(from: 0.65, to: 1.0, duration: 0.2)
                }
            }
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.cornerRadius = 12.0
        if #available(iOS 13.0, *) {
            self.layer.cornerCurve = .continuous
        }
    }
    
    public func transitionToProgress() {
        guard self.progressNode == nil, let size = self.size else {
            return
        }
        
        self.isUserInteractionEnabled = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rotationAnimation.duration = 1.0
        rotationAnimation.fromValue = NSNumber(value: Float(0.0))
        rotationAnimation.toValue = NSNumber(value: Float.pi * 2.0)
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotationAnimation.beginTime = 1.0
        
        let buttonOffset: CGFloat = 0.0
        let buttonWidth = size.width
        
        let progressNode = ASImageNode()
        
        let diameter: CGFloat = size.height - 22.0
        let progressFrame = CGRect(origin: CGPoint(x: floorToScreenPixels(buttonOffset + (buttonWidth - diameter) / 2.0), y: floorToScreenPixels((size.height - diameter) / 2.0)), size: CGSize(width: diameter, height: diameter))
        progressNode.frame = progressFrame
        progressNode.image = generateIndefiniteActivityIndicatorImage(color: .white, diameter: diameter, lineWidth: 3.0)
            
        self.addSubnode(progressNode)
 
        progressNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
        progressNode.layer.add(rotationAnimation, forKey: "progressRotation")
        self.progressNode = progressNode
        
        self.textNode.alpha = 0.0
        self.textNode.layer.animateAlpha(from: 0.55, to: 0.0, duration: 0.2)
    }
    
    public func transitionFromProgress() {
        guard let progressNode = self.progressNode else {
            return
        }
        self.progressNode = nil
        
        progressNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak progressNode, weak self] _ in
            progressNode?.removeFromSupernode()
            self?.isUserInteractionEnabled = true
        })
        
        self.textNode.alpha = 1.0
        self.textNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
    }
    
    private func setupShimmering() {
    }
    
    func updateShimmerParameters() {
    }
    
    private func setupGradientAnimations() {
        if let _ = self.backgroundAnimationNode.layer.animation(forKey: "movement") {
        } else {
            let offset = (self.backgroundAnimationNode.frame.width - self.frame.width) / 2.0
            let previousValue = self.backgroundAnimationNode.position.x
            var newValue: CGFloat = offset
            if offset - previousValue < self.backgroundAnimationNode.frame.width * 0.25 {
                newValue -= self.backgroundAnimationNode.frame.width * 0.35
            }
            self.backgroundAnimationNode.position = CGPoint(x: newValue, y: self.backgroundAnimationNode.bounds.size.height / 2.0)
            
            CATransaction.begin()
            
            let animation = CABasicAnimation(keyPath: "position.x")
            animation.duration = 4.5
            animation.fromValue = previousValue
            animation.toValue = newValue
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            CATransaction.setCompletionBlock { [weak self] in
                self?.setupGradientAnimations()
            }

            self.backgroundAnimationNode.layer.add(animation, forKey: "movement")
            CATransaction.commit()
        }
    }
    
    func updateLayout(size: CGSize, state: AttachmentMainButtonState, transition: ContainedViewLayoutTransition) {
        let previousState = self.state
        self.state = state
        self.size = size
        
        self.isUserInteractionEnabled = state.isVisible
        
        self.setupShimmering()
        
        if let text = state.text {
            let font: UIFont
            switch state.font {
            case .regular:
                font = Font.regular(17.0)
            case .bold:
                font = Font.semibold(17.0)
            }
            self.textNode.attributedText = NSAttributedString(string: text, font: font, textColor: state.textColor)
            
            let textSize = self.textNode.updateLayout(size)
            self.textNode.frame = CGRect(origin: CGPoint(x: floorToScreenPixels((size.width - textSize.width) / 2.0), y: floorToScreenPixels((size.height - textSize.height) / 2.0)), size: textSize)
            
            switch state.background {
            case let .color(backgroundColor):
                self.backgroundAnimationNode.image = nil
                self.backgroundAnimationNode.layer.removeAllAnimations()
                self.backgroundColor = backgroundColor
            case .premium:
                if self.backgroundAnimationNode.image == nil {
                    let backgroundColors = [
                        UIColor(rgb: 0x0077ff),
                        UIColor(rgb: 0x6b93ff),
                        UIColor(rgb: 0x8878ff),
                        UIColor(rgb: 0xe46ace)
                    ]
                    var locations: [CGFloat] = []
                    let delta = 1.0 / CGFloat(backgroundColors.count - 1)
                    for i in 0 ..< backgroundColors.count {
                        locations.append(delta * CGFloat(i))
                    }
                    self.backgroundAnimationNode.image = generateGradientImage(size: CGSize(width: 200.0, height: 50.0), colors: backgroundColors, locations: locations, direction: .horizontal)
                    
                    self.backgroundAnimationNode.bounds = CGRect(origin: CGPoint(), size: CGSize(width: size.width * 2.4, height: size.height))
                    if self.backgroundAnimationNode.layer.animation(forKey: "movement") == nil {
                        self.backgroundAnimationNode.position = CGPoint(x: size.width * 2.4 / 2.0 - self.backgroundAnimationNode.frame.width * 0.35, y: size.height / 2.0)
                    }
                    self.setupGradientAnimations()
                }
                self.backgroundColor = UIColor(rgb: 0x8878ff)
            }
        }
        
        if previousState.progress != state.progress {
            if state.progress == .center {
                self.transitionToProgress()
            } else {
                self.transitionFromProgress()
            }
        }
        
//        if let shimmerView = self.shimmerView, let borderView = self.borderView, let borderMaskView = self.borderMaskView, let borderShimmerView = self.borderShimmerView {
//            let buttonFrame = CGRect(origin: .zero, size: size)
//            let buttonWidth = size.width
//            let buttonHeight = size.height
//            transition.updateFrame(view: shimmerView, frame: buttonFrame)
//            transition.updateFrame(view: borderView, frame: buttonFrame)
//            transition.updateFrame(view: borderMaskView, frame: buttonFrame)
//            transition.updateFrame(view: borderShimmerView, frame: buttonFrame)
//            
//            shimmerView.updateAbsoluteRect(CGRect(origin: CGPoint(x: buttonWidth * 4.0, y: 0.0), size: size), within: CGSize(width: buttonWidth * 9.0, height: buttonHeight))
//            borderShimmerView.updateAbsoluteRect(CGRect(origin: CGPoint(x: buttonWidth * 4.0, y: 0.0), size: size), within: CGSize(width: buttonWidth * 9.0, height: buttonHeight))
//        }
        
//        let statusSize = CGSize(width: 20.0, height: 20.0)
//        transition.updateFrame(node: self.statusNode, frame: CGRect(origin: CGPoint(x: size.width - statusSize.width - 15.0, y: floorToScreenPixels((size.height - statusSize.height) / 2.0)), size: statusSize))
        
//        self.statusNode.foregroundNodeColor = state.textColor
//        self.statusNode.transitionToState(state.progress == .side ? .progress(value: nil, cancelEnabled: false, appearance: SemanticStatusNodeState.ProgressAppearance(inset: 0.0, lineWidth: 2.0)) : .none)
    }
}

internal class AttachmentPanel: ASDisplayNode, ASScrollViewDelegate {
    private let context: AccountContext
    private let isScheduledMessages: Bool
    
    private var resourceProvider: IResourceProvider
    
//    private var iconDisposables: [MediaId: Disposable] = [:]
    
//    private var presentationInterfaceState: ChatPresentationInterfaceState
//    private var interfaceInteraction: ChatPanelInterfaceInteraction?
//    
//    private let makeEntityInputView: () -> AttachmentTextInputPanelInputView?
    
    private let containerNode: ASDisplayNode
    private let backgroundNode: NavigationBackgroundNode
    private let scrollNode: ASScrollNode
    private let separatorNode: ASDisplayNode
    
    //private var textInputPanelNode: AttachmentTextInputPanelNode?
    private var progressNode: LoadingProgressNode?
    private var mainButtonNode: MainButtonNode
    
    private var loadingProgress: CGFloat?
    private var mainButtonState: AttachmentMainButtonState = .initial
    
    private var elevateProgress: Bool = false
    private var buttons: [AttachmentButtonType] = []
    private var selectedIndex: Int = 0
    private(set) var isSelecting: Bool = false
    private var _isButtonVisible: Bool = false
    var isButtonVisible: Bool {
        return self.mainButtonState.isVisible
    }
    
    private var validLayout: ContainerViewLayout?
    private var scrollLayout: (width: CGFloat, contentSize: CGSize)?
    
    var fromMenu: Bool = false
    var isStandalone: Bool = false
    
    var selectionChanged: (AttachmentButtonType) -> Bool = { _ in return false }
    var longPressed: (AttachmentButtonType) -> Void = { _ in }

    var beganTextEditing: () -> Void = {}
    var textUpdated: (NSAttributedString) -> Void = { _ in }
   // var sendMessagePressed: (AttachmentTextInputPanelSendMode) -> Void = { _ in }
    var requestLayout: () -> Void = {}
    var present: (ViewController) -> Void = { _ in }
    var presentInGlobalOverlay: (ViewController) -> Void = { _ in }
    
    var mainButtonPressed: () -> Void = { }
    
    init(context: AccountContext, isScheduledMessages: Bool) {
        self.context = context
        self.resourceProvider = context.resourceProvider
        self.isScheduledMessages = isScheduledMessages
        
        self.containerNode = ASDisplayNode()
        self.containerNode.clipsToBounds = true
        
        self.scrollNode = ASScrollNode()
        
        self.backgroundNode = NavigationBackgroundNode(color: self.resourceProvider.getColor(key: KEY_TAB_BAR_BACKGROUND_COLOR))
        self.separatorNode = ASDisplayNode()
        self.separatorNode.backgroundColor = self.resourceProvider.getColor(key: KEY_TAB_BAR_SEPARATOR_COLOR)
        
        self.mainButtonNode = MainButtonNode()
        
        super.init()
                        
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.backgroundNode)
        self.containerNode.addSubnode(self.separatorNode)
        self.containerNode.addSubnode(self.scrollNode)
        
        self.addSubnode(self.mainButtonNode)
        
        self.mainButtonNode.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: .touchUpInside)
    }
    
    override func didLoad() {
        super.didLoad()
        if #available(iOS 13.0, *) {
            self.containerNode.layer.cornerCurve = .continuous
        }
    
        self.scrollNode.view.delegate = self.wrappedScrollViewDelegate
        self.scrollNode.view.showsHorizontalScrollIndicator = false
        self.scrollNode.view.showsVerticalScrollIndicator = false
        
        self.view.accessibilityTraits = .tabBar
    }
    
    @objc private func buttonPressed() {
        self.mainButtonPressed()
    }
    
    func updateBackgroundAlpha(_ alpha: CGFloat, transition: ContainedViewLayoutTransition) {
        transition.updateAlpha(node: self.separatorNode, alpha: alpha)
        transition.updateAlpha(node: self.backgroundNode, alpha: alpha)
    }
    
    func updateCaption(_ caption: NSAttributedString) {
        if !caption.string.isEmpty {
            self.loadTextNodeIfNeeded()
        }
    }

    func updateTheme() {
        self.backgroundNode.updateColor(color: self.resourceProvider.getColor(key: KEY_TAB_BAR_BACKGROUND_COLOR), transition: .immediate)
        self.separatorNode.backgroundColor = self.resourceProvider.getColor(key: KEY_TAB_BAR_SEPARATOR_COLOR)
        
        if let layout = self.validLayout {
            let _ = self.update(layout: layout, buttons: self.buttons, isSelecting: self.isSelecting, elevateProgress: self.elevateProgress, transition: .immediate)
        }
    }
    
    func updateSelectedIndex(_ index: Int) {
        self.selectedIndex = index
        self.updateViews(transition: .init(animation: .curve(duration: 0.2, curve: .spring)))
    }
    
    func updateViews(transition: Transition) {
        guard let layout = self.validLayout else {
            return
        }
        
        let visibleRect = self.scrollNode.bounds.insetBy(dx: -180.0, dy: 0.0)
        var validButtons = Set<Int>()
        
        var distanceBetweenNodes = layout.size.width / CGFloat(self.buttons.count)
        let internalWidth = distanceBetweenNodes * CGFloat(self.buttons.count - 1)
        var leftNodeOriginX = (layout.size.width - internalWidth) / 2.0
        
        var buttonWidth = buttonSize.width
        if self.buttons.count > 6 && layout.size.width < layout.size.height {
            buttonWidth = smallButtonWidth
            distanceBetweenNodes = buttonWidth
            leftNodeOriginX = layout.safeInsets.left + sideInset + buttonWidth / 2.0
        }
        
        for i in 0 ..< self.buttons.count {
            let originX = floor(leftNodeOriginX + CGFloat(i) * distanceBetweenNodes - buttonWidth / 2.0)
            let buttonFrame = CGRect(origin: CGPoint(x: originX, y: 0.0), size: CGSize(width: buttonWidth, height: buttonSize.height))
            if !visibleRect.intersects(buttonFrame) {
                continue
            }
            validButtons.insert(i)
        }
    }
    
    private func updateScrollLayoutIfNeeded(force: Bool, transition: ContainedViewLayoutTransition) -> Bool {
        guard let layout = self.validLayout else {
            return false
        }
        if self.scrollLayout?.width == layout.size.width && !force {
            return false
        }
        
        var contentSize = CGSize(width: layout.size.width, height: buttonSize.height)
        var buttonWidth = buttonSize.width
        if self.buttons.count > 6 && layout.size.width < layout.size.height {
            buttonWidth = smallButtonWidth
            contentSize.width = layout.safeInsets.left + layout.safeInsets.right + sideInset * 2.0 + CGFloat(self.buttons.count) * buttonWidth
        }
        self.scrollLayout = (layout.size.width, contentSize)

        transition.updateFrameAsPositionAndBounds(node: self.scrollNode, frame: CGRect(origin: CGPoint(x: 0.0, y: self.isSelecting || self._isButtonVisible ? -buttonSize.height : 0.0), size: CGSize(width: layout.size.width, height: buttonSize.height)))
        self.scrollNode.view.contentSize = contentSize

        return true
    }
    
    private func loadTextNodeIfNeeded() {
    }
    
    func updateLoadingProgress(_ progress: CGFloat?) {
        self.loadingProgress = progress
    }
    
    func updateMainButtonState(_ mainButtonState: AttachmentMainButtonState?) {
        var currentButtonState = self.mainButtonState
        if mainButtonState == nil {
            currentButtonState = AttachmentMainButtonState(text: currentButtonState.text, font: currentButtonState.font, background: currentButtonState.background, textColor: currentButtonState.textColor, isVisible: false, progress: .none, isEnabled: currentButtonState.isEnabled)
        }
        self.mainButtonState = mainButtonState ?? currentButtonState
    }
    
    let animatingTransitionPromise = ValuePromise<Bool>(false)
    private(set) var animatingTransition = false {
        didSet {
            self.animatingTransitionPromise.set(self.animatingTransition)
        }
    }
    
    func animateTransitionIn(inputTransition: AttachmentController.InputPanelTransition, transition: ContainedViewLayoutTransition) {
        guard !self.animatingTransition, let inputNodeSnapshotView = inputTransition.inputNode.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        guard let menuIconSnapshotView = inputTransition.menuIconNode.view.snapshotView(afterScreenUpdates: false), let menuTextSnapshotView = inputTransition.menuTextNode.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        self.animatingTransition = true
        
        let targetButtonColor = self.mainButtonNode.backgroundColor
        self.mainButtonNode.backgroundColor = inputTransition.menuButtonBackgroundNode.backgroundColor
        transition.updateBackgroundColor(node: self.mainButtonNode, color: targetButtonColor ?? .clear)
        
        transition.animateFrame(layer: self.mainButtonNode.layer, from: inputTransition.menuButtonNode.frame)
        transition.animatePosition(node: self.mainButtonNode.textNode, from: CGPoint(x: inputTransition.menuButtonNode.frame.width / 2.0, y: inputTransition.menuButtonNode.frame.height / 2.0))
        
        let targetButtonCornerRadius = self.mainButtonNode.cornerRadius
        self.mainButtonNode.cornerRadius = inputTransition.menuButtonNode.cornerRadius
        transition.updateCornerRadius(node: self.mainButtonNode, cornerRadius: targetButtonCornerRadius)
        self.mainButtonNode.subnodeTransform = CATransform3DMakeScale(0.2, 0.2, 1.0)
        transition.updateSublayerTransformScale(node: self.mainButtonNode, scale: 1.0)
        self.mainButtonNode.textNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
        
        let menuContentDelta = (self.mainButtonNode.frame.width - inputTransition.menuButtonNode.frame.width) / 2.0
        menuIconSnapshotView.frame = inputTransition.menuIconNode.frame.offsetBy(dx: inputTransition.menuButtonNode.frame.minX, dy: inputTransition.menuButtonNode.frame.minY)
        self.view.addSubview(menuIconSnapshotView)
        menuIconSnapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak menuIconSnapshotView] _ in
            menuIconSnapshotView?.removeFromSuperview()
        })
        transition.updatePosition(layer: menuIconSnapshotView.layer, position: CGPoint(x: menuIconSnapshotView.center.x + menuContentDelta, y: self.mainButtonNode.position.y))
        
        menuTextSnapshotView.frame = inputTransition.menuTextNode.frame.offsetBy(dx: inputTransition.menuButtonNode.frame.minX + 19.0, dy: inputTransition.menuButtonNode.frame.minY)
        self.view.addSubview(menuTextSnapshotView)
        menuTextSnapshotView.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak menuTextSnapshotView] _ in
            menuTextSnapshotView?.removeFromSuperview()
        })
        transition.updatePosition(layer: menuTextSnapshotView.layer, position: CGPoint(x: menuTextSnapshotView.center.x + menuContentDelta, y: self.mainButtonNode.position.y))
        
        inputNodeSnapshotView.clipsToBounds = true
        inputNodeSnapshotView.contentMode = .right
        inputNodeSnapshotView.frame = CGRect(x: inputTransition.menuButtonNode.frame.maxX, y: 0.0, width: inputNodeSnapshotView.frame.width - inputTransition.menuButtonNode.frame.maxX, height: inputNodeSnapshotView.frame.height)
        self.view.addSubview(inputNodeSnapshotView)
        
        let targetInputPosition = CGPoint(x: inputNodeSnapshotView.center.x + inputNodeSnapshotView.frame.width, y: self.mainButtonNode.position.y)
        transition.updatePosition(layer: inputNodeSnapshotView.layer, position: targetInputPosition, completion: { [weak inputNodeSnapshotView, weak self] _ in
            inputNodeSnapshotView?.removeFromSuperview()
            self?.animatingTransition = false
        })
    }
    
    private var dismissed = false
    func animateTransitionOut(inputTransition: AttachmentController.InputPanelTransition, dismissed: Bool, transition: ContainedViewLayoutTransition) {
        guard !self.animatingTransition, let inputNodeSnapshotView = inputTransition.inputNode.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        if dismissed {
            inputTransition.prepareForDismiss()
        }
      
        self.animatingTransition = true
        self.dismissed = dismissed
        
        let action = {
            guard let menuIconSnapshotView = inputTransition.menuIconNode.view.snapshotView(afterScreenUpdates: false), let menuTextSnapshotView = inputTransition.menuTextNode.view.snapshotView(afterScreenUpdates: false) else {
                return
            }
            
            let sourceButtonColor = self.mainButtonNode.backgroundColor
            transition.updateBackgroundColor(node: self.mainButtonNode, color: inputTransition.menuButtonBackgroundNode.backgroundColor ?? .clear)
            
            let sourceButtonFrame = self.mainButtonNode.frame
            transition.updateFrame(node: self.mainButtonNode, frame: inputTransition.menuButtonNode.frame)
            let sourceButtonTextPosition = self.mainButtonNode.textNode.position
            transition.updatePosition(node: self.mainButtonNode.textNode, position: CGPoint(x: inputTransition.menuButtonNode.frame.width / 2.0, y: inputTransition.menuButtonNode.frame.height / 2.0))
            
            let sourceButtonCornerRadius = self.mainButtonNode.cornerRadius
            transition.updateCornerRadius(node: self.mainButtonNode, cornerRadius: inputTransition.menuButtonNode.cornerRadius)
            transition.updateSublayerTransformScale(node: self.mainButtonNode, scale: 0.2)
            self.mainButtonNode.textNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false)
            
            let menuContentDelta = (sourceButtonFrame.width - inputTransition.menuButtonNode.frame.width) / 2.0
            var menuIconSnapshotViewFrame = inputTransition.menuIconNode.frame.offsetBy(dx: inputTransition.menuButtonNode.frame.minX + menuContentDelta, dy: inputTransition.menuButtonNode.frame.minY)
            menuIconSnapshotViewFrame.origin.y = self.mainButtonNode.position.y - menuIconSnapshotViewFrame.height / 2.0
            menuIconSnapshotView.frame = menuIconSnapshotViewFrame
            self.view.addSubview(menuIconSnapshotView)
            menuIconSnapshotView.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
            transition.updatePosition(layer: menuIconSnapshotView.layer, position: CGPoint(x: menuIconSnapshotView.center.x - menuContentDelta, y: inputTransition.menuButtonNode.position.y))
            
            var menuTextSnapshotViewFrame = inputTransition.menuTextNode.frame.offsetBy(dx: inputTransition.menuButtonNode.frame.minX + 19.0 + menuContentDelta, dy: inputTransition.menuButtonNode.frame.minY)
            menuTextSnapshotViewFrame.origin.y = self.mainButtonNode.position.y - menuTextSnapshotViewFrame.height / 2.0
            menuTextSnapshotView.frame = menuTextSnapshotViewFrame
            self.view.addSubview(menuTextSnapshotView)
            menuTextSnapshotView.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
            transition.updatePosition(layer: menuTextSnapshotView.layer, position: CGPoint(x: menuTextSnapshotView.center.x - menuContentDelta, y: inputTransition.menuButtonNode.position.y))
            
            inputNodeSnapshotView.clipsToBounds = true
            inputNodeSnapshotView.contentMode = .right
            let targetInputFrame = CGRect(x: inputTransition.menuButtonNode.frame.maxX, y: 0.0, width: inputNodeSnapshotView.frame.width - inputTransition.menuButtonNode.frame.maxX, height: inputNodeSnapshotView.frame.height)
            inputNodeSnapshotView.frame = targetInputFrame.offsetBy(dx: targetInputFrame.width, dy: self.mainButtonNode.position.y - inputNodeSnapshotView.frame.height / 2.0)
            self.view.addSubview(inputNodeSnapshotView)
            transition.updateFrame(layer: inputNodeSnapshotView.layer, frame: targetInputFrame, completion: { [weak inputNodeSnapshotView, weak menuIconSnapshotView, weak menuTextSnapshotView, weak self] _ in
                inputNodeSnapshotView?.removeFromSuperview()
                self?.animatingTransition = false
                
                if !dismissed {
                    menuIconSnapshotView?.removeFromSuperview()
                    menuTextSnapshotView?.removeFromSuperview()
                    
                    self?.mainButtonNode.backgroundColor = sourceButtonColor
                    self?.mainButtonNode.frame = sourceButtonFrame
                    self?.mainButtonNode.textNode.position = sourceButtonTextPosition
                    self?.mainButtonNode.textNode.layer.removeAllAnimations()
                    self?.mainButtonNode.cornerRadius = sourceButtonCornerRadius
                }
            })
        }
        
        if dismissed {
            Queue.mainQueue().after(0.01, action)
        } else {
            action()
        }
    }
    
    func update(layout: ContainerViewLayout, buttons: [AttachmentButtonType], isSelecting: Bool, elevateProgress: Bool, transition: ContainedViewLayoutTransition) -> CGFloat {
        self.validLayout = layout
        self.buttons = buttons
        self.elevateProgress = elevateProgress
                
        let isButtonVisibleUpdated = self._isButtonVisible != self.mainButtonState.isVisible
        self._isButtonVisible = self.mainButtonState.isVisible
        
        let isSelectingUpdated = self.isSelecting != isSelecting
        self.isSelecting = isSelecting
        
        self.scrollNode.isUserInteractionEnabled = !isSelecting
        
        let isButtonVisible = self.mainButtonState.isVisible
        let isNarrowButton = isButtonVisible && self.mainButtonState.font == .regular
        
        var insets = layout.insets(options: [])
        if let inputHeight = layout.inputHeight, inputHeight > 0.0 && (isSelecting/* || isButtonVisible*/) {
            insets.bottom = inputHeight
        } else if layout.intrinsicInsets.bottom > 0.0 {
            insets.bottom = layout.intrinsicInsets.bottom
        }
        
        if isSelecting {
            self.loadTextNodeIfNeeded()
        }
        
        let bounds = CGRect(origin: CGPoint(), size: CGSize(width: layout.size.width, height: buttonSize.height + insets.bottom))
        var containerTransition: ContainedViewLayoutTransition
        let containerFrame: CGRect
        if isButtonVisible {
            var height: CGFloat
            if layout.intrinsicInsets.bottom > 0.0 && (layout.inputHeight ?? 0.0).isZero {
                height = bounds.height
                if case .regular = layout.metrics.widthClass {
                    if self.isStandalone {
                        height -= 3.0
                    } else {
                        height += 6.0
                    }
                }
            } else {
                height = bounds.height + 8.0
            }
            if !isNarrowButton {
                height += 9.0
            }
            containerFrame = CGRect(origin: CGPoint(), size: CGSize(width: bounds.width, height: height))
        } else if isSelecting {
            containerFrame = CGRect(origin: CGPoint(), size: CGSize(width: bounds.width, height: /*textPanelHeight + */insets.bottom))
        } else {
            containerFrame = bounds
        }
        let containerBounds = CGRect(origin: CGPoint(), size: containerFrame.size)
        if isSelectingUpdated/* || isButtonVisibleUpdated*/ {
            containerTransition = .animated(duration: 0.25, curve: .easeInOut)
        } else {
            containerTransition = transition
        }
        containerTransition.updateAlpha(node: self.scrollNode, alpha: isSelecting /*|| isButtonVisible*/ ? 0.0 : 1.0)
        containerTransition.updateTransformScale(node: self.scrollNode, scale: isSelecting /*|| isButtonVisible*/ ? 0.85 : 1.0)
        
//        if isSelectingUpdated {
//            if isSelecting {
//                self.loadTextNodeIfNeeded()
//                if let textInputPanelNode = self.textInputPanelNode {
//                    textInputPanelNode.alpha = 1.0
//                    textInputPanelNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
//                    textInputPanelNode.layer.animatePosition(from: CGPoint(x: 0.0, y: 44.0), to: CGPoint(), duration: 0.25, additive: true)
//                }
//            } else {
//                if let textInputPanelNode = self.textInputPanelNode {
//                    textInputPanelNode.alpha = 0.0
//                    textInputPanelNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25)
//                    textInputPanelNode.layer.animatePosition(from: CGPoint(), to: CGPoint(x: 0.0, y: 44.0), duration: 0.25, additive: true)
//                }
//            }
//        }
        
        if self.containerNode.frame.size.width.isZero {
            containerTransition = .immediate
        }
        
        containerTransition.updateFrame(node: self.containerNode, frame: containerFrame)
        containerTransition.updateFrame(node: self.backgroundNode, frame: containerBounds)
        self.backgroundNode.update(size: containerBounds.size, transition: transition)
        containerTransition.updateFrame(node: self.separatorNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: bounds.width, height: UIScreenPixel)))
                
        let _ = self.updateScrollLayoutIfNeeded(force: isSelectingUpdated/* || isButtonVisibleUpdated*/, transition: containerTransition)

        self.updateViews(transition: .immediate)
        
        if let progress = self.loadingProgress {
            let loadingProgressNode: LoadingProgressNode
            if let current = self.progressNode {
                loadingProgressNode = current
            } else {
                loadingProgressNode = LoadingProgressNode(color: self.resourceProvider.getColor(key: KEY_TAB_BAR_SELECTED_ICON_COLOR))
                self.addSubnode(loadingProgressNode)
                self.progressNode = loadingProgressNode
            }
            let loadingProgressHeight: CGFloat = 3.0
            let loadingProgressY: CGFloat = elevateProgress ? -loadingProgressHeight : -loadingProgressHeight / 2.0
            transition.updateFrame(node: loadingProgressNode, frame: CGRect(origin: CGPoint(x: 0.0, y: loadingProgressY), size: CGSize(width: layout.size.width, height: loadingProgressHeight)))
            
            loadingProgressNode.updateProgress(progress, animated: true)
        } else if let progressNode = self.progressNode {
            self.progressNode = nil
            progressNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak progressNode] _ in
                progressNode?.removeFromSupernode()
            })
        }

        let sideInset: CGFloat = 16.0
        let buttonSize = CGSize(width: layout.size.width - (sideInset + layout.safeInsets.left) * 2.0, height: 50.0)
        let buttonTopInset: CGFloat = /*isNarrowButton ? 2.0 : */8.0
        
        if !self.dismissed {
            self.mainButtonNode.updateLayout(size: buttonSize, state: self.mainButtonState, transition: transition)
        }
        if !self.animatingTransition {
            transition.updateFrame(node: self.mainButtonNode, frame: CGRect(origin: CGPoint(x: layout.safeInsets.left + sideInset, y: isButtonVisible || self.fromMenu ? buttonTopInset : containerFrame.height), size: buttonSize))
        }
        
        return containerFrame.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateViews(transition: .immediate)
    }
}

