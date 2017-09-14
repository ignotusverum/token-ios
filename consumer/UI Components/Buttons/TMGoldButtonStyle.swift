//
//  TMGoldButtonStyle.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

struct TMGoldButtonStyle: TMButtonStyleProtocol, TMButtonGradientStyleProtocol {
    func titleAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryBold(14), range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    func initialState(button: @escaping () -> UIButton) {
        normalState { () -> UIButton in
            return button()
        }
    }
    
    func normalState(button: @escaping () -> UIButton) {
        button().alpha = 1
        enableShadow(for: button().layer, shadowOpacity: 0.3, shadowRadius: 4, shadowOffset: CGSize(width: 0, height: 4))
    }
    
    func highlightedState(button: @escaping () -> UIButton) {
        enableShadow(for: button().layer, shadowOpacity: 0.3, shadowRadius: 2, shadowOffset: CGSize(width: 0, height: 2))
    }
    
    func inactiveState(button: @escaping () -> UIButton) {
        button().alpha = 0.3
        disableShadow(for: button().layer)
    }
    
    func gradientColors() -> [CGColor] {
        
        return UIColor.goldGradientColors
    }
}
