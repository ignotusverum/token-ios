//
//  TMPhoneValidationTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMPhoneValidationTableViewCell: TMCreateAccountCell {
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 4
    }
    
    override func validateTextField(_ textField: UITextField) {
        
        super.validateTextField(textField)
        
        var validationResult = false
        
        if textField.text?.length == 4 {
            validationResult = true
        }
        
        self.delegate?.validationSuccessForCell(self, success: validationResult)
    }
}
