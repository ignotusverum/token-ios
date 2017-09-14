//
//  TMGiftButtonStyle.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

struct TMGiftButtonStyle: TMButtonStyleProtocol {
    func titleAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryBold(14), range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func initialState(button: @escaping () -> UIButton) {
        button().setBackgroundImage(UIImage(named: "GiftButtonNormalBackground"), for: .normal)
        button().setBackgroundImage(UIImage(named: "GiftButtonHighlightedBackground"), for: .highlighted)
    }
    
    func normalState(button: @escaping () -> UIButton) {
    }
    
    func highlightedState(button: @escaping () -> UIButton) {
    }
    
    func inactiveState(button: @escaping () -> UIButton) {
    }
}
