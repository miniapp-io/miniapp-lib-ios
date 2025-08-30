//
//  MiniAppClient.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/5/28.
//
import Foundation
import UIKit
import MiniAppUIKit
@preconcurrency import WebKit

open class WebAppLaunchParameters {
    func isDev() -> Bool {
        return false
    }
}

open class BaseBuilder<T: WebAppLaunchParameters> {
    
    var parentVC: UIViewController? = nil
    var botId: String? = nil
    var botName: String? = nil
    var miniAppId: String? = nil
    var miniAppName: String? = nil
    var id: String? = nil
    var startParams: String? = nil
    var params: [String:String]? = nil
    var isLocalSource: Bool = false
    var isLaunchUrl: Bool = false
    var isSystem: Bool = false
    var url: String? = nil
    var useCustomNavigation: Bool = false
    var useModalStyle: Bool? = nil
    var useWeChatStyle: Bool = true
    var useCache: Bool = true
    var autoExpand: Bool = false
    var peer: PeerParams? = nil
    var bridgeProvider: BridgeProvider? = nil
    var getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil}
    var getInputContainerNode: () -> (CGFloat, UIView?)? = {return nil}
    var completion: (IMiniApp) -> Void = { _ in }
    var willDismiss: () -> Void = {}
    var didDismiss: () -> Void = {}
    var errorCallback: (Int,String?) -> Void = {_,_ in}
    
    public init() {
    }
    
    public func parentVC(_ parentVC: UIViewController) -> BaseBuilder {
        self.parentVC = parentVC
        return self
    }
    
    public func botId(_ botId: String?) -> BaseBuilder {
        self.botId = botId
        return self
    }
    
    public func botName(_ botName: String?) -> BaseBuilder {
        self.botName = botName
        return self
    }
    
    public func miniAppId(_ miniAppId: String?) -> BaseBuilder {
        self.miniAppId = miniAppId
        return self
    }
    
    public func miniAppName(_ miniAppName: String?) -> BaseBuilder {
        self.miniAppName = miniAppName
        return self
    }
    
    public func id(_ id: String?) -> BaseBuilder {
        self.id = id
        return self
    }
    
    public func startParams(_ startParams: String?) -> BaseBuilder {
        self.startParams = startParams
        return self
    }
    
    public func params(_ params: [String:String]?) -> BaseBuilder {
        self.params = params
        return self
    }
    
    public func url(_ url: String?) -> BaseBuilder {
        self.url = url
        return self
    }
    
    public func useModalStyle(_ useModalStyle: Bool) -> BaseBuilder {
        self.useModalStyle = useModalStyle
        return self
    }
    
    public func useCustomNavigation(_ useCustomNavigation: Bool) -> BaseBuilder {
        self.useCustomNavigation = useCustomNavigation
        return self
    }
    
    public func useWeChatStyle(_ useWeChatStyle: Bool) -> BaseBuilder {
        self.useWeChatStyle = useWeChatStyle
        return self
    }
    
    public func isLocalSource(_ isLocalSource: Bool) -> BaseBuilder {
        self.isLocalSource = isLocalSource
        return self
    }
    
    public func isLaunchUrl(_ isLaunchUrl: Bool) -> BaseBuilder {
        self.isLaunchUrl = isLaunchUrl
        return self
    }
    
    public func isSystem(_ isSystem: Bool) -> BaseBuilder {
        self.isSystem = isSystem
        return self
    }
    
    public func useCache(_ useCache: Bool) -> BaseBuilder {
        self.useCache = useCache
        return self
    }
    
    public func autoExpand(_ autoExpand: Bool) -> BaseBuilder {
        self.autoExpand = autoExpand
        return self
    }
    
    public func peer(_ peer: PeerParams?) -> BaseBuilder {
        self.peer = peer
        return self
    }
    
    public func bridgeProvider(_ bridgeProvider: BridgeProvider?) -> BaseBuilder {
        self.bridgeProvider = bridgeProvider
        return self
    }
    
    public func getActionBarNode(_ getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?) -> BaseBuilder {
        self.getActionBarNode = getActionBarNode
        return self
    }
    
    public func getInputContainerNode(_ getInputContainerNode: @escaping () -> (CGFloat, UIView?)? = { return nil }) -> BaseBuilder {
        self.getInputContainerNode = getInputContainerNode
        return self
    }
    
    public func completion(_ completion: @escaping (IMiniApp) -> Void = { _ in }) -> BaseBuilder {
        self.completion = completion
        return self
    }
    
    public func willDismiss(_ willDismiss: @escaping () -> Void = {}) -> BaseBuilder {
        self.willDismiss = willDismiss
        return self
    }
    
    public func didDismiss(_ didDismiss: @escaping () -> Void = {}) -> BaseBuilder {
        self.didDismiss = didDismiss
        return self
    }
    
    public func errorCallback(_ errorCallback: @escaping (Int,String?) -> Void) -> BaseBuilder {
        self.errorCallback = errorCallback
        return self
    }
    
    open func require() throws {
        guard let parentVC = self.parentVC else {
            throw ApiError.invalidParameter("Invalid context")
        }
    }
    
    open func build() throws -> T {
        fatalError("Subclasses must override build()")
    }
}

public class DAppLaunchParameters : WebAppLaunchParameters {
    let parentVC: UIViewController
    let id: String?
    let url: String?
    
    let bridgeProvider: BridgeProvider?
    
    let getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?
    
    let completion: (IMiniApp) -> Void
    let willDismiss: () -> Void
    let didDismiss: () -> Void
    let errorCallback: (Int,String?) -> Void
    
    private init(
        parentVC: UIViewController,
        id: String? = nil,
        url: String? = nil,
        bridgeProvider: BridgeProvider? = nil,
        getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil},
        completion: @escaping (IMiniApp) -> Void = { _ in },
        willDismiss: @escaping () -> Void = {},
        didDismiss: @escaping () -> Void = {},
        errorCallback: @escaping (Int,String?) -> Void = {_,_ in}
    ) {
        self.parentVC = parentVC
        self.id = id
        self.url = url
        self.bridgeProvider = bridgeProvider
        self.getActionBarNode = getActionBarNode
        
        self.completion = completion
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.errorCallback = errorCallback
        
        super.init()
    }
    
    public class Builder: BaseBuilder<DAppLaunchParameters> {
        
        public override func build() throws -> DAppLaunchParameters {
            try require()
            
            return DAppLaunchParameters(
                parentVC: parentVC!,
                id: id,
                url: url,
                bridgeProvider: bridgeProvider,
                getActionBarNode: getActionBarNode,
                completion: completion,
                willDismiss: willDismiss,
                didDismiss: didDismiss,
                errorCallback: errorCallback
            )
        }
    }
}

public class WebAppPreloadParameters : WebAppLaunchParameters {
    let botId: String?
    let botName: String?
    let miniAppId: String?
    let miniAppName: String?
    let startParams: String?
    let params: [String:String]?
    let url: String?
    let peer: PeerParams?
    let bridgeProvider: BridgeProvider?
    
    private init(botId: String?,
                 botName: String?,
                 miniAppId: String?,
                 miniAppName: String?,
                 startParams: String? = nil,
                 params: [String:String]? = nil,
                 url: String? = nil,
                 peer: PeerParams? = nil,
                 bridgeProvicer: BridgeProvider? = nil) {
        self.botId = botId
        self.botName = botName
        self.miniAppId = miniAppId
        self.miniAppName = miniAppName
        self.startParams = startParams
        self.params = params
        self.url = url
        self.peer = peer
        self.bridgeProvider = bridgeProvicer
        super.init()
    }
    
    public class Builder : BaseBuilder<WebAppPreloadParameters>  {
        
        public override func build() -> WebAppPreloadParameters {
 
            return WebAppPreloadParameters(
                botId: botId,
                botName: botName,
                miniAppId: miniAppId,
                miniAppName: miniAppName,
                startParams: startParams,
                params: params,
                url: url,
                peer: peer,
                bridgeProvicer: bridgeProvider
            )
        }
    }
}

