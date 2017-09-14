//
//  TMAlternateBlackButtonStyle.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

struct TMAlternateBlackButtonStyle: TMButtonStyleProtocol {
    func titleAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryBold(14), range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func initialState(button: @escaping () -> UIButton) {
        button().layer.cornerRadius = 0
        normalState { () -> UIButton in
            return button()
        }
    }
    
    func normalState(button: @escaping () -> UIButton) {
        button().backgroundColor = UIColor(colorLiteralRed: 20/255, green: 20/255, blue: 20/255, alpha: 1)
    }
    
    func highlightedState(button: @escaping () -> UIButton) {
         button().backgroundColor = UIColor(colorLiteralRed: 61/255, green: 37/255, blue: 50/255, alpha: 1)
    }
    
    func inactiveState(button: @escaping () -> UIButton) {
        button().backgroundColor = UIColor(colorLiteralRed: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    }
}
