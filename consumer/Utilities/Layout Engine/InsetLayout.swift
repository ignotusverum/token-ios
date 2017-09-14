//
//  InsetLayout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/17/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Layout for content with inset values applied to rect.
struct InsetLayout: Layout {
    
    /// Content to modify insets for.
    var content: Layout
    
    /// Insets for content.
    var insets: UIEdgeInsets
    
    fileprivate init(content: Layout, insets: UIEdgeInsets) {
        self.content = content
        self.insets = insets
    }
    
    /// Lays out content with provided rect and insets.
    ///
    /// - Parameter rect: Rect for content.
    mutating func layout(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, insets)
        
        content.layout(in: newRect)
    }
}

///Extension for layout protocol that allows you to simply call a method on a current layout to provide insets.
extension Layout {

    /// Creates a new inset layout for top, bottom, left and right values.
    ///
    /// - Parameters:
    ///   - top: Top inset value.
    ///   - left: Left inset value.
    ///   - bottom: Bottom inset value.
    ///   - right: Right inset value.
    /// - Returns: Layout for inset values.
    func withInsets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> InsetLayout {
        let insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        
        return withInsets(insets: insets)
    }
    
    /// Creates a new inset layout for a single value to use as top, bottom, left and right value.
    ///
    /// - Parameter insets: Inset value to create inset object.
    /// - Returns: Layout for an inset value.
    func withInsets(all insets: CGFloat) -> InsetLayout {
        return withInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
    
    /// Creates a new inset layout for an inset object.
    ///
    /// - Parameter insets: Insets object layout.
    /// - Returns: Layout for inset object.
    func withInsets(insets: UIEdgeInsets) -> InsetLayout {
        return InsetLayout(content: self, insets: insets)
    }
}
