//
//  TMNewRequestLocationCollectionViewLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

struct TMNewRequestLocationCollectionViewLayout: Layout {

    /// Title layout
    var title: Layout
    
    /// Container input
    var container: Layout
    var containerLayout: TMNewRequestLocationInputLayout
   
    /// Location buttons
    var locationButtons: [Layout]
    
    init(title: Layout, container: Layout, containerLayout: TMNewRequestLocationInputLayout, locationButtons: [Layout]) {
        self.title = title
        self.container = container
        self.containerLayout = containerLayout
        self.locationButtons = locationButtons
    }
    
    /// Will layout image and content for location cell.
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {
        
        /// Horizontal + insets
        /// Buttons layout
        var locationButtonsLayout = HorizontalLayout(contents: locationButtons, horizontalSeperatingSpace: 8).withInsets(left: 40, right: 40)
        
        let buttonsRect = CGRect(x: rect.x, y: rect.height - 40 - 24, w: rect.width, h: 40)
        
        /// Container layout
        let containerRect = CGRect(x: rect.x, y: 15 + 50, w: rect.width, h: rect.height - 35 - 60 - 40 - 20)
        
        /// Vertial + insets
        var layout = VerticalLayout(contents: [title, container, locationButtonsLayout], verticalSeperatingSpace: 0).withInsets(top: 15, bottom: 15)
        layout.layout(in: rect)
        
        ///
        locationButtonsLayout.layout(in: buttonsRect)
        
        ///
        var containerInsetLayout = HorizontalLayout(contents: [container], horizontalSeperatingSpace: 0).withInsets(left: 45, right:45)
        containerInsetLayout.layout(in: containerRect)
        containerLayout.layout(in: containerRect)
    }
}
