//
//  TMLabel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/6/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMLabel: UILabel {

    @IBInspectable
    var letterSpacing: Float = 0.0 {
        didSet {
            self.attributedText = self.text?.setCharSpacing(letterSpacing)
        }
    }
    
    @IBInspectable
    var iPhone5: CGFloat = TMDefaultFont5Size {
        didSet {
            if UIScreen.main.bounds.maxY == 568 {
                self.font = self.font.withSize(iPhone5)
                if let attributedText = self.attributedText {
                    
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    mutableText.addAttributes([NSFontAttributeName: self.font.withSize(iPhone5)], range: NSMakeRange(0, attributedText.length))
                    self.attributedText = mutableText
                }
            }
        }
    }
    
    @IBInspectable
    var iPhone6: CGFloat = TMDefaultFontSize {
        didSet {
            if UIScreen.main.bounds.maxY == 667 {
                self.font = self.font.withSize(iPhone6)
                if let attributedText = self.attributedText {
                    
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    mutableText.addAttributes([NSFontAttributeName: self.font.withSize(iPhone6)], range: NSMakeRange(0, attributedText.length))
                    self.attributedText = mutableText
                }
            }
        }
    }
    
    @IBInspectable
    var iPhone6p: CGFloat = TMDefaultFont6pSize {
        didSet {
            if UIScreen.main.bounds.maxY == 736 {
                self.font = self.font.withSize(iPhone6p)
                if let attributedText = self.attributedText {
                    
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    mutableText.addAttributes([NSFontAttributeName: self.font.withSize(iPhone6p)], range: NSMakeRange(0, attributedText.length))
                    self.attributedText = mutableText
                }
            }
        }
    }
}
