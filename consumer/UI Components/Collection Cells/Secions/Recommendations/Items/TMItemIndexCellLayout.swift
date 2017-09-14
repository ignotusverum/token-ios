//
//  TMItemIndexCellLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/23/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

/// Used for a status layout type where a width must be defined to set correct insets.
protocol TMItemIndexCellLayoutProtocol {
    
    var item: TMItem? { get set }
    
    var imageView: UIImageView { get set }
    
    var titleLabel: UILabel { get set }
    
    var priceLabel: UILabel { get set }
    
    var separatorView: UIView { get set }
    
    var feedbackView: TMFeedbackContainerRatingView { get set }
}

/// Layout to assemble a request cell.
struct TMItemIndexCellLayout: Layout {
    
    /// Image of product.
    var image: Layout
    
    /// Title of product.
    var title: Layout
    
    /// Price for item.
    var price: Layout
    
    /// Separator
    var separator: Layout
    
    /// Feedback View
    var feedback: Layout
    
    init(image: Layout, title: Layout, price: Layout, separator: Layout, feedback: Layout) {
        self.image = image
        self.title = title
        self.price = price
        self.separator = separator
        self.feedback = feedback
    }
    
    /// Will layout image and content for index cell..
    ///
    /// - Parameter rect: Rect of main content. Image will use the top half of the rect and other info will be near the bottom.
    mutating func layout(in rect: CGRect) {
        
        /// Feedback View
        let feedbackHeight: CGFloat = 60
        let feedbackRect = CGRect(x: rect.origin.x, y: rect.height - feedbackHeight, width: rect.width, height: feedbackHeight)
        
        feedback.layout(in: feedbackRect)
        
        /// Separator
        let separatorHeight: CGFloat = 1
        let separatorRect = CGRect(x: rect.origin.x, y: feedbackRect.y - separatorHeight, width: rect.width, height: separatorHeight)
        
        separator.layout(in: separatorRect)
        
        /// Image layout
        let imageViewLayout = SquareLayout(content: image).withInsets(bottom: -40)
        
        /// Product info layout
        let infoContents: [Layout] = [title, price]
        let infoLayout = VerticalLayout(contents: infoContents, verticalSeperatingSpace: 0).withInsets(top: 48, left: 40, right: 40)
        
        /// Top Rect
        let topPartRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height - feedbackHeight)
        var topLayout = VerticalLayout(contents: [imageViewLayout, infoLayout], verticalSeperatingSpace: 0).withInsets(top: 22, bottom: 8)
        
        topLayout.layout(in: topPartRect)
    }
}
