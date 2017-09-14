//
//  TMCardCVVTextFIeld.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

// Payment
import Stripe
import BKMoneyKit

class TMCardCVVTextField: TMPaymentTextField {
    
    // non numeric regex
    let nonNumericRegex = BKMoneyUtils.nonNumericRegularExpression()
    
    // number character set
    let numberCharacterSet = BKMoneyUtils.numberCharacterSet()
    
    var cvvNumberLimitation = 3
    var cardBrand = STPCardBrand.unknown {
        didSet {
            
            // Checking cvv number limitation depending on type
            if cardBrand != .amex {
                cvvNumberLimitation = 3
                
                if let text = text, text.length > 3 {
                    self.text = ""
                }
            }
            else {
                cvvNumberLimitation = 4
            }
        }
    }
    
    var cvv: String? {
        guard let _cvv = text else {
            return nil
        }
        
        return _cvv
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
    }
}

extension TMCardCVVTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        
        let nonNumberCharacterSet = self.numberCharacterSet?.inverted
        
        var newRange = range
        
        if string.length == 0 && currentString.substring(with: range).trimmingCharacters(in: nonNumberCharacterSet!).length == 0 {
            
            let numberCharacterRange = currentString.rangeOfCharacter(from: self.numberCharacterSet!, options: .backwards, range: NSMakeRange(0, range.location))
            
            if numberCharacterRange.location != NSNotFound {
                newRange = NSUnionRange(newRange, numberCharacterRange)
            }
        }
        
        let replacedString = currentString.replacingCharacters(in: newRange, with: string)
        
        if replacedString.length <= self.cvvNumberLimitation {
            
            textField.text = replacedString
        }
        
        if replacedString.length == self.cvvNumberLimitation {
            
            self.customDelegate?.paymentTextFieldDidFinishEditing(self)
        }
        
        return false
    }
}
