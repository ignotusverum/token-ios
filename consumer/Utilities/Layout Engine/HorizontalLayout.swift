//
//  HorizontalLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/1/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Layout to set content horizontally within a rect where each content object is equal in width and height.
struct HorizontalLayout: Layout {
    
    /// Content within horizontal layout.
    var contents: [Layout]
    
    /// Extra seperation between views layed out horizontally.
    var horizontalSeperatingSpace: CGFloat
    
    init(contents: [Layout], horizontalSeperatingSpace: CGFloat) {
        self.contents = contents
        self.horizontalSeperatingSpace = horizontalSeperatingSpace
    }
    
    /// Will set each content rect to the same fraction of the height from the main layout rect. Takes horizontal spacing into account as well.
    ///
    /// - Parameter rect: Main layout rect.
    mutating func layout(in rect: CGRect) {
        let rectWidth = rect.width / CGFloat(contents.count) //Height of each rect is equal to each other based on height of the layout rect.
        var previousRect = CGRect(x: rect.origin.x + horizontalSeperatingSpace / 2, y: rect.origin.y, width: rectWidth - horizontalSeperatingSpace, height: rect.height) //Rect that will be mutated when laying out other content.
        
        for index in contents.indices {
            contents[index].layout(in: previousRect)
            previousRect = previousRect.offsetBy(dx: rectWidth, dy: 0) //Shift the x position down to set next rect.
        }
    }
}
