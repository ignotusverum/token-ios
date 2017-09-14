//
//  RequestCellLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Used for a status layout type where a width must be defined to set correct insets.
struct RequestStatusLayout {
    /// Layout for status.
    var layout: Layout
    
    /// Width of status in layout.
    var width: CGFloat
}

/// Layout to assemble a request cell.
struct RequestCellLayout: Layout {
    
    /// Image for request.
    var image: Layout
    
    /// Name of user.
    var name: Layout
    
    /// Request Info layout.
    var info: Layout
    
    /// Request status containing inner layout and required width to layout status rect.
    var status: RequestStatusLayout?
    
    /// Badge for status.
    var badge: Layout?
    
    init(image: Layout, name: Layout, info: Layout, status: RequestStatusLayout?, badge: Layout?) {
        self.image = image
        self.name = name
        self.info = info
        self.status = status
        self.badge = badge
    }
    
    /// Will layout image and content for request cell.
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {
        
        let imageViewLayout = SquareLayout(content: image).withInsets(bottom: 10)
        
        var infoContents: [Layout] = [name, info.withInsets(bottom: 7)]
        
        if let status = status {
            let statusLayoutInset: CGFloat = (rect.width - status.width) / 2 - 12 //Inset that gets the difference of width between status label and bounds. Divided in half because the right and left inset use the value. And subtracting 12 to give the text a little more room.
            
            if let badge = badge { //If a badge is needed, create a layout for that.
                
                let badgeLayout = BadgeLayout(content: status.layout, badge: badge).withInsets(left: statusLayoutInset, right: statusLayoutInset)
                
                infoContents.append(badgeLayout)
                
            } else { //Else just use the status layout.
                infoContents.append(status.layout.withInsets(left: statusLayoutInset, right: statusLayoutInset))
            }
        }
        
        let infoLayout = VerticalLayout(contents: infoContents, verticalSeperatingSpace: 0).withInsets(top: 10, bottom: 0)
        var layout = VerticalLayout(contents: [imageViewLayout, infoLayout], verticalSeperatingSpace: 0).withInsets(top: 20, bottom: 20)
        
        layout.layout(in: rect)
    }
}
