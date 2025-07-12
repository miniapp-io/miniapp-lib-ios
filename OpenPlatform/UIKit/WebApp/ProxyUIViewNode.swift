//
//  ProxyUIViewNode.swift
//  MiniAppKit
//
//  Created by w3bili on 2024/5/31.
//

import UIKit
import MiniAppUIKit

internal class ProxyUIViewNode : ASDisplayNode {
    
    private var srcView: UIView?
    let srcSize: CGSize?
    
    public init(srcView: UIView, size: CGSize? = nil) {
        self.srcView = srcView
        self.srcSize = size
        super.init()
        
    }
    
    public override func didLoad() {
        if let nodeView = self.srcView {
            view.addSubview(nodeView)
        }
    }
    
    override public func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        if let size = self.srcSize {
            return size
        } else {
            return super.calculateSizeThatFits(constrainedSize)
        }
    }
    
}

