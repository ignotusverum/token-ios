//
//  BadgeLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/16/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Layout of content with a top right badge.
struct BadgeLayout: Layout {
    
    /// Content to display badge on.
    var content: Layout
    
    /// Badge to display on content.
    var badge: Layout
    
    init(content: Layout, badge: Layout) {
        self.content = content
        self.badge = badge
    }
    
    /// Will layout content and layout the rect for a badge on the top right of the content rect.
    ///
    /// - Parameter rect: Rect of main content. Badge will extend a little outside of this.
    mutating func layout(in rect: CGRect) {
        content.layout(in: rect)
        
        let badgeSize: CGFloat = 25
        
        let badgeRect = CGRect(x: rect.origin.x + rect.width - badgeSize / 2, y: rect.origin.y - badgeSize / 2, width: badgeSize, height: badgeSize) //Positions badge frame on top right of content.
        
        badge.layout(in: badgeRect)
    }
}
