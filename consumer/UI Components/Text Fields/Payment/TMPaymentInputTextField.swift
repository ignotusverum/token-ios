//
//  TMPaymentInputTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMPaymentInputTextField: UITextField {

    // Style
    var lightStyle = false {
        didSet {

            var color = UIColor.TMGrayDisabledButtonColor
            
            self.keyboardAppearance = .dark
            self.textColor = UIColor.white
            
            if self.lightStyle {
                color = UIColor.TMColorWithRGBFloat(78.0, green: 75.0, blue: 79.0, alpha: 1.0)
                
                self.keyboardAppearance = .light
                
                self.textColor = UIColor.black
            }
            
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder!,
                                                            attributes:[NSForegroundColorAttributeName: color])
        }
    }
}
