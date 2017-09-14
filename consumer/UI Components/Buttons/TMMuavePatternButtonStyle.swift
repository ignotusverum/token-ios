//
//  TMMuavePatternButtonStyle.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/23/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

struct TMMuavePatternButtonStyle: TMButtonStyleProtocol {
    func titleAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryMedium(14), range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func initialState(button: @escaping () -> UIButton) {
        button().setBackgroundImage(UIImage(named: "MuaveButtonNormalBackground"), for: .normal)
        button().setBackgroundImage(UIImage(named: "MuaveButtonHighlightedBackground"), for: .highlighted)
        button().setBackgroundImage(UIImage(named: "MuaveButtonDisabledBackground"), for: .disabled)
    }
    
    func normalState(button: @escaping () -> UIButton) {
    }
    
    func highlightedState(button: @escaping () -> UIButton) {
    }
    
    func inactiveState(button: @escaping () -> UIButton) {
    }
}
