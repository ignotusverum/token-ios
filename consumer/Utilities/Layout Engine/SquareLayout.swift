//
//  SquareLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/16/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Layout to set content into a square shape size based on its width or height, whatever is smallest.
struct SquareLayout: Layout {
    
    /// Content to convert into a square.
    var content: Layout
    
    init(content: Layout) {
        self.content = content
    }

    /// Will layout content into a square rect.
    ///
    /// - Parameter rect: Current rect of content.
    mutating func layout(in rect: CGRect) {
        var minSize: CGFloat = 0
        
        if rect.width > rect.height {
            minSize = rect.height
        } else {
            minSize = rect.width
        }
        
        let x = rect.width / 2 - minSize / 2
        
        let newRect = CGRect(x: x, y: rect.y, width: minSize, height: minSize)
        content.layout(in: newRect)
    }
}