public class WebAppLaunchWithDialogParameters : WebAppLaunchParameters {
    let parentVC: UIViewController
    let source: Source = .generic
    let botId: String?
    let botName: String?
    let miniAppId: String?
    let miniAppName: String?
    let startParams: String?
    let params: [String:String]?
    let isLocalSource: Bool
    let isSystem: Bool
    let isLaunchUrl: Bool
    let useModalStyle: Bool?
    let useCustomNavigation: Bool
    let url: String?
    let useWeChatStyle: Bool
    let useCache: Bool
    let autoExpand: Bool
    let peer: PeerParams?
    
    let bridgeProvider: BridgeProvider?
    
    let getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?
    
    let completion: (IMiniApp) -> Void
    let willDismiss: () -> Void
    let didDismiss: () -> Void
    let errorCallback: (Int,String?) -> Void
    
    private init(
        parentVC: UIViewController,
        botId: String?,
        botName: String?,
        miniAppId: String?,
        miniAppName: String?,
        startParams: String? = nil,
        params: [String:String]? = nil,
        url: String? = nil,
        isLaunchUrl: Bool = false,
        useWeChatStyle: Bool = true,
        isLocalSource: Bool = false,
        isSystem: Bool = false,
        useModalStyle: Bool? = nil,
        useCustomNavigation: Bool = false,
        useCache: Bool = true,
        autoExpand: Bool = false,
        peer: PeerParams? = nil,
        bridgeProvider: BridgeProvider? = nil,
        getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil},
        completion: @escaping (IMiniApp) -> Void = { _ in },
        willDismiss: @escaping () -> Void = {},
        didDismiss: @escaping () -> Void = {},
        errorCallback: @escaping (Int,String?) -> Void = {_,_ in}
    ) {
        self.parentVC = parentVC
        self.botId = botId
        self.botName = botName
        self.miniAppId = miniAppId
        self.miniAppName = miniAppName
        self.startParams = startParams
        self.params = params
        self.url = url
        self.useWeChatStyle = useWeChatStyle
        self.isLocalSource = isLocalSource
        self.isSystem = isSystem
        self.isLaunchUrl = isLaunchUrl
        self.useModalStyle = useModalStyle
        self.useCustomNavigation = useCustomNavigation
        self.useCache = useCache
        self.autoExpand = autoExpand
        self.peer = peer
        self.bridgeProvider = bridgeProvider
        self.getActionBarNode = getActionBarNode
        
        self.completion = completion
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.errorCallback = errorCallback
        
        super.init()
    }
    
    override func isDev() -> Bool {
        return isLocalSource
    }
    
    public class Builder : BaseBuilder<WebAppLaunchWithDialogParameters> {
        
        public override func build() throws -> WebAppLaunchWithDialogParameters {
            
            try require()
            
            return WebAppLaunchWithDialogParameters(
                parentVC: parentVC!,
                botId: botId,
                botName: botName,
                miniAppId: miniAppId,
                miniAppName: miniAppName,
                startParams: startParams,
                params: params,
                url: url,
                isLaunchUrl: isLaunchUrl,
                useWeChatStyle: useWeChatStyle,
                isLocalSource: isLocalSource,
                isSystem: isSystem,
                useModalStyle: useModalStyle,
                useCustomNavigation: useCustomNavigation,
                useCache: useCache,
                autoExpand: autoExpand,
                peer: peer,
                bridgeProvider: bridgeProvider,
                getActionBarNode: getActionBarNode,
                completion: completion,
                willDismiss: willDismiss,
                didDismiss: didDismiss,
                errorCallback: errorCallback
            )
        }
    }
}

public class WebAppLaunchWithParentParameters : WebAppLaunchParameters {
    let parentVC: UIViewController
    let source: Source = .menu
    let botId: String?
    let botName: String?
    let miniAppId: String?
    let miniAppName: String?
    let startParams: String?
    let params: [String:String]?
    let isLocalSource: Bool
    let isSystem: Bool
    let isLaunchUrl: Bool
    let url: String?
    let useWeChatStyle: Bool
    let useCache: Bool
    let autoExpand: Bool
    let peer: PeerParams?
    let bridgeProvider: BridgeProvider?
    let getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?
    let getInputContainerNode: () -> (CGFloat, UIView?)?
    let completion: (IMiniApp) -> Void
    let willDismiss: () -> Void
    let didDismiss: () -> Void
    let errorCallback: (Int,String?) -> Void
    
    private init(
        parentVC: UIViewController,
        botId: String?,
        botName: String?,
        miniAppId: String?,
        miniAppName: String?,
        startParams: String? = nil,
        params: [String:String]? = nil,
        url: String? = nil,
        isLaunchUrl: Bool = false,
        useWeChatStyle: Bool = true,
        isLocalSource: Bool = false,
        isSystem: Bool = false,
        useCache: Bool = true,
        autoExpand: Bool = false,
        peer: PeerParams? = nil,
        bridgeProvider: BridgeProvider?,
        getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil},
        getInputContainerNode: @escaping () -> (CGFloat, UIView?)? = { return nil },
        completion: @escaping (IMiniApp) -> Void = { _ in },
        willDismiss: @escaping () -> Void = {},
        didDismiss: @escaping () -> Void = {},
        errorCallback: @escaping (Int,String?) -> Void = {_,_ in}
    ) {
        self.parentVC = parentVC
        self.botId = botId
        self.botName = botName
        self.miniAppId = miniAppId
        self.miniAppName = miniAppName
        self.startParams = startParams
        self.params = params
        self.url = url
        self.isLaunchUrl = isLaunchUrl
        self.useWeChatStyle = useWeChatStyle
        self.isLocalSource = isLocalSource
        self.isSystem = isSystem
        self.useCache = useCache
        self.autoExpand = autoExpand
        self.peer = peer
        
        self.bridgeProvider = bridgeProvider
        
        self.getInputContainerNode = getInputContainerNode
        self.getActionBarNode = getActionBarNode
        self.completion = completion
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.errorCallback = errorCallback
        
        super.init()
    }
    
    override func isDev() -> Bool {
        return isLocalSource
    }
    
    public class Builder : BaseBuilder<WebAppLaunchWithParentParameters> {
        
        
        public override func build() throws -> WebAppLaunchWithParentParameters {
            
            try require()
            
            return WebAppLaunchWithParentParameters(
                parentVC: parentVC!,
                botId: botId,
                botName: botName,
                miniAppId: miniAppId,
                miniAppName: miniAppName,
                startParams: startParams,
                params: params,
                url: url,
                useWeChatStyle: useWeChatStyle,
                isLocalSource: isLocalSource,
                isSystem: isSystem,
                useCache: useCache,
                autoExpand: autoExpand,
                peer: peer,
                bridgeProvider: bridgeProvider,
                getActionBarNode: getActionBarNode,
                getInputContainerNode: getInputContainerNode,
                completion: completion,
                willDismiss: willDismiss,
                didDismiss: didDismiss,
                errorCallback: errorCallback
            )
        }
    }
}

internal enum Source {
    case generic
    case menu
    case attachMenu
    case inline
    case simple
    case settings
    
    var isSimple: Bool {
        if [.simple, .inline, .settings].contains(self) {
            return true
        } else {
            return false
        }
    }
}

internal struct WebAppParameters {
    let source: Source
    let miniAppDto: MiniAppDto?
    let dAppDto: DAppDto?
    let botId: String?
    var botName: String?
    var miniAppId: String?
    var miniAppName: String?
    let startParams: String?
    let params: [String:String]?
    let isLocalSource: Bool
    let isSystem: Bool
    var useModalStyle: Bool?
    var useCustomNavigation: Bool
    let url: String?
    let useWeChatStyle: Bool
    let useCache: Bool
    var autoExpand: Bool
    let isDApp: Bool
    let peer: PeerParams?
    
    let bridgeProvider: BridgeProvider?
    let getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?
    var errorCallback: (Int,String?) -> Void = {_,_ in}
    
