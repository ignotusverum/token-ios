//
//  TMPaymentTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMPaymentTextFieldDelegate {
    func paymentTextFieldDidFinishEditing(_ textField: TMPaymentTextField)
}

class TMPaymentTextField: TMPaymentInputTextField {
    
    // Delegate
    var customDelegate: TMPaymentTextFieldDelegate?
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.insetBy(dx: 0.0, dy: 8.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.insetBy(dx: -25.0, dy: 8.0)
    }
}
