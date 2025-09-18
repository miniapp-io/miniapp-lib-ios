//
//  PageLoadingView.swift
//  MiniAppX
//
//  Created by w3bili on 2024/12/2.
//

import UIKit
import MiniAppUIKit

internal class PageLoadingView: UIView {
    
    var isDark = MiniAppServiceImpl.instance.resourceProvider.isDark()
    
    private let imageView: UIImageView = UIImageView()
    private let errorLabel: UILabel = UILabel()
    
    init(resourcesProvider: IResourceProvider) {
        super.init(frame: CGRect())
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        self.backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16.0
        imageView.clipsToBounds = true
        
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        
        addSubview(imageView)
        addSubview(errorLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16)
        ])
        
        updateIconUrl(nil)
        
        isHidden = true
    }
    
    private func getImage(named name: String) -> UIImage? {
        return UIKitResourceManager.image(named: name)
    }
    
    func updateIconUrl(_ url: String?) {

        // Check URL validity
        guard let url = url, let imageUrl = URL(string: url) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = image
                self.imageView.layer.cornerRadius = 16.0
                self.imageView.tintColor = nil
            }
        }
        task.resume()
    }
    
    func showLoading() {
        guard isHidden else { return }
        
        // Set placeholder image
        imageView.image = getImage(named: "icon_loading_default")
        imageView.layer.cornerRadius = 0.0
        imageView.tintColor = UIColor(hexString: isDark ? "#1C1D22" : "#E1E5EA")
        
        imageView.isHidden = false
        errorLabel.isHidden = true
        animateVisibility(show: true)
    }
    
    func showError(_ errorMessage: String) {
        imageView.isHidden = true
        errorLabel.text = errorMessage
        errorLabel.isHidden = false
    }
    
    func hide() {
        guard !isHidden else { return }
        animateVisibility(show: false)
    }
    
    private func animateVisibility(show: Bool) {
        let targetAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = targetAlpha
        }) { _ in
            self.isHidden = !show
        }
    }
}