    private init(
        source: Source,
        miniAppDto: MiniAppDto?,
        dAppDto: DAppDto?,
        botId: String?,
        botName: String?,
        miniAppId: String?,
        miniAppName: String?,
        startParams: String? = nil,
        params: [String:String]? = nil,
        url: String? = nil,
        useWeChatStyle: Bool = true,
        isLocalSource: Bool = false,
        isSystem: Bool = false,
        useModalStyle: Bool? = nil,
        useCustomNavigation: Bool = false,
        useCache: Bool = true,
        autoExpand: Bool = false,
        isDApp: Bool = false,
        peer: PeerParams? = nil,
        bridgeProvider: BridgeProvider? = nil,
        getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil},
        errorCallback: @escaping (Int,String?) -> Void = {_,_ in}
        
    ) {
        self.source = source
        self.miniAppDto = miniAppDto
        self.dAppDto = dAppDto
        self.botId = botId
        self.botName = botName
        self.miniAppId = miniAppId
        self.miniAppName = miniAppName
        self.startParams = startParams
        self.params = params
        self.url = url
        self.useWeChatStyle = useWeChatStyle
        self.isLocalSource = isLocalSource
        self.isSystem = isSystem
        self.useModalStyle = useModalStyle
        self.useCustomNavigation = useCustomNavigation
        self.useCache = useCache
        self.autoExpand = autoExpand
        self.isDApp = isDApp
        self.peer = peer
        self.bridgeProvider = bridgeProvider
        self.getActionBarNode = getActionBarNode
        self.errorCallback = errorCallback
    }
    
    public func buildCacheKey() -> String? {
        if self.isDApp {
            return self.url
        }
        
        if self.miniAppId != nil && ((self.miniAppId?.isEmpty) != nil) {
            return "__app_\(String(describing: self.miniAppId))"
        }
        if  (self.botId == nil || true==self.botId?.isEmpty)
                && (self.botName == nil || true == self.botName?.isEmpty) {
            return nil
        }
        
        if self.miniAppName == nil || true == self.miniAppName?.isEmpty {
            return nil
        }
        
        return "__\(String(describing: self.botId))_\(String(describing: self.botName))_\(String(describing: self.miniAppName))"
    }
    
    public func toCacheKey() -> String? {
        return buildCacheKey()
    }
    
    public class Builder {
        private var source: Source = .generic
        private var miniAppDto: MiniAppDto? = nil
        private var dAppDto: DAppDto? = nil
        private var botId: String? = nil
        private var botName: String? = nil
        private var miniAppId: String? = nil
        private var miniAppName: String? = nil
        private var startParams: String? = nil
        private var params: [String:String]? = nil
        
        private var url: String? = nil
        private var useWeChatStyle: Bool = true
        private var isLocalSource: Bool = false
        private var isSystem: Bool = false
        private var useModalStyle: Bool? = nil
        private var useCustomNavigation: Bool = false
        private var useCache: Bool = true
        private var autoExpand: Bool = false
        private var isDApp: Bool = false
        private var peer: PeerParams? = nil
        private var bridgeProvider: BridgeProvider? = nil
        private var getActionBarNode: (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil}
        var errorCallback: (Int,String?) -> Void = {_,_ in}
        
        public init() {}
        
        public func source(_ source: Source) -> Builder {
            self.source = source
            return self
        }
        
        public func miniAppDto(_ miniAppDto: MiniAppDto?) -> Builder {
            self.miniAppDto = miniAppDto
            if let app = miniAppDto {
                self.botId = app.botId
                self.botName = app.botName
                self.miniAppId = app.id
                self.miniAppName = app.identifier
            }
            return self
        }
        
        public func dAppDto(_ dAppDto: DAppDto?) -> Builder {
            self.dAppDto = dAppDto
            return self
        }
        
        public func botId(_ botId: String?) -> Builder {
            self.botId = botId
            return self
        }
        
        public func botName(_ botName: String?) -> Builder {
            self.botName = botName
            return self
        }
        
        public func miniAppId(_ miniAppId: String?) -> Builder {
            self.miniAppId = miniAppId
            return self
        }
        
        public func miniAppName(_ miniAppName: String?) -> Builder {
            self.miniAppName = miniAppName
            return self
        }
        
        public func startParams(_ startParams: String?) -> Builder {
            self.startParams = startParams
            return self
        }
        
        public func params(_ params: [String:String]?) -> Builder {
            self.params = params
            return self
        }
        
        public func url(_ url: String?) -> Builder {
            self.url = url
            return self
        }
        
        public func useWeChatStyle(_ useWeChatStyle: Bool) -> Builder {
            self.useWeChatStyle = useWeChatStyle
            return self
        }
        
        public func isLocalSource(_ isLocalSource: Bool) -> Builder {
            self.isLocalSource = isLocalSource
            return self
        }
        
        public func isSystem(_ isSystem: Bool) -> Builder {
            self.isSystem = isSystem
            return self
        }
        
        public func useModalStyle(_ useModalStyle: Bool?) -> Builder {
            self.useModalStyle = useModalStyle
            return self
        }
        
        public func useCustomNavigation(_ useCustomNavigation: Bool) -> Builder {
            self.useCustomNavigation = useCustomNavigation
            return self
        }
        
        public func useCache(_ useCache: Bool) -> Builder {
            self.useCache = useCache
            return self
        }
        
        public func autoExpand(_ autoExpand: Bool) -> Builder {
            self.autoExpand = autoExpand
            return self
        }
        
        public func isDApp(_ isDApp: Bool) -> Builder {
            self.isDApp = isDApp
            return self
        }
        
        public func peer(_ peer: PeerParams?) -> Builder {
            self.peer = peer
            return self
        }
        
        public func bridgeProvider(_ bridgeProvider: BridgeProvider?) -> Builder {
            self.bridgeProvider = bridgeProvider
            return self
        }
        
        public func getActionBarNode(_ getActionBarNode: @escaping  (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)?) -> Builder {
            self.getActionBarNode = getActionBarNode
            return self
        }
        
        public func errorCallback(_ errorCallback: @escaping (Int,String?) -> Void) -> Builder {
            self.errorCallback = errorCallback
            return self
        }
        
        public func build() -> WebAppParameters {
            return WebAppParameters(
                source: source,
                miniAppDto: miniAppDto,
                dAppDto: dAppDto,
                botId: botId,
                botName: botName,
                miniAppId: miniAppId,
                miniAppName: miniAppName,
                startParams: startParams,
                params: params,
                url: url,
                useWeChatStyle: useWeChatStyle,
                isLocalSource: isLocalSource,
                isSystem: isSystem,
                useModalStyle: useModalStyle,
                useCustomNavigation: useCustomNavigation,
                useCache: useCache,
                autoExpand: autoExpand,
                isDApp: isDApp,
                peer: peer,
                bridgeProvider: bridgeProvider,
                getActionBarNode: getActionBarNode,
                errorCallback: errorCallback
            )
        }
    }
}

public protocol IMiniApp: AnyObject {
    func reloadPage() -> Void
    func requestDismiss(_ force: Bool) -> Bool
    func getVC() -> UIViewController?
    func getShareUrl() async -> String?
    func getShareInfo() async -> ShareDto?
    func isSystem() -> Bool
    func minimization() -> Void
    func maximize() -> Void
    func clickMenu(type: String) -> Void
    func capture() -> UIImage?
}

public protocol IAppDelegate {
    /**
     QR code provider that generates and returns a navigation controller.
     
     - Parameters:
     - content: QR code content.
     - completion: Callback closure after generating QR code, returns the Base64 encoded string of the generated QR code image.
     
     - Returns: Returns a navigation controller for displaying the generated QR code.
     */
    var qrcodeProvider: (IMiniApp, String?, @escaping (String?) -> Void) -> UINavigationController? { get }
    
