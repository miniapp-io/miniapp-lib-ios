import Foundation
import UIKit
import MiniAppUIKit

internal enum AttachmentButtonType: Equatable {
    case gallery
    case file
    case location
    case quickReply
    case contact
    case poll
    case gift
    case standalone
    
    public static func ==(lhs: AttachmentButtonType, rhs: AttachmentButtonType) -> Bool {
        switch lhs {
        case .gallery:
            if case .gallery = rhs {
                return true
            } else {
                return false
            }
        case .file:
            if case .file = rhs {
                return true
            } else {
                return false
            }
        case .location:
            if case .location = rhs {
                return true
            } else {
                return false
            }
        case .quickReply:
            if case .quickReply = rhs {
                return true
            } else {
                return false
            }
        case .contact:
            if case .contact = rhs {
                return true
            } else {
                return false
            }
        case .poll:
            if case .poll = rhs {
                return true
            } else {
                return false
            }
        case .gift:
            if case .gift = rhs {
                return true
            } else {
                return false
            }
        case .standalone:
            if case .standalone = rhs {
                return true
            } else {
                return false
            }
        }
    }
}

protocol AttachmentContainable: ViewController {
    var requestFullScreen: (Bool) -> Void { get set }
    var requestAttachmentMenuExpansion: () -> Void { get set }
    var updateNavigationStack: (@escaping ([AttachmentContainable]) -> ([AttachmentContainable], AttachmentMediaPickerContext?)) -> Void { get set }
    var parentController: () -> ViewController? { get set }
    var updateTabBarAlpha: (CGFloat, ContainedViewLayoutTransition) -> Void { get set }
    var updateTabBarVisibility: (Bool, ContainedViewLayoutTransition) -> Void { get set }
    var cancelPanGesture: () -> Void { get set }
    var isContainerPanning: () -> Bool { get set }
    var isContainerExpanded: () -> Bool { get set }
    var isPanGestureEnabled: (() -> Bool)? { get set }
    var mediaPickerContext: AttachmentMediaPickerContext? { get }
    var updateContainerHeadColor: (UIColor, UIColor, UIColor, ContainedViewLayoutTransition) -> Void  { get set }
    var updateContainerHeadAlpha: (Double, ContainedViewLayoutTransition) -> Void  { get set }
    
    func isContainerPanningUpdated(_ panning: Bool)
    
    func resetForReuse()
    func prepareForReuse()
    
    func requestDismiss(completion: @escaping () -> Void)
    func shouldDismissImmediately() -> Bool
    func isAutoExpand() -> Bool
    func isModalStyle() -> Bool
    func canExpand() -> Bool
    func isFullScreenMod() -> Bool
    func isCustomNavitationStyle() -> Bool
    
    func onUpdateModalProgress(_ topInset: CGFloat) -> Void
    
    func allowVerticalSwipe() -> Bool
    func allowHorizontalSwipe() -> Bool
    
    func isBackButtonVisible() -> Bool
    func requestBackClick() -> Void
}

internal extension AttachmentContainable {
    func isContainerPanningUpdated(_ panning: Bool) {
        
    }
    
    func resetForReuse() {
        
    }
    
    func prepareForReuse() {
        
    }
    
    func requestDismiss(completion: @escaping () -> Void) {
        completion()
    }
    
    func shouldDismissImmediately() -> Bool {
         return true
    }
    
    func isAutoExpand() -> Bool {
        return true
    }
    
    func canExpand() -> Bool {
         return true
    }
    
    func onUpdateModalProgress(_ topIns: CGFloat) -> Void {
        
    }
    
    var isPanGestureEnabled: (() -> Bool)? {
        return nil
    }
    
    func isBackButtonVisible() -> Bool {
        return false
    }
    
    func requestBackClick() -> Void {
    }
}

internal enum AttachmentMediaPickerSendMode {
    case generic
    case silently
    case whenOnline
}

internal enum AttachmentMediaPickerAttachmentMode {
    case media
    case files
}

internal protocol AttachmentMediaPickerContext {
    var selectionCount: Signal<Int, NoError> { get }
    var caption: Signal<NSAttributedString?, NoError> { get }
    
    var loadingProgress: Signal<CGFloat?, NoError> { get }
    var mainButtonState: Signal<AttachmentMainButtonState?, NoError> { get }
    
    func mainButtonAction()
    
    func setCaption(_ caption: NSAttributedString)
    func send(mode: AttachmentMediaPickerSendMode, attachmentMode: AttachmentMediaPickerAttachmentMode)
    func schedule()
}

internal func generateShadowImage() -> UIImage? {
    return generateImage(CGSize(width: 140.0, height: 140.0), rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        
        context.saveGState()
        context.setShadow(offset: CGSize(), blur: 60.0, color: UIColor(white: 0.0, alpha: 0.4).cgColor)

        let path = UIBezierPath(roundedRect: CGRect(x: 60.0, y: 60.0, width: 20.0, height: 20.0), cornerRadius: 10.0).cgPath
        context.addPath(path)
        context.fillPath()
        
        context.restoreGState()
        
        context.setBlendMode(.clear)
        context.addPath(path)
        context.fillPath()
    })?.stretchableImage(withLeftCapWidth: 70, topCapHeight: 70)
}

internal func generateMaskImage() -> UIImage? {
    return generateImage(CGSize(width: 390.0, height: 220.0), rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        
        context.setFillColor(UIColor.white.cgColor)
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: 390.0, height: 209.0), cornerRadius: 10.0).cgPath
        context.addPath(path)
        context.fillPath()
        
        try? drawSvgPath(context, path: "M183.219,208.89 H206.781 C205.648,208.89 204.567,209.371 203.808,210.214 L197.23,217.523 C196.038,218.848 193.962,218.848 192.77,217.523 L186.192,210.214 C185.433,209.371 184.352,208.89 183.219,208.89 Z ")
    })?.stretchableImage(withLeftCapWidth: 195, topCapHeight: 110)
}

