//
//  TMNewRequestLocationInputLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

struct TMNewRequestLocationInputLayout: Layout {
    
    /// Location input
    var locationInput: Layout
    
    /// Clear button
    var clearButton: Layout
    
    /// Location pin
    var locationImageView: Layout
    
    /// Divider
    var dividerView: Layout
    
    init(locationInput: Layout, clearButton: Layout, locationImageView: Layout, dividerView: Layout) {
        self.locationInput = locationInput
        self.clearButton = clearButton
        self.locationImageView = locationImageView
        self.dividerView = dividerView
    }
    
    /// Will layout image and content for location container.
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {

        /// Location imageView
        let locationImageRect = CGRect(x: rect.x, y: rect.height/2 - 15/2, w: 15, h: 15)
        locationImageView.layout(in: locationImageRect)
    
        /// Clear button
        let clearButtonRect = CGRect(x: rect.width - 25, y: rect.height/2 - 20/2, w: 20, h: 20)
        clearButton.layout(in: clearButtonRect)
        
        /// Divider
        let dividerRect = CGRect(x: rect.x, y: rect.height - 1, w: rect.width, h: 1)
        dividerView.layout(in: dividerRect)
        
        /// Text input
        let locationInputRect = CGRect(x: locationImageRect.x + locationImageRect.width + 7, y: 0, w: rect.width - 25 - 5 - 7, h: rect.height)
        locationInput.layout(in: locationInputRect)
    }
}