    /**
     Custom method provider.
     
     - Parameters:
     - methodName: Method name.
     - params: Method parameters.
     - completion: Callback closure after method execution, returns execution result.
     */
    var customMethodProvider: (IMiniApp, String, String?, @escaping (String?) -> Void) -> Bool { get }
    
    /**
     Attachment action provider.
     
     - Parameters:
     - action: Action name.
     - params: Action parameters.
     */
    var attachActionProvider: (IMiniApp, String?, String) -> Void { get }
    
    
    /**
     Scheme provider.
     
     - Parameters:
     - action: Action name.
     - params: Action parameters.
     - Returns: Returns a boolean value, True: scheme is consumed, False: scheme is not consumed
     */
    var schemeProvider: (IMiniApp, String) async ->  Bool { get }
    
    /**
     Switch to new session within the app.
     
     - Parameters:
     - query: Query string.
     - types: Type list.
     
     - Returns: Returns a boolean value indicating whether successfully switched to new session.
     */
    func switchInlineQuery(app: IMiniApp, query: String, types: [String]) async -> Bool
    
    /**
     Share link or text.
     
     - Parameters:
     - linkOrText: Link or text to share.
     */
    func shareLinkOrText(linkOrText: String)
    
    /**
     Check if current session supports and is authorized for sending message functionality.
     
     - Returns: Returns a boolean value indicating whether current session supports and is authorized for sending message functionality.
     */
    func checkPeerMessageAccess(app: IMiniApp) async -> Bool
    
    /**
     Request authorization for sending message functionality from current session.
     
     - Returns: Returns a boolean value indicating whether successfully requested authorization for sending message functionality.
     */
    func requestPeerMessageAccess(app: IMiniApp) async -> Bool
    
    /**
     Send message to current session.
     
     - Parameters:
     - content: Message content.
     
     - Returns: Returns a boolean value indicating whether successfully sent message.
     */
    func sendMessageToPeer(app: IMiniApp, content: String?) -> Bool
    
    /**
     Request to send phone number to current session.
     
     - Returns: Returns a boolean value indicating whether successfully requested to send phone number to current session.
     */
    func requestPhoneNumberToPeer(app: IMiniApp) async -> Bool
    
    /**
     Whether biometric authentication is supported
     
     - Returns: Bool.
     */
    func canUseBiometryAuth(app: IMiniApp) -> Bool
    
    /**
     Request to update biometric authentication Token.
     
     - Parameters:
     - token: Biometric authentication Token to update.
     - reason: Reason for requesting update.
     
     - Returns: Returns a boolean value and string tuple, indicating whether update is successful and the updated Token value. Boolean value true means update successful, string is the updated Token value; boolean value false means update failed, string is nil.
     */
    func updateBiometryToken(app: IMiniApp, token: String?, reason: String?) async -> (Bool, String?)
    
    /**
     Open biometric authentication settings interface.
     */
    func openBiometrySettings(app: IMiniApp) async -> Void
    
    /**
     Share Mini App.
     
     - Parameters:
     - code: Error code.
     - message: Error message.
     */
    func onApiError(error: ApiError) -> Void
    
    /**
     Window minimization
     
     - Parameters:
     - app: Current MiniApp instance
     
     */
    func onMinimization(app: IMiniApp) -> Void
    
    /**
     Window maximization
     
     - Parameters:
     - app: Current MiniApp instance
     
     */
    func onMaximize(app: IMiniApp) -> Void
    
    /**
     Menu button clicked
     
     - Parameters:
     - app: Current MiniApp instance
     - menus: Menu type list that application layer needs to display
     types: []
     
     - Returns: true means application layer has handled the click event, false means use SDK's popup menu
     */
    func onMoreButtonClick(app: IMiniApp, menus: [String]) -> Bool
    
    
    /**
     Menu button clicked
     
     - Parameters:
     - app: Current MiniApp instance
     - type: Menu type.
     */
    func onClickMenu(app: IMiniApp, type: String) -> Void
}

internal func generateWebAppThemeParams(resourceProvider: IResourceProvider) -> [String: String] {
    let themeKeys =  [
        "bg_color",
        "secondary_bg_color",
        "text_color",
        "hint_color",
        "link_color",
        "button_color",
        "button_text_color",
        "header_bg_color",
        "accent_text_color",
        "section_bg_color",
        "section_header_text_color",
        "subtitle_text_color",
        "destructive_text_color",
        "section_separator_color"
    ]
    
    return themeKeys.reduce(into: [String: String]()) { (result, key) in
        result[key] = resourceProvider.getColor(key: key).toHexString()
    }
}

public struct ShareDto {
    public let type: String
    public let id: String?
    public let identifier: String?
    public let title: String?
    public let url: String?
    public let description: String?
    public let iconUrl: String?
    public let bannerUrl: String?
    public let params: String?
}


public class AppConfig {
    let appName: String
    let webAppName: String
    let mePath: [String]
    let window: UIWindow
    let languageCode: String
    let userInterfaceStyle: UIUserInterfaceStyle
    let maxCachePage: Int
    let appDelegate: IAppDelegate
    let resourceProvider: IResourceProvider?
    let bridgeProviderFactory : BridgeProviderFactory?
    let floatWindowWidth: CGFloat
    let floatWindowHeight: CGFloat
    let privacyUrl: String?
    let termsOfServiceUrl: String?
    
    private init(builder: Builder) {
        self.appName = builder.appName
        self.webAppName = builder.webAppName
        self.mePath = builder.mePath
        self.window = builder.window
        self.languageCode = builder.languageCode
        self.userInterfaceStyle = builder.userInterfaceStyle
        self.maxCachePage = builder.maxCachePage
        self.appDelegate = builder.appDelegate
        self.resourceProvider = builder.resourceProvider
        self.bridgeProviderFactory = builder.bridgeProviderFactory
        self.floatWindowWidth = builder.floatWindowWidth
        self.floatWindowHeight = builder.floatWindowHeight
        self.privacyUrl = builder.privacyUrl
        self.termsOfServiceUrl = builder.termsOfServiceUrl
    }
    
    public class Builder {
        var appName: String
        var webAppName: String
        var mePath: [String]
        var window: UIWindow
        var languageCode: String = "en"
        var userInterfaceStyle: UIUserInterfaceStyle = .light
        var maxCachePage: Int = 5
        var appDelegate: IAppDelegate
        var resourceProvider: IResourceProvider? = nil
        var bridgeProviderFactory : BridgeProviderFactory? = nil
        var floatWindowWidth: CGFloat = 86.0
        var floatWindowHeight: CGFloat = 128.0
        var privacyUrl: String? = nil
        var termsOfServiceUrl: String? = nil
        
        public init(appName: String, webAppName: String, mePath: [String], window: UIWindow, appDelegate: IAppDelegate) {
            self.appName = appName
            self.webAppName = webAppName
            self.mePath = mePath
            self.window = window
            self.appDelegate = appDelegate
        }
        
        public func languageCode(_ languageCode: String) -> Builder {
            self.languageCode = languageCode
            return self
        }
        
        public func userInterfaceStyle(_ userInterfaceStyle: UIUserInterfaceStyle) -> Builder {
            self.userInterfaceStyle = userInterfaceStyle
            return self
        }
        
        public func maxCachePage(_ maxCachePage: Int) -> Builder {
            self.maxCachePage = maxCachePage
            return self
        }
        
        public func resourceProvider(_ resourceProvider: IResourceProvider?) -> Builder {
            self.resourceProvider = resourceProvider
            return self
        }
        
        public func bridgeProviderFactory(_ bridgeProviderFactory: BridgeProviderFactory?) -> Builder {
            self.bridgeProviderFactory = bridgeProviderFactory
            return self
        }
        
        public func floatWindowSize(width: CGFloat, height: CGFloat) -> Builder {
            self.floatWindowWidth = width
            self.floatWindowHeight = height
            return self
        }
        
        public func privacyUrl(_ privacyUrl: String?) -> Builder {
            self.privacyUrl = privacyUrl
            return self
        }
        
        public func termsOfServiceUrl(_ termsOfServiceUrl: String?) -> Builder {
            self.termsOfServiceUrl = termsOfServiceUrl
            return self
        }
        
