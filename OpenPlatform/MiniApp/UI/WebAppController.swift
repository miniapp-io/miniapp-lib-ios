import Foundation
import UIKit
import WebKit
import MiniAppUIKit

internal final class WebAppController: ViewController, AttachmentContainable  {
    
    public var isPanGestureEnabled: (() -> Bool)? = nil
    public var requestFullScreen: (Bool) -> Void = { _ in }
    public var requestAttachmentMenuExpansion: () -> Void = { }
    public var updateNavigationStack: (@escaping ([AttachmentContainable]) -> ([AttachmentContainable], AttachmentMediaPickerContext?)) -> Void = { _ in }
    public var parentController: () -> ViewController? = {
        return nil
    }
    public var updateTabBarAlpha: (CGFloat, ContainedViewLayoutTransition) -> Void  = { _, _ in }
    public var updateTabBarVisibility: (Bool, ContainedViewLayoutTransition) -> Void = { _, _ in }
    public var cancelPanGesture: () -> Void = { }
    public var isContainerPanning: () -> Bool = { return false }
    public var isContainerExpanded: () -> Bool = { return false }
    public var updateContainerHeadColor: (UIColor, UIColor, UIColor, ContainedViewLayoutTransition) -> Void  = { _, _, _, _ in }
    public var updateContainerHeadAlpha: (Double, ContainedViewLayoutTransition) -> Void  = { _, _ in }
    
    fileprivate var controllerNode: Node {
        return self.displayNode as! Node
    }
    
    fileprivate var floatingToolBar: UIView?
    fileprivate let toolBarWidth: CGFloat = 109
    fileprivate let toolBarHeight: CGFloat = 30.0
    
    private var titleView: CounterControllerTitleView?
    fileprivate let cancelButtonNode: WebAppCancelButtonNode
    private var useWeChatStyle: Bool = true
    
    private let context: AccountContext
    private var miniAppDto: MiniAppDto? = nil
    private var webAppParameters: WebAppParameters
    private let threadId: Int64?
    private var mUrl: String? = nil
    
    private var hasSettings = false
    private var hasPrivacy = false
    private var isGetLaunchUrlSuccess = false
    
    public var getNavigationController: () -> NavigationController? = { return nil }

    public func getWebView() -> BaseWebView? {
        return self.controllerNode.webAppWebView
    }
    
    internal init(context: AccountContext, params: WebAppParameters, threadId: Int64?) {
        
        FloatingWindowManager.shared.dismissFloatingWindow(force: true)
        
        self.context = context
        self.webAppParameters = params
        self.threadId = threadId
        self.miniAppDto = params.miniAppDto
        self.useWeChatStyle = params.useWeChatStyle
        
        self.cancelButtonNode = WebAppCancelButtonNode(resourceProvider: self.context.resourceProvider)
        
        let navigationBarPresentationData = NavigationBarPresentationData(resourceProvider: self.context.resourceProvider, strings: NavigationBarStrings(back: "", close: ""))
        
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        self.statusBar.statusBarStyle = context.resourceProvider.isDark() ? .Black : .White
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customDisplayNode: self.cancelButtonNode)
        self.navigationItem.leftBarButtonItem?.action = #selector(self.cancelPressed)
        self.navigationItem.leftBarButtonItem?.target = self
        
        if(self.useWeChatStyle) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customDisplayNode: createRightButtonView())
            self.cancelButtonNode.isHidden = true
        }
        
        let titleView = CounterControllerTitleView(resourceProvider: self.context.resourceProvider)
        
        self.navigationItem.titleView = titleView
        self.titleView = titleView
        
        updateActionBarTitle()
        
        MiniAppServiceImpl.instance.inserMiniApp(self)
    }
    
    private func updateActionBarTitle() {
        
        let title: String
        let subTitle: String
        
        if webAppParameters.isDApp, let pageMetaDatas = self.getWebView()?.pageMetaDatas {
            subTitle = self.mUrl ?? self.webAppParameters.url ?? ""
            title = (pageMetaDatas["title"] ?? "") ?? ""
        } else {
            subTitle = ""
            title = ""
        }
        
        self.titleView?.title = CounterControllerTitle(title: self.miniAppDto?.title ?? self.webAppParameters.miniAppName ?? self.webAppParameters.dAppDto?.title ?? title, counter: subTitle)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        assert(true)
    }
    
    fileprivate func updateNavigationBarTheme(transition: ContainedViewLayoutTransition) {
        let navigationBarPresentationData: NavigationBarPresentationData
        
        if true == self.isFullScreenMod() || true == self.isCustomNavitationStyle() {
            let theme = NavigationBarTheme(
                    buttonColor: .clear,
                    disabledButtonColor: .clear,
                    primaryTextColor: .clear,
                    backgroundColor: .clear,
                    enableBackgroundBlur: false,
                    separatorColor: .clear,
                    badgeBackgroundColor: .clear,
                    badgeStrokeColor: .clear,
                    badgeTextColor: .clear
                )
            
            navigationBarPresentationData = NavigationBarPresentationData(
                resourceProvider: self.context.resourceProvider,
                strings: NavigationBarStrings(back: "", close: ""),
                theme: theme
            )
        } else {
            if let backgroundColor = self.controllerNode.headerColor, let textColor = self.controllerNode.headerPrimaryTextColor {
                
                let theme = NavigationBarTheme(
                        buttonColor: textColor,
                        disabledButtonColor: textColor,
                        primaryTextColor: textColor,
                        backgroundColor: backgroundColor,
                        enableBackgroundBlur: true,
                        separatorColor: UIColor(rgb: 0x000000, alpha: 0.25),
                        badgeBackgroundColor: .clear,
                        badgeStrokeColor: .clear,
                        badgeTextColor: .clear
                    )
                
                navigationBarPresentationData = NavigationBarPresentationData(
                    resourceProvider: self.context.resourceProvider,
                    strings: NavigationBarStrings(back: "", close: ""),
                    theme: theme
                )
                
            } else {
                navigationBarPresentationData = NavigationBarPresentationData(
                    resourceProvider: self.context.resourceProvider,
                    strings: NavigationBarStrings(back: "", close: "")
                )
            }
        }
        
        self.navigationBar?.updatePresentationData(navigationBarPresentationData)
    }
    
    override public func loadDisplayNode() {
        self.displayNode = Node(context: self.context, controller: self)
        self.navigationBar?.updateBackgroundAlpha(0.0, transition: .immediate)
        self.updateContainerHeadAlpha(0.0, .immediate)
        self.updateTabBarAlpha(1.0, .immediate)
    }
    
    override public func loadView() {
        super.loadView()
        self.createToolBarView()
    }
    
    public func isContainerPanningUpdated(_ isPanning: Bool) {
        self.controllerNode.isContainerPanningUpdated(isPanning)
    }
        
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationLayout(layout: layout).navigationFrame.maxY, transition: transition)
    }
    
    override public var presentationController: UIPresentationController? {
        get {
            return nil
        } set(value) {
        }
    }
    
    override public func dismiss(completion: (() -> Void)? = nil) {
        
        self.rootNV = nil
        self.rootVC = nil
        
        self.controllerNode.releaseRef()
        
        super.dismissNative(animated: false, completion: completion )
    }
    
    private var rootNV: UINavigationController? = nil
    private var rootVC: UIViewController? = nil
    
    fileprivate class Node: WebAppNode {
        private weak var controller: WebAppController?
        
        private var pageLoadingView: PageLoadingView? = nil
        
        private var maskView: UIView? = nil
        private var popupWebView: WKWebView? = nil
        private var _webAppWebView: BaseWebView? = nil
        fileprivate var webAppWebView: BaseWebView?  {
            get {
                return self._webAppWebView
            }
        }
        
        private var isUseCacheWebView: Bool = false
        
        private var placeholderIcon: (UIImage, Bool)?
            
        fileprivate let loadingProgressPromise = Promise<CGFloat?>(nil)
        
        fileprivate var mainButtonState: AttachmentMainButtonState? {
            didSet {
                self.mainButtonStatePromise.set(.single(self.mainButtonState))
            }
        }
        fileprivate let mainButtonStatePromise = Promise<AttachmentMainButtonState?>(nil)
        
        private let context: AccountContext
        private let resourceProvider: IResourceProvider
        private var queryId: Int64?
        
        private var placeholderDisposable: Disposable?
        private var iconDisposable: Disposable?
        private var keepAliveDisposable: Disposable?
        
        private var paymentDisposable: Disposable?
        
        private var lastExpansionTimestamp: Double?
        
        private var didTransitionIn = false
        private var dismissed = false
        
        private var validLayout: (ContainerViewLayout, CGFloat)?
        
        private var progressObserver: NSKeyValueObservation?
        
        init(context: AccountContext, controller: WebAppController) {
            self.context = context
            self.controller = controller
            self.resourceProvider = context.resourceProvider
            
            super.init()
            
            self.buildWebView()
            
            self.controller?.updateContainerHeadColor(self.backgroundColor ?? .clear, self.headerColor ??  .clear, self.controller?.navigationBar?.backgroundNode.bgColor ?? .clear,  .immediate)
        }
        
        deinit {
            self.placeholderDisposable?.dispose()
            self.iconDisposable?.dispose()
            self.keepAliveDisposable?.dispose()
            self.paymentDisposable?.dispose()
            self.progressObserver?.invalidate()
            self._webAppWebView = nil
        }
        
        override func didLoad() {
            super.didLoad()
            
            self.createLoadingView()
            
            self.setupWebView()
            
            guard let webView = self.webAppWebView else {
                return
            }
            
            self.view.addSubview(webView)
            
            webView.scrollView.insertSubview(self.topOverscrollNode.view, at: 0)
            
            self.controller?.webAppParameters.bridgeProvider?.onWebViewCreated(webView, parentVC: self.controller!.getVC()!)
        }
        
        private func animateTransitionIn() {
            self.pageLoadingView?.hide()
            
            guard !self.didTransitionIn, let webView = self.webAppWebView else {
                return
            }
            self.didTransitionIn = true
            
            let transition = ContainedViewLayoutTransition.animated(duration: 0.2, curve: .linear)
            transition.updateAlpha(layer: webView.layer, alpha: 1.0)
            
            self.updateHeaderBackgroundColor(transition: transition)
                        
            if let (layout, navigationBarHeight) = self.validLayout {
                self.containerLayoutUpdated(layout, navigationBarHeight: navigationBarHeight, transition: .immediate)
            }
        }
        
        private func updateNavigationBarAlpha(transition: ContainedViewLayoutTransition) {
            if let webView =  self.webAppWebView {
                let contentOffset = webView.scrollView.contentOffset.y
                let backgroundAlpha = min(30.0, contentOffset) / 30.0
                self.controller?.navigationBar?.updateBackgroundAlpha(backgroundAlpha, transition: transition)
                self.controller?.updateContainerHeadAlpha(backgroundAlpha, transition)
            }
        }
        
        private var targetContentOffset: CGPoint?
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.updateNavigationBarAlpha(transition: .immediate)
            if let targetContentOffset = self.targetContentOffset, scrollView.contentOffset != targetContentOffset {
                scrollView.contentOffset = targetContentOffset
            }
        }
        
        fileprivate func isContainerPanningUpdated(_ isPanning: Bool) {
            if let (layout, navigationBarHeight) = self.validLayout {
                self.containerLayoutUpdated(layout, navigationBarHeight: navigationBarHeight, transition: .immediate)
            }
        }
                
        func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
            
            let useFullStyle = (true == self.controller?.isFullScreenMod() ||  true==self.controller?.isCustomNavitationStyle())
            
            let headContainerHeight: CGFloat = useFullStyle ? 0.0 : navigationBarHeight
            
            let previousLayout = self.validLayout?.0
            self.validLayout = (layout, headContainerHeight)
            
            let bgSize = CGSize(width: layout.size.width, height: layout.size.height)
            transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: .zero, size: bgSize))
            
            
            let parentSize = self.bounds.size
            let targetSize = CGSize(width: 200, height: 200)
            let centerOrigin = CGPoint(
                x: (parentSize.width - targetSize.width) / 2,
                y: (parentSize.height - targetSize.height) / 2
            )
            let newFrame = CGRect(origin: centerOrigin, size: targetSize)
            transition.updateFrame(node: self.pageLodingNode, frame: newFrame)
            
            transition.updateFrame(node: self.headerBackgroundNode, frame: CGRect(origin: .zero, size: CGSize(width: layout.size.width, height: headContainerHeight)))
            
            transition.updateFrame(node: self.topOverscrollNode, frame: CGRect(origin: CGPoint(x: 0.0, y: -1000.0), size: CGSize(width: layout.size.width, height: 1000.0)))
            
            if let webView = self.webAppWebView {
                var scrollInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: layout.intrinsicInsets.bottom, right: 0.0)
                var frameBottomInset: CGFloat = 0.0
                
                if scrollInset.bottom > 40.0 {
                    frameBottomInset = scrollInset.bottom
                    scrollInset.bottom = 0.0
                }
                
                if true == self.controller?.isFullScreenMod() {
                    frameBottomInset = 0.0
                    scrollInset.bottom = 0.0
                }
                
                let frame = CGRect(origin: CGPoint(x: layout.safeInsets.left, y: headContainerHeight), size: CGSize(width: layout.size.width - layout.safeInsets.left - layout.safeInsets.right, height: max(1.0, layout.size.height - headContainerHeight - frameBottomInset)))
                
                var bottomInset = layout.intrinsicInsets.bottom + layout.additionalInsets.bottom
                if let inputHeight = self.validLayout?.0.inputHeight, inputHeight > 44.0 {
                    bottomInset = max(bottomInset, inputHeight)
                }
                let viewportFrame = CGRect(origin: CGPoint(x: layout.safeInsets.left, y: headContainerHeight), size: CGSize(width: layout.size.width - layout.safeInsets.left - layout.safeInsets.right, height: max(1.0, layout.size.height - headContainerHeight - bottomInset)))
                
                if webView.scrollView.contentInset != scrollInset {
                    webView.scrollView.contentInset = scrollInset
                    webView.scrollView.scrollIndicatorInsets = scrollInset
                }
                
                if previousLayout != nil && (previousLayout?.inputHeight ?? 0.0).isZero, let inputHeight = layout.inputHeight, inputHeight > 44.0, transition.isAnimated {
                    webView.scrollToActiveElement(layout: layout, completion: { [weak self] contentOffset in
                        self?.targetContentOffset = contentOffset
                    }, transition: transition)
                    Queue.mainQueue().after(0.4, {
                        if let inputHeight = self.validLayout?.0.inputHeight, inputHeight > 44.0 {
                            transition.updateFrame(view: webView, frame: frame)
                            Queue.mainQueue().after(0.1) {
                                self.targetContentOffset = nil
                            }
                        }
                    })
                } else {
                    transition.updateFrame(view: webView, frame: frame)
                }
                
                var customInsets: UIEdgeInsets = .zero
                if useFullStyle {
                    customInsets.top = layout.statusBarHeight ?? 0.0
                }
                if layout.intrinsicInsets.bottom > 44.0 || (layout.inputHeight ?? 0.0) > 0.0 {
                    customInsets.bottom = 0.0
                } else {
                    customInsets.bottom = layout.intrinsicInsets.bottom
                }
                customInsets.left = layout.safeInsets.left
                customInsets.right = layout.safeInsets.left
                webView.customInsets = customInsets
                
                if let controller = self.controller {
                    
                    responseContentSafeArea()
                    responseSafeArea()
                    
                    let data = "{height:\(viewportFrame.height), is_expanded:\(controller.isContainerExpanded() ? "true" : "false"), is_state_stable:\(!controller.isContainerPanning() ? "true" : "false")}"
                    controller.controllerNode.sendEvent(name: "viewport_changed", data: data)
                }
            }
            
            if let previousLayout = previousLayout, (previousLayout.inputHeight ?? 0.0).isZero, let inputHeight = layout.inputHeight, inputHeight > 44.0 {
                Queue.mainQueue().justDispatch {
                    self.requestExpansion()
                }
            }
        }
             
        private let hapticFeedback = HapticFeedback()
        
        private weak var currentQrCodeScannerScreen: UINavigationController?
        
        private var delayedScriptMessage: WKScriptMessage?
        
        fileprivate var needDismissConfirmation = false
        fileprivate var enalbeExpand: Bool? = nil
        fileprivate var showActionBar = true
        fileprivate var showFullScreen: Bool? = nil
        
        fileprivate var headerColor: UIColor?
        fileprivate var headerPrimaryTextColor: UIColor?
        private var headerColorKey: String?
        
        private func updateHeaderBackgroundColor(transition: ContainedViewLayoutTransition) {
            guard let controller = self.controller else {
                return
            }
            
            var color: UIColor?
            var primaryTextColor: UIColor?
            var secondaryTextColor: UIColor?
            var backgroundColor = self.resourceProvider.getColor(key: KEY_BG_COLOR)
            let secondaryBackgroundColor = self.resourceProvider.getColor(key: KEY_SECONDARY_BG_COLOR)
           
            if let headerColor = self.headerColor {
                color = headerColor
                let textColor = headerColor.lightness > 0.5 ? UIColor(rgb: 0x000000) : UIColor(rgb: 0xffffff)
                func calculateSecondaryAlpha(luminance: CGFloat, targetContrast: CGFloat) -> CGFloat {
                    let targetLuminance = luminance > 0.5 ? 0.0 : 1.0
                    let adaptiveAlpha = (luminance - targetLuminance + targetContrast) / targetContrast
                    return max(0.5, min(0.64, adaptiveAlpha))
                }
                
                primaryTextColor = textColor
                self.headerPrimaryTextColor = textColor
                secondaryTextColor = textColor.withAlphaComponent(calculateSecondaryAlpha(luminance: headerColor.lightness, targetContrast: 2.5))
            } else if let headerColorKey = self.headerColorKey {
                switch headerColorKey {
                    case "bg_color":
                        color = backgroundColor
                    case "secondary_bg_color":
                        color = secondaryBackgroundColor
                    default:
                        color = nil
                }
            } else {
                color = nil
            }
            
            if true == self.controller?.isFullScreenMod() || true == self.controller?.isCustomNavitationStyle() {
                color = .clear
                backgroundColor = .clear
            }
            
            self.updateNavigationBarAlpha(transition: transition)
            controller.updateNavigationBarTheme(transition: transition)
            
            controller.titleView?.updateTextColors(primary: primaryTextColor, secondary: secondaryTextColor, transition: transition)
            controller.cancelButtonNode.updateColor(primaryTextColor, transition: transition)
            
            transition.updateBackgroundColor(node: self.headerBackgroundNode, color: color ?? .clear)
            transition.updateBackgroundColor(node: self.topOverscrollNode, color: color ?? .clear)
            
            controller.updateContainerHeadColor(self.backgroundColor ?? .clear,  color ?? .clear, self.controller?.navigationBar?.backgroundNode.bgColor ?? .clear,  transition)
        }
        
        private func handleSendData(data string: String) {
            guard let controller = self.controller, !self.dismissed else {
                return
            }
            controller.dismiss(animated: true)
            
            if let data = string.data(using: .utf8), let jsonArray = try? JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any], let data = jsonArray["data"] {
                var resultString: String?
                if let string = data as? String {
                    resultString = string
                } else if let data1 = try? JSONSerialization.data(withJSONObject: data, options: []), let convertedString = String(data: data1, encoding: String.Encoding.utf8) {
                    resultString = convertedString
                }
                if let resultString = resultString {
                    self.dismissed = true
                    guard let app = self.controller else { return }
                    MiniAppServiceImpl.instance.appDelegate.sendMessageToPeer(app: app, content: resultString)
                }
            }
        }
        
        private func sendThemeChangedEvent() {
            let themeParams = generateWebAppThemeParams(resourceProvider: self.resourceProvider)
            var themeParamsString = "{theme_params: {"
            for (key, value) in themeParams {
                themeParamsString.append("\"\(key)\": \"\(value)\"")
            }
            themeParamsString.append("}}")
            self.sendEvent(name: "theme_changed", data: themeParamsString)
        }
        
        enum InvoiceCloseResult {
            case paid
            case pending
            case cancelled
            case failed
            
            var string: String {
                switch self {
                    case .paid:
                        return "paid"
                    case .pending:
                        return "pending"
                    case .cancelled:
                        return "cancelled"
                    case .failed:
                        return "failed"
                    }
            }
        }
        
        private var currentState: BotBiometricsState? = nil
    }
}

