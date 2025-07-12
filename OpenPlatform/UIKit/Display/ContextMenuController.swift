import Foundation
import UIKit
import MiniAppUIKit

internal final class ContextMenuControllerPresentationArguments {
    public let sourceNodeAndRect: () -> (ASDisplayNode, CGRect, ASDisplayNode, CGRect)?
    public let bounce: Bool
    
    public init(sourceNodeAndRect: @escaping () -> (ASDisplayNode, CGRect, ASDisplayNode, CGRect)?, bounce: Bool = true) {
        self.sourceNodeAndRect = sourceNodeAndRect
        self.bounce = bounce
    }
}

internal protocol ContextMenuController: ViewController, StandalonePresentableController {
    var centerHorizontally: Bool { get set }
    var dismissed: (() -> Void)? { get set }
    var dismissOnTap: ((UIView, CGPoint) -> Bool)? { get set }
}

internal struct ContextMenuControllerArguments {
    public var actions: [ContextMenuAction]
    public var catchTapsOutside: Bool
    public var hasHapticFeedback: Bool
    public var blurred: Bool
    public var skipCoordnateConversion: Bool
    public var isDark: Bool
    
    public init(actions: [ContextMenuAction], catchTapsOutside: Bool, hasHapticFeedback: Bool, blurred: Bool, skipCoordnateConversion: Bool, isDark: Bool) {
        self.actions = actions
        self.catchTapsOutside = catchTapsOutside
        self.hasHapticFeedback = hasHapticFeedback
        self.blurred = blurred
        self.skipCoordnateConversion = skipCoordnateConversion
        self.isDark = isDark
    }
}

private var contextMenuControllerProvider: ((ContextMenuControllerArguments) -> ContextMenuController)?

internal func setContextMenuControllerProvider(_ f: @escaping (ContextMenuControllerArguments) -> ContextMenuController) {
    contextMenuControllerProvider = f
}

internal func makeContextMenuController(actions: [ContextMenuAction], catchTapsOutside: Bool = false, hasHapticFeedback: Bool = false, blurred: Bool = false, isDark: Bool = true, skipCoordnateConversion: Bool = false) -> ContextMenuController {
    guard let contextMenuControllerProvider = contextMenuControllerProvider else {
        preconditionFailure()
    }
    return contextMenuControllerProvider(ContextMenuControllerArguments(
        actions: actions,
        catchTapsOutside: catchTapsOutside,
        hasHapticFeedback: hasHapticFeedback,
        blurred: blurred,
        skipCoordnateConversion: skipCoordnateConversion,
        isDark: isDark
    ))
}