        public func build() -> AppConfig {
            return AppConfig(builder: self)
        }
    }
}

open class MiniAppService : NSObject {
    
    open func load() -> Bool {
        return false
    }
    
    open func unload() {
        
    }
    
    open func batchGetMiniApps(appIds: [String]) async -> Result<MiniAppResponse, ApiError> {
        return .failure(.invalidResponse)
    }
    
    open func getMiniAppInfoById(appId: String) async -> Result<MiniAppDto,ApiError>  {
        return .failure(.invalidResponse)
    }
    
    open func getMiniAppInfoByNames(botIdOrName: String, appName: String) async -> Result<MiniAppDto,ApiError>  {
        return .failure(.invalidResponse)
    }
    
    open func getDAppInfoById(dappId: String) async -> Result<DAppDto,ApiError>  {
        return .failure(.invalidResponse)
    }
    
    open func setup(config: AppConfig, complete: @escaping () -> Void) -> Void {}
    
    open func updateTheme(userInterfaceStyle: UIUserInterfaceStyle) {}
    
    open func updateLanguage(languageCode: String) {}
    
    open func preload(config: WebAppLaunchParameters) {}
    
    open func launch(config: WebAppLaunchParameters) -> IMiniApp? { return nil }
    
    open func setupInTestDelegate(appDelegate: IAppDelegate) {}
    
    open func clearCache() {
    }
    
    open func dismissAll() {
        
    }
}

internal final class MiniAppServiceImpl : MiniAppService {
    
    static public let instance: MiniAppServiceImpl = MiniAppServiceImpl()
    
    private let sharedQueue = Queue()
    
    private var MINIAPP: String = "MINIAPP"
    private var WEBPAGE: String = "WEBPAGE"
    
    private var uiWindow: UIWindow? = nil
    
    private var isSetupOK = false
    
    private var _webAppName = "MiniAppX"
    public var webAppName: String {
        get {
            return _webAppName
        }
    }
    
    private var _appConfig: AppConfig? = nil
    public var appConfig: AppConfig? {
        get {
            return _appConfig
        }
    }
    
    private var _resourceProvider: IResourceProvider!
    public var resourceProvider: IResourceProvider {
        get {
            return _resourceProvider
        }
    }
    
    private var _appDelegate: IAppDelegate!
    public var appDelegate: IAppDelegate {
        get {
            return _appDelegate
        }
    }
    
    private var _context: AccountContext? = nil
    public func getContext() -> AccountContext? {
        return _context
    }
    
    private var _navigationController: UINavigationController?
    public func getNavigationController() -> UINavigationController? {
        return _navigationController
    }
    
    private var _openMiniApps: [IMiniApp] = []
    
    override public func load() -> Bool {
        return true
    }
    
    override public func unload() {
        WebAppLruCache.removeAll()
    }
    
    override public func clearCache() {
        WebAppLruCache.removeAll()
    }
    
    override public func dismissAll() {
        FloatingWindowManager.shared.dismissFloatingWindow(force: true)
        for miniApp in _openMiniApps {
            let _ = miniApp.requestDismiss(true)
        }
        _openMiniApps.removeAll()
    }
    
    public func inserMiniApp(_ miniApp: IMiniApp) {
        _openMiniApps.append(miniApp)
    }
    
    public func removeMiniApp(_ miniApp: IMiniApp) {
        _openMiniApps.removeAll { existingMiniApp in
            return existingMiniApp === miniApp
        }
    }
    
    private func getTopMiniApp() -> IMiniApp? {
        return _openMiniApps.last
    }
    
    override public func batchGetMiniApps(appIds: [String]) async -> Result<MiniAppResponse,ApiError> {
        return await OpenServiceRepository.shared.batchGetMiniApp(appIds: appIds)
    }
    
    override func getMiniAppInfoById(appId: String) async -> Result<MiniAppDto,ApiError> {
        return await OpenServiceRepository.shared.getMiniAppInfo(id: appId)
    }
    
    override func getMiniAppInfoByNames(botIdOrName: String, appName: String) async -> Result<MiniAppDto,ApiError> {
        return await OpenServiceRepository.shared.getMiniAppInfo(botIdOrName: botIdOrName, appName: appName)
    }
    
