//
//  TMPaymentCardDetailsTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMPaymentCardDetailsTableViewCellDelegate {
    func didFinishEnteringCellDetails()
}

class TMPaymentCardDetailsTableViewCell: TMPaymentInputTableViewCell {

    // Delegate
    var delegate: TMPaymentCardDetailsTableViewCellDelegate?
    
    // Presentation Style
    override var lightStyle: Bool {
        didSet {
            
            var color = lightColor
            
            var placeholderColor = UIColor.TMGrayDisabledButtonColor
            
            if lightStyle {
                self.expirationTextField.textColor = UIColor.black
                self.cvvTextField.textColor = UIColor.black
                self.zipTextField.textColor = UIColor.black
                
                placeholderColor = lightColor
            }
            else {
                self.expirationTextField.textColor = UIColor.white
                self.cvvTextField.textColor = UIColor.white
                self.zipTextField.textColor = UIColor.white
                color = darkColor
            }
            
            self.expirationTextField.keyboardAppearance = self.textField.keyboardAppearance
            self.cvvTextField.keyboardAppearance = self.textField.keyboardAppearance
            self.zipTextField.keyboardAppearance = self.textField.keyboardAppearance
            
            self.expirationTextField.attributedPlaceholder = NSAttributedString(string:self.expirationTextField.placeholder!,
                                                                                attributes:[NSForegroundColorAttributeName: placeholderColor])
            self.cvvTextField.attributedPlaceholder = NSAttributedString(string:self.cvvTextField.placeholder!,
                                                                         attributes:[NSForegroundColorAttributeName: placeholderColor])
            self.zipTextField.attributedPlaceholder = NSAttributedString(string:self.zipTextField.placeholder!,
                                                                         attributes:[NSForegroundColorAttributeName: placeholderColor])
            
            for view in self.separatorsOutlets {
            
                view.backgroundColor = color
            }
        }
    }
    
    // Separators outlets
    @IBOutlet var separatorsOutlets: [UIView]!
    
    // expiration text field
    var expirationTextField: TMTCardInfoExpirationTextField!
    
    var expYear: UInt? {
        guard let _expYear = expirationTextField.expYear else {
            return nil
        }
        
        return UInt(_expYear)
    }
    
    var expMonth: UInt? {
        guard let _expMo = expirationTextField.expMonth else {
            return nil
        }
        
        return UInt(_expMo)
    }
    
    // cvv text field
    var cvvTextField: TMCardCVVTextField!
    
    var cvv: String? {
        guard let _cvv = cvvTextField.text else {
            return nil
        }
        
        return _cvv
    }
    
    // zip code text field
    @IBOutlet var zipTextField: UITextField!
    
    var zip: String? {
        guard let _zip = zipTextField.text else {
            return nil
        }
        
        return _zip
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.expirationTextField.customDelegate = self
        self.cvvTextField.customDelegate = self
        
        self.contentView.backgroundColor = UIColor.clear
    }
}

extension TMPaymentCardDetailsTableViewCell: TMPaymentTextFieldDelegate {
    func paymentTextFieldDidFinishEditing(_ textField: TMPaymentTextField) {
        
        if textField == expirationTextField {
            
            cvvTextField.becomeFirstResponder()
        }
        else if textField == cvvTextField {
            
            zipTextField.becomeFirstResponder()
        }
        else {
            self.delegate?.didFinishEnteringCellDetails()
        }
    }
}
