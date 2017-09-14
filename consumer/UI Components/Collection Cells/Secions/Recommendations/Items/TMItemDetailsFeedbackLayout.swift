//
//  TMItemDetailsFeedbackLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/30/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

/// Used for a status layout type where a width must be defined to set correct insets.
protocol TMItemDetailsFeedbackLayoutProtocol {
    
    var item: TMItem? { get set }
    
    var separatorView: UIView { get set }
    
    var feedbackView: TMFeedbackContainerRatingView { get set }
}

struct TMItemDetailsFeedbackLayout: Layout {
    
    /// Separator
    var separator: Layout
    
    /// Feedback View
    var feedback: Layout
    
    init(separator: Layout, feedback: Layout) {
        self.separator = separator
        self.feedback = feedback
    }
    
    mutating func layout(in rect: CGRect) {
        
        /// Feedback View
        let feedbackHeight: CGFloat = 60
        let feedbackRect = CGRect(x: rect.origin.x, y: rect.height - feedbackHeight, width: rect.width, height: feedbackHeight)
        
        feedback.layout(in: feedbackRect)
        
        /// Separator
        let separatorHeight: CGFloat = 1
        let separatorRect = CGRect(x: rect.origin.x, y: feedbackRect.y - separatorHeight, width: rect.width, height: separatorHeight)
        
        separator.layout(in: separatorRect)
    }
}