    override func getDAppInfoById(dappId: String) async -> Result<DAppDto,ApiError> {
        return await OpenServiceRepository.shared.getDAppInfo(id: dappId)
    }
    
    
    private func swizzleClassMethod(cls: AnyClass, origSelector: Selector, newSelector: Selector) {
        guard let origMethod = class_getClassMethod(cls, origSelector),
              let newMethod = class_getClassMethod(cls, newSelector),
              let cls = object_getClass(cls)
        else {
            return
        }
        
        if class_addMethod(cls, origSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
            class_replaceMethod(cls, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod))
        }
        else {
            method_exchangeImplementations(origMethod, newMethod)
        }
    }
    
    override public func setup(config: AppConfig, complete: @escaping () -> Void) {
        
        self._appConfig = config
        self.uiWindow = config.window
        self._appDelegate = config.appDelegate
        self._webAppName = config.webAppName
        
        WebAppLruCache.resize(size: config.maxCachePage)
        
        if let resourceProvider = config.resourceProvider {
            self._resourceProvider = config.resourceProvider
            self._context = SharedAccountContextImpl(appName: config.appName,
                                                     mePath: config.mePath,
                                                     mainWindow: nil,
                                                     resourceProvider: resourceProvider)
            self.isSetupOK = true
            
            complete()
        } else {
            let _ = (makeDefaultResourceProvider(window: config.window,
                                                 userInterfaceStype: config.userInterfaceStyle,
                                                 languageCode: config.languageCode)
                     |> deliverOnMainQueue)
                .start(next: { provider in
                    self._resourceProvider =  provider
                    self._context = SharedAccountContextImpl(appName: config.appName,
                                                             mePath: config.mePath,
                                                             mainWindow: nil,
                                                             resourceProvider: provider)
                    self.isSetupOK = true
                    
                    complete()
                })
        }
    }
    
    override public func preload(config: WebAppLaunchParameters) {
        if !self.isSetupOK {
            self.appDelegate.onApiError(error: .waitForSetup)
            return
        }
        
        guard let config = config as? WebAppPreloadParameters else {
            self.appDelegate.onApiError(error: .invalidData)
            return
        }
        
        let webConfig = WebAppParameters.Builder()
            .miniAppId(config.miniAppId)
            .botId(config.botId)
            .miniAppName(config.miniAppName)
            .botName(config.botName)
            .peer(config.peer)
            .startParams(config.startParams)
            .bridgeProvider(config.bridgeProvider ?? appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.miniAppId, type: self.MINIAPP, url: config.url))
            .build()
        
        guard let cacheKey = webConfig.toCacheKey() else {
            return
        }
        
        
        let process : (String) -> Void = { appId in
            Task {
                let result = await OpenServiceRepository.shared.getLaunchInfo(params: LaunchParams(url: nil, appId: appId, languageCode: DefaultResourceProvider.shared.getLanguageCode(), startParams: config.startParams, themeParams: generateWebAppThemeParams(resourceProvider: self.resourceProvider), peer: config.peer, platform: "IOS"))
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let launchInfo):
                        if let uri = URL(string: launchInfo.url) {
                            
                            let request = URLRequest(url: uri)
                            
                            let cacheData =  "\(webConfig.startParams ?? "")_\(DefaultResourceProvider.shared.getLanguageCode())_\(DefaultResourceProvider.shared.isDark())"
                            
                            if let webView = WebAppLruCache.get(key: cacheKey), webView.isExpired {
                                webView.handleDismiss?()
                                WebAppLruCache.remove(key: cacheKey)
                            }

                            if let webView = WebAppLruCache.get(key: cacheKey), cacheData == webView.cacheData {
                                if webView.isDismiss && !webView.isPageLoaded {
                                    webView.reload()
                                }
                            } else {
                                let webView = WebAppWebView(accountId: "0", webAppName: self.webAppName)
                                webView.frame = UIScreen.main.bounds
                                webView.cacheData = cacheData
                                webView.uiDelegate = self
                                webView.navigationDelegate = self
                                WebAppLruCache.put(key: cacheKey, webView: webView)
                                webView.load(request)
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        if let appId = config.miniAppId {
            process(appId)
            return
        }
        
        if let botIdOrName = config.botId ?? config.botName, let appName = config.miniAppName {
            Task { [weak self] in
                guard let self = self else { return }
                
                let result = await self.getMiniAppInfoByNames(botIdOrName: botIdOrName, appName: appName)
                switch result {
                case .success(let app):
                    process(app.id)
                default:
                    return
                }
            }
        }
    }
    
    override public func launch(config: WebAppLaunchParameters)  -> IMiniApp? {
        return _launch(config: config)
    }
    
    
    private func _launch(config: WebAppLaunchParameters)  -> IMiniApp? {
        
        if !self.isSetupOK {
            self.appDelegate.onApiError(error: .waitForSetup)
            return nil
        }
        
        if let config = config as? WebAppLaunchWithDialogParameters {
            
            if let url = config.url {
                return launchWithUrl(parentViewController: config.parentVC,
                                     url: url,
                                     isLaunchLink: config.isLaunchUrl,
                                     useModalStyle: config.useModalStyle,
                                     peer: config.peer,
                                     startParams: config.startParams,
                                     params: config.params,
                                     bridgeProvider: config.bridgeProvider ?? self.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.miniAppId, type: self.MINIAPP, url: url),
                                     getActionBarNode: config.getActionBarNode,
                                     completion: config.completion,
                                     willDismiss: config.willDismiss,
                                     didDismiss: config.didDismiss,
                                     errorCallback: config.errorCallback)
                
            } else {
                let webParams = WebAppParameters.Builder()
                    .botId(config.botId)
                    .botName(config.botName)
                    .miniAppId(config.miniAppId)
                    .miniAppName(config.miniAppName)
                    .useModalStyle(config.useModalStyle)
                    .useCustomNavigation(config.useCustomNavigation)
                    .isLocalSource(config.isLocalSource)
                    .isSystem(config.isSystem)
                    .autoExpand(config.autoExpand)
                    .source(config.source)
                    .useCache(config.useCache)
                    .useWeChatStyle(config.useWeChatStyle)
                    .getActionBarNode(config.getActionBarNode)
                    .errorCallback(config.errorCallback)
                    .startParams(config.startParams)
                    .params(config.params)
                    .bridgeProvider(config.bridgeProvider ?? self.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.miniAppId, type: self.MINIAPP, url: config.url))
                    .peer(config.peer).build()
                
                return launchWithDialog(parentViewController: config.parentVC,
                                        config: webParams,
                                        completion: config.completion,
                                        willDismiss: config.willDismiss,
                                        didDismiss: config.didDismiss)
            }
            
        } else if let config = config as? WebAppLaunchWithParentParameters {
            
            if let url = config.url  {
                return launchWithUrl(parentViewController: config.parentVC,
                                     url: url,
                                     isLaunchLink: config.isLaunchUrl,
                                     autoExpand: config.autoExpand,
                                     peer: config.peer,
                                     startParams: config.startParams,
                                     params: config.params,
                                     bridgeProvider: config.bridgeProvider ?? self.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.miniAppId, type: self.MINIAPP, url: config.url),
                                     getActionBarNode: config.getActionBarNode,
                                     getInputContainerNode: config.getInputContainerNode,
                                     completion: config.completion,
                                     willDismiss: config.willDismiss,
                                     didDismiss: config.didDismiss,
                                     errorCallback: config.errorCallback)
                
            } else {
                let webParams = WebAppParameters.Builder()
                    .botId(config.botId)
                    .botName(config.botName)
                    .miniAppId(config.miniAppId)
                    .miniAppName(config.miniAppName)
                    .isLocalSource(config.isLocalSource)
                    .isSystem(config.isSystem)
                    .autoExpand(config.autoExpand)
                    .source(config.source)
                    .useCache(config.useCache)
                    .useWeChatStyle(config.useWeChatStyle)
                    .startParams(config.startParams)
                    .params(config.params)
                    .errorCallback(config.errorCallback)
                    .getActionBarNode(config.getActionBarNode)
                    .bridgeProvider(config.bridgeProvider ?? self.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.miniAppId, type: self.MINIAPP, url: config.url))
                    .peer(config.peer).build()
                
                return launchWithDialog(parentViewController: config.parentVC,
                                        config: webParams,
                                        getInputContainerNode: config.getInputContainerNode,
                                        completion: config.completion,
                                        willDismiss: config.willDismiss,
                                        didDismiss: config.didDismiss)
            }
            
        } else if let config = config as? DAppLaunchParameters {
            
            if let dappId = config.id {
                Task {
                    let result = await OpenServiceRepository.shared.getDAppInfo(id: dappId)
                    DispatchQueue.main.async { [weak self] in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        switch result {
                        case .success(let dapp):
                            let webParams = WebAppParameters.Builder()
                                .url(dapp.url)
                                .isDApp(true)
                                .autoExpand(true)
                                .dAppDto(dapp)
                                .errorCallback(config.errorCallback)
                                .getActionBarNode(config.getActionBarNode)
                                .bridgeProvider(config.bridgeProvider ?? weakSelf.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.id, type: weakSelf.WEBPAGE, url: config.url))
                                .build()
                            
                            let _ = weakSelf.launchWithDialog(parentViewController: config.parentVC,
                                                              config: webParams,
                                                              completion: config.completion,
                                                              willDismiss: config.willDismiss,
                                                              didDismiss: config.didDismiss)
                        case .failure(let error):
                            weakSelf.appDelegate.onApiError(error: error)
                            switch(error) {
                            case .requestFailed(let code, let message):
                                config.errorCallback(code, message)
                            default:
                                break
                            }
                            return
                        }
                    }
                }
                return nil
            }
            
            
            let webParams = WebAppParameters.Builder()
                .url(config.url)
                .isDApp(true)
                .autoExpand(true)
                .getActionBarNode(config.getActionBarNode)
                .errorCallback(config.errorCallback)
                .bridgeProvider(config.bridgeProvider ?? self.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: config.id, type: self.WEBPAGE, url: config.url))
                .build()
            
            return launchWithDialog(parentViewController: config.parentVC,
                                    config: webParams,
                                    completion: config.completion,
                                    willDismiss: config.willDismiss,
                                    didDismiss: config.didDismiss)
        }
        
        return nil
    }
    
    private func launchWithDialog(parentViewController: UIViewController,
                                  config: WebAppParameters,
                                  getInputContainerNode: @escaping () -> (CGFloat, UIView?)? = { return nil },
                                  completion: @escaping (IMiniApp) -> Void = { _ in },
                                  willDismiss: @escaping () -> Void = {},
                                  didDismiss: @escaping () -> Void = {})  -> IMiniApp? {
        
        guard self.isSetupOK else {
            return nil
        }
        
        
        if let (attachmentController, miniApp) = standaloneWebAppController(params:config,
                                                                            getInputContainerNode: getInputContainerNode,
                                                                            completion: completion,
                                                                            willDismiss: willDismiss,
                                                                            didDismiss: didDismiss) {
            present(parentViewController: parentViewController, viewController: attachmentController, isDialog: true)
            
            return miniApp
        }
        
        return nil
    }
    
    private func merge(_ d1: [String: String]?, _ d2: [String: String]?) -> [String: String] {
        return (d1 ?? [:]).merging(d2 ?? [:]) { (_, new) in new }
    }
    
    private func launchWithUrl(parentViewController: UIViewController,
                               url: String,
                               useWeChatStyle: Bool = true,
                               isLaunchLink: Bool = false,
                               useModalStyle: Bool? = nil,
                               isSystem: Bool = false,
                               autoExpand: Bool = false,
                               peer: PeerParams? = nil,
                               startParams: String? = nil,
                               params: [String:String]? = nil,
                               bridgeProvider: BridgeProvider? = nil,
                               getActionBarNode: @escaping (@escaping () -> Void, @escaping () -> Void) -> (CGSize,UIView)? = { _,_ in return nil},
                               getInputContainerNode: @escaping () -> (CGFloat, UIView?)? = { return nil },
                               completion: @escaping (IMiniApp) -> Void = { _ in },
                               willDismiss: @escaping () -> Void = {},
                               didDismiss: @escaping () -> Void = {},
                               errorCallback: @escaping (Int,String?) -> Void = {_,_ in}) -> IMiniApp?  {
        
        guard self.isSetupOK else {
            return nil
        }
        
        var resoleveUrl = url
        
        if let resolveUrl = resolveUrlImpl(url: resoleveUrl, basePaths: _context!.mePaths) {
            switch resolveUrl {
            case let .startAttach(name, payload, chooseValue):
                guard let app = parentViewController as? IMiniApp else {
                    return nil
                }
                if let chooseValue = chooseValue?.lowercased() {
                    let components = chooseValue.components(separatedBy: "+")
                    if components.contains("users") {
                        self._appDelegate.attachActionProvider(app, payload, "users")
                    }
                }
                
            case let .app(appId, querys, urlParams):
                
                Task {
                    let result = await OpenServiceRepository.shared.getMiniAppInfo(id: appId)
                    DispatchQueue.main.async { [weak self] in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        switch result {
                        case .success(let app):
                            
                            let params = WebAppParameters.Builder()
                                .source(.generic)
                                .miniAppDto(app)
                                .isSystem(isSystem)
                                .startParams(querys ?? startParams)
                                .params(weakSelf.merge(urlParams, params))
                                .useWeChatStyle(useWeChatStyle)
                                .peer(peer)
                                .bridgeProvider(bridgeProvider)
                                .getActionBarNode(getActionBarNode)
                                .errorCallback(errorCallback)
                                .build()
                            
                            var parentVC = parentViewController
                            if let app = parentViewController as? IMiniApp {
                                parentVC = app.getVC() ?? parentViewController
                            }
                            
                            if let (attachmentController, _) = weakSelf.standaloneWebAppController(params:params,
                                                                                                   getInputContainerNode: getInputContainerNode,
                                                                                                   completion: completion,
                                                                                                   willDismiss: willDismiss,
                                                                                                   didDismiss: didDismiss) {
                                weakSelf.present(parentViewController: parentVC, viewController: attachmentController, isDialog: true)
                                
                            }
                        case .failure(let error):
                            weakSelf.appDelegate.onApiError(error: error)
                            switch(error) {
                            case .requestFailed(let code, let message):
                                errorCallback(code, message)
                            default:
                                break
                            }
                            return
                        }
                    }
                }
                
            case let .peer(.name(botName), .appStart(miniAppName, statApp, urlParams)):
                
                Task { [weak self] in
                    let result = await OpenServiceRepository.shared.getMiniAppInfo(botIdOrName: botName, appName: miniAppName)
                    DispatchQueue.main.async {
                        guard let weakSelf = self else {
                            return
                        }
                        
                        switch result {
                        case .success(let app):
                            
                            let params = WebAppParameters.Builder()
                                .source(.generic)
                                .miniAppDto(app)
                                .isSystem(isSystem)
                                .startParams(statApp ?? startParams)
                                .params(weakSelf.merge(urlParams, params))
                                .useWeChatStyle(useWeChatStyle)
                                .peer(peer)
                                .bridgeProvider(bridgeProvider)
                                .getActionBarNode(getActionBarNode)
                                .errorCallback(errorCallback)
                                .build()
                            
                            var parentVC = parentViewController
                            if let app = parentViewController as? IMiniApp {
                                parentVC = app.getVC() ?? parentViewController
                            }
                            
                            
                            if let (attachmentController, _) = weakSelf.standaloneWebAppController(params:params,
                                                                                                   getInputContainerNode: getInputContainerNode,
                                                                                                   completion: completion,
                                                                                                   willDismiss: willDismiss,
                                                                                                   didDismiss: didDismiss) {
                                weakSelf.present(parentViewController: parentVC, viewController: attachmentController, isDialog: true)
                                
                            }
                        case .failure(let error):
                            weakSelf.appDelegate.onApiError(error: error)
                            switch(error) {
                            case .requestFailed(let code, let message):
                                errorCallback(code, message)
                            default:
                                break
                            }
                            return
                        }
                    }
                }
                
            case let .share(url, text, to):
                self.appDelegate.shareLinkOrText(linkOrText: url ?? text ?? "")
                return nil
                
            case let .dapp(appId, querys):
                Task {  [weak self] in
                    let result = await OpenServiceRepository.shared.getDAppInfo(id: appId)
                    DispatchQueue.main.async {
                        guard let weakSelf = self else {
                            return
                        }
                        
                        switch result {
                        case .success(let app):
                            
                            let params = WebAppParameters.Builder()
                                .source(.generic)
                                .dAppDto(app)
                                .isDApp(true)
                                .url(app.url)
                                .isSystem(isSystem)
                                .useWeChatStyle(useWeChatStyle)
                                .bridgeProvider(bridgeProvider)
                                .getActionBarNode(getActionBarNode)
                                .errorCallback(errorCallback)
                                .build()
                            
                            var parentVC = parentViewController
                            if let app = parentViewController as? IMiniApp {
                                parentVC = app.getVC() ?? parentViewController
                            }
                            
                            
                            if let (attachmentController, _) = weakSelf.standaloneWebAppController(params:params,
                                                                                                   getInputContainerNode: getInputContainerNode,
                                                                                                   completion: completion,
                                                                                                   willDismiss: willDismiss,
                                                                                                   didDismiss: didDismiss) {
                                weakSelf.present(parentViewController: parentVC, viewController: attachmentController, isDialog: true)
                                
                            }
                        case .failure(let error):
                            weakSelf.appDelegate.onApiError(error: error)
                            switch(error) {
                            case .requestFailed(let code, let message):
                                errorCallback(code, message)
                            default:
                                break
                            }
                            return
                        }
                    }
                }
                
            default:
                if isMeLink(resoleveUrl, baseMePaths: _context!.mePaths) {
                    return nil
                }
                
                
                let params = WebAppParameters.Builder()
                    .source(.generic)
                    .url(url)
                    .useWeChatStyle(useWeChatStyle)
                    .useModalStyle(useModalStyle)
                    .peer(peer)
                    .isDApp(!isLaunchLink)
                    .isSystem(isSystem)
                    .getActionBarNode(getActionBarNode)
                    .bridgeProvider(bridgeProvider)
                    .errorCallback(errorCallback)
                    .build()
                
                var parentVC = parentViewController
                if let app = parentViewController as? IMiniApp {
                    parentVC = app.getVC() ?? parentViewController
                }
                
                
                if let (attachmentController, miniApp) = standaloneWebAppController(params:params,
                                                                                    getInputContainerNode: getInputContainerNode,
                                                                                    completion: completion,
                                                                                    willDismiss: willDismiss,
                                                                                    didDismiss: didDismiss) {
                    present(parentViewController: parentVC, viewController: attachmentController, isDialog: true)
                    
                    return miniApp
                }
            }
        }
        
        return nil
    }
    
    func present(parentViewController: UIViewController, viewController: ViewController, isDialog: Bool) {
        
        
        if let window = parentViewController.view.window {
            
            let fullView = UIView()
            fullView.frame = CGRect(origin: CGPoint(), size: UIScreen.main.bounds.size)
            
            let hostView = WindowHostView(
                containerView: fullView,
                eventView: window,
                isRotating: {
                    return window.isRotating()
                },
                systemUserInterfaceStyle: .single(.light),
                currentInterfaceOrientation: {
                    return getCurrentViewInterfaceOrientation(view: window)
                },
                updateSupportedInterfaceOrientations: { _ in
                },
                updateDeferScreenEdgeGestures: { _ in
                },
                updatePrefersOnScreenNavigationHidden: { _ in
                }
            )
            
            let statusBarHost = ApplicationStatusBarHost()
            let mainWindow = Window1(hostView: hostView, statusBarHost: statusBarHost)
            
            let rootNavitationController = UINavigationController(rootViewController: viewController)
            
            if isDialog {
                rootNavitationController.modalPresentationStyle = .overCurrentContext
                rootNavitationController.modalTransitionStyle = .crossDissolve
            }
            
            parentViewController.present(rootNavitationController, animated: false, completion: {
                viewController.containerLayoutUpdated(mainWindow.getContainedLayoutForWindowLayout(), transition: .immediate)
            } )
        }
    }
    
    override public func updateTheme(userInterfaceStyle: UIUserInterfaceStyle) {
        DefaultResourceProvider.shared.setUserInterfaceStyle(userInterfaceStyle: userInterfaceStyle)
    }
    
    override public func updateLanguage(languageCode: String ) {
        Task {
            await DefaultResourceProvider.shared.setLanguage(languageCode: languageCode)
        }
    }

    public func openInDefaultBrowser(url: URL) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    public func openUrl(viewController: ViewController?,
                        url: String,
                        webLaunchParams: WebAppParameters?) {
        Task { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            var parentVC: UIViewController? = viewController
            
            if let app = viewController as? IMiniApp {
                parentVC = app.getVC()
                if await weakSelf.appDelegate.schemeProvider(app, url) {
                    return
                }
            }
            
            var parsedUrl = URL(string: url)
            if let parsed = parsedUrl {
                if parsed.scheme == nil || parsed.scheme!.isEmpty {
                    parsedUrl = URL(string: "https://\(url)")
                }
            }
            
            guard let deepLink = parsedUrl?.absoluteString else {
                return
            }
            
            if !isHttpScheme(deepLink) {
                await UIApplication.shared.open(parsedUrl!, options: [:], completionHandler: nil)
                return
            }
            
            if let vc = parentVC {
                DispatchQueue.main.async {
                    if let mePaths = weakSelf.getContext()?.mePaths {
                        if !isMeLink(url, baseMePaths: mePaths) {
                            do {
                                let dappConfig = try DAppLaunchParameters.Builder()
                                    .parentVC(vc)
                                    .url(deepLink)
                                    .bridgeProvider(weakSelf.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: nil, type: weakSelf.WEBPAGE, url: url))
                                    .build()
                                let _ = weakSelf.launch(config: dappConfig)
                            } catch {
                                print("An error occurred: \(error)")
                            }
                            return
                        }
                        
                        let _ = weakSelf.launchWithUrl(
                            parentViewController: viewController!,
                            url: url,
                            peer: webLaunchParams?.peer,
                            bridgeProvider: weakSelf.appConfig?.bridgeProviderFactory?.buildBridgeProvider(id: nil, type: weakSelf.MINIAPP, url: url),
                            getActionBarNode: webLaunchParams?.getActionBarNode ?? { _,_ in return nil},
                            errorCallback: webLaunchParams?.errorCallback ?? { _,_ in}
                        )
                    }
                }
            }
        }
    }
    
    func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No active window or rootViewController found")
            return nil
        }
        
        var topViewController = rootViewController
        while let presentedVC = topViewController.presentedViewController {
            topViewController = presentedVC
        }
        
        return topViewController
    }
    
    public func standaloneWebAppController(
        params: WebAppParameters,
        getInputContainerNode: @escaping () -> (CGFloat, UIView?)? = { return nil },
        completion: @escaping (IMiniApp) -> Void = {_ in },
        willDismiss: @escaping () -> Void = {},
        didDismiss: @escaping () -> Void = {} ) -> (ViewController, IMiniApp?)? {
            
            let context = _context!
            
            if let cacheKey = params.toCacheKey() {
                if let cacheWebView = WebAppLruCache.get(key: cacheKey) {

                    if cacheWebView.isExpired {
                        cacheWebView.handleDismiss?()
                        WebAppLruCache.remove(key: cacheKey)
                        return nil
                    }

                    if let topWebView = (getTopMiniApp() as? WebAppController)?.getWebView(), topWebView == cacheWebView {
                        if FloatingWindowManager.shared.currentApp() === getTopMiniApp() {
                            FloatingWindowManager.shared.maximize()
                            return nil
                        } else if (getTopMiniApp() as? WebAppController)?.getVC() != getTopViewController() {
                            cacheWebView.handleDismiss?()
                        }
                    } else {
                        cacheWebView.handleDismiss?()
                    }
                }
            }
            
            let attachmentController = AttachmentController(context: context,
                                                            buttons: [.standalone],
                                                            initialButton: .standalone,
                                                            fromMenu: params.source == .menu)
            
            attachmentController.getInputContainerNode = {
                if let (inputPanelHeight, inputPannelView) = getInputContainerNode() {
                    if let srcView = inputPannelView {
                        return (inputPanelHeight, ProxyUIViewNode(srcView: srcView), { return nil})
                    }
                    return (inputPanelHeight, nil, { return nil})
                }
                return nil
            }
            
            
            let webAppController = WebAppController(context: context,
                                                    params: params,
                                                    threadId: nil)
            
            attachmentController.requestController = {  _, f in
                f(webAppController, webAppController.mediaPickerContext)
                completion(webAppController)
            }
            
            attachmentController.willDismiss = willDismiss
            attachmentController.didDismiss = didDismiss
            attachmentController.getSourceRect = nil
            attachmentController.navigationPresentation = .flatModal
            
            return (attachmentController, webAppController)
        }
    
    private func isLaunchWebAppUrl(url: String) -> Bool {
        return true
    }
    
    private func makeDefaultResourceProvider(window: UIWindow,
                                             userInterfaceStype: UIUserInterfaceStyle,
                                             languageCode: String) -> Signal<IResourceProvider, NoError> {
        return Signal { subscriber in
            Task {
                await DefaultResourceProvider.shared.initResouce(userInterfaceStyle: userInterfaceStype, languageCode: languageCode)
                subscriber.putNext(DefaultResourceProvider.shared)
                subscriber.putCompletion()
            }
            return EmptyDisposable
        }
    }
}

