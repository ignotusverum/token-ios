//
//  UIView+Layout.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation
import UIKit

extension UIView: Layout {
    
    func layout(in rect: CGRect) {
        frame = rect
    }
}

/// Calayer
extension CALayer: Layout {
    
    func layout(in rect: CGRect) {
        frame = rect
    }
}
