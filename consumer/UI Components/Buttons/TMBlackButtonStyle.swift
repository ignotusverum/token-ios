//
//  TMBlackButtonStyle.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

struct TMBlackButtonStyle: TMButtonStyleProtocol {
    func titleAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryMedium(14), range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func initialState(button: @escaping () -> UIButton) {
        normalState { () -> UIButton in
            return button()
        }
    }
    
    func normalState(button: @escaping () -> UIButton) {
        button().titleLabel?.alpha = 1
        button().backgroundColor = UIColor.blackNormal
        
        enableShadow(for: button().layer, shadowOpacity: 0.2, shadowRadius: 4, shadowOffset: CGSize(width: 0, height: 1))
    }
    
    func highlightedState(button: @escaping () -> UIButton) {
        button().backgroundColor = .black
        disableShadow(for: button().layer)
    }
    
    func inactiveState(button: @escaping () -> UIButton) {
        button().titleLabel?.alpha = 0.3
        disableShadow(for: button().layer)
        button().backgroundColor = UIColor.blackNormal
    }
}