internal class AttachmentController: ViewController {
    private let context: AccountContext
    //private let chatLocation: ChatLocation?
    private let isScheduledMessages: Bool
    private let buttons: [AttachmentButtonType]
    private let initialButton: AttachmentButtonType
    private let fromMenu: Bool
    private let hasTextInput: Bool
    //private let makeEntityInputView: () -> AttachmentTextInputPanelInputView?
    public var animateAppearance: Bool = false
    
    public var willDismiss: () -> Void = {}
    public var didDismiss: () -> Void = {}
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public var mediaPickerContext: AttachmentMediaPickerContext? {
        get {
            return self.node.mediaPickerContext
        }
        set {
            self.node.mediaPickerContext = newValue
        }
    }
    
    private let _ready = Promise<Bool>()
    override public var ready: Promise<Bool> {
        return self._ready
    }
        
    private final class Node: ASDisplayNode {
        private let isStandDevice = UIDevice.current.userInterfaceIdiom == .phone
        private weak var controller: AttachmentController?
        private let dim: ASDisplayNode
        private let maskNode: ASDisplayNode
        private let shadowNode: ASImageNode
        fileprivate let container: AttachmentContainer
        //private let makeEntityInputView: () -> AttachmentTextInputPanelInputView?
        let panel: AttachmentPanel
        
        private var currentType: AttachmentButtonType?
        private var currentControllers: [AttachmentContainable] = []
        
        private var validLayout: ContainerViewLayout?
        private var modalProgress: CGFloat = 0.0
        fileprivate var isDismissing = false
                
        private let captionDisposable = MetaDisposable()
        private let mediaSelectionCountDisposable = MetaDisposable()
        
        private let loadingProgressDisposable = MetaDisposable()
        private let mainButtonStateDisposable = MetaDisposable()
        
        private var selectionCount: Int = 0
        
        fileprivate func removeAllControllers() {
            currentControllers.forEach { it in
                it.dismiss()
            }
            currentControllers.removeAll()
        }
        
        fileprivate var mediaPickerContext: AttachmentMediaPickerContext? {
            didSet {
                if let mediaPickerContext = self.mediaPickerContext {
                    self.captionDisposable.set((mediaPickerContext.caption
                    |> deliverOnMainQueue).startStrict(next: { [weak self] caption in
                        if let strongSelf = self {
                            strongSelf.panel.updateCaption(caption ?? NSAttributedString())
                        }
                    }))
                    self.mediaSelectionCountDisposable.set((mediaPickerContext.selectionCount
                    |> deliverOnMainQueue).startStrict(next: { [weak self] count in
                        if let strongSelf = self {
                            strongSelf.updateSelectionCount(count)
                        }
                    }))
                    self.loadingProgressDisposable.set((mediaPickerContext.loadingProgress
                    |> deliverOnMainQueue).startStrict(next: { [weak self] progress in
                        if let strongSelf = self {
                            strongSelf.panel.updateLoadingProgress(progress)
                            if let layout = strongSelf.validLayout {
                                strongSelf.containerLayoutUpdated(layout, transition: .animated(duration: 0.4, curve: .spring))
                            }
                        }
                    }))
                    self.mainButtonStateDisposable.set((mediaPickerContext.mainButtonState
                    |> deliverOnMainQueue).startStrict(next: { [weak self] mainButtonState in
                        if let strongSelf = self {
                            let _ = (strongSelf.panel.animatingTransitionPromise.get()
                            |> filter { value in
                                return !value
                            }
                            |> take(1)).startStandalone(next: { [weak self] _ in
                                if let strongSelf = self {
                                    strongSelf.panel.updateMainButtonState(mainButtonState)
                                    if let layout = strongSelf.validLayout {
                                        strongSelf.containerLayoutUpdated(layout, transition: .animated(duration: 0.4, curve: .spring))
                                    }
                                }
                            })
                        }
                    }))
                } else {
                    self.updateSelectionCount(0)
                    self.mediaSelectionCountDisposable.set(nil)
                    self.loadingProgressDisposable.set(nil)
                    self.mainButtonStateDisposable.set(nil)
                }
            }
        }
                 
        private let wrapperNode: ASDisplayNode
        
        private let headMaskNode: ASDisplayNode
        private let headBackgroudNode: ASDisplayNode
        private let headScrolldNode: ASDisplayNode
        private var headBackgoundNodeHeight: CGFloat = 0
        private var headBackgoundOnAnimi = false
        
