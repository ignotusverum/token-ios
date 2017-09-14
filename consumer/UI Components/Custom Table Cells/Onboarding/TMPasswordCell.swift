//
//  TMPasswordCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import JDStatusBarNotification

class TMPasswordCell: TMCreateAccountCell {
    
    override func validateTextField(_ textField: UITextField) {
        
        super.validateTextField(textField)
        
        var validationResult = false
        
        if TMInputValidation.isValidPassword(textField.text) {
            validationResult = true
        }
        
        self.delegate?.validationSuccessForCell(self, success: validationResult)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        
        if !TMInputValidation.isValidPassword(textField.text) && (textField.text?.length)! > 0 {
            
            JDStatusBarNotification.show(withStatus: "Wrong Password", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}
