//
//  TMLayoutButton.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/6/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMLayoutButton: UIButton {

    @IBInspectable
    var iPhone5: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 568 {
                self.titleLabel?.font = self.titleLabel?.font.withSize(iPhone5)
            }
        }
    }
    
    @IBInspectable
    var iPhone6: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 667 {
                self.titleLabel?.font = self.titleLabel?.font.withSize(iPhone6)
            }
        }
    }
    
    @IBInspectable
    var iPhone6p: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 736 {
                self.titleLabel?.font = self.titleLabel?.font.withSize(iPhone6p)
            }
        }
    }
    
    @IBInspectable
    var SpacingEnabled: Bool = false {
        didSet {
            
            guard let text = self.titleLabel?.text else {
                return
            }
            
            if SpacingEnabled {
            
                let attributedText = NSMutableAttributedString(string: text, attributes: [NSKernAttributeName: UIFont.titleSpacing, NSFontAttributeName: UIFont.MalloryBook(UIFont.titleFont)])
                
                self.titleLabel?.attributedText = attributedText
            }
        }
    }
}
