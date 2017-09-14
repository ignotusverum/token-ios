//
//  TMLayoutConstraint.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/4/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

@IBDesignable
class TMLayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable
    var iPhone4: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY < 568 {
                constant = iPhone4
            }
        }
    }
    
    @IBInspectable
    var iPhone5: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 568 {
                constant = iPhone5
            }
        }
    }
    
    @IBInspectable
    var iPhone6: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 667 {
                constant = iPhone6
            }
        }
    }
    
    @IBInspectable
    var iPhone6p: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 736 {
                constant = iPhone6p
            }
        }
    }
}
