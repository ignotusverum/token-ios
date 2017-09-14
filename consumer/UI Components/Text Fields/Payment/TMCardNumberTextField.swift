//
//  TMCardNumberTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe
import BKMoneyKit

protocol TMCardNumberTextFieldDelegate {
    func textFieldDidchangeWithNotification()
    func ccNumberTetFieldDidFinishedEntering()
}

class TMCardNumberTextField: TMPaymentInputTextField {
    
    // Delegate
    var customDelegate: TMCardNumberTextFieldDelegate?
    
    // Card Number
    var cardNumber: String? {
        didSet {
            guard let _cardNumber = cardNumber else {
                return
            }
            
            // Formatting string
            self.text = self.formatter.formattedString(fromRawString: _cardNumber)
            
            // Calling delegate method for card imag
            self.customDelegate?.textFieldDidchangeWithNotification()
        }
    }
    
    // Card number formatter
    let formatter = BKCardNumberFormatter()
    
    // Character Set
    let characterSet = BKMoneyUtils.numberCharacterSet()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
        
        self.keyboardType = .numberPad
    }
}

extension TMCardNumberTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString? = textField.text as NSString?
        
        let nonNumberCharacterSet = self.characterSet?.inverted
        
        var newRange = range
        
        if string.length == 0 {
            if let currentText = currentText, currentText.substring(with: range).trimmingCharacters(in: nonNumberCharacterSet!).length == 0 {
                
                let numberCharacterRange = currentText.rangeOfCharacter(from: self.characterSet!, options: .backwards, range: NSMakeRange(0, range.location))
                
                if numberCharacterRange.location != NSNotFound {
                    newRange = NSUnionRange(newRange, numberCharacterRange)
                }
            }
        }
        
        let newString = currentText?.replacingCharacters(in: newRange, with: string)
        
        textField.text = self.formatter.formattedString(fromRawString: newString)
        
        self.customDelegate?.textFieldDidchangeWithNotification()
        
        if STPCardValidator.validationState(forNumber: textField.text!, validatingCardBrand: false) == .valid {
            self.customDelegate?.ccNumberTetFieldDidFinishedEntering()
        }
        
        return false
    }
}
