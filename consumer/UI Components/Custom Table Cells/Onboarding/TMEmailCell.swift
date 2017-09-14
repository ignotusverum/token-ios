//
//  TMEmailCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import JDStatusBarNotification

class TMEmailCell: TMCreateAccountCell {
    
    override func validateTextField(_ textField: UITextField) {
        
        super.validateTextField(textField)
        
        var validationResult = false
        
        if TMInputValidation.isValidEmail(textField.text) {
            validationResult = true
        }
        
        self.delegate?.validationSuccessForCell(self, success: validationResult)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        
        if !TMInputValidation.isValidEmail(textField.text) && (textField.text?.length)! > 0 {
            
            JDStatusBarNotification.show(withStatus: "Wrong email", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}
