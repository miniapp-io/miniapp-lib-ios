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

// 模拟菜单项数据
internal struct MenuItem {
    let type: OW3MenuType
    let title: String
    let icon: String
}

internal class MenusBottomSheetViewController: UIViewController {
    
    let buttonsPerRow = 4 // 每行最多显示4个按钮
    let spacing: CGFloat = 10  // 按钮之间的间隔
    let sideMargin: CGFloat = 10  // 左右边距
    let topMargin: CGFloat = 35  // 顶部边距
    let buttonHeight: CGFloat = 120  // 每个按钮的高度
    
    var isDark = MiniAppServiceImpl.instance.resourceProvider.isDark()
    var menus: [MenuItem] = []
    
    // 初始化菜单点击事件的监听器
    private var itemClickListener: ((Int) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景颜色，模拟底部弹窗的样式
        view.backgroundColor = UIColor(hexString: isDark ? "#1C1D22" : "#F2F3F5")
        view.layer.cornerRadius = 20
        
        // 如果系统版本支持 UISheetPresentationController
        if #available(iOS 15.0, *) {
            if let sheetPresentationController = self.sheetPresentationController {
                // 设置底部弹窗的样式和行为
                if #available(iOS 16.0, *) {
                    let contentHeight = CGFloat((menus.count + buttonsPerRow - 1) / buttonsPerRow) * buttonHeight + CGFloat((menus.count + buttonsPerRow - 1) / buttonsPerRow) * spacing + topMargin
                    
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return contentHeight
                    }
                    sheetPresentationController.detents = [customDetent]
                } else {
                    sheetPresentationController.detents = [.medium()]
                }
                
                sheetPresentationController.prefersGrabberVisible = true // 显示拖拽的把手
                sheetPresentationController.preferredCornerRadius = 20 // 设置圆角
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 构建菜单按钮
        buildMenus()
    }
    
    private func getImage(named name: String) -> UIImage? {
        let bundle = Bundle(for: ToolBarComponent.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
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
    
    // 构建菜单按钮
    private func buildMenus() {
        let buttonContainer = self.view
        
        var buttonCount = 0 // 当前行按钮数
        var rowIndex = 0 // 用于跟踪行数，设置行间距
        
        let totalWidth = self.view.safeAreaLayoutGuide.layoutFrame.width
        
        let buttonWidth = (totalWidth - sideMargin * 2) / CGFloat(buttonsPerRow)
        
        var titleLabelHeight: CGFloat = 0
        for menu in menus {
            titleLabelHeight = max(titleLabelHeight, calLabelHeight(menu.title, viewWidth: buttonWidth))
        }
        
        // 动态生成按钮
        for (index, menu) in menus.enumerated() {
            if buttonCount == buttonsPerRow {
                rowIndex += 1 // 每添加一行，行数增加
                buttonCount = 0 // 每次新建一行时，按钮计数器重置为 0
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
    
    // 按钮点击事件
    @objc private func buttonClicked(_ sender: UIButton) {
        // 触发点击事件的回调
        dismiss(animated: true, completion: nil)
        print("Button clicked: \(sender.tag)")
        itemClickListener?(sender.tag)
    }
    
    // 设置菜单点击事件的监听器
    func setItemClickListener(_ listener: @escaping (Int) -> Void) {
        self.itemClickListener = listener
    }
}

internal class LLCustomButtons: UIControl {
    /// 布局类型 (同时有标题和图片的时候生效)
    internal enum Layout {
        /// 标题在左
        case titleLeft
        /// 标题在右
        case titleRight
        /// 标题在上
        case titleTop
        /// 标题在下
        case titleBottom
    }

    public var layout: Layout = .titleLeft {
        didSet { layoutIfNeeded() }
    }

    /// 标题
    public lazy var titleLabel = LLCustomButtonLabel()

    /// 图片
    public lazy var imageView = UIImageView()

    /// 水平间距
    public var horizontalSpace: CGFloat = 4.0

    /// 竖直间距
    public var verticalSpace: CGFloat = 4.0

    /// 高亮背景色
    public var hightlightBackColor: UIColor?

    /// 渐变高亮色
    public var gradientHightlightBackColors: [CGColor?] = []
    
    /// 文本颜色
    private var normalTextColor: UIColor = .black
    
    /// 按钮点击高亮文本颜色
    public var hightlightTextColor: UIColor?

    /// 背景色
    private var previousBackgroundColor: UIColor = .clear

    /// 渐变色数组
    private var gradientColors: [CGColor?] = []

    /// 渐变色layer
    private var gradientLayer: CAGradientLayer?

    /// 高亮色layer
    private var hightLigihtLayer: CAGradientLayer?

    /// 是否长按
    private var isTouched: Bool = false

    /// 每组颜色所在位置（范围0~1)
    private var colorLocations: [NSNumber] = [0.0, 1.0]

    /// 开始位置 （默认是矩形左上角）
    private var startPoint = CGPoint(x: 0, y: 0)

    /// 结束位置（默认是矩形右上角）
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
        /// 不管是点语法设值还是方法设值都在这里处理
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

    /// 渐变色背景设置
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

    /// 移除渐变层
    public func removeGradientLayer() {
        gradientLayer?.removeFromSuperlayer()
        gradientHightlightBackColors.removeAll()
        gradientColors.removeAll()
    }
}

// MARK: - 控件布局

extension LLCustomButtons {
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard frame.size.width > 0, frame.size.height > 0 else { return }
        // ======== 渐变色层部分 ============
        if let gradientLayer = gradientLayer {
            // 去除隐式动画
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            // KVC取出Button圆角值，渐变层也要设置
            gradientLayer.cornerRadius = layer.value(forKeyPath: "cornerRadius") as? CGFloat ?? 0
            // 渐变色frame设置
            gradientLayer.frame = bounds
            
            CATransaction.commit()
        }

        // ======== 子控件布局部分 ============
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

    /// 更新控件大小
    func updateViewSize(with targetView: UIView, size: CGSize) {
        var rect = targetView.frame
        rect.size.width = size.width
        rect.size.height = size.height
        targetView.frame = rect
    }

    /// 计算文本大小
    func labelSize(text: String?, maxSize: CGSize, font: UIFont) -> CGSize {
        guard let text = text else { return CGSize.zero }
        let constraintRect = CGSize(width: maxSize.width, height: maxSize.height)
        let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.size
    }
}

// MARK: - 按钮点击效果

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
        // 文字高亮色
        if hightlightTextColor != nil {
            titleLabel.isHightlightColor = true
            titleLabel.textColor = hightlightTextColor
            titleLabel.isHightlightColor = false
        }
        // 添加高亮背景色layer
        layer.insertSublayer(hightLigihtLayer, below: titleLabel.layer)

        // 高亮展示0.2秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isTouched {
                // 移除高亮背景layer
                hightLigihtLayer.removeFromSuperlayer()
                // 如果有设置文本高亮 则恢复
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

// MARK: - 自定义按钮的lable
internal class LLCustomButtonLabel: UILabel {
    var setTitleText: (() -> Void)?
    var setTitleColor: (() -> Void)?
    
    // 是否是高亮色
    var isHightlightColor: Bool = false
     
   /// 保证任何方式赋值都能做相应处理
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
            // 如果是设置高亮色 则不触发回调
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
