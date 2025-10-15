//
//  ToolBarComponent.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/6/20.
//

import Foundation
import UIKit
import MiniAppUIKit

internal class ToolBarComponent : UIView {
    
    private let cornerRadius: CGFloat = 15.0
    private var isFullScreen: Bool = false
    
    private let shareButton = UIButton()
    private let closeButton = UIButton()
    private let minisizeButton = UIButton()
    private let verticalLine1 = CALayer()
    private let verticalLine2 = CALayer()
    
    public var dismiss: (() -> Void)? = nil
    public var share: (() -> Void)? = nil
    public var minisize: (() -> Void)? = nil
    
    private let btnHeight = 30.0
    private let btnMargin = 5.0
    
    public func setFullscreen(isFullScreen:Bool) {
        if self.isFullScreen == isFullScreen {
            return
        }
        self.isFullScreen = isFullScreen
        self.updateUI()
    }
    
    public init(frame: CGRect, isFullScreen: Bool) {
        super.init(frame: frame)
        self.isFullScreen = isFullScreen
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc func closePressed() {
        self.dismiss?()
    }
    
    @objc func minisizePressed() {
        self.minisize?()
    }
    
    @objc func sharePressed() {
        self.share?()
    }
    
    private func getImage(named name: String) -> UIImage? {
        return UIKitResourceManager.image(named: name)
    }
    
    private func setupUI() {
        
        let bgColor: UIColor
        if isFullScreen {
            bgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR, isDark: true)
        } else {
            bgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR)
        }
        
        let fgColor: UIColor
        if isFullScreen {
            fgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR, isDark: true)
        } else {
            fgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR)
        }
        
        backgroundColor = bgColor.withAlphaComponent(0.3)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 0.5
        layer.borderColor = fgColor.withAlphaComponent(0.2).cgColor
        layer.masksToBounds = true
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(getImage(named: "icon_share"), for: .normal)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        shareButton.tintColor = fgColor
        shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        
        minisizeButton.translatesAutoresizingMaskIntoConstraints = false
        minisizeButton.setImage(getImage(named: "icon_minimization"), for: .normal)
        minisizeButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        minisizeButton.tintColor = fgColor
        minisizeButton.addTarget(self, action: #selector(minisizePressed), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(getImage(named: "icon_close"), for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        closeButton.tintColor = fgColor
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        
        verticalLine1.backgroundColor = fgColor.withAlphaComponent(0.2).cgColor
        layer.addSublayer(verticalLine1)
        
        verticalLine2.backgroundColor = fgColor.withAlphaComponent(0.2).cgColor
        layer.addSublayer(verticalLine2)
        
        let stackView = UIStackView(arrangedSubviews: [shareButton, minisizeButton, closeButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing // Ensure equal spacing between each view
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: btnMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -btnMargin),
            shareButton.widthAnchor.constraint(equalToConstant: btnHeight),
            shareButton.heightAnchor.constraint(equalToConstant: btnHeight),
            minisizeButton.widthAnchor.constraint(equalToConstant: btnHeight),
            minisizeButton.heightAnchor.constraint(equalToConstant: btnHeight),
            closeButton.widthAnchor.constraint(equalToConstant: btnHeight),
            closeButton.heightAnchor.constraint(equalToConstant: btnHeight)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position the vertical line
        let lineX = bounds.width / 3 - 0.5 // Adjust the position as needed
        verticalLine1.frame = CGRect(x: lineX, y: btnMargin, width: 0.5, height: bounds.height - 12) // Adjust the height and position as needed
        verticalLine2.frame = CGRect(x: lineX * 2 - 0.5, y: btnMargin, width: 0.5, height: bounds.height - 12) // Adjust the height and position as needed
    }
    
    private func updateUI() {
        let bgColor: UIColor
        if isFullScreen {
            bgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR, isDark: true)
        } else {
            bgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR)
        }
        
        let fgColor: UIColor
        if isFullScreen {
            fgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR, isDark: true)
        } else {
            fgColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR)
        }
        
        backgroundColor = bgColor.withAlphaComponent(0.3)
        layer.borderColor = fgColor.withAlphaComponent(0.2).cgColor
        shareButton.tintColor = fgColor
        minisizeButton.tintColor = fgColor
        closeButton.tintColor = fgColor
        verticalLine1.backgroundColor = fgColor.withAlphaComponent(0.2).cgColor
        verticalLine2.backgroundColor = fgColor.withAlphaComponent(0.2).cgColor
    }
}
