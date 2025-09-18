//
//  MenusBottomSheet.swift
//  MiniAppX
//
//  Created by w3bili on 2024/11/15.
//

import UIKit

enum OW3MenuType: String {
    case RELOAD
    case SETTINGS
    case FEEDBACK
    case SHARE
    case TERMS
    case PRIVACY
    case SHORTCUT
}

// Mock menu item data  
internal struct MenuItem {
    let type: OW3MenuType
    let title: String
    let icon: String
}

internal class MenusBottomSheetViewController: UIViewController {
    
    let buttonsPerRow = 4 // Maximum 4 buttons per row
    let spacing: CGFloat = 10  // Spacing between buttons
    let sideMargin: CGFloat = 10  // Left and right margins
    let topMargin: CGFloat = 35  // Top margin
    let buttonHeight: CGFloat = 120  // Height of each button
    
    var isDark = MiniAppServiceImpl.instance.resourceProvider.isDark()
    var menus: [MenuItem] = []
    
    // 初始化菜单点击事件的监听器
    private var itemClickListener: ((Int) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color, simulate bottom sheet style
        view.backgroundColor = UIColor(hexString: isDark ? "#1C1D22" : "#F2F3F5")
        view.layer.cornerRadius = 20
        
        // If system version supports UISheetPresentationController
        if #available(iOS 15.0, *) {
            if let sheetPresentationController = self.sheetPresentationController {
                // Set bottom sheet style and behavior
                if #available(iOS 16.0, *) {
                    let contentHeight = CGFloat((menus.count + buttonsPerRow - 1) / buttonsPerRow) * buttonHeight + CGFloat((menus.count + buttonsPerRow - 1) / buttonsPerRow) * spacing + topMargin
                    
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return contentHeight
                    }
                    sheetPresentationController.detents = [customDetent]
                } else {
                    sheetPresentationController.detents = [.medium()]
                }
                
                sheetPresentationController.prefersGrabberVisible = true // Show drag handle
                sheetPresentationController.preferredCornerRadius = 20 // Set corner radius
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Build menu buttons
        buildMenus()
    }
    
    private func getImage(named name: String) -> UIImage? {
        return UIKitResourceManager.image(named: name, false)
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func calLabelHeight(_ title: String, viewWidth: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: viewWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = title.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: UIFont.systemFont(ofSize: 12)], context: nil)
        
        return boundingBox.height
    }
    
    // Build menu buttons
    private func buildMenus() {
        let buttonContainer = self.view
        
        var buttonCount = 0 // Current row button count
        var rowIndex = 0 // Used to track row count, set row spacing
        
        let totalWidth = self.view.safeAreaLayoutGuide.layoutFrame.width
        
        let buttonWidth = (totalWidth - sideMargin * 2) / CGFloat(buttonsPerRow)
        
        var titleLabelHeight: CGFloat = 0
        for menu in menus {
            titleLabelHeight = max(titleLabelHeight, calLabelHeight(menu.title, viewWidth: buttonWidth))
        }
        
        // Dynamically generate buttons
        for (index, menu) in menus.enumerated() {
            if buttonCount == buttonsPerRow {
                rowIndex += 1 // Each time a new row is added, the row count increases
                buttonCount = 0 // Each time a new row is created, the button counter is reset to 0
            }
            
            let button = LLCustomButtons(labelHeight: titleLabelHeight)
            
            button.tag = index
            button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            button.frame = CGRect(x: CGFloat(buttonCount) * buttonWidth + sideMargin, y: CGFloat(rowIndex) * (buttonHeight + spacing) + topMargin, width: buttonWidth, height: buttonHeight)
            buttonContainer?.addSubview(button)
            
            button.setTitleColor(UIColor(hexString: isDark ? "#FFFFFF" : "#7D7D7D"))
            button.layout = .titleBottom
            button.setTitle(menu.title)
            button.setImage(resizeImage(getImage(named: menu.icon)!, to: CGSize(width: 34, height: 34)))
            button.setButtonStyle(UIColor(hexString: isDark ? "#27272F" : "#FFFFFF")!)
            
            button.hightlightBackColor = .gray.withAlphaComponent(0.2) //normal
            
            button.clipsToBounds = true
            button.layer.cornerRadius = 20
    
            buttonCount += 1
        }
    }
    
    // Button click event
    @objc private func buttonClicked(_ sender: UIButton) {
        // Trigger callback for click event
        dismiss(animated: true, completion: nil)
        print("Button clicked: \(sender.tag)")
        itemClickListener?(sender.tag)
    }
    
    // Set menu click event listener
    func setItemClickListener(_ listener: @escaping (Int) -> Void) {
        self.itemClickListener = listener
    }
}