        init(controller: AttachmentController/*, makeEntityInputView: @escaping () -> AttachmentTextInputPanelInputView?*/) {
            self.controller = controller
            //self.makeEntityInputView = makeEntityInputView
            
            self.dim = ASDisplayNode()
            //self.dim.alpha = 0.0
            //self.dim.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
            
            self.maskNode = ASDisplayNode()
            self.maskNode.alpha = 0.0
            self.maskNode.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
            
            self.shadowNode = ASImageNode()
            self.shadowNode.isUserInteractionEnabled = false
            
            self.wrapperNode = ASDisplayNode()
            self.wrapperNode.clipsToBounds = true
            
            self.headMaskNode = ASDisplayNode()
            self.headMaskNode.alpha = 0.0
            
            self.headBackgroudNode = ASDisplayNode()
            self.headMaskNode.addSubnode(self.headBackgroudNode)
            
            self.headScrolldNode = ASDisplayNode()
            self.headMaskNode.addSubnode(self.headScrolldNode)
            
            self.container = AttachmentContainer()
            self.container.canHaveKeyboardFocus = true
            self.panel = AttachmentPanel(context: controller.context, isScheduledMessages: controller.isScheduledMessages)
            self.panel.fromMenu = controller.fromMenu
            self.panel.isStandalone = controller.isStandalone
            self.headBackgoundNodeHeight = 500
            
            super.init()
            
            self.addSubnode(self.dim)
            self.addSubnode(self.maskNode)
            self.addSubnode(self.shadowNode)
            self.addSubnode(self.headMaskNode)
            self.addSubnode(self.wrapperNode)
                        
            self.container.controllerRemoved = { [weak self] controller in
                if let strongSelf = self, let layout = strongSelf.validLayout, !strongSelf.isDismissing {
                    strongSelf.currentControllers = strongSelf.currentControllers.filter { $0 !== controller }
                    strongSelf.containerLayoutUpdated(layout, transition: .immediate)
                }
            }
            
            self.container.updateModalProgress = { [weak self] progress, topInset, transition in
                if let strongSelf = self, let layout = strongSelf.validLayout, !strongSelf.isDismissing {
                    var transition = transition
                    if strongSelf.container.supernode == nil {
                        transition = .animated(duration: 0.4, curve: .spring)
                    }
                    
                    if topInset <= 10  {
                       strongSelf.ainimShowHeadBackgroud(width: layout.size.width)
                    } else {
                        strongSelf.ainimHideHeadBackgroud(topInset < 50)
                    }
                    
                    
                    strongSelf.controller?.updateModalStyleOverlayTransitionFactor(progress, transition: transition)
                    
                    strongSelf.modalProgress = progress
                    strongSelf.containerLayoutUpdated(layout, transition: transition)
                    
                    if let currentController = strongSelf.currentControllers.last {
                        currentController.onUpdateModalProgress(topInset)
                    }
                }
            }
            
            
            self.container.isReadyUpdated = { [weak self] in
                if let strongSelf = self, let layout = strongSelf.validLayout {
                    strongSelf.containerLayoutUpdated(layout, transition: .animated(duration: 0.4, curve: .spring))
                }
            }
            
            self.container.interactivelyDismissed = { [weak self] in
                if let strongSelf = self {
                    strongSelf.controller?.dismiss(animated: true)
                }
            }
            
            self.container.isPanningUpdated = { [weak self] value in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last, !value {
                    currentController.isContainerPanningUpdated(value)
                }
            }
            
            self.container.isPanGestureEnabled = { [weak self] in
                guard let self, let currentController = self.currentControllers.last else {
                    return true
                }
                if let isPanGestureEnabled = currentController.isPanGestureEnabled {
                    return isPanGestureEnabled()
                } else {
                    return true
                }
            }
            
            self.container.shouldCancelPanGesture = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if !currentController.shouldDismissImmediately() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
            
            self.container.allowExpand = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if currentController.canExpand() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
            
            self.container.allowVerticalSwipe = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if currentController.allowVerticalSwipe() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
            
            self.container.allowHorizontalSwipe = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if currentController.allowHorizontalSwipe() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
            
            
            self.container.isModalStyle = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if currentController.isModalStyle() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
            
            self.container.isFullScreenMod = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    if currentController.isFullScreenMod() {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }
            
            self.container.requestDismiss = { [weak self] in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    currentController.requestDismiss { [weak self] in
                        if let strongSelf = self {
                            strongSelf.controller?.dismiss(animated: true)
                        }
                    }
                }
            }
            
            self.panel.selectionChanged = { [weak self] type in
                if let strongSelf = self {
                    return strongSelf.switchToController(type)
                } else {
                    return false
                }
            }
            
            self.panel.longPressed = { [weak self] _ in
                if let strongSelf = self, let currentController = strongSelf.currentControllers.last {
                    currentController.longTapWithTabBar?()
                }
            }
            
            self.panel.beganTextEditing = { [weak self] in
                if let strongSelf = self {
                    strongSelf.container.update(isExpanded: true, transition: .animated(duration: 0.4, curve: .spring))
                }
            }
            
//            self.panel.textUpdated = { [weak self] text in
//                if let strongSelf = self {
//                    strongSelf.mediaPickerContext?.setCaption(text)
//                }
//            }
            
//            self.panel.sendMessagePressed = { [weak self] mode in
//                if let strongSelf = self {
//                    switch mode {
//                    case .generic:
//                        strongSelf.mediaPickerContext?.send(mode: .generic, attachmentMode: .media)
//                    case .silent:
//                        strongSelf.mediaPickerContext?.send(mode: .silently, attachmentMode: .media)
//                    case .schedule:
//                        strongSelf.mediaPickerContext?.schedule()
//                    case .whenOnline:
//                        strongSelf.mediaPickerContext?.send(mode: .whenOnline, attachmentMode: .media)
//                    }
//                }
//            }
            
            self.panel.mainButtonPressed = { [weak self] in
                if let strongSelf = self {
                    strongSelf.mediaPickerContext?.mainButtonAction()
                }
            }
            
            self.panel.requestLayout = { [weak self] in
                if let strongSelf = self, let layout = strongSelf.validLayout {
                    strongSelf.containerLayoutUpdated(layout, transition: .animated(duration: 0.2, curve: .easeInOut))
                }
            }
            
            self.panel.present = { [weak self] c in
                if let strongSelf = self {
                    strongSelf.controller?.present(c, in: .window(.root))
                }
            }
            
            self.panel.presentInGlobalOverlay = { [weak self] c in
                if let strongSelf = self {
                    strongSelf.controller?.presentInGlobalOverlay(c, with: nil)
                }
            }
        }
        
        deinit {
            self.captionDisposable.dispose()
            self.mediaSelectionCountDisposable.dispose()
            self.loadingProgressDisposable.dispose()
            self.mainButtonStateDisposable.dispose()
        }
        
        private var inputContainerHeight: CGFloat?
        private var inputContainerNode: ASDisplayNode?
        
