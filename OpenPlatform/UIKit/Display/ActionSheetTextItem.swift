import Foundation
import UIKit

internal class ActionSheetTextItem: ActionSheetItem {
    internal enum Font {
        case `default`
        case large
    }
    
    public let title: String
    public let font: Font
    public let parseMarkdown: Bool
    
    public init(title: String, font: Font = .default, parseMarkdown: Bool = true) {
        self.title = title
        self.font = font
        self.parseMarkdown = parseMarkdown
    }
    
    public func node(theme: ActionSheetControllerTheme) -> ActionSheetItemNode {
        let node = ActionSheetTextNode(theme: theme)
        node.setItem(self)
        return node
    }
    
    public func updateNode(_ node: ActionSheetItemNode) {
        guard let node = node as? ActionSheetTextNode else {
            assertionFailure()
            return
        }
        
        node.setItem(self)
        node.requestLayoutUpdate()
    }
}

internal class ActionSheetTextNode: ActionSheetItemNode {
    private let theme: ActionSheetControllerTheme
    
    private var item: ActionSheetTextItem?
    
    private let label: ImmediateTextNode
    
    private let accessibilityArea: AccessibilityAreaNode
    
    override public init(theme: ActionSheetControllerTheme) {
        self.theme = theme
        
        self.label = ImmediateTextNode()
        self.label.isUserInteractionEnabled = false
        self.label.maximumNumberOfLines = 0
        self.label.displaysAsynchronously = false
        self.label.truncationType = .end
        self.label.isAccessibilityElement = false
        self.label.textAlignment = .center
        
        self.accessibilityArea = AccessibilityAreaNode()
        self.accessibilityArea.accessibilityTraits = .staticText
        
        super.init(theme: theme)
        
        self.label.isUserInteractionEnabled = false
        self.addSubnode(self.label)
        
        self.addSubnode(self.accessibilityArea)
    }
    
    func setItem(_ item: ActionSheetTextItem) {
        self.item = item
        
        let fontSize: CGFloat
        switch item.font {
        case .default:
            fontSize = 13.0
        case .large:
            fontSize = 15.0
        }
        
        let defaultFont = Font.regular(floor(self.theme.baseFontSize * fontSize / 17.0))
        let boldFont = Font.semibold(floor(self.theme.baseFontSize * fontSize / 17.0))
        
        if item.parseMarkdown {
            let body = MarkdownAttributeSet(font: defaultFont, textColor: self.theme.secondaryTextColor)
            let bold = MarkdownAttributeSet(font: boldFont, textColor: self.theme.secondaryTextColor)
            let link = body
            
            self.label.attributedText = parseMarkdownIntoAttributedString(item.title, attributes: MarkdownAttributes(body: body, bold: bold, link: link, linkAttribute: { _ in
                return nil
            }))
        } else {
            self.label.attributedText = NSAttributedString(string: item.title, font: defaultFont, textColor: self.theme.secondaryTextColor, paragraphAlignment: .center)
        }
        
        self.accessibilityArea.accessibilityLabel = item.title
    }
    
    public override func updateLayout(constrainedSize: CGSize, transition: ContainedViewLayoutTransition) -> CGSize {
        let labelSize = self.label.updateLayout(CGSize(width: max(1.0, constrainedSize.width - 20.0), height: constrainedSize.height))
        let size = CGSize(width: constrainedSize.width, height: max(57.0, labelSize.height + 32.0))
       
        self.label.frame = CGRect(origin: CGPoint(x: floorToScreenPixels((size.width - labelSize.width) / 2.0), y: floorToScreenPixels((size.height - labelSize.height) / 2.0)), size: labelSize)
        
        self.accessibilityArea.frame = CGRect(origin: CGPoint(), size: size)
        
        self.updateInternalLayout(size, constrainedSize: constrainedSize)
        return size
    }
}