internal extension WebAppController {
    
    @objc private func cancelPressed() {
        if self.webAppParameters.isDApp {
            self.controllerNode.webAppWebView?.goBack()
            return
        }
        
        if case .back = self.cancelButtonNode.state {
            self.controllerNode.sendBackButtonEvent()
        } else {
            self.requestDismiss {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc fileprivate func mainButtonPressed() {
        self.controllerNode.sendEvent(name: "main_button_pressed", data: nil)
    }
    
    private func createRightButtonView() -> ProxyUIViewNode {
        
        if let (size, actionBarView) = webAppParameters.getActionBarNode({ [weak self] in
            if let strongSelf = self {
                strongSelf.requestDismiss {
                    strongSelf.dismiss(animated: true)
                }
            }
        }, { [weak self] in
            if let strongSelf = self {
                strongSelf.shareWebAppLink()
            }
        }) {
            actionBarView.frame.origin = .zero
            return  ProxyUIViewNode(srcView: actionBarView, size: CGSize(width: size.width, height: size.height))
        }
        
        let toolBarY = CGFloat(14.0)
        
        let rightBar = ToolBarComponent(frame: CGRect(x: 0, y: toolBarY, width: toolBarWidth, height: toolBarHeight))
        
        rightBar.dismiss = { [weak self] in
            if let strongSelf = self {
                strongSelf.requestDismiss {
                    strongSelf.dismiss(animated: true)
                }
            }
        }
        
        rightBar.share = { [weak self] in
            if let strongSelf = self {
                strongSelf.shareWebAppLink()
            }
        }
        
        rightBar.minisize = { [weak self] in
            if let strongSelf = self {
                strongSelf.minimization()
            }
        }
        
        
        let node = ProxyUIViewNode(srcView: rightBar, size: CGSize(width: toolBarWidth, height: toolBarWidth))
        
        return node
    }
    
    private func shareWebAppLink() {
        if MiniAppServiceImpl.instance.appDelegate.onMoreButtonClick(app: self, menus: getVisibleMenus().map({ it in
            it.type.rawValue
        })) {
            return
        }
        self.showMenuBottomSheet()
    }
    
    private func createToolBarView() {
        
        
        if let (_, actionBarView) = webAppParameters.getActionBarNode({ [weak self] in
            if let strongSelf = self {
                strongSelf.requestDismiss {
                    strongSelf.dismiss(animated: true)
                }
            }
        }, { [weak self] in
            if let strongSelf = self {
                strongSelf.shareWebAppLink()
            }
        }) {
           let toolBar = actionBarView
            
            // Add floating button to view
            view.addSubview(toolBar)
            
            toolBar.isHidden = true
            
            floatingToolBar = toolBar
            
            return
        }
        
        let statusBarHeight:CGFloat!
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        

        let toolBarX = UIScreen.main.bounds.size.width - toolBarWidth - 16
        let toolBarY = CGFloat( self.isFullScreenMod() ? (statusBarHeight + 14) : 14)
        
        let toolBar = ToolBarComponent(frame: CGRect(x: toolBarX, y: toolBarY, width: toolBarWidth, height: toolBarHeight))
        
        toolBar.dismiss = { [weak self] in
            if let strongSelf = self {
                strongSelf.requestDismiss {
                    strongSelf.dismiss(animated: true)
                }
            }
        }
        
        toolBar.share = { [weak self] in
            if let strongSelf = self {
                strongSelf.shareWebAppLink()
            }
        }
        
        toolBar.minisize = { [weak self] in
            if let strongSelf = self {
                strongSelf.minimization()
            }
        }
        
        // Add floating button to view
        view.addSubview(toolBar)
        
        toolBar.isHidden = true
        
        floatingToolBar = toolBar
        
    }
    
    private func resetFloatToolbarPositon() {
        let statusBarHeight:CGFloat!
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        if !isIPhone {
            floatingToolBar?.frame.origin.x = self.controllerNode.frame.width - toolBarWidth - 16
        }
        floatingToolBar?.frame.origin.y = CGFloat( self.isFullScreenMod() ? (statusBarHeight + 14) : 14)
    }
    
    var mediaPickerContext: AttachmentMediaPickerContext? {
        return WebAppPickerContext(controller: self)
    }
    
    func prepareForReuse() {
        self.updateTabBarAlpha(1.0, .immediate)
    }
    
    func refresh() {
        self.controllerNode.setupWebView()
    }
    
    func getCacheKey() -> String? {
        return self.webAppParameters.toCacheKey()
    }
    
    func requestDismiss(completion: @escaping () -> Void) {
        if self.controllerNode.needDismissConfirmation {
            if FloatingWindowManager.shared.currentApp() === self {
                FloatingWindowManager.shared.maximize()
            }
            let actionSheet = ActionSheetController(resourceProvider: self.context.resourceProvider)
            actionSheet.setItemGroups([
                ActionSheetItemGroup(items: [
                    ActionSheetTextItem(title: self.context.resourceProvider.getString(key: "WebApp.CloseConfirmation") ?? ""),
                    ActionSheetButtonItem(title: self.context.resourceProvider.getString(key: "WebApp.CloseAnyway") ?? "", color: .destructive, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        completion()
                    })
                ]),
                ActionSheetItemGroup(items: [
                    ActionSheetButtonItem(title: self.context.resourceProvider.getString(key: "Common.Cancel") ?? "", color: .accent, font: .bold, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                    })
                ])
            ])
            self.showAlert(viewController: actionSheet)
        } else {
            completion()
        }
    }
    
    func shouldDismissImmediately() -> Bool {
        if self.controllerNode.needDismissConfirmation {
            return false
        } else {
            return true
        }
    }
    
    func canExpand() -> Bool {
        return self.allowVerticalSwipe()
    }
    
   func onUpdateModalProgress(_ topIns: CGFloat) -> Void {
        if self.isFullScreenMod() {
            if topIns > 10 {
                if self.floatingToolBar?.alpha == 1 {
                    UIView.animate(withDuration: 0.2, animations: { [weak self] in
                        self?.floatingToolBar?.alpha = 0
                    }, completion: {  [weak self] _ in
                        self?.floatingToolBar?.alpha = 0
                    })
                }
            } else if self.floatingToolBar?.alpha == 0 {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.floatingToolBar?.alpha = 1
                }, completion: {  [weak self] _ in
                    self?.floatingToolBar?.alpha = 1
                })
            }
        }
    }
    
    func isModalStyle() -> Bool {
        return self.webAppParameters.useModalStyle ?? (self.miniAppDto?.options?.viewStyle == "modal")
    }
    
    func isCustomNavitationStyle() -> Bool {
        if self.webAppParameters.useCustomNavigation {
            return true
        }
        
        return self.miniAppDto?.options?.navigationStyle == "custom"
    }
    
    func isFullScreenMod() -> Bool {
        if let showFullScreen = self.controllerNode.showFullScreen, showFullScreen {
            return true
        }
        return self.isCustomNavitationStyle() &&
            !self.isModalStyle()
    }
    
    func allowVerticalSwipe() -> Bool {
        if self.webAppParameters.isDApp {
            return false
        }
        
        if true == self.controllerNode.showFullScreen {
            return false
        }
        
        return self.controllerNode.enalbeExpand
            ?? self.miniAppDto?.options?.allowVerticalSwipe
            ?? (self.miniAppDto != nil) ? self.isModalStyle() : false
    }
    
    func allowHorizontalSwipe() -> Bool {
        if self.webAppParameters.isDApp {
            return true
        }
        
        return !isBackButtonVisible() && (self.miniAppDto?.options?.allowHorizontalSwipe ?? true)
    }
    
    func isBackButtonVisible() -> Bool {
        if case .back = self.cancelButtonNode.state {
            return true
        }
        return false
    }
    
    func requestBackClick() -> Void {
        self.controllerNode.sendBackButtonEvent()
    }
            
    func showAlert(viewController: ViewController) {
        if let layout = self.parentController()?.currentlyAppliedLayout {
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
            self.present(viewController, animated: false, completion: {
                viewController.containerLayoutUpdated(layout, transition: .immediate)
            } )
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.rootVC = nil
        self.rootNV = nil
        MiniAppServiceImpl.instance.removeMiniApp(self)
        getVC()?.dismiss(animated: flag, completion: completion)
    }
}