internal class LLCustomButtons: UIControl {
        /// Layout type (effective when both title and image are present)
    internal enum Layout {
        /// Title on the left
        case titleLeft
        /// Title on the right
        case titleRight
        /// Title on the top
        case titleTop
        /// Title on the bottom
        case titleBottom
    }

    public var layout: Layout = .titleLeft {
        didSet { layoutIfNeeded() }
    }

    /// Title
    public lazy var titleLabel = LLCustomButtonLabel()

    /// Image
    public lazy var imageView = UIImageView()

    /// Horizontal spacing
    public var horizontalSpace: CGFloat = 4.0

    /// Vertical spacing
    public var verticalSpace: CGFloat = 4.0

    /// Highlighted background color
    public var hightlightBackColor: UIColor?

    /// Gradient highlighted color
    public var gradientHightlightBackColors: [CGColor?] = []
    
    /// Text color
    private var normalTextColor: UIColor = .black
    
    /// Button click highlighted text color
    public var hightlightTextColor: UIColor?

    /// Background color
    private var previousBackgroundColor: UIColor = .clear

    /// Gradient color array
    private var gradientColors: [CGColor?] = []

    /// Gradient layer
    private var gradientLayer: CAGradientLayer?

    /// Highlighted layer
    private var hightLigihtLayer: CAGradientLayer?

    /// Whether long press
    private var isTouched: Bool = false

    /// Each group of colors所在位置（范围0~1)
    private var colorLocations: [NSNumber] = [0.0, 1.0]

    /// Start position （default is top left corner of rectangle）
    private var startPoint = CGPoint(x: 0, y: 0)

    /// End position（default is top right corner of rectangle）
    private var endPoint = CGPoint(x: 1, y: 0)
    
    private var labelHeight: CGFloat? = nil

    convenience init(labelHeight: CGFloat?) {
        self.init(frame: CGRect.zero)
        backgroundColor = .clear
        self.labelHeight = labelHeight
        initViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func initViews() {
        addSubview(titleLabel)
        addSubview(imageView)
        titleLabel.isHidden = true
        imageView.isHidden = true
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        /// Whether the value is set by point syntax or method is processed here
        titleLabel.setTitleText = { [unowned self] in
            if titleLabel.text == nil || titleLabel.text == "" {
                titleLabel.isHidden = true
                return
            }
            titleLabel.isHidden = false
            layoutIfNeeded()
            setNeedsLayout()
        }
        
        titleLabel.setTitleColor = { [unowned self] in
            normalTextColor = titleLabel.textColor ?? .black
        }
    }

    public func setTitle(_ text: String?) {
        titleLabel.text = text
    }

    public func setTitleColor(_ color: UIColor?) {
        guard let color = color else { return }
        titleLabel.textColor = color
    }

    public func setImage(_ image: UIImage?) {
        guard let image = image else {
            imageView.isHidden = true
            return
        }
        imageView.isHidden = false
        imageView.image = image
        layoutIfNeeded()
        setNeedsLayout()
    }

    /// Gradient background setting
   public func gradientColor(colors: [CGColor?], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 0), colorLocations: [NSNumber] = [0, 1]) {
        guard let gradient = gradientLayer == nil ? CAGradientLayer() : gradientLayer else { return }
        gradient.locations = colorLocations
        gradient.colors = colors as [Any]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        gradientColors = colors
        self.colorLocations = colorLocations
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    /// Remove gradient layer
    public func removeGradientLayer() {
        gradientLayer?.removeFromSuperlayer()
        gradientHightlightBackColors.removeAll()
        gradientColors.removeAll()
    }
}

// MARK: - Control layout

extension LLCustomButtons {
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard frame.size.width > 0, frame.size.height > 0 else { return }
        // ======== Gradient layer part ============
        if let gradientLayer = gradientLayer {
            // Remove implicit animation
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            // Get the button corner radius value, the gradient layer也要设置
            gradientLayer.cornerRadius = layer.value(forKeyPath: "cornerRadius") as? CGFloat ?? 0
            // Set the gradient frame
            gradientLayer.frame = bounds
            
            CATransaction.commit()
        }

