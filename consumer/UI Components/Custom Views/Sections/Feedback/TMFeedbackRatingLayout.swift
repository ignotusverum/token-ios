//
//  TMFeedbackRatingLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

/// Used for a status layout type where a width must be defined to set correct insets.
protocol TMFeedbackRatingLayoutProtocol {
    
    var ratingViews: [TMFeedbackRatingView] { get set }
}

/// Layout to assemble a request cell.
struct TMFeedbackRatingLayout: Layout {
    
    /// Image of product.
    var views: [Layout]
    
    init(views: [Layout]) {
        self.views = views
    }
    
    /// Will layout image and content for request cell..
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {

        var feedbackLayout = HorizontalLayout(contents: views, horizontalSeperatingSpace: 0)
        
        feedbackLayout.layout(in: rect)
    }
}
