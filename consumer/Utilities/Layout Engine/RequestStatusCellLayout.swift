//
//  RequestStatusCellLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/9/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Used for a status layout type where a width must be defined to set correct insets.
struct RequestStatusCellProtocol {
    /// Layout for status.
    var layout: Layout
    
    /// Width of status in layout.
    var width: CGFloat
}

/// Layout to assemble a request cell.
struct RequestStatusCellLayout: Layout {
    
    /// Image for request.
    var image: Layout
    
    /// Name of user.
    var name: Layout
    
    /// Request Info layout.
    var info: Layout
    
    init(image: Layout, name: Layout, info: Layout) {
        self.image = image
        self.name = name
        self.info = info
    }
    
    /// Will layout image and content for request cell..
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {
        
        let imageViewLayout = SquareLayout(content: image).withInsets(bottom: 5)
        
        let infoContents: [Layout] = [name, info]
        
        let infoLayout = VerticalLayout(contents: infoContents, verticalSeperatingSpace: 0).withInsets(top: 10, bottom: 0)
        var layout = VerticalLayout(contents: [imageViewLayout, infoLayout], verticalSeperatingSpace: 0).withInsets(top: 10, bottom: 20)
        
        layout.layout(in: rect)
    }
}
