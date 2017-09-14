//
//  TMPaymentCardTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe

extension STPPaymentCardTextField {
    
    func formTextFieldWithMatchingPlaceholder(_ placehoolder: String)-> UITextField? {
        
        var resultTextField: UITextField?
        
        for subView in self.subviews {
               
            for textField in subView.subviews {
                
                if textField is UITextField {
                    if (textField as! UITextField).placeholder == placehoolder {
                        resultTextField = (textField as! UITextField)
                    }
                }
            }
        }
        
        return resultTextField
    }
}
