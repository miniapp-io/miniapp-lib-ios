//
//  BackComponent.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/6/20.
//

import Foundation
import UIKit
import MiniAppUIKit

internal class BackComponent : UIView {
    
    private let cornerRadius: CGFloat = 15.0
    private let isDark: Bool = false
    
    private let backButton = UIButton()
    
    public var back: (() -> Void)? = nil
    
    private let btnHeight = 30.0
    private let btnMargin = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc func backPressed() {
        self.back?()
    }
    
    private func getImage(named name: String) -> UIImage? {
        return UIKitResourceManager.image(named: name)
    }
    
    private func setupUI() {
        
        backgroundColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_BG_COLOR, isDark: true).withAlphaComponent(0.3)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 0.5
        layer.borderColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR, isDark: true).withAlphaComponent(0.2).cgColor
        layer.masksToBounds = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(getImage(named: "icon_back"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: btnMargin, left: btnMargin, bottom: btnMargin, right: btnMargin)
        backButton.tintColor = MiniAppServiceImpl.instance.resourceProvider.getColor(key: KEY_TEXT_COLOR, isDark: true)
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [backButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing // Ensure equal spacing between each view
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: btnHeight),
            backButton.heightAnchor.constraint(equalToConstant: btnHeight)
        ])
        
        updateUI()
    }
    
    private func updateUI() {
    }
}
