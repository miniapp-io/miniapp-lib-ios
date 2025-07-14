//
//  WebAppNode.swift
//  MiniAppX
//
//  Created by w3bili on 2025/1/4.
//

import Foundation
import MiniAppUIKit

internal class WebAppNode: ViewControllerTracingNode, ASScrollViewDelegate {
    
    public let backgroundNode: ASDisplayNode
    public let headerBackgroundNode: ASDisplayNode
    public let topOverscrollNode: ASDisplayNode
    public let pageLodingNode: ASDisplayNode
    
    public override init() {
        self.backgroundNode = ASDisplayNode()
        self.headerBackgroundNode = ASDisplayNode()
        self.topOverscrollNode = ASDisplayNode()
        self.pageLodingNode = ASDisplayNode()
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.headerBackgroundNode)
        self.addSubnode(self.pageLodingNode)
    }
}