        func ainimShowHeadBackgroud(width: CGFloat) {
            if !self.isStandDevice {
                return
            }
            
            
            if let currentController = self.currentControllers.last {
                if currentController.isModalStyle() {
                    self.ainimHideHeadBackgroud(false)
                    return
                }
            }
            
            if self.isUpdatingContainer {
                return
            }
            
            if !self.headBackgoundOnAnimi && self.headMaskNode.frame.height != self.headBackgoundNodeHeight  {
                self.headBackgoundOnAnimi = true
                
                // 设置初始位置在视图之外，隐藏在顶部
                self.headMaskNode.frame = CGRect(
                    origin: CGPoint(x: 0.0, y: self.headBackgoundNodeHeight),
                    size: CGSize(width: width, height: 0)
                )
                self.headScrolldNode.frame =  self.headMaskNode.frame
                self.headBackgroudNode.frame = self.headMaskNode.frame
                self.headMaskNode.alpha = 0
                
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let weakSelf = self else {
                        return
                    }
                    weakSelf.headMaskNode.alpha = 1
                    weakSelf.headMaskNode.frame = CGRect(
                        origin: .zero,
                        size: CGSize(width: width, height: weakSelf.headBackgoundNodeHeight)
                    )
                    weakSelf.headScrolldNode.frame =  weakSelf.headMaskNode.frame
                    weakSelf.headBackgroudNode.frame = weakSelf.headMaskNode.frame
                }, completion: {  [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.headMaskNode.alpha = 1
                    self.headBackgoundOnAnimi = false
                })
            }
        }
        
        func ainimHideHeadBackgroud(_ animia: Bool) {
            if !self.isStandDevice {
                return
            }
            
            if self.isUpdatingContainer || self.headBackgoundOnAnimi {
                return
            }
            if animia {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let weakSelf = self else {
                        return
                    }
                    weakSelf.headMaskNode.frame = CGRect(
                        origin: CGPoint(x: 0.0, y: weakSelf.headBackgoundNodeHeight),
                        size: CGSize(width: weakSelf.headMaskNode.frame.width, height: 0))
                    weakSelf.headScrolldNode.frame =  weakSelf.headMaskNode.frame
                    weakSelf.headBackgroudNode.frame = weakSelf.headMaskNode.frame
                }, completion: { [weak self] _ in
                    self?.headBackgoundOnAnimi = false
                })
            } else {
                self.headBackgoundOnAnimi = false
                self.headMaskNode.frame = CGRect(
                    origin: CGPoint(x: 0.0, y: self.headBackgoundNodeHeight),
                    size: CGSize(width: self.headMaskNode.frame.width, height: 0))
                self.headScrolldNode.frame =  self.headMaskNode.frame
                self.headBackgroudNode.frame = self.headMaskNode.frame
            }
        }
        
        
        override func didLoad() {
            super.didLoad()
            
            self.view.disablesInteractiveModalDismiss = true
            
            self.dim.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dimTapGesture(_:))))
            
            if let controller = self.controller {
                let _ = self.switchToController(controller.initialButton)
                if controller.initialButton != .standalone {
                    if let index = controller.buttons.firstIndex(where: {
                        if $0 == controller.initialButton {
                            return true
                        } else {
                            return false
                        }
                    }) {
                        self.panel.updateSelectedIndex(index)
                    }
                }
            }
            
            if let (inputContainerHeight, inputContainerNode, _) = self.controller?.getInputContainerNode() {
                self.inputContainerHeight = inputContainerHeight
                self.inputContainerNode = inputContainerNode
                if let inputNode = inputContainerNode {
                    self.addSubnode(inputNode)
                }
            }
        }
        
        fileprivate func updateSelectionCount(_ count: Int, animated: Bool = true) {
            self.selectionCount = count
            if let layout = self.validLayout {
                self.containerLayoutUpdated(layout, transition: animated ? .animated(duration: 0.4, curve: .spring) : .immediate)
            }
        }
        
        @objc func dimTapGesture(_ recognizer: UITapGestureRecognizer) {
            guard !self.isDismissing else {
                return
            }
            if case .ended = recognizer.state {
                if let controller = self.currentControllers.last {
                    controller.requestDismiss(completion: { [weak self] in
                        self?.controller?.dismiss(animated: true)
                    })
                } else {
                    self.controller?.dismiss(animated: true)
                }
            }
        }
        
        func switchToController(_ type: AttachmentButtonType, animated: Bool = true) -> Bool {
            guard self.currentType != type else {
                if self.animating {
                    return false
                }
                if let controller = self.currentControllers.last {
                    controller.scrollToTopWithTabBar?()
                    controller.requestAttachmentMenuExpansion()
                }
                return true
            }
            let previousType = self.currentType
            self.currentType = type
            self.controller?.requestController(type, { [weak self] controller, mediaPickerContext in
                if let strongSelf = self {
                    if let controller = controller  {
                        strongSelf.controller?._ready.set(controller.ready.get())
                        controller._presentedInModal = true
                        controller.navigation_setPresenting(strongSelf.controller)
                        
                        controller.requestAttachmentMenuExpansion = { [weak self] in
                            if let strongSelf = self, !strongSelf.container.isTracking {
                                strongSelf.container.update(isExpanded: true, transition: .animated(duration: 0.4, curve: .spring))
                            }
                        }
                        
                        controller.requestFullScreen = { [weak self] show in
                            if let strongSelf = self, !strongSelf.container.isTracking {
                                strongSelf.container.requestFullScreen(show)
                                strongSelf.controller?.requestLayout(transition: .animated(duration: 0.4, curve: .spring))
                            }
                        }
                        
                        controller.updateNavigationStack = { [weak self] f in
                            if let strongSelf = self {
                                let (controllers, mediaPickerContext) = f(strongSelf.currentControllers)
                                strongSelf.currentControllers = controllers
                                strongSelf.mediaPickerContext = mediaPickerContext
                                if let layout = strongSelf.validLayout {
                                    strongSelf.containerLayoutUpdated(layout, transition: .animated(duration: 0.4, curve: .spring))
                                }
                            }
                        }
                        controller.parentController = { [weak self] in
                            guard let self else {
                                return nil
                            }
                            return self.controller
                        }
                        
                        controller.updateTabBarAlpha = { [weak self, weak controller] alpha, transition in
                            if let strongSelf = self, strongSelf.currentControllers.contains(where: { $0 === controller }) {
                                strongSelf.panel.updateBackgroundAlpha(alpha, transition: transition)
                            }
                        }
                        
                        controller.updateTabBarVisibility = { [weak self, weak controller] isVisible, transition in
                            if let strongSelf = self, strongSelf.currentControllers.contains(where: { $0 === controller }) {
                                strongSelf.updateIsPanelVisible(isVisible, transition: transition)
                            }
                        }
                        
                        controller.cancelPanGesture = { [weak self] in
                            if let strongSelf = self {
                                strongSelf.container.cancelPanGesture()
                            }
                        }
                        
                        controller.isContainerPanning = { [weak self] in
                            if let strongSelf = self {
                                return strongSelf.container.isPanning
                            } else {
                                return false
                            }
                        }
                        
                        controller.isContainerExpanded = { [weak self] in
                            if let strongSelf = self {
                                return strongSelf.container.isExpanded
                            } else {
                                return false
                            }
                        }
                        
                        controller.updateContainerHeadColor = { [weak self] bgColor, headColor, scrollColor, transition in
                            if let strongSelf = self {
                                transition.updateBackgroundColor(node: strongSelf.headScrolldNode, color: scrollColor)
                                transition.updateBackgroundColor(node: strongSelf.headMaskNode, color: bgColor)
                                transition.updateBackgroundColor(node: strongSelf.headBackgroudNode, color: headColor)
                            }
                        }
                        
                        controller.updateContainerHeadAlpha = { [weak self] alpha, transition in
                            if let strongSelf = self {
                                let alpha = max(0.0, min(1.0, alpha))
                                transition.updateAlpha(node: strongSelf.headScrolldNode, alpha: alpha, delay: 0.15)
                            }
                        }
                        
                        let previousController = strongSelf.currentControllers.last
                        strongSelf.currentControllers = [controller]
                        
                        if previousType != nil && animated {
                            strongSelf.animateSwitchTransition(controller, previousController: previousController)
                        }
                        
                        if let layout = strongSelf.validLayout {
                            strongSelf.switchingController = true
                            strongSelf.containerLayoutUpdated(layout, transition: animated ? .animated(duration: 0.3, curve: .spring) : .immediate)
                            strongSelf.switchingController = false
                        }
                    }
                    strongSelf.mediaPickerContext = mediaPickerContext
                }
            })
            return true
        }
        
        private func animateSwitchTransition(_ controller: AttachmentContainable, previousController: AttachmentContainable?) {
            guard let snapshotView = self.container.container.view.snapshotView(afterScreenUpdates: false) else {
                return
            }
            
            snapshotView.frame = self.container.container.frame
            self.container.clipNode.view.addSubview(snapshotView)
            
            let _ = (controller.ready.get()
            |> filter {
                $0
            }
            |> take(1)
            |> deliverOnMainQueue).startStandalone(next: { [weak self, weak snapshotView] _ in
                guard let strongSelf = self, let layout = strongSelf.validLayout else {
                    return
                }
                
                if case .compact = layout.metrics.widthClass {
                    let offset = 25.0
                    
                    let initialPosition = strongSelf.container.clipNode.layer.position
                    let targetPosition = initialPosition.offsetBy(dx: 0.0, dy: offset)
                    var startPosition = initialPosition
                    if let presentation = strongSelf.container.clipNode.layer.presentation() {
                        startPosition = presentation.position
                    }
                    
                    strongSelf.container.clipNode.layer.animatePosition(from: startPosition, to: targetPosition, duration: 0.2, removeOnCompletion: false, completion: { [weak self] finished in
                        if let strongSelf = self, finished {
                            strongSelf.container.clipNode.layer.animateSpring(from: NSValue(cgPoint: targetPosition), to: NSValue(cgPoint: initialPosition), keyPath: "position", duration: 0.4, delay: 0.0, initialVelocity: 0.0, damping: 70.0, removeOnCompletion: false, completion: { [weak self] finished in
                                if finished {
                                    self?.container.clipNode.layer.removeAllAnimations()
                                }
                            })
                        }
                    })
                }
                
                snapshotView?.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.23, removeOnCompletion: false, completion: { [weak snapshotView] _ in
                    snapshotView?.removeFromSuperview()
                    previousController?.resetForReuse()
                })
            })
        }
        
        private var animating = false
        func animateIn() {
            guard let layout = self.validLayout, let controller = self.controller else {
                return
            }
            
            self.animating = true
            if case .regular = layout.metrics.widthClass {
                if controller.animateAppearance {
                    let targetPosition = self.position
                    let startPosition = targetPosition.offsetBy(dx: 0.0, dy: layout.size.height)
                    
                    self.position = startPosition
                    let transition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring)
                    transition.animateView(allowUserInteraction: true, {
                        self.position = targetPosition
                    }, completion: { _ in
                        self.animating = false
                        if self.container.isExpanded {
                            self.ainimShowHeadBackgroud(width: layout.size.width)
                        }
                    })
                } else {
                    self.animating = false
                    if self.container.isExpanded {
                        self.ainimShowHeadBackgroud(width: layout.size.width)
                    }
                }
                ContainedViewLayoutTransition.animated(duration: 0.3, curve: .linear).updateAlpha(node: self.maskNode, alpha: 0.1)
            } else {
                ContainedViewLayoutTransition.animated(duration: 0.3, curve: .linear).updateAlpha(node: self.maskNode, alpha: 1.0)
                
                let targetPosition = CGPoint(x: layout.size.width / 2.0, y: layout.size.height / 2.0)
                let startPosition = targetPosition.offsetBy(dx: 0.0, dy: layout.size.height)
                
                self.container.position = startPosition
                let transition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring)
                transition.animateView(allowUserInteraction: true, {
                    self.container.position = targetPosition
                }, completion: { _ in
                    self.animating = false
                    if self.container.isExpanded {
                        self.ainimShowHeadBackgroud(width: layout.size.width)
                    }
                })
            }
        }
        
        func animateOut(completion: @escaping () -> Void = {}) {
            guard let controller = self.controller else {
                return
            }
            self.isDismissing = true
            
            guard let layout = self.validLayout else {
                return
            }
            
            self.ainimHideHeadBackgroud(false)
            
            self.animating = true
            if case .regular = layout.metrics.widthClass {
                self.layer.allowsGroupOpacity = true
                self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3, removeOnCompletion: false, completion: { [weak self] _ in
                    let _ = self?.container.dismiss(transition: .immediate, completion: completion)
                    self?.animating = false
                    self?.layer.removeAllAnimations()
                })
            } else {
                let positionTransition: ContainedViewLayoutTransition = .animated(duration: 0.25, curve: .easeInOut)
                positionTransition.updatePosition(node: self.container, position: CGPoint(x: self.container.position.x, y: self.bounds.height + self.container.bounds.height / 2.0), completion: { [weak self] _ in
                    let _ = self?.container.dismiss(transition: .immediate, completion: completion)
                    self?.animating = false
                })
                let alphaTransition: ContainedViewLayoutTransition = .animated(duration: 0.25, curve: .easeInOut)
                alphaTransition.updateAlpha(node: self.maskNode, alpha: 0.0)
                
                self.controller?.updateModalStyleOverlayTransitionFactor(0.0, transition: positionTransition)
                
                if controller.fromMenu && self.hasButton, let (_,_, getTransition) = controller.getInputContainerNode(), let inputTransition = getTransition() {
                    self.panel.animateTransitionOut(inputTransition: inputTransition, dismissed: true, transition: positionTransition)
                    self.containerLayoutUpdated(layout, transition: positionTransition)
                }
            }
        }
        
        func scrollToTop() {
            self.currentControllers.last?.scrollToTop?()
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if let controller = self.controller, controller.isInteractionDisabled() {
                return self.view
            } else {
                let result = super.hitTest(point, with: event)
                if result == self.wrapperNode.view {
                    return self.dim.view
                }
                return result
            }
        }
        
        private var isUpdatingContainer = false
        private var switchingController = false
        
        private var hasButton = false
        
        private var isPanelVisible: Bool = true
        
        private func updateIsPanelVisible(_ isVisible: Bool, transition: ContainedViewLayoutTransition) {
            if self.isPanelVisible == isVisible {
                return
            }
            self.isPanelVisible = isVisible
            if let layout = self.validLayout {
                self.containerLayoutUpdated(layout, transition: transition)
            }
        }
        
        func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
            self.validLayout = layout
            
            guard let controller = self.controller else {
                return
            }
            
            transition.updateFrame(node: self.dim, frame: CGRect(origin: CGPoint(), size: layout.size))
            transition.updateFrame(node: self.maskNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: layout.size.width, height: layout.size.height - (self.inputContainerHeight ?? 0))))
            
            let fromMenu = controller.fromMenu
            
            var containerLayout = layout
            let containerRect: CGRect
            var wrapperNodeRect: CGRect? = nil
            var isCompact = true
            
            if case .regular = layout.metrics.widthClass {
                
                if true == controller.node.container.isFullScreenMod?() {
                    containerRect = CGRect(origin: .zero, size: layout.size)
                    self.wrapperNode.cornerRadius = 0.0
                    self.wrapperNode.view.mask = nil
                    self.shadowNode.alpha = 0.0
                } else {
                    isCompact = false
                    
                    let availableHeight = layout.size.height - (layout.inputHeight ?? 0.0) - 60.0
                    
                    let availableSize = CGSize(width: 390.0, height: min(620.0, availableHeight))
                    
                    let insets = layout.insets(options: [.input])
                    let masterWidth = min(max(320.0, floor(layout.size.width / 3.0)), floor(layout.size.width / 2.0))
                                    
                    let position: CGPoint
                    let positionY = layout.size.height - availableSize.height - insets.bottom - 40.0
                    if let sourceRect = controller.getSourceRect?() {
                        position = CGPoint(x: min(layout.size.width - availableSize.width - 28.0, floor(sourceRect.midX - availableSize.width / 2.0)), y: min(positionY, sourceRect.minY - availableSize.height))
                    } else {
                        position = CGPoint(x: masterWidth - 174.0, y: positionY)
                    }
                    
                    if controller.isStandalone && !controller.forceSourceRect {
                        var containerY = floorToScreenPixels((layout.size.height - availableSize.height) / 2.0)
                        if let inputHeight = layout.inputHeight, inputHeight > 88.0 {
                            containerY = layout.size.height - inputHeight - availableSize.height - 80.0
                        }
                        containerRect = CGRect(origin: CGPoint(x: floorToScreenPixels((layout.size.width - availableSize.width) / 2.0), y: containerY), size: availableSize)
                    } else {
                        containerRect = CGRect(origin: position, size: availableSize)
                    }
                    
                    containerLayout.size = containerRect.size
                    containerLayout.intrinsicInsets.bottom = 12.0
                    containerLayout.inputHeight = nil
                    
                    if controller.isStandalone {
                        self.wrapperNode.cornerRadius = 10.0
                    } else if self.wrapperNode.view.mask == nil {
                        let maskView = UIImageView()
                        maskView.image = generateMaskImage()
                        maskView.contentMode = .scaleToFill
                        self.wrapperNode.view.mask = maskView
                    }
                    
                    if let maskView = self.wrapperNode.view.mask {
                        transition.updateFrame(view: maskView, frame: CGRect(origin: CGPoint(), size: availableSize))
                    }
                    
                    self.shadowNode.alpha = 1.0
                    if self.shadowNode.image == nil {
                        self.shadowNode.image = generateShadowImage()
                    }
                }
            } else {
                let containerHeight: CGFloat
                if fromMenu {
                    if let inputContainerHeight = self.inputContainerHeight {
                        containerHeight = layout.size.height - inputContainerHeight
                    } else {
                        containerHeight = layout.size.height
                    }
                } else {
                    containerHeight = layout.size.height
                }
                containerRect = CGRect(origin: CGPoint(), size: CGSize(width: layout.size.width, height: layout.size.height))
                wrapperNodeRect = CGRect(origin: CGPoint(), size: CGSize(width: layout.size.width, height: containerHeight))
                
                self.wrapperNode.cornerRadius = 0.0
                self.shadowNode.alpha = 0.0
                
                self.wrapperNode.view.mask = nil
            }
            
            var containerInsets = containerLayout.intrinsicInsets
            var hasPanel = false
            let previousHasButton = self.hasButton
            let hasButton = self.panel.isButtonVisible && !self.isDismissing
            self.hasButton = hasButton
            if let controller = self.controller, controller.buttons.count > 1 || controller.hasTextInput {
                hasPanel = true
            }
            if !self.isPanelVisible {
                hasPanel = false
            }
                            
            let isEffecitvelyCollapsedUpdated = (self.selectionCount > 0) != (self.panel.isSelecting)
            
            var panelHeight = self.panel.update(layout: containerLayout, 
                                                buttons: self.controller?.buttons ?? [],
                                                isSelecting: self.selectionCount > 0,
                                                elevateProgress: !hasPanel && !hasButton,
                                                transition: transition)
            
            
            if fromMenu && !hasButton, let inputContainerHeight = self.inputContainerHeight {
               panelHeight = inputContainerHeight
            }
            
            if hasPanel || hasButton || (fromMenu && isCompact) {
                containerInsets.bottom = panelHeight
            }
            
            var transitioning = false
            if fromMenu && previousHasButton != hasButton, let (_,_, getTransition) = controller.getInputContainerNode(), let inputTransition = getTransition() {
                if hasButton {
                    self.panel.animateTransitionIn(inputTransition: inputTransition, transition: transition)
                } else {
                    self.panel.animateTransitionOut(inputTransition: inputTransition, dismissed: false, transition: transition)
                }
                transitioning = true
            }
                        
            var panelTransition = transition
            if isEffecitvelyCollapsedUpdated {
                panelTransition = .animated(duration: 0.25, curve: .easeInOut)
            }
            
            var panelY = containerRect.height - panelHeight
            
            if fromMenu && isCompact {
                panelY = layout.size.height - panelHeight
            } else if !hasPanel && !hasButton {
                panelY = containerRect.height
            }
            
            if fromMenu && isCompact {
                if hasButton {
                    self.panel.isHidden = false
                    self.inputContainerNode?.isHidden = true
                } else if !transitioning {
                    if !self.panel.animatingTransition {
                        self.panel.isHidden = true
                        self.inputContainerNode?.isHidden = false
                    }
                }
            }
            
            panelTransition.updateFrame(node: self.panel, frame: CGRect(origin: CGPoint(x: 0.0, y: panelY), size: CGSize(width: containerRect.width, height: panelHeight)), completion: { [weak self] finished in
                if transitioning && finished, isCompact {
                    self?.panel.isHidden = !hasButton
                    self?.inputContainerNode?.isHidden = hasButton
                }
            })
            
            var shadowFrame = containerRect.insetBy(dx: -60.0, dy: -60.0)
            shadowFrame.size.height -= 12.0
            transition.updateFrame(node: self.shadowNode, frame: shadowFrame)
            transition.updateFrame(node: self.wrapperNode, frame: wrapperNodeRect ?? containerRect)
            
            if !self.isUpdatingContainer && !self.isDismissing {
                self.isUpdatingContainer = true
            
                let containerTransition: ContainedViewLayoutTransition
                if self.container.supernode == nil {
                    containerTransition = .immediate
                } else {
                    containerTransition = transition
                }
                
                let controllers = self.currentControllers
                if !self.animating {
                    containerTransition.updateFrame(node: self.container, frame: CGRect(origin: CGPoint(), size: containerRect.size))
                }
                
                let containerLayout = containerLayout.withUpdatedIntrinsicInsets(containerInsets)
                
                self.container.update(layout: containerLayout, 
                                      controllers: controllers,
                                      coveredByModalTransition: 0.0,
                                      transition: self.switchingController ? .immediate : transition)
                                    
                if self.container.supernode == nil, !controllers.isEmpty && self.container.isReady && !self.isDismissing {
                    self.wrapperNode.addSubnode(self.container)
                    
                    if fromMenu, let _ = controller.getInputContainerNode() {
                        self.addSubnode(self.panel)
                    } else {
                        self.container.addSubnode(self.panel)
                    }
                    
                    self.animateIn()
                }
                
                self.isUpdatingContainer = false
            }
        }
    }
    
    public var requestController: (AttachmentButtonType, @escaping (AttachmentContainable?, AttachmentMediaPickerContext?) -> Void) -> Void = { _, completion in
        completion(nil, nil)
    }
    
    public var getInputContainerNode: () -> (CGFloat, ASDisplayNode?, () -> AttachmentController.InputPanelTransition?)? = { return nil }
    
    public var getSourceRect: (() -> CGRect?)?
    
    public init(context: AccountContext, updatedPresentationData: (initial: PresentationData, signal: Signal<PresentationData, NoError>)? = nil, /*chatLocation: ChatLocation?*/ isScheduledMessages: Bool = false, buttons: [AttachmentButtonType], initialButton: AttachmentButtonType = .gallery, fromMenu: Bool = false /*, makeEntityInputView: @escaping () -> AttachmentTextInputPanelInputView? = { return nil}*/) {
        self.context = context
        //self.chatLocation = chatLocation
        self.isScheduledMessages = isScheduledMessages
        self.buttons = buttons
        self.initialButton = initialButton
        self.fromMenu = fromMenu
        self.hasTextInput = false
        //self.makeEntityInputView = makeEntityInputView
        
        super.init(navigationBarPresentationData: nil)
        
        self.statusBar.statusBarStyle = .Ignore
        self.blocksBackgroundWhenInOverlay = true
        self.acceptsFocusWhenInOverlay = true
        
        self.scrollToTop = { [weak self] in
            if let strongSelf = self {
                strongSelf.node.scrollToTop()
            }
        }
    }
        
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var forceSourceRect = false
    
    fileprivate var isStandalone: Bool {
        return self.buttons.contains(.standalone)
    }
    
    public func updateSelectionCount(_ count: Int) {
        self.node.updateSelectionCount(count, animated: false)
    }
    
    private var node: Node {
        return self.displayNode as! Node
    }
    
    open override func loadDisplayNode() {
        self.displayNode = Node(controller: self/*, makeEntityInputView: self.makeEntityInputView*/)
        self.displayNodeDidLoad()
    }
    
    private var dismissedFlag = false
    public func _dismiss() {
        if let _ = self.navigationController as? NavigationController {
            super.dismiss(animated: false, completion: {})
        } else {
            self.dismissNative(animated: false, completion: {})
        }
    }
    
    public var ensureUnfocused = true
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: flag, completion: completion)
            return
        }
        if self.ensureUnfocused {
            self.view.endEditing(true)
        }
        if flag {
            if !self.dismissedFlag {
                self.dismissedFlag = true
                self.willDismiss()
                self.node.animateOut(completion: { [weak self] in
                    self?.didDismiss()
                    self?.node.removeAllControllers()
                    self?._dismiss()
                    completion?()
                    self?.dismissedFlag = false
                    self?.node.isDismissing = false
                    self?.node.container.removeFromSupernode()
                })
            }
        } else {
            self.didDismiss()
            self.node.removeAllControllers()
            self._dismiss()
            completion?()
            self.node.isDismissing = false
            self.node.container.removeFromSupernode()
        }
    }
    
    private func isInteractionDisabled() -> Bool {
        return false
    }
    
    private var validLayout: ContainerViewLayout?
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        let previousSize = self.validLayout?.size
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.validLayout = layout
        if let previousSize, previousSize != layout.size {
            Queue.mainQueue().after(0.1) {
                self.node.containerLayoutUpdated(layout, transition: transition)
            }
        }
        self.node.containerLayoutUpdated(layout, transition: transition)
    }
    
    internal  final class InputPanelTransition {
        let inputNode: ASDisplayNode
        let accessoryPanelNode: ASDisplayNode?
        let menuButtonNode: ASDisplayNode
        let menuButtonBackgroundNode: ASDisplayNode
        let menuIconNode: ASDisplayNode
        let menuTextNode: ASDisplayNode
        let prepareForDismiss: () -> Void

        public init(
            inputNode: ASDisplayNode,
            accessoryPanelNode: ASDisplayNode?,
            menuButtonNode: ASDisplayNode,
            menuButtonBackgroundNode: ASDisplayNode,
            menuIconNode: ASDisplayNode,
            menuTextNode: ASDisplayNode,
            prepareForDismiss: @escaping () -> Void
        ) {
            self.inputNode = inputNode
            self.accessoryPanelNode = accessoryPanelNode
            self.menuButtonNode = menuButtonNode
            self.menuButtonBackgroundNode = menuButtonBackgroundNode
            self.menuIconNode = menuIconNode
            self.menuTextNode = menuTextNode
            self.prepareForDismiss = prepareForDismiss
        }
    }
    
    public static func preloadAttachBotIcons(context: AccountContext) -> DisposableSet {
        let disposableSet = DisposableSet()
//        let _ = (context.engine.messages.attachMenuBots()
//        |> take(1)
//        |> deliverOnMainQueue).startStandalone(next: { bots in
//            for bot in bots {
//                for (name, file) in bot.icons {
//                    if [.iOSAnimated, .placeholder].contains(name), let peer = PeerReference(bot.peer._asPeer()) {
//                        if case .placeholder = name {
//                            let path = context.account.postbox.mediaBox.cachedRepresentationCompletePath(file.resource.id, representation: CachedPreparedSvgRepresentation())
//                            if !FileManager.default.fileExists(atPath: path) {
//                                let accountFullSizeData = Signal<(Data?, Bool), NoError> { subscriber in
//                                    let accountResource = context.account.postbox.mediaBox.cachedResourceRepresentation(file.resource, representation: CachedPreparedSvgRepresentation(), complete: false, fetch: true)
//                                    
//                                    let fetchedFullSize = fetchedMediaResource(mediaBox: context.account.postbox.mediaBox, userLocation: .other, userContentType: MediaResourceUserContentType(file: file), reference: .media(media: .attachBot(peer: peer, media: file), resource: file.resource))
//                                    let fetchedFullSizeDisposable = fetchedFullSize.start()
//                                    let fullSizeDisposable = accountResource.start()
//                                    
//                                    return ActionDisposable {
//                                        fetchedFullSizeDisposable.dispose()
//                                        fullSizeDisposable.dispose()
//                                    }
//                                }
//                                disposableSet.add(accountFullSizeData.start())
//                            }
//                        } else {
//                            disposableSet.add(freeMediaFileInteractiveFetched(account: context.account, userLocation: .other, fileReference: .attachBot(peer: peer, media: file)).start())
//                        }
//                    }
//                }
//            }
//        })
        return disposableSet
    }
}
