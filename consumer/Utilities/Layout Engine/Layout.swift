//
//  Layout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

protocol Layout {
    
    /// Lays out object within a specified rect.
    ///
    /// - Parameter rect: Rect to layout within.
    mutating func layout(in rect: CGRect)    
}
