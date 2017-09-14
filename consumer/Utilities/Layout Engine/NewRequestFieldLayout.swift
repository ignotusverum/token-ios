//
//  NewRequestFieldLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/20/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

struct NewRequestFieldLayout: Layout {
    
    /// Field title.
    var title: Layout
    
    /// Field subtitle.
    var subtitle: Layout
    
    /// Content body of the field.
    var body: Layout
    
    init(title: Layout, subtitle: Layout, body: Layout) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
    
    /// Will layout title and body content of a new request field.
    ///
    /// - Parameter rect: Rect of cell to place title and body.
    mutating func layout(in rect: CGRect) {
        let titleRect = CGRect(x: 0, y: 26, width: rect.width, height: 20)
        
        title.layout(in: titleRect)
        
        let subtitleRect = CGRect(x: 0, y: titleRect.y + titleRect.height, width: rect.width, height: 20)
        
        subtitle.layout(in: subtitleRect)
        
        let bodyMargin: CGFloat = 10 //Margin all around body.
        let bodyYOrigin = subtitleRect.y + subtitleRect.height + bodyMargin
        let bodyRect = CGRect(x: bodyMargin, y: bodyYOrigin + 20, width: rect.width - (bodyMargin * 2), height: 30 + rect.height - bodyYOrigin - bodyMargin)
        
        body.layout(in: bodyRect)
    }
}