extension WebAppController : IMiniApp {
    func reloadPage() {
        if let webView = self.controllerNode.webAppWebView, webView.isExpired {
            self.controllerNode.loadPage()
            return
        }
        guard let _ = self.mUrl else {
            self.controllerNode.loadPage()
            return
        }
        if let webView = self.controllerNode.webAppWebView {
            webView.reload()
        }
    }
    
    func requestDismiss(_ force: Bool) -> Bool {
        if force {
            self.controllerNode.releaseRef()
            self.dismiss(animated: true)
            return true
        }
        if case .back = self.cancelButtonNode.state {
            self.controllerNode.sendBackButtonEvent()
            return false
        } else {
            let needDismissConfirmation = self.controllerNode.needDismissConfirmation
            self.requestDismiss {
                self.controllerNode.releaseRef()
                self.dismiss(animated: true)
            }
            return !needDismissConfirmation
        }
    }
    
    func getVC() -> UIViewController? {
        return self.parentController()
    }
    
    func getShareUrl() async -> String? {
        
        return await getShareInfo()?.url
    }
    
    
    func getShareInfo() async -> ShareDto? {
        return await withCheckedContinuation { [weak self] continuation in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.controllerNode.getWebBehavior { result in
                if weakSelf.webAppParameters.isDApp {
                    switch result {
                    case .success(let metaData):
                        continuation.resume(returning: ShareDto(type: "WEBPAGE",
                                                     id: weakSelf.webAppParameters.dAppDto?.id,
                                                     identifier: nil,
                                                                title: metaData["title"] ?? weakSelf.webAppParameters.dAppDto?.title,
                                                     url: metaData["url"] ?? weakSelf.webAppParameters.url,
                                                                description: metaData["description"] ?? weakSelf.webAppParameters.dAppDto?.description,
                                                                iconUrl: weakSelf.controllerNode.webAppWebView?.pageIcon ?? weakSelf.webAppParameters.dAppDto?.iconUrl,
                                                                bannerUrl: metaData["image"] ?? weakSelf.webAppParameters.dAppDto?.bannerUrl,
                                                     params: metaData["params"] as? String))
                        
                    case .failure(_):
                        continuation.resume(returning: weakSelf.webAppParameters.dAppDto?.toShareData() ??
                                            ShareDto(type: "WEBPAGE",
                                                     id: nil,
                                                     identifier: nil,
                                                     title: nil,
                                                     url: weakSelf.webAppParameters.url,
                                                     description: nil,
                                                     iconUrl: weakSelf.controllerNode.webAppWebView?.pageIcon,
                                                     bannerUrl: nil,
                                                     params: nil))
                        
                    }
                    
                    return
                    
                } else {
                    
                    let mePath = MiniAppServiceImpl.instance.getContext()?.mePaths.first
                    let buildUrl: (MiniAppDto?) -> String? = { miniAppDto in
                        guard let mePath = mePath, let botIdOrName = miniAppDto?.botId ?? miniAppDto?.botName , let identifier = miniAppDto?.identifier else { return nil }
                        if let miniAppId = miniAppDto?.id {
                            return "\(mePath)/apps/\(miniAppId)"
                        }
                        return "\(mePath)/\(botIdOrName)/\(identifier)"
                    }
                    
                    switch result {
                    case .success(let metaData):
                        if let miniAppDto = weakSelf.miniAppDto {
                            continuation.resume(returning: miniAppDto.toShareData(url: buildUrl(miniAppDto), metaData: metaData))
                        } else {
                            weakSelf.controllerNode.requestMiniAppInfo { miniAppDto in
                                continuation.resume(returning: miniAppDto?.toShareData(url: buildUrl(miniAppDto), metaData: metaData))
                            }
                        }
                    case .failure(_):
                        if let miniAppDto = weakSelf.miniAppDto {
                            continuation.resume(returning: miniAppDto.toShareData(url: buildUrl(miniAppDto), metaData: [:]))
                        } else {
                            weakSelf.controllerNode.requestMiniAppInfo { miniAppDto in
                                continuation.resume(returning: miniAppDto?.toShareData(url: buildUrl(miniAppDto), metaData: [:]))
                            }
                        }
                    }
                }
            }
        }
    }

    func isSystem() -> Bool {
        return self.webAppParameters.isSystem
    }
    
    func minimization() {
        
        let width = MiniAppServiceImpl.instance.appConfig?.floatWindowWidth ?? 86.0
        let height = MiniAppServiceImpl.instance.appConfig?.floatWindowHeight ?? 128.0
        
        FloatingWindowManager.shared.showFloatingWindow(miniApp: self, webView: self.controllerNode.webAppWebView, iconUrl: miniAppDto?.iconUrl, width: width, height: height)
        self.getVC()?.view.isHidden = true
        if let navigationController = self.getVC()?.navigationController {
            self.rootNV = navigationController
            self.rootVC = navigationController.presentingViewController
            navigationController.dismiss(animated: false, completion: nil)
        }
        
        MiniAppServiceImpl.instance.appDelegate.onMinimization(app: self)
    }
    
    func maximize() {
        guard let webView = self.controllerNode.webAppWebView else {
            return
        }
        self.controllerNode.view.addSubview(webView)
        if let toolBar = self.floatingToolBar {
            self.view.bringSubviewToFront(toolBar)
        }
        self.getVC()?.view.isHidden = false
        
        if let vc = self.rootVC, let nv = self.rootNV {
            vc.present(nv, animated: false)
        }
        
        MiniAppServiceImpl.instance.appDelegate.onMaximize(app: self)
    }
    
    func clickMenu(type: String) -> Void {
        if let menuType = OW3MenuType(rawValue: type) {
            onClickMenu(type: menuType)
        }
    }
    
    func capture() -> UIImage? {
        return self.controllerNode.capture()
    }
    
}

extension WebAppController.Node {
    
    private func handleSchemeMessage(_ message: WKScriptMessage) {
        guard let controller = self.controller else {
            return
        }
        guard let url = message.body as? String else {
            return
        }
        
        if let uri = URL(string: url), self.getBridgeProvider()?.shouldOverrideUrlLoading(url: uri) ?? false {
            return
        }
    }
    
    private func buildWebView() {
        guard let controller = self.controller else {
            return
        }
        
        var bgColor = self.resourceProvider.getColor(key: KEY_BG_COLOR)
                                 
        if bgColor.rgb == 0x000000 {
            bgColor = self.resourceProvider.getColor(key: KEY_ITEM_BLOCKS_BACKGROUND_COLOR)
        }
        self.backgroundColor = bgColor
        
        if true == self.controller?.webAppParameters.isDApp {
            
            var cacheWebView: DAppWebView? = nil
            if let cacheKey = controller.getCacheKey() {
                cacheWebView = WebAppLruCache.get(key: cacheKey) as? DAppWebView
            }
            
            let webView = cacheWebView ?? DAppWebView()
            
            self.isUseCacheWebView = (cacheWebView != nil)
            
            webView.handleDismiss = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if !strongSelf.dismissed {
                    strongSelf.controller?.dismiss(animated: false)
                }
            }
            
            if cacheWebView == nil {
                if let cacheKey = controller.getCacheKey() {
                    WebAppLruCache.put(key: cacheKey, webView: webView)
                }
                webView.alpha = 0.0
                
                let cacheData = "\(controller.getCacheKey() ?? "")_\(DefaultResourceProvider.shared.getLanguageCode())_\(DefaultResourceProvider.shared.isDark())"
                
                webView.cacheData = cacheData
            }else if webView.isPageLoaded {
                webView.alpha = 1.0
            }
            
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.delegate = self.wrappedScrollViewDelegate
            webView.tintColor = self.resourceProvider.getColor(key: KEY_TAB_BAR_ICON_COLOR)
            obserWebViewProgress(webView)
            
            if #available(iOS 13.0, *) {
                if self.resourceProvider.isDark() {
                    webView.overrideUserInterfaceStyle = .dark
                } else {
                    webView.overrideUserInterfaceStyle = .unspecified
                }
            }
            
