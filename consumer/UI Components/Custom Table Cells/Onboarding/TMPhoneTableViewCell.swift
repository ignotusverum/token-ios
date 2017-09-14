//
//  TMPhoneTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import JDStatusBarNotification

class TMPhoneTableViewCell: TMCreateAccountCell {
    
    var phoneNumber: String? {
        
        let phoneNumber = self.textField?.text
        
        if let text = self.textField?.text {
            do {
                
                let phoneNumberKit = PhoneNumberKit()
                
                let phone = try phoneNumberKit.parse(text, withRegion: self.countryCode)
                
                let phoneFormatted = phoneNumberKit.format(phone, toType: .e164)
                
                return phoneFormatted
            }
            catch { }
        }
        
        return phoneNumber
    }
    var rawPhoneInput: String?
    
    // MARK: - Country code
    
    var countryCode = "US"
    
    // MARK: - Text fields for delegation
    @IBOutlet var countryInput: TMCountryInput!
    
    override func validateTextField(_ textField: UITextField) {
        super.validateTextField(textField)
        
        var validationResult = false
        
        if TMInputValidation.isValidPhone(textField.text, countryCode: self.countryCode) {
            validationResult = true
        }
        
        self.delegate?.validationSuccessForCell(self, success: validationResult)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        self.countryInput.dismissPicker(true)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        
        if !TMInputValidation.isValidPhone(textField.text, countryCode: self.countryCode) && (textField.text?.length)! > 0 {
            
            JDStatusBarNotification.show(withStatus: "Wrong phone number", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}

extension PhoneNumberTextField {
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        if DeviceType.IS_IPHONE_5 {
            return bounds.insetBy(dx: 0.0, dy: 2.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 12.0)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        if DeviceType.IS_IPHONE_5 {
            return bounds.insetBy(dx: 0.0, dy: 2.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 12.0)
    }
}
