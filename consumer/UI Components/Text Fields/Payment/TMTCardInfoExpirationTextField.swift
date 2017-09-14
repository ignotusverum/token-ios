//
//  TMTCardInfoExpirationTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import BKMoneyKit

class TMTCardInfoExpirationTextField: TMPaymentTextField {
    
    // non numeric regex
    let nonNumericRegex = BKMoneyUtils.nonNumericRegularExpression()
    
    // number character set
    let numberCharacterSet = BKMoneyUtils.numberCharacterSet()
    
    // Exp month
    var expMonth: String? {
        guard let _text = self.text else {
            return nil
        }
        
        if _text.length > 2 {
            
            return _text[0..<2]
        }
        
        return nil
    }
    
    // Exp year
    var expYear: String? {
        guard let _text = self.text else {
            return nil
        }
        
        if _text.length == 5 {
            
            return _text[3..<5]
        }
        
        return nil
    }
    
    func numberOnlyStringWithString(_ string: String)-> String {
        return self.nonNumericRegex!.stringByReplacingMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.length), withTemplate: "")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
    }
}

extension TMTCardInfoExpirationTextField: UITextFieldDelegate {
    
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
        var numberOnlyString:NSString = self.numberOnlyStringWithString(replacedString) as NSString
        
        if numberOnlyString.length > 4 {
            
            return false
        }
        
        if numberOnlyString.length == 1 && numberOnlyString.substring(to: 1).toInt()! > 1 {
            numberOnlyString = "0".appending(String(numberOnlyString)) as NSString
        }
        
        var formattedString = ""
        
        if numberOnlyString.length > 0 {
            
            let monthString = numberOnlyString.substring(to: min(2, numberOnlyString.length))
            
            if monthString.length == 2 {
                let monthInteger = monthString.toInt()
                if monthInteger! < 1 || monthInteger! > 12 {
                    return false
                }
            }
            
            formattedString.append(monthString)
        }
        
        if numberOnlyString.length > 1 {
            formattedString.append("/")
        }
        
        if numberOnlyString.length > 2 {
            let yearString = numberOnlyString.substring(from: 2)
            formattedString.append(yearString)
        }
        
        self.text = formattedString
        
        if formattedString.length == 5 {
            self.customDelegate?.paymentTextFieldDidFinishEditing(self)
        }
        
        return false
    }
}