            self._webAppWebView = webView
        } else {
            var cacheWebView: WebAppWebView? = nil
            if let cacheKey = controller.getCacheKey() {
                cacheWebView = WebAppLruCache.get(key: cacheKey) as? WebAppWebView
            }
            
            let paramString = controller.webAppParameters.params?.map { key,value in
                "\(key)=\(value)"
            }.joined(separator: "&")
            
            let cacheData =  "\(controller.webAppParameters.startParams ?? "")_\(DefaultResourceProvider.shared.getLanguageCode())_\(DefaultResourceProvider.shared.isDark())_\(paramString)"
            
            let refreshFlag = !( nil != cacheWebView && cacheWebView?.cacheData == cacheData)
            if refreshFlag {
                cacheWebView = nil
            }
            
            cacheWebView?.isDismiss = false
            
            if let cacheWebView = cacheWebView, !controller.webAppParameters.useCache {
                cacheWebView.goToHomePage()
                setBackButtonVisible(false)
            }
            
            let webView = cacheWebView ?? WebAppWebView(accountId: "0", webAppName: MiniAppServiceImpl.instance.webAppName)
            
            self.isUseCacheWebView = (cacheWebView != nil)
            
            webView.handleDismiss = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if !strongSelf.dismissed {
                    strongSelf.controller?.dismiss(animated: false)
                }
            }
            
            if cacheWebView == nil {
                if let cacheKey = controller.getCacheKey() {
                    WebAppLruCache.put(key: cacheKey, webView: webView)
                }
                webView.alpha = 0.0
                webView.cacheData = cacheData
            } else if webView.isPageLoaded {
                webView.alpha = 1.0
            }
            
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.delegate = self.wrappedScrollViewDelegate
            webView.tintColor = self.resourceProvider.getColor(key: KEY_TAB_BAR_ICON_COLOR)
            obserWebViewProgress(webView)
            
            webView.handleScriptMessage = { [weak self] message in
                self?.handleScriptMessage(message)
            }
            webView.handleSchemeMessage = { [weak self] message in
                self?.handleSchemeMessage(message)
            }
            webView.onFirstTouch = { [weak self] in
                if let strongSelf = self, let delayedScriptMessage = strongSelf.delayedScriptMessage {
                    strongSelf.delayedScriptMessage = nil
                    strongSelf.handleScriptMessage(delayedScriptMessage)
                }
            }
            if #available(iOS 13.0, *) {
                if self.resourceProvider.isDark() {
                    webView.overrideUserInterfaceStyle = .dark
                } else {
                    webView.overrideUserInterfaceStyle = .unspecified
                }
            }
            self._webAppWebView = webView
        }
        
        self.webAppWebView?.canGoBackObseve = { [weak self] canGoBack in
            if false == self?.controller?.webAppParameters.isDApp {
                if !canGoBack {
                    self?.setBackButtonVisible(false)
                }
                return
            }
            self?.setBackButtonVisible(canGoBack)
        }
        
        if let bgColor = self._webAppWebView?.bgColor {
            self.backgroundColor = bgColor
        }
        
        if let headColor = self._webAppWebView?.headerColor {
            self.headerColor = headColor
        }
        
        if let backButtonVisible = self._webAppWebView?.backButtonVisible {
            self.controller?.cancelButtonNode.isHidden = !backButtonVisible
            self.controller?.cancelButtonNode.setState(backButtonVisible ? .back : .cancel, animated: true)
        }
        
        if let showFullScreen = self._webAppWebView?.showFullScreen {
            self.showFullScreen = showFullScreen
        }
        
        if let enalbeExpand = self._webAppWebView?.enalbeExpand {
            self.enalbeExpand = enalbeExpand
        }
        
        if let closeConfirm = self._webAppWebView?.closeConfirm {
            self.needDismissConfirmation = closeConfirm
        }
        
        if let hasSettings = self._webAppWebView?.hasSettings {
            self.controller?.hasSettings = hasSettings
        }
    }
    
    func sendEvent(name: String, data: String?) {
        if let webView = _webAppWebView as? WebAppWebView {
            webView.sendEvent(name: name, data: data)
        }
    }
    
    func setLastTouchTimestamp(timestamp: Double?) {
        if let webView = _webAppWebView {
            webView.lastTouchTimestamp = timestamp
        }
    }
    
    func getLastTouchTimestamp() -> Double? {
        if let webView = _webAppWebView {
            return webView.lastTouchTimestamp
        }
        return nil
    }
    
    func isDidTouchOnce() -> Bool {
        if let webView = _webAppWebView {
            return webView.didTouchOnce
        }
        return false
    }
    
    private func obserWebViewProgress(_ webView: WKWebView) {
        progressObserver?.invalidate()
        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let newProgress = change.newValue else { return }
            self?.loadingProgressPromise.set(.single(CGFloat(newProgress)))
        }
    }
    
    private func createLoadingView() {
        let loadingView = PageLoadingView(resourcesProvider: context.resourceProvider)
        loadingView.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        self.pageLoadingView = loadingView
        self.pageLodingNode.view.addSubview(loadingView)
    }
    
    fileprivate func releaseRef() {
        if let webView = self.webAppWebView {
            self.controller?.webAppParameters.bridgeProvider?.onWebViewDestroy(webView)
            
            if let cacheKey = self.controller?.getCacheKey() {
                webView.handleScriptMessage = nil
                webView.handleSchemeMessage = nil
                webView.handleDismiss = nil
                webView.onFirstTouch = nil
                WebAppLruCache.put(key: cacheKey, webView: webView)
            } else {
                webView.handleDismiss = nil
            }
        }
        
        self._webAppWebView?.evaluateJavaScript("document.querySelectorAll('audio, video').forEach(media => media.pause());", completionHandler: nil)
        self._webAppWebView?.removeFromSuperview()
        self._webAppWebView?.isDismiss = true
        self.webAppWebView?.canGoBackObseve = nil
        self._webAppWebView = nil
    }
    
    private func autoExpand(_ delay: Double? = nil) {
        if true == self.controller?.webAppParameters.autoExpand ||
            false == self.controller?.isModalStyle() ||
            false == self.controller?.allowVerticalSwipe() ||
            true == self.webAppWebView?.isExpanded
        {
            Queue.mainQueue().justDispatch {
                self.requestSetExpandBehavior(false, delay: delay)
            }
        }
    }
    
    private func showFullScreenIfNeeded(_ delay: Double = 0.0) {
        guard let controller = self.controller else {
            return
        }
        let isFullScreen = controller.isFullScreenMod()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.controller?.controllerNode.requestShowFullScreen(isFullScreen)
        }
    }
    
    private func setupWithOption() {
        guard let controller = self.controller else {
            return
        }
        
        if controller.webAppParameters.isDApp {
            controller.isPanGestureEnabled = {
                return false
            }
        }
    }
    
    
    private func to110Request(url: String) async -> URLRequest? {
        if await true == self.controller?.webAppParameters.isDApp {
            
            let result = await OpenServiceRepository.shared.get110LaunchInfo(url: url, id: self.controller?.webAppParameters.dAppDto?.id)
            
            switch(result) {
            case .success(let launchDto):
                if let uri = URL(string: launchDto.redirectUrl) {
                    return URLRequest(url: uri)
                }
            case .failure(let error):
                //callback(nil)
                MiniAppServiceImpl.instance.appDelegate.onApiError(error: error)
                switch(error) {
                case .requestFailed(let code, let message):
                    if code == 460 {
                        await self.controller?.dismiss(animated: true)
                    }
                    await self.controller?.webAppParameters.errorCallback(code, message)
                default:
                    break
                }
                return nil
            }
        }
        
        if let uri = URL(string: url) {
            return URLRequest(url: uri)
        }
        return nil
    }
    
    func setupWebView() {
        guard let controller = self.controller else {
            return
        }
        
        if controller.webAppParameters.isDApp {
            controller.isPanGestureEnabled = {
                return false
            }
        }
        
        self.setupWithOption()
        
        self.loadPage()
    }
    
    fileprivate func loadPage() {
        guard let controller = self.controller else {
            return
        }
        
        self.pageLoadingView?.showLoading()
        
        if let url = controller.webAppParameters.url {
            Task {
                if let directUrl = await to110Request(url: url)?.url?.absoluteString, let webView =  self.webAppWebView {
                    DispatchQueue.main.async { [weak self] in
                        self?.pageLoadingView?.updateIconUrl(self?.controller?.webAppParameters.dAppDto?.iconUrl)
                        self?.loadUrl(url: directUrl)
                    }
                }
            }
            self.showFullScreenIfNeeded()
        } else {
            
            if let miniAppName =  self.controller?.webAppParameters.miniAppName, true == self.controller?.webAppParameters.isLocalSource {
                self.controller?.isGetLaunchUrlSuccess = true
                if let htmlURL = Bundle.main.url(forResource: miniAppName, withExtension: "html", subdirectory: ""), let webView =  self.webAppWebView {
                    
                    let url = htmlURL.absoluteString + "#tgWebAppData=user%3D%257B%2522id%2522%253A6132055853%252C%2522first_name%2522%253A%2522billb%2522%252C%2522last_name%2522%253A%2522%2522%252C%2522username%2522%253A%2522billb008%2522%252C%2522language_code%2522%253A%2522zh-hans%2522%252C%2522allows_write_to_pm%2522%253Atrue%252C%2522photo_url%2522%253A%2522https%253A%255C%252F%255C%252Ft.me%255C%252Fi%255C%252Fuserpic%255C%252F320%255C%252F_ooPOu3U0aIepjoddkmjGdRrmxif7NVgrDl8Hu3MxK0FRU8w8HNdRPfzvuQDqU8k.svg%2522%257D%26chat_instance%3D6874471725191745609%26chat_type%3Dsender%26auth_date%3D1731772698%26hash%3D4b28282a3ca6bb84534560442d4550b9dd68954099447267aacc60c10a4920da&tgWebAppVersion=8.0&tgWebAppPlatform=android&tgWebAppThemeParams=%7B%22bg_color%22%3A%22%23ffffff%22%2C%22section_bg_color%22%3A%22%23ffffff%22%2C%22secondary_bg_color%22%3A%22%23f0f0f0%22%2C%22text_color%22%3A%22%23222222%22%2C%22hint_color%22%3A%22%23a8a8a8%22%2C%22link_color%22%3A%22%232678b6%22%2C%22button_color%22%3A%22%2350a8eb%22%2C%22button_text_color%22%3A%22%23ffffff%22%2C%22header_bg_color%22%3A%22%23527da3%22%2C%22accent_text_color%22%3A%22%231c93e3%22%2C%22section_header_text_color%22%3A%22%233a95d5%22%2C%22subtitle_text_color%22%3A%22%2382868a%22%2C%22destructive_text_color%22%3A%22%23cc2929%22%2C%22section_separator_color%22%3A%22%23d9d9d9%22%2C%22bottom_bar_bg_color%22%3A%22%23f0f0f0%22%7D"
  
                    self.controller?.mUrl = url
                    
                    webView.load(URLRequest(url: URL(string: url)!))
                }
                
                self.showFullScreenIfNeeded()
                
                return
            }
            
            requestMiniAppInfo { [weak self] app in
                guard let weakSelf = self else {
                    return
                }
                guard let _ = app else {
                    return
                }
                weakSelf.pageLoadingView?.updateIconUrl(app?.iconUrl)
                weakSelf.controller?.miniAppDto = app
                weakSelf.controller?.webAppParameters.miniAppId = app?.id
                weakSelf.controller?.webAppParameters.miniAppName = app?.identifier ?? ""
                weakSelf.controller?.webAppParameters.botName = app?.botName
                weakSelf.requestLaunchUrl()
                DispatchQueue.main.async { [weak self] in
                    if let weakSelf = self {
                        weakSelf.controller?.updateActionBarTitle()
                        weakSelf.autoExpand()
                        if weakSelf.isUseCacheWebView {
                            weakSelf.sendThemeChangedEvent()
                        }
                        weakSelf.showFullScreenIfNeeded()
                    }
                }
            }
        }
    }
    
    fileprivate func requestMiniAppInfo(callback : @escaping  (MiniAppDto?)-> Void) {
        
        if let app = self.controller?.miniAppDto {
            callback(app)
            return
        }
        
        if let appId = self.controller?.webAppParameters.miniAppId {
            Task {  [weak self] in
                let result = await  MiniAppServiceImpl.instance.getMiniAppInfoById(appId: appId)
                switch(result) {
                case .success(let app):
                    callback(app)
                case .failure(let error):
                    //callback(nil)
                    MiniAppServiceImpl.instance.appDelegate.onApiError(error: error)
                    switch(error) {
                    case .requestFailed(let code, let message):
                        if code == 460 {
                            await self?.controller?.dismiss(animated: true)
                        }
                        await self?.controller?.webAppParameters.errorCallback(code, message)
                    default:
                        break
                    }
                }
            }
            return
        }
        
        let idOrName = self.controller?.webAppParameters.botId ?? self.controller?.webAppParameters.botName
        let appName = self.controller?.webAppParameters.miniAppName
        
        if let idOrName = idOrName, let appName = appName {
            Task { [weak self] in
                let result = await  MiniAppServiceImpl.instance.getMiniAppInfoByNames(botIdOrName: idOrName, appName: appName)
                switch(result) {
                case .success(let app):
                    callback(app)
                case .failure(let error):
                    //callback(nil)
                    MiniAppServiceImpl.instance.appDelegate.onApiError(error: error)
                    switch(error) {
                    case .requestFailed(let code, let message):
                        await self?.controller?.webAppParameters.errorCallback(code, message)
                    default:
                        break
                    }
                }
            }
            
            return
        }
        
        callback(nil)
    }
    
    fileprivate func requestLaunchUrl() {
        
        guard let webAppParameters = self.controller?.webAppParameters, let appId = self.controller?.webAppParameters.miniAppId else {
            return
        }
        
        Task { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let result = await OpenServiceRepository.shared.getLaunchInfo(params: LaunchParams(url: nil, appId: appId, languageCode: DefaultResourceProvider.shared.getLanguageCode(), startParams: webAppParameters.startParams, themeParams: generateWebAppThemeParams(resourceProvider: strongSelf.resourceProvider), peer: webAppParameters.peer, platform: "IOS"))
            
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self, let webView = strongSelf.webAppWebView {
                    switch result {
                    case .success(let launchInfo):
                        strongSelf.controller?.isGetLaunchUrlSuccess = true
                        let url: String
                        
                        if let params = self?.controller?.webAppParameters.params {
                            var components = URLComponents()
                            components.queryItems = params.map({ key,value in
                                URLQueryItem(name: key, value: value)
                            })
                
                            if let queryStr = components.query, !queryStr.isEmpty {
                                url = launchInfo.url + "&" + queryStr
                            } else {
                                url = launchInfo.url
                            }
                        } else {
                            url = launchInfo.url
                        }
                        
                        strongSelf.loadUrl(url: url)
                        
                    case .failure(let error):
                        // Handle error
                        strongSelf.controller?.isGetLaunchUrlSuccess = false
                        MiniAppServiceImpl.instance.appDelegate.onApiError(error: error)
                        switch(error) {
                        case .requestFailed(let code, let message):
                            if code == 460 {
                                strongSelf.controller?.dismiss(animated: true)
                            }
                            strongSelf.controller?.webAppParameters.errorCallback(code, message)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func loadUrl(url: String) {
        if let webView = self.webAppWebView, let uri = URL(string: url) {
            let request = URLRequest(url: uri)
            let cacheUrl = webView.url
            if !isUseCacheWebView || cacheUrl == nil || !webView.isPageLoaded  {
                if let _ = webView.url {
                    webView.reload()
                } else {
                    webView.load(request)
                }
            } else {
                if webView.refreshFlag {
                    self.pageLoadingView?.showLoading()
                    setBackButtonVisible(false)
                    webView.isPageLoaded = false
                    webView.goToHomePage()
                    webView.load(request)
                } else {
                    self.webAppWebView?.isPageLoaded = true
                    self.webAppWebView?.alpha = 1.0
                    self.pageLoadingView?.hide()
                    self.controller?.webAppParameters.bridgeProvider?.onWebPageLoaded(webView)
                    webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                        if let height = result as? CGFloat {
                            if height < 0.1 {
                                DispatchQueue.main.async {
                                    self.controller?.reloadPage()
                                }
                            }
                        }
                    }
                }
            }
            self.controller?.mUrl = url
        }
    }
    
    private func shouldOverrideUrlLoading(uri: URL) -> Bool {
        return false
    }
    
    // Close popup
    @objc func closePopup() {
        popupWebView?.removeFromSuperview()
        popupWebView = nil
        maskView?.removeFromSuperview()
        maskView = nil
    }
    
    // Handle when closing popup
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            closePopup()
        }
    }
    
    func capture() -> UIImage? {
        let screenWidth = UIScreen.main.bounds.width
        
        let screenshotHeight = screenWidth * 0.8
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: screenWidth, height: screenshotHeight))
        
        let image = renderer.image { context in
            webAppWebView?.drawHierarchy(in: CGRect(x: 0, y: 0, width: screenWidth, height: screenshotHeight), afterScreenUpdates: true)
        }
        
        return image
    }
    
    private func getWebFavicon() {
        webAppWebView?.evaluateJavaScript("document.querySelector('link[rel=\"shortcut icon\"]')?.href") { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting favicon: \(error.localizedDescription)")
                return
            }
            
            if let iconUrl = result as? String {
                webAppWebView?.pageIcon = iconUrl
            } else {
                if let url = self.webAppWebView?.url {
                    let iconUrl = "\(url.scheme ?? "http")://\(url.host ?? "")/favicon.ico"
                    webAppWebView?.pageIcon = iconUrl
                }
            }
        }
    }
    
    private func getWebMetaData(completion: @escaping (Result<[String: String?], Error>) -> Void) {
        let jsCode = """
            (function() {
                var metaTags = document.getElementsByTagName('meta');
                var metaData = {};
                for (var i = 0; i < metaTags.length; i++) {
                    var name = metaTags[i].getAttribute('property') || metaTags[i].getAttribute('name');
                    if (name) {
                        switch(name.toLowerCase()) {
                            case 'og:title':
                                metaData.title = metaTags[i].getAttribute('content');
                                break;
                            case 'og:description':
                            case 'description':
                                metaData.description = metaTags[i].getAttribute('content');
                                break;
                            case 'og:url':
                                metaData.url = metaTags[i].getAttribute('content');
                                break;
                            case 'og:params':
                                metaData.params = metaTags[i].getAttribute('content');
                                break;
                            case 'og:image':
                                metaData.image = metaTags[i].getAttribute('content');
                                break;       
                        }
                    }
                }
                
                if (!metaData.title) {
                    metaData.title = document.title;
                }
                if (!metaData.url) {
                    metaData.url = window.location.href;
                }
                
                return JSON.stringify(metaData);
            })();
            """
        
        self.webAppWebView?.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let jsonString = result as? String {
                let trimmedString = jsonString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let unescapedString = trimmedString.replacingOccurrences(of: "\\\"", with: "\"")
                
                do {
                    if let data = unescapedString.data(using: .utf8) {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String?] {
                            self.webAppWebView?.pageMetaDatas = json
                            completion(.success(json))
                        } else {
                            completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                        }
                    } else {
                        completion(.failure(NSError(domain: "String to Data conversion failed", code: 0, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Invalid result type", code: 0, userInfo: nil)))
            }
        }
    }

    
    func getWebBehavior(completion: @escaping (Result<[String: String?], Error>) -> Void) {
        self.getWebFavicon()
        self.getWebMetaData(completion: completion)
    }
    
    private func responseContentSafeArea() {
        let useFullStyle = (true == self.controller?.isFullScreenMod() ||  true==self.controller?.isCustomNavitationStyle())
        if let webView = self.webAppWebView, let controller = self.controller {
            let contentTopInset =  useFullStyle ? self.controller?.floatingToolBar?.frame.bottomLeft.y : 0
            let contentInsetsData = "{top:\(contentTopInset), bottom:0.0, left:0.0, right:0.0}"
            controller.controllerNode.sendEvent(name: "content_safe_area_changed", data: contentInsetsData)
        }
    }
    
    private func responseSafeArea() {
        if let webView = self.webAppWebView, let controller = self.controller {
            let safeInsetsData = "{top:\(webView.customInsets.top), bottom:\(webView.customInsets.bottom), left:\(webView.customInsets.left), right:\(webView.customInsets.right)}"
            controller.controllerNode.sendEvent(name: "safe_area_changed", data: safeInsetsData)
        }
    }
    
    fileprivate func requestLayout() {
        if let layout = self.controller?.currentlyAppliedLayout {
            self.controller?.containerLayoutUpdated(layout, transition: .animated(duration: 0.4, curve: .spring))
        }
    }
    
    fileprivate func requestExpansion(_ delay: Double? = nil) {
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.controller?.requestAttachmentMenuExpansion()
            }
        } else {
            self.controller?.requestAttachmentMenuExpansion()
        }
    }
    
    fileprivate func setBackButtonVisible(_ isVisible: Bool) {
        self.controller?.cancelButtonNode.setState(isVisible ? .back : .cancel, animated: true)
        if true == self.controller?.useWeChatStyle {
            self.controller?.cancelButtonNode.isHidden = !isVisible
            if let webView = self.webAppWebView as? WebAppWebView {
                webView.backButtonVisible = isVisible
            }
        }
        if false == self.controller?.webAppParameters.isDApp {
            if !isVisible && true == self.webAppWebView?.canGoBack {
                self.webAppWebView?.allowsBackForwardNavigationGestures = false
            } else {
                self.webAppWebView?.allowsBackForwardNavigationGestures = true
            }
        }
    }
    
    fileprivate func requestSetExpandBehavior(_ enalbe: Bool, delay: Double? = nil) {
        if !enalbe {
            self.requestExpansion(delay)
        }
    }
    
    fileprivate func requestshowActionBar(_ show: Bool) {
        self.showActionBar = show
        if true == self.controller?.isFullScreenMod() || true == self.controller?.isCustomNavitationStyle() {
            self.controller?.floatingToolBar?.isHidden = !show
            self.controller?.navigationBar?.isHidden = true
        } else {
            self.controller?.floatingToolBar?.isHidden = true
            self.controller?.navigationBar?.isHidden = !show
        }
        self.requestLayout()
    }
    
    fileprivate func requestShowFullScreen(_ show: Bool) {

        requestshowActionBar(self.showActionBar)
        
        if show || true == self.controller?.isContainerExpanded() {
            self.controller?.requestFullScreen(show)
        } else {
            self.autoExpand(0.3)
        }
        
        self.controller?.resetFloatToolbarPositon()
        self.requestLayout()
        
        self.updateHeaderBackgroundColor(transition: .animated(duration: 0.2, curve: .linear))
        self.sendFullscreenEvent(isFullscreen: show)
    }
    
    fileprivate func sendSayHelloEvent() {
        let paramsString = "{msg: 'Welcome to IOS OpenService MiniApp!'}"
        self.sendEvent(name: "webview:notify", data: paramsString)
    }
    
    fileprivate func sendInvoiceClosedEvent(slug: String, result: InvoiceCloseResult) {
        let paramsString = "{slug: \"\(slug)\", status: \"\(result.string)\"}"
        self.sendEvent(name: "invoice_closed", data: paramsString)
    }
    
    fileprivate func sendBackButtonEvent() {
        self.sendEvent(name: "back_button_pressed", data: nil)
    }
    
    fileprivate func sendSettingsButtonEvent() {
        self.sendEvent(name: "settings_button_pressed", data: nil)
    }
    
    fileprivate func sendFullscreenEvent(isFullscreen: Bool) {
        let paramsString = "{is_fullscreen: \(isFullscreen)}"
        self.sendEvent(name: "fullscreen_changed", data: paramsString)
    }
    
    fileprivate func sendAlertButtonEvent(id: String?) {
        var paramsString: String?
        if let id = id {
            paramsString = "{button_id: \"\(id)\"}"
            self.sendEvent(name: "popup_closed", data: paramsString ?? "{}")
        }
    }
    
    fileprivate func sendPhoneRequestedEvent(phone: String?) {
        var paramsString: String?
        if let phone = phone {
            paramsString = "{phone_number: \"\(phone)\"}"
            self.sendEvent(name: "phone_requested", data: paramsString)
        }
    }
    
    fileprivate func sendQrCodeScannedEvent(data: String?) {
        let paramsString = data.flatMap { "{data: \"\($0)\"}" } ?? "{}"
        self.sendEvent(name: "qr_text_received", data: paramsString)
    }
    
    fileprivate func sendQrCodeScannerClosedEvent() {
        self.sendEvent(name: "scan_qr_popup_closed", data: nil)
    }
    
    fileprivate func sendClipboardTextEvent(requestId: String, fillData: Bool) {
        var paramsString: String
        if fillData {
            let data = UIPasteboard.general.string ?? ""
            paramsString = "{req_id: \"\(requestId)\", data: \"\(data)\"}"
        } else {
            paramsString = "{req_id: \"\(requestId)\"}"
        }
        self.sendEvent(name: "clipboard_text_received", data: paramsString)
    }
    
    fileprivate func requestWriteAccess() {

        let sendEvent: (Bool) -> Void = { success in
            var paramsString: String
            if success {
                paramsString = "{status: \"allowed\"}"
            } else {
                paramsString = "{status: \"cancelled\"}"
            }
            self.sendEvent(name: "write_access_requested", data: paramsString)
        }
        
        let getAccessSignal: Signal<Bool, NoError> = .single(false)
        let _ = (getAccessSignal
        |> deliverOnMainQueue).start(next: { [weak self] result in
            guard let self, let controller = self.controller else {
                return
            }
            if result {
                sendEvent(true)
            } else {
                
                let resourceProvider = context.resourceProvider
                let alertController = textAlertController(context: self.context, title: resourceProvider.getString(key: "WebApp.AllowWriteTitle") ?? "", text: resourceProvider.getString(key: "WebApp.AllowWriteConfirmation" ?? "", withValues: [controller.webAppParameters.miniAppName ?? "", controller.context.appName] ), actions: [TextAlertAction(type: .genericAction, title: resourceProvider.getString(key: "Common.Cancel") ?? "", action: {
                    sendEvent(false)
                }), TextAlertAction(type: .defaultAction, title: resourceProvider.getString(key: "Common.OK") ?? "", action: {
                    sendEvent(false)
                    
                })], parseMarkdown: true)
                alertController.dismissed = { byOutsideTap in
                    if byOutsideTap {
                        sendEvent(false)
                    }
                }
                self.controller?.showAlert(viewController: alertController)
            }
        })
    }
    
    fileprivate func sendBiometryInfoReceivedEvent() {
        guard let controller = self.controller else {
            return
        }
        
        let canUseBiometryAuth = MiniAppServiceImpl.instance.appDelegate.canUseBiometryAuth(app: controller)
        
        var data: [String: Any] = [:]
        if canUseBiometryAuth, let cacheKey = controller.webAppParameters.buildCacheKey() {
            
            let state = currentState ?? loadCodableData(forKey: cacheKey) ?? BotBiometricsState.create()
            self.currentState = state
            
            data["available"] = true
            
            let biometricAuthentication = LocalAuth.biometricAuthentication
            switch biometricAuthentication {
            case .faceId:
                data["type"] = "face"
            case .touchId:
                data["type"] = "finger"
            default:
                data["type"] = "unknown"
            }
            
            data["access_requested"] = state.accessRequested
            data["access_granted"] = state.accessGranted
            data["token_saved"] = state.opaqueToken != nil
            data["device_id"] = hexString(state.deviceId)
        } else {
            data["available"] = false
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            return
        }
        guard let jsonDataString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        self.sendEvent(name: "biometry_info_received", data: jsonDataString)
    }
    
    fileprivate func requestBiometryAccess(reason: String?) {
        
        guard let controller = self.controller else {
            return
        }
        
        if let currentState = self.currentState, currentState.accessGranted {
            self.sendBiometryInfoReceivedEvent()
            return
        }
        
        let updateAccessGranted: (Bool) -> Void = { [weak self] granted in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.currentState?.accessRequested = true
            strongSelf.currentState?.accessGranted = granted
            
            if let cacheKey = controller.webAppParameters.buildCacheKey() {
                saveCodableData(strongSelf.currentState, forKey: cacheKey)
            }
    
            strongSelf.sendBiometryInfoReceivedEvent()
        }
        
        var alertTitle: String?
        let alertText: String
        if let reason {
            if case .touchId = LocalAuth.biometricAuthentication {
                alertTitle = controller.context.resourceProvider.getString(key: "WebApp.AlertBiometryAccessTouchIDText", withValues: [controller.webAppParameters.miniAppName ?? ""])
            } else {
                alertTitle = controller.context.resourceProvider.getString(key: "WebApp.AlertBiometryAccessText", withValues: [controller.webAppParameters.miniAppName ?? ""])
            }
            alertText = reason
        } else {
            if case .touchId = LocalAuth.biometricAuthentication {
                alertText = controller.context.resourceProvider.getString(key: "WebApp.AlertBiometryAccessTouchIDText", withValues: [controller.webAppParameters.miniAppName ?? ""])
            } else {
                alertText = controller.context.resourceProvider.getString(key: "WebApp.AlertBiometryAccessText", withValues: [controller.webAppParameters.miniAppName ?? ""])
            }
        }
        
        let alterController = standardTextAlertController(theme: AlertControllerTheme(resourceProvider: controller.context.resourceProvider, fontSize: .regular), title: alertTitle, text: alertText, actions: [
            TextAlertAction(type: .genericAction, title: controller.context.resourceProvider.getString(key: "Common.No") ?? "", action: {
                updateAccessGranted(false)
            }),
            TextAlertAction(type: .defaultAction, title: controller.context.resourceProvider.getString(key: "Common.Yes") ?? "", action: {
                updateAccessGranted(true)
            })
        ], parseMarkdown: false)
        
        if let layout = controller.parentController()?.currentlyAppliedLayout {
            controller.present(alterController, animated: false, completion: {
                alterController.containerLayoutUpdated(layout, transition: .immediate)
            })
        }
    }
    
    fileprivate func requestBiometryAuth(reason: String?) {

        guard let currentState = self.currentState else {
            return
        }
        
        if currentState.accessRequested && currentState.accessGranted {
            Task() { [weak self] in
                guard let app = self?.controller else { return }
                let (isAuthorized, data) = await MiniAppServiceImpl.instance.appDelegate.updateBiometryToken(app: app, token: nil, reason: reason)
                self?.sendBiometryAuthResult(isAuthorized: isAuthorized, tokenData: data, isUpdate: false  )
            }
        }
    }
    
    fileprivate func requestBiometryUpdateToken(token: String?, reason: String?) {
        Task() {[weak self] in
            guard let app = self?.controller else { return }
            let (isAuthorized, data) = await MiniAppServiceImpl.instance.appDelegate.updateBiometryToken(app: app, token: token, reason: reason)
            self?.sendBiometryAuthResult(isAuthorized: isAuthorized, tokenData: data, isUpdate: true  )
        }
    }
    
    fileprivate func openBotSettings() {
        Task() { [weak self] in
            guard let app = self?.controller else { return }
            await MiniAppServiceImpl.instance.appDelegate.openBiometrySettings(app: app)
        }
    }
    
    fileprivate func addToHomeScreeen() {
        Task { [weak self] in
            if let shareDto = await self?.controller?.getShareInfo(), let id = shareDto.id, let link = shareDto.url, let title = shareDto.title {
                if !HomeScreenShortcutUtils.isShortcutAdded(id: id, type: shareDto.type) {
                    HomeScreenShortcutUtils.createShortcutLink(id: id, link: link, type: shareDto.type, label: title)
                }
                self?.sendEvent(name: "home_screen_added", data: nil)
            } else {
                let paramsString = "{\"error\": \"UNSUPPORTED\"}"
                self?.sendEvent(name: "home_screen_failed", data: paramsString)
            }
        }
    }
    
    fileprivate func checkHomeScreeen() {
        Task {  [weak self] in
            var status = "added"
            if let shareDto = await self?.controller?.getShareInfo(), let id = shareDto.id, let link = shareDto.url, let title = shareDto.title {
                if !HomeScreenShortcutUtils.isShortcutAdded(id: id, type: shareDto.type) {
                    status = "missed"
                }
            } else {
                status = "unsupported"
            }
            let paramsString = "{\"status\": \"\(status)\"}"
            self?.sendEvent(name: "home_screen_checked", data: paramsString)
        }
    }
    
    fileprivate func sendBiometryAuthResult(isAuthorized: Bool, tokenData: String?, isUpdate: Bool = false) {
        var data: [String: Any] = [:]
        
        if isUpdate {
            if isAuthorized {
                if let token = tokenData {
                    data["status"] = "updated"
                } else {
                    data["status"] = "removed"
                }
            } else {
                data["status"] = "failed"
            }
        } else {
            data["status"] = isAuthorized ? "authorized" : "failed"
        }
        
        if !isUpdate {
            if let tokenData {
                data["token"] = tokenData
            } else {
                data["token"] = ""
            }
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            return
        }
        guard let jsonDataString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        if isUpdate {
            self.sendEvent(name: "biometry_token_updated", data: jsonDataString)
        } else {
            self.sendEvent(name: "biometry_auth_requested", data: jsonDataString)
        }
      
    }
    
    fileprivate func shareAccountContact() {
    }
    
    fileprivate func invokeCustomMethod(requestId: String, method: String, params: String) {
        guard !self.dismissed else {
            return
        }
        
       guard let app = self.controller else { return }
        
       let isDeal = MiniAppServiceImpl.instance.appDelegate.customMethodProvider(app, method, params) { [weak self] result in
            if let strongSelf = self {
                let paramsString = "{req_id: \"\(requestId)\", result: \(result ?? "{}")}"
                strongSelf.sendEvent(name: "custom_method_invoked", data: paramsString)
            }
        }
        if !isDeal, let appId = self.controller?.webAppParameters.miniAppId {
            Task {
                let result = await OpenServiceRepository.shared.invokeCustomMethods(params: CustomMethodParams(appId: appId, method: method, params: params))
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else {
                        return
                    }
                    switch result {
                    case .success(let data):
                        let paramsString = "{req_id: \"\(requestId)\", result: \(data.result)}"
                        weakSelf.sendEvent(name: "custom_method_invoked", data: paramsString)
                    case .failure(_):
                         return
                    }
                }
            }
        }
    }
}

