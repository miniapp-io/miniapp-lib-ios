import Foundation
import UIKit

internal struct ToolbarAction: Equatable {
    internal enum Color: Equatable {
        case accent
        case custom(UIColor)
    }

    public let title: String
    public let isEnabled: Bool
    public let color: Color
    
    public init(title: String, isEnabled: Bool, color: Color = .accent) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
    }
}

internal struct Toolbar: Equatable {
    public let leftAction: ToolbarAction?
    public let rightAction: ToolbarAction?
    public let middleAction: ToolbarAction?
    
    public init(leftAction: ToolbarAction?, rightAction: ToolbarAction?, middleAction: ToolbarAction?) {
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.middleAction = middleAction
    }
}
