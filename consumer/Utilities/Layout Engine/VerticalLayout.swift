//
//  VerticalLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Layout to set content vertically within a rect where each content object is equal in width and height.
struct VerticalLayout: Layout {
    
    /// Content within vertical layout.
    var contents: [Layout]
    
    /// Extra seperation between views layed out vertically.
    var verticalSeperatingSpace: CGFloat
    
    init(contents: [Layout], verticalSeperatingSpace: CGFloat) {
        self.contents = contents
        self.verticalSeperatingSpace = verticalSeperatingSpace
    }
    
    /// Will set each content rect to the same fraction of the height from the main layout rect. Takes vertical spacing into account as well.
    ///
    /// - Parameter rect: Main layout rect.
    mutating func layout(in rect: CGRect) {
        let rectHeight = rect.height / CGFloat(contents.count) //Height of each rect is equal to each other based on height of the layout rect.
        var previousRect = CGRect(x: rect.origin.x, y: rect.origin.y + verticalSeperatingSpace / 2, width: rect.width, height: rectHeight - verticalSeperatingSpace) //Rect that will be mutated when laying out other content.
        
        for index in contents.indices {
            contents[index].layout(in: previousRect)
            previousRect = previousRect.offsetBy(dx: 0, dy: rectHeight) //Shift the y position down to set next rect.
        }
    }
}