extension WebAppController.Node : WKNavigationDelegate, WKUIDelegate{
    
    private func getBridgeProvider() -> BridgeProvider? {
        return self.controller?.webAppParameters.bridgeProvider
    }
    
    private func getUIDelegateByProvider() -> WKUIDelegate? {
        return self.getBridgeProvider()?.uIDelegate()
    }
    
    private func getNavigationDelegateByProvider() -> WKNavigationDelegate? {
        return self.getBridgeProvider()?.navigationDelegate()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let navigationDelegate =  self.getNavigationDelegateByProvider() {
            navigationDelegate.webView?(webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler)
            return
        }
        decisionHandler(.allow)
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let navigationDelegate =  self.getNavigationDelegateByProvider() {
            navigationDelegate.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
            return
        }
    
        guard let redirectUri = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if self.getBridgeProvider()?.shouldOverrideUrlLoading(url: redirectUri) ?? false {
            decisionHandler(.cancel)
            return
        }
        
        if self.shouldOverrideUrlLoading(uri: redirectUri) {
            decisionHandler(.cancel)
            return
        }
        
        let url = redirectUri.absoluteString
        if isMeLink(url, baseMePaths: context.mePaths) {
            decisionHandler(.cancel)
            MiniAppServiceImpl.instance.openUrl(viewController: self.controller, url: url, webLaunchParams: self.controller?.webAppParameters)
        } else {
            if (!isNormalScheme(url) && !isLocalFile(url) && !isBlank(url)) {
                MiniAppServiceImpl.instance.openUrl(viewController: self.controller, url: url, webLaunchParams: self.controller?.webAppParameters)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let uIDelegate =  self.getUIDelegateByProvider() {
            return uIDelegate.webView?(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
        }
        
        guard let popUri = navigationAction.request.url else {
            return nil
        }
        
        if self.getBridgeProvider()?.shouldOverrideUrlLoading(url: popUri) ?? false {
            return nil
        }
        
        if self.shouldOverrideUrlLoading(uri: popUri) {
            return nil
        }
        
        if windowFeatures.height != nil || windowFeatures.width != nil {
            let maskView = UIView(frame: self.webAppWebView!.frame)
            maskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(maskView)
            self.maskView = maskView
            
            // Add tap gesture recognizer to mask layer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopup))
            maskView.addGestureRecognizer(tapGesture)
            
            let popupWebView: WKWebView
            if windowFeatures.height as! CGFloat >= self.webAppWebView!.bounds.height {
                // Full screen
                popupWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
            } else {
                // Create popup WKWebView, set maximum height
                let maxPopupHeight: CGFloat = self.webAppWebView!.bounds.height * 0.7
                popupWebView = WKWebView(frame: CGRect(x: 15, y: self.webAppWebView!.frame.origin.y + (self.webAppWebView!.bounds.height-maxPopupHeight)/2 , width: self.view.frame.width - 30, height: maxPopupHeight), configuration: configuration)
                
                popupWebView.layer.cornerRadius = 10
                popupWebView.clipsToBounds = true
            }
            
            popupWebView.alpha = 0.0
            popupWebView.uiDelegate = self
            popupWebView.navigationDelegate = self
            popupWebView.customUserAgent = webView.defaultUserAgent()
            
            self.view.addSubview(popupWebView)
            self.popupWebView = popupWebView
            
            return popupWebView
        }
        
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
           MiniAppServiceImpl.instance.openInDefaultBrowser(url: url)
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let navigationDelegate =  self.getNavigationDelegateByProvider() {
            navigationDelegate.webView?(webView, didStartProvisionalNavigation: navigation)
            return
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if webView == self.popupWebView {
            webView.alpha = 1.0
            return
        }
        
        self.pageLoadingView?.hide()
        
        if webView.canGoBack {
            if true == self.controller?.webAppParameters.isDApp {
                self.setBackButtonVisible(true)
            }
        } else {
            self.setBackButtonVisible(false)
        }
        
        if let navigationDelegate =  self.getNavigationDelegateByProvider() {
            navigationDelegate.webView?(webView, didFinish: navigation)
            return
        }
        
        if let webView = _webAppWebView {
            webView.isPageLoaded = true
            self.controller?.webAppParameters.bridgeProvider?.onWebPageLoaded(webView)
        }
        
        if true == self.controller?.webAppParameters.isDApp {
            self.getWebMetaData { _ in
                self.controller?.updateActionBarTitle()
            }
        }
    }
                    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Queue.mainQueue().after(0.6, {
            self.animateTransitionIn()
        })
    }
    
    @available(iOSApplicationExtension 15.0, iOS 15.0, *)
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.prompt)
    }
            
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if let uIDelegate =  self.getUIDelegateByProvider() {
            uIDelegate.webView?(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
            return
        }
        
        var completed = false
        let resourceProvider = context.resourceProvider
        let alertController = textAlertController(context: self.context, title: nil, text: message, actions: [TextAlertAction(type: .defaultAction, title: resourceProvider.getString(key: "Common.OK") ?? "", action: {
            if !completed {
                completed = true
                completionHandler()
            }
        })])
        alertController.dismissed = { byOutsideTap in
            if byOutsideTap {
                if !completed {
                    completed = true
                    completionHandler()
                }
            }
        }
        self.controller?.showAlert(viewController: alertController)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
         if let uIDelegate =  self.getUIDelegateByProvider() {
             uIDelegate.webView?(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
             return
         }
         
        
        var completed = false
        let resourceProvider = context.resourceProvider
        let alertController = textAlertController(context: self.context, title: nil, text: message, actions: [TextAlertAction(type: .genericAction, title: resourceProvider.getString(key: "Common.Cancel") ?? "", action: {
            if !completed {
                completed = true
                completionHandler(false)
            }
        }), TextAlertAction(type: .defaultAction, title: resourceProvider.getString(key: "Common.OK") ?? "", action: {
            if !completed {
                completed = true
                completionHandler(true)
            }
        })])
        alertController.dismissed = { byOutsideTap in
            if byOutsideTap {
                if !completed {
                    completed = true
                    completionHandler(false)
                }
            }
        }
        self.controller?.showAlert(viewController: alertController)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
       
        if let uIDelegate =  self.getUIDelegateByProvider() {
            uIDelegate.webView?(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
            return
        }
        
        var completed = false
        let promptController = promptController(sharedContext: self.context, text: prompt, value: defaultText, apply: { value in
            if !completed {
                completed = true
                if let value = value {
                    completionHandler(value)
                } else {
                    completionHandler(nil)
                }
            }
        })
        promptController.dismissed = { byOutsideTap in
            if byOutsideTap {
                if !completed {
                    completed = true
                    completionHandler(nil)
                }
            }
        }
        self.controller?.present(promptController, in: .window(.root))
    }
}

extension WebAppController.Node {
    
    private func handleScriptMessage(_ message: WKScriptMessage) {
        guard let controller = self.controller else {
            return
        }
        guard let body = message.body as? [String: Any] else {
            return
        }
        guard let eventName = body["eventName"] as? String else {
            return
        }
        
        let currentTimestamp = CACurrentMediaTime()
        let eventData = (body["eventData"] as? String)?.data(using: .utf8)
        let json = try? JSONSerialization.jsonObject(with: eventData ?? Data(), options: []) as? [String: Any]
         
        print("========> \(eventName) data: \(body["eventData"] as? String ?? "")")
        
        switch eventName {
            case "web_app_say_hello":
                self.sendSayHelloEvent()
            
            case "web_app_ready":
                self.animateTransitionIn()
            
            case "web_app_switch_inline_query":
                if let json, let query = json["query"] as? String {
                    if let chatTypes = json["chat_types"] as? [String], !chatTypes.isEmpty {
                        Task() { [weak self] in
                            guard let app = self?.controller else { return }
                            let needDismiss = await MiniAppServiceImpl.instance.appDelegate.switchInlineQuery(app: app, query: query, types: chatTypes)
                            if needDismiss {
                                guard let strongSelf = self else { return }
                                await MainActor.run {
                                    strongSelf.controller?.dismiss(animated: true)
                                }
                            }
                        }
                    } else {
                        Task() { [weak self] in
                            guard let app = self?.controller else { return }
                            let needDismiss =  await MiniAppServiceImpl.instance.appDelegate.switchInlineQuery(app: app, query: query, types: [])
                            if needDismiss {
                                guard let strongSelf = self else { return }
                                await MainActor.run {
                                    strongSelf.controller?.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            
            case "web_app_data_send":
                if let eventData = body["eventData"] as? String {
                    self.handleSendData(data: eventData)
                }
            
            case "web_app_setup_main_button":
                if !self.isDidTouchOnce() && controller.webAppParameters.url == nil && controller.webAppParameters.source == .attachMenu {
                    self.delayedScriptMessage = message
                } else if let json = json {
                    if var isVisible = json["is_visible"] as? Bool {
                        let text = json["text"] as? String
                        if (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isVisible = false
                        }
                        
                        let backgroundColorString = json["color"] as? String
                        let backgroundColor = backgroundColorString.flatMap({ UIColor(hexString: $0) }) ?? self.resourceProvider.getColor(key: KEY_ITEM_CHECK_FILL_COLOR)
                        
                        let textColorString = json["text_color"] as? String
                        let textColor = textColorString.flatMap({ UIColor(hexString: $0) }) ?? self.resourceProvider.getColor(key: KEY_ITEM_CHECK_FOREGROUND_COLOR)
                        
                        let isLoading = json["is_progress_visible"] as? Bool
                        let isEnabled = json["is_active"] as? Bool
                        let state = AttachmentMainButtonState(text: text, font: .bold, background: .color(backgroundColor), textColor: textColor, isVisible: isVisible, progress: (isLoading ?? false) ? .side : .none, isEnabled: isEnabled ?? true)
                        self.mainButtonState = state
                    }
                }
            
            case "web_app_request_viewport":
                if let (layout, navigationBarHeight) = self.validLayout {
                    self.containerLayoutUpdated(layout, navigationBarHeight: navigationBarHeight, transition: .immediate)
                }
            
            case "web_app_request_theme":
                self.sendThemeChangedEvent()
            
            case "web_app_expand":
                if let lastExpansionTimestamp = self.lastExpansionTimestamp, currentTimestamp < lastExpansionTimestamp + 1.0 {
                    
                } else {
                    self.lastExpansionTimestamp = currentTimestamp
                    //controller.requestAttachmentMenuExpansion()
                    self.webAppWebView?.isExpanded = true
                    self.requestSetExpandBehavior(false)
                }
            
            case "web_app_close":
                controller.requestDismiss {
                    controller.dismiss(animated: true)
                }
            
            case "web_app_open_tg_link":
                if let json = json, let path = json["path_full"] as? String, let mePath = self.context.mePaths.first {
                    MiniAppServiceImpl.instance.openUrl( viewController: self.controller, url: "\(mePath)\(path)", webLaunchParams: self.controller?.webAppParameters)
                }
            
            case "web_app_open_webapp_link":
                if let json = json, let path = json["path_full"] as? String, let mePath = self.context.mePaths.first{
                    MiniAppServiceImpl.instance.openUrl( viewController: self.controller, url: "\(mePath)\(path)", webLaunchParams: self.controller?.webAppParameters)
                }
            
            case "web_app_open_link":
                if let json = json, let url = json["url"] as? String {
                    let tryInstantView = json["try_instant_view"] as? Bool ?? false
                    if let lastTouchTimestamp = self.getLastTouchTimestamp(), currentTimestamp < lastTouchTimestamp + 10.0 {
                        self.setLastTouchTimestamp(timestamp: nil)
                        if tryInstantView {
                            
                        } else {
                            var parsedUrl = URL(string: url)
                            if let parsed = parsedUrl {
                                if parsed.scheme == nil || parsed.scheme!.isEmpty {
                                    parsedUrl = URL(string: "https://\(url)")
                                }
                            }
                            
                            if let parsedUrl = parsedUrl {
                                MiniAppServiceImpl.instance.openUrl( viewController: self.controller, url: parsedUrl.absoluteString, webLaunchParams: self.controller?.webAppParameters)
                            } else if let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let parsedUrl = URL(string: escapedUrl) {
                                MiniAppServiceImpl.instance.openUrl( viewController: self.controller, url: escapedUrl, webLaunchParams: self.controller?.webAppParameters)
                            }
                        }
                    }
                }
            
            case "web_app_setup_back_button":
                if let json = json, let isVisible = json["is_visible"] as? Bool {
                    self.setBackButtonVisible(isVisible)
                }
            
            case "web_app_trigger_haptic_feedback":
                if let json = json, let type = json["type"] as? String {
                    switch type {
                        case "impact":
                            if let impactType = json["impact_style"] as? String {
                                switch impactType {
                                    case "light":
                                        self.hapticFeedback.impact(.light)
                                    case "medium":
                                        self.hapticFeedback.impact(.medium)
                                    case "heavy":
                                        self.hapticFeedback.impact(.heavy)
                                    case "rigid":
                                        self.hapticFeedback.impact(.rigid)
                                    case "soft":
                                        self.hapticFeedback.impact(.soft)
                                    default:
                                        break
                                }
                            }
                        case "notification":
                            if let notificationType = json["notification_type"] as? String {
                                switch notificationType {
                                    case "success":
                                        self.hapticFeedback.success()
                                    case "error":
                                        self.hapticFeedback.error()
                                    case "warning":
                                        self.hapticFeedback.warning()
                                    default:
                                        break
                                }
                            }
                        case "selection_change":
                            self.hapticFeedback.tap()
                        default:
                            break
                    }
                }
            
            case "web_app_set_background_color":
                if let json = json, let colorValue = json["color"] as? String, let color = UIColor(hexString: colorValue) {
                    let transition = ContainedViewLayoutTransition.animated(duration: 0.2, curve: .linear)
                    transition.updateBackgroundColor(node: self.backgroundNode, color: color)
                    if let webView = self.webAppWebView as? WebAppWebView {
                        webView.bgColor = color
                    }
                }
            
            case "web_app_set_header_color":
                if let json = json {
                    if let colorKey = json["color_key"] as? String, ["bg_color", "secondary_bg_color"].contains(colorKey) {
                        self.headerColor = nil
                        self.headerColorKey = colorKey
                    } else if let hexColor = json["color"] as? String, let color = UIColor(hexString: hexColor) {
                        self.headerColor = color
                        self.headerColorKey = nil
                        if let webView = self.webAppWebView as? WebAppWebView {
                            webView.headerColor = color
                        }
                    }
                    self.updateHeaderBackgroundColor(transition: .animated(duration: 0.2, curve: .linear))
                }
            
            case "web_app_open_popup":
                if let json = json, let message = json["message"] as? String, let buttons = json["buttons"] as? [Any] {
                    let resourceProvider = context.resourceProvider
                    
                    let title = json["title"] as? String
                    var alertButtons: [TextAlertAction] = []
                    
                    for buttonJson in buttons {
                        if let button = buttonJson as? [String: Any], let id = button["id"] as? String, let type = button["type"] as? String {
                            let buttonAction = {
                                self.sendAlertButtonEvent(id: id)
                            }
                            let text = button["text"] as? String
                            switch type {
                                case "default":
                                    if let text = text {
                                        alertButtons.append(TextAlertAction(type: .genericAction, title: text, action: {
                                            buttonAction()
                                        }))
                                    }
                                case "destructive":
                                    if let text = text {
                                        alertButtons.append(TextAlertAction(type: .destructiveAction, title: text, action: {
                                            buttonAction()
                                        }))
                                    }
                                case "ok":
                                alertButtons.append(TextAlertAction(type: .defaultAction, title: resourceProvider.getString(key: "Common.OK") ?? "", action: {
                                        buttonAction()
                                    }))
                                case "cancel":
                                    alertButtons.append(TextAlertAction(type: .genericAction, title: resourceProvider.getString(key: "Common.Cancel") ?? "", action: {
                                        buttonAction()
                                    }))
                                case "close":
                                    alertButtons.append(TextAlertAction(type: .genericAction, title: resourceProvider.getString(key: "Common.Close") ?? "", action: {
                                        buttonAction()
                                    }))
                                default:
                                    break
                            }
                        }
                    }
                    
                    var actionLayout: TextAlertContentActionLayout = .horizontal
                    if alertButtons.count > 2 {
                        actionLayout = .vertical
                    }
                    let alertController = textAlertController(context: self.context, title: title, text: message, actions: alertButtons, actionLayout: actionLayout)
                    alertController.dismissed = { byOutsideTap in
                        if byOutsideTap {
                            self.sendAlertButtonEvent(id: nil)
                        }
                    }
                    
                    self.controller?.showAlert(viewController: alertController)
                }
            
            case "web_app_setup_closing_behavior":
                if let json = json, let needConfirmation = json["need_confirmation"] as? Bool {
                    self.needDismissConfirmation = needConfirmation
                    if let webView = self.webAppWebView as? WebAppWebView {
                        webView.closeConfirm = needConfirmation
                    }
                }
            
            case "web_app_setup_swipe_behavior":
                if let json = json, let canExpand = json["allow_vertical_swipe"] as? Bool {
                    self.requestSetExpandBehavior(canExpand)
                    self.enalbeExpand = canExpand
                    if let webView = self.webAppWebView {
                        webView.enalbeExpand = canExpand
                    }
                }
            
            case "web_app_request_fullscreen":
                self.showFullScreen = true
                self.webAppWebView?.showFullScreen = true
                self.requestShowFullScreen(true)

            case "web_app_exit_fullscreen":
                self.showFullScreen = false
                self.webAppWebView?.showFullScreen = false
                self.requestShowFullScreen(false)
            
            case "web_app_request_safe_area":
                self.controller?.requestLayout(transition: .immediate)
            
            case "web_app_request_content_safe_area":
                self.controller?.requestLayout(transition: .immediate)
            
            case "web_app_setup_show_head":
                if let json = json, let showHead = json["show_head"] as? Bool {
                    self.requestshowActionBar(showHead)
                }
            
            case "web_app_open_scan_qr_popup":
                var info: String = ""
                if let json = json, let text = json["text"] as? String {
                    info = text
                }
                guard let app = self.controller else { return }
                let controller = MiniAppServiceImpl.instance.appDelegate.qrcodeProvider(app, info, { [weak self] result in
                if let strongSelf = self {
                        if let data = result {
                            strongSelf.sendQrCodeScannedEvent(data: data)
                        } else {
                            strongSelf.sendQrCodeScannerClosedEvent()
                        }
                    }
                })
                self.currentQrCodeScannerScreen = controller
                if let controller = controller, let navigatioinController = self.controller?.getNavigationController() {
                    navigatioinController.pushViewController(controller, animated: true)
                }
            
            case "web_app_close_scan_qr_popup":
                if let controller = self.currentQrCodeScannerScreen {
                    self.currentQrCodeScannerScreen = nil
                    controller.popViewController(animated: true)
                }
            
            case "web_app_read_text_from_clipboard":
                if let json = json, let requestId = json["req_id"] as? String {
                    self.sendClipboardTextEvent(requestId: requestId, fillData: true)
                }
            
            case "web_app_request_write_access":
                self.requestWriteAccess()
            
            case "web_app_request_phone":
                self.shareAccountContact()
            
            case "web_app_invoke_custom_method":
                if let json, let requestId = json["req_id"] as? String, let method = json["method"] as? String, let params = json["params"] {
                    var paramsString: String?
                    if let string = params as? String {
                        paramsString = string
                    } else if let data1 = try? JSONSerialization.data(withJSONObject: params, options: []), let convertedString = String(data: data1, encoding: String.Encoding.utf8) {
                        paramsString = convertedString
                    }
                    self.invokeCustomMethod(requestId: requestId, method: method, params: paramsString ?? "{}")
                }
            
            case "web_app_setup_settings_button":
                if let json = json, let isVisible = json["is_visible"] as? Bool {
                    self.webAppWebView?.hasSettings = isVisible
                    self.controller?.hasSettings = isVisible
                }
            
            case "web_app_biometry_get_info":
                self.sendBiometryInfoReceivedEvent()
            
            case "web_app_biometry_request_access":
                var reason: String?
                if let json, let reasonValue = json["reason"] as? String, !reasonValue.isEmpty {
                    reason = reasonValue
                }
                self.requestBiometryAccess(reason: reason)
            
            case "web_app_biometry_request_auth":
                var reason: String?
                if let json, let reasonValue = json["reason"] as? String, !reasonValue.isEmpty {
                    reason = reasonValue
                }
                self.requestBiometryAuth(reason: reason)
            
            case "web_app_biometry_update_token":
                if let json, let tokenDataValue = json["token"] as? String, !tokenDataValue.isEmpty {
                    self.requestBiometryUpdateToken(token: tokenDataValue, reason: nil)
                }
            
            case "web_app_biometry_open_settings":
                if let lastTouchTimestamp = self.getLastTouchTimestamp(), currentTimestamp < lastTouchTimestamp + 10.0 {
                    self.setLastTouchTimestamp(timestamp: nil)
                    self.openBotSettings()
                }
            
            case "web_app_add_to_home_screen":
                self.addToHomeScreeen()
            
            case "web_app_check_home_screen":
                self.checkHomeScreeen()
            
            default:
                break
        }
    }
}

extension WebAppController: UIViewControllerTransitioningDelegate {
    
    func getPrivacyUrl() -> String? {
        return MiniAppServiceImpl.instance.appConfig?.privacyUrl
    }
    
    func getTermsOfServiceUrl() -> String? {
        return MiniAppServiceImpl.instance.appConfig?.termsOfServiceUrl
    }
    
    func onClickMenu(type: OW3MenuType) {
        switch type {
        case .RELOAD:
            reloadPage()
        case .SETTINGS:
            self.controllerNode.sendSettingsButtonEvent()
        case .FEEDBACK,.SHARE,.SHORTCUT:
            MiniAppServiceImpl.instance.appDelegate.onClickMenu(app: self, type: type.rawValue)
        case .TERMS:
            if let url = getTermsOfServiceUrl() {
                MiniAppServiceImpl.instance.openUrl(viewController: self, url: url, webLaunchParams: self.webAppParameters)
            }
        case .PRIVACY:
            if let url = getPrivacyUrl() {
                MiniAppServiceImpl.instance.openUrl(viewController: self, url: url, webLaunchParams: self.webAppParameters)
            }
        default:
            return
            
        }
    }
    
    func getVisibleMenus() -> [MenuItem] {
        var menus: [MenuItem] = [
            MenuItem(type: .RELOAD, title: context.resourceProvider.getString(key: "Common.Reload") ?? "", icon: "icon_menu_reload"),
            MenuItem(type: .SHORTCUT, title: context.resourceProvider.getString(key: "Common.Shortcut") ?? "", icon: "icon_menu_shortcut"),
            MenuItem(type: .FEEDBACK, title: context.resourceProvider.getString(key: "Common.Feedback") ?? "", icon: "icon_menu_feedback")
        ]
        
        let settingAt: Int
        
        if true == miniAppDto?.isShareEnable || true == webAppParameters.dAppDto?.isShareEnable  ||
            (webAppParameters.dAppDto == nil && webAppParameters.isDApp) {
            settingAt = 2
            menus.insert(MenuItem(type: .SHARE, title: context.resourceProvider.getString(key: "Common.Share") ?? "", icon: "icon_menu_share"), at: 0)
        } else {
            settingAt = 1
        }
        
        
        if hasSettings {
            menus.insert(MenuItem(type: .SETTINGS, title: context.resourceProvider.getString(key: "Common.Settings") ?? "", icon: "icon_menu_settings"), at: settingAt)
        }
        
        if let _ = getTermsOfServiceUrl() {
            menus.insert(MenuItem(type: .TERMS, title: context.resourceProvider.getString(key: "Common.Terms") ?? "", icon: "icon_menu_user_agreement"), at: menus.count)
        }
        
        if let _ = getPrivacyUrl() {
            menus.insert(MenuItem(type: .PRIVACY, title: context.resourceProvider.getString(key: "Common.Privacy") ?? "", icon: "icon_menu_privacy"), at: menus.count)
        }
        
        return menus
    }
    
    func showMenuBottomSheet() -> Void {
        
        let menus = getVisibleMenus()
        
        // Create and display BottomSheet
        let bottomSheetVC = MenusBottomSheetViewController()
        bottomSheetVC.menus = menus
        
        // Set menu item click listener
        bottomSheetVC.setItemClickListener { [weak self] index in
            if index >= 0 && index < menus.count {
                let item = menus[index]
                self?.onClickMenu(type: item.type)
            } else {
                print("Invalid index \(index)")
            }
        }
        
        // Show BottomSheet
        let navController = UINavigationController(rootViewController: bottomSheetVC)
        getVC()?.present(navController, animated: true, completion: nil)
    }
}


internal extension MiniAppDto {
    func toShareData(url: String?, metaData: [String: String?]) -> ShareDto {
        let pageMetas: [String: String?]
        if metaData["params"] != nil {
            pageMetas = metaData
        } else {
            pageMetas = [:]
        }

        return ShareDto(type: "MINIAPP",
                        id: self.id,
                        identifier: self.identifier,
                        title:  pageMetas["title"] ?? self.title,
                        url: url,
                        description:  pageMetas["description"] ??  self.description,
                        iconUrl: self.iconUrl,
                        bannerUrl:  pageMetas["image"] ?? self.bannerUrl,
                        params:  pageMetas["params"] ?? nil )
    }
}

internal extension DAppDto {
    func toShareData() -> ShareDto {
        return ShareDto(type: "WEBPAGE",
                        id: self.id,
                        identifier: nil,
                        title: self.title,
                        url: self.url,
                        description: self.description,
                        iconUrl: self.iconUrl,
                        bannerUrl: self.bannerUrl,
                        params: nil)
    }
}

internal final class WebAppPickerContext: AttachmentMediaPickerContext {
    private weak var controller: WebAppController?
    
    var selectionCount: Signal<Int, NoError> {
        return .single(0)
    }
    
    var caption: Signal<NSAttributedString?, NoError> {
        return .single(nil)
    }
    
    public var loadingProgress: Signal<CGFloat?, NoError> {
        return self.controller?.controllerNode.loadingProgressPromise.get() ?? .single(nil)
    }
    
    public var mainButtonState: Signal<AttachmentMainButtonState?, NoError> {
        return self.controller?.controllerNode.mainButtonStatePromise.get() ?? .single(nil)
    }
        
    init(controller: WebAppController) {
        self.controller = controller
    }
    
    func setCaption(_ caption: NSAttributedString) {
    }
    
    func send(mode: AttachmentMediaPickerSendMode, attachmentMode: AttachmentMediaPickerAttachmentMode) {
    }
    
    func schedule() {
    }
    
    func mainButtonAction() {
        self.controller?.mainButtonPressed()
    }
}

internal enum KeepWebViewError {
    case generic
}