extension MiniAppServiceImpl: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let webView = webView as? WebAppWebView {
            Queue.mainQueue().after(0.6, {
                let webViewHeight = UIScreen.main.bounds.size.height
                let data = "{height:\(webViewHeight), is_expanded:true, is_state_stable:true}"
                webView.sendEvent(name: "viewport_changed", data: data)
            })
        }
    }
    
            // This method determines whether to allow navigation requests
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // Here you can make judgments based on the response, such as deciding whether to continue loading based on status codes and other conditions
        print("Navigating to: \(navigationResponse.response.url?.absoluteString ?? "Unknown URL")")
        decisionHandler(.allow)
    }
    
            // This method determines whether to allow navigation actions for requests (e.g., clicking links)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Navigating to URL: \(navigationAction.request.url?.absoluteString ?? "Unknown URL")")
        
        // You can make conditional judgments based on the request URL to decide whether to allow access to that URL
        if let url = navigationAction.request.url, url.absoluteString.contains("somecondition") {
            // If certain conditions are met, you can block this request
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
            // This method is called when the webpage finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web page finished loading")
        // If it's a custom BaseWebView class, set the page loading state
        if let webView = webView as? BaseWebView {
            webView.isPageLoaded = true
        }
    }
    
            // Handle page loading failure
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load page with error: \(error.localizedDescription)")
        // You can do some error handling here, such as displaying error messages or retrying to load the page
    }
    
            // This method can be used to monitor loading progress, usually used when loading large files or pages that require user attention
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started loading page: \(webView.url?.absoluteString ?? "Unknown URL")")
    }
    
            // Handle security issues such as SSL errors here
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("Received server redirect: \(webView.url?.absoluteString ?? "Unknown URL")")
    }
}
