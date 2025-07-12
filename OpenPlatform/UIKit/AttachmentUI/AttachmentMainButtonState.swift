import Foundation
import UIKit

internal struct AttachmentMainButtonState {
    internal enum Background {
        case color(UIColor)
        case premium
    }
    
    internal enum Progress: Equatable {
        case none
        case side
        case center
    }
    
    internal enum Font: Equatable {
        case regular
        case bold
    }
    
    public let text: String?
    public let font: Font
    public let background: Background
    public let textColor: UIColor
    public let isVisible: Bool
    public let progress: Progress
    public let isEnabled: Bool
    
    public init(
        text: String?,
        font: Font,
        background: Background,
        textColor: UIColor,
        isVisible: Bool,
        progress: Progress,
        isEnabled: Bool
    ) {
        self.text = text
        self.font = font
        self.background = background
        self.textColor = textColor
        self.isVisible = isVisible
        self.progress = progress
        self.isEnabled = isEnabled
    }
    
    public static var initial: AttachmentMainButtonState {
        return AttachmentMainButtonState(text: nil, font: .bold, background: .color(.clear), textColor: .clear, isVisible: false, progress: .none, isEnabled: false)
    }
}