        // ======== Sub-control layout part ============
        let viewWidth = frame.size.width
        let viewHeight = frame.size.height
        let text = titleLabel.text
        let image = imageView.image
        if let text = text, let _ = image {
            
            var titleLabelSize: CGSize = CGSize.zero
            titleLabelSize = labelSize(text: text, maxSize: CGSize(width: viewWidth, height: viewHeight), font: titleLabel.font)

            updateViewSize(with: titleLabel, size: titleLabelSize)
            //updateViewSize(with: imageView, size: image.size)
            
            let horizontalSpaceImage = horizontalSpace + imageView.frame.size.width / 2.0
            let horizontalSpaceTitle = horizontalSpace + titleLabelSize.width / 2.0
            let verticalSpaceImage = verticalSpace + imageView.frame.size.height / 2.0
            let verticalSpaceTitle = verticalSpace +  (self.labelHeight ?? titleLabelSize.height) / 2.0

            switch layout {
            case .titleLeft:
                titleLabel.center = CGPoint(x: viewWidth / 2.0 - horizontalSpaceImage, y: viewHeight / 2.0)
                imageView.center = CGPoint(x: viewWidth / 2.0 + horizontalSpaceTitle, y: viewHeight / 2.0)
            case .titleRight:
                titleLabel.center = CGPoint(x: viewWidth / 2.0 + horizontalSpaceImage, y: viewHeight / 2.0)
                imageView.center = CGPoint(x: viewWidth / 2.0 - horizontalSpaceTitle, y: viewHeight / 2.0)
            case .titleTop:
                titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 - verticalSpaceImage)
                imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 + verticalSpaceTitle)
            case .titleBottom:
                titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 + verticalSpaceImage)
                imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 - verticalSpaceTitle)
            }
        } else if let text = text {
            let size = labelSize(text: text, maxSize: CGSize(width: viewWidth, height: viewHeight), font: titleLabel.font)
            updateViewSize(with: titleLabel, size: size)
            titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0)
        } else if let image = image {
            updateViewSize(with: imageView, size: image.size)
            imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0)
        }
    }

    /// Update control size
    func updateViewSize(with targetView: UIView, size: CGSize) {
        var rect = targetView.frame
        rect.size.width = size.width
        rect.size.height = size.height
        targetView.frame = rect
    }

    /// Calculate text size
    func labelSize(text: String?, maxSize: CGSize, font: UIFont) -> CGSize {
        guard let text = text else { return CGSize.zero }
        let constraintRect = CGSize(width: maxSize.width, height: maxSize.height)
        let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.size
    }
}

// MARK: - Button click effect

internal extension LLCustomButtons {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isEnabled || !self.point(inside: point, with: event) { return super.hitTest(point, with: event) }
        setHightLigihtLayer()
        guard let hightLigihtLayer = hightLigihtLayer else { return super.hitTest(point, with: event) }
        if !gradientHightlightBackColors.isEmpty, !gradientColors.isEmpty {
            hightLigihtLayer.colors = gradientHightlightBackColors as [Any]
        } else if let hightlightBackColor = hightlightBackColor {
            hightLigihtLayer.colors = [hightlightBackColor.cgColor, hightlightBackColor.cgColor] as [Any]
        }
        // Text highlighted color
        if hightlightTextColor != nil {
            titleLabel.isHightlightColor = true
            titleLabel.textColor = hightlightTextColor
            titleLabel.isHightlightColor = false
        }
        // Add highlighted background color layer
        layer.insertSublayer(hightLigihtLayer, below: titleLabel.layer)

        // Highlighted display for 0.2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isTouched {
                // Remove highlighted background layer
                hightLigihtLayer.removeFromSuperlayer()
                // If text highlighting is set, restore
                if self.hightlightTextColor != nil{
                    self.titleLabel.textColor = self.normalTextColor
                }
            }
        }
        return super.hitTest(point, with: event)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isTouched = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        hightLigihtLayer?.removeFromSuperlayer()
        titleLabel.textColor = normalTextColor
        isTouched = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hightLigihtLayer?.removeFromSuperlayer()
        titleLabel.textColor = normalTextColor
        isTouched = false
    }

    func setHightLigihtLayer() {
        guard let ligihtLayer = hightLigihtLayer == nil ? CAGradientLayer() : hightLigihtLayer else { return }
        ligihtLayer.locations = colorLocations
        ligihtLayer.startPoint = startPoint
        ligihtLayer.endPoint = endPoint
        ligihtLayer.frame = bounds
        ligihtLayer.cornerRadius = gradientLayer?.cornerRadius ?? 0
        hightLigihtLayer = ligihtLayer
    }
    
    func setButtonStyle(_ bgColor: UIColor) {
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        imageView.backgroundColor = bgColor
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: 58, height: 58)
    }
}

// MARK: - Custom button label
internal class LLCustomButtonLabel: UILabel {
    var setTitleText: (() -> Void)?
    var setTitleColor: (() -> Void)?    
    
    // Whether it is a highlighted color
    var isHightlightColor: Bool = false
     
   /// Ensure that any way of assigning values can do the corresponding processing
    public override var text: String? {
       didSet {
           setTitleText?()
       }
   }

    public override var attributedText: NSAttributedString? {
       didSet {
           text = attributedText?.string
       }
   }
    
    public override var textColor: UIColor?{
        didSet {
            // If it is a highlighted color, it will not trigger the callback
            guard !isHightlightColor else { return }
            setTitleColor?()
        }
    }
    
   convenience init() {
       self.init(frame: CGRect.zero)
   }

   override init(frame: CGRect) {
       super.init(frame: frame)
   }

   required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
