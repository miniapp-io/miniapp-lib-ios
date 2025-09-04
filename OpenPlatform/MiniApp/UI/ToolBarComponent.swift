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
    private let isDark: Bool = false
    
    private let loadingIndicator = UIButton()
    private let ratingLabel = UILabel()
    private let starImageView = UIImageView()
    private let closeButton = UIButton()
    private let minisizeButton = UIButton()
    private let verticalLine1 = CALayer()
    private let verticalLine2 = CALayer()
    
    public var dismiss: (() -> Void)? = nil
    public var share: (() -> Void)? = nil
    public var minisize: (() -> Void)? = nil
    
    private let btnHeight = 30.0
    private let btnMargin = 5.0
    
    public func setStarLabel(label:String) {
        self.isLoading = false
        ratingLabel.text = label
        self.updateUI()
    }
    
    var isLoading: Bool = true {
        didSet {
            updateUI()
        }
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
        
        backgroundColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR).withAlphaComponent(0.8)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 0.5
        layer.borderColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR).withAlphaComponent(0.2).cgColor
        layer.masksToBounds = true
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.setImage(getImage(named: "icon_share"), for: .normal)
        loadingIndicator.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        loadingIndicator.tintColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR)
        
        loadingIndicator.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 15)
        ratingLabel.textColor = .white
        
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.image = getImage(named: "icon_star")
        starImageView.tintColor = .yellow
        
        minisizeButton.translatesAutoresizingMaskIntoConstraints = false
        minisizeButton.setImage(getImage(named: "icon_minimization"), for: .normal)
        minisizeButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        minisizeButton.tintColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR)
        minisizeButton.addTarget(self, action: #selector(minisizePressed), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(getImage(named: "icon_close"), for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        closeButton.tintColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        
        verticalLine1.backgroundColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR).withAlphaComponent(0.2).cgColor
        layer.addSublayer(verticalLine1)
        
        verticalLine2.backgroundColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR).withAlphaComponent(0.2).cgColor
        layer.addSublayer(verticalLine2)
        
        let stackView = UIStackView(arrangedSubviews: [loadingIndicator, minisizeButton, closeButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing // Ensure equal spacing between each view
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: btnMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -btnMargin),
            loadingIndicator.widthAnchor.constraint(equalToConstant: btnHeight),
            loadingIndicator.heightAnchor.constraint(equalToConstant: btnHeight),
            minisizeButton.widthAnchor.constraint(equalToConstant: btnHeight),
            minisizeButton.heightAnchor.constraint(equalToConstant: btnHeight),
            closeButton.widthAnchor.constraint(equalToConstant: btnHeight),
            closeButton.heightAnchor.constraint(equalToConstant: btnHeight)
        ])
        
        updateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position the vertical line
        let lineX = bounds.width / 3 - 0.5 // Adjust the position as needed
        verticalLine1.frame = CGRect(x: lineX, y: btnMargin, width: 0.5, height: bounds.height - 12) // Adjust the height and position as needed
        verticalLine2.frame = CGRect(x: lineX * 2 - 0.5, y: btnMargin, width: 0.5, height: bounds.height - 12) // Adjust the height and position as needed
    }
    
    private func updateUI() {
        if isLoading {
            loadingIndicator.isHidden = false
            ratingLabel.isHidden = true
            starImageView.isHidden = true
        } else {
            loadingIndicator.isHidden = true
            ratingLabel.isHidden = false
            starImageView.isHidden = false
        }
    }
}
