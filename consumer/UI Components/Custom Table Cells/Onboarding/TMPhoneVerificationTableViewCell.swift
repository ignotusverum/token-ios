//
//  TMPhoneVerificationTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMPhoneVerificationTableViewCellDelegate {
    
    func phoneVerificationFiledsFilled(_ filled: Bool, string: String?)
}

class TMPhoneVerificationTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textFields: [TMPhoneVerificationTextField]!
    
    var verificationString: String?
    fileprivate var verificationCharactersArray = [String]()
    
    var delegate: TMPhoneVerificationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.attributedText = NSMutableAttributedString.initWithString(titleLabel.text!, lineSpacing: 5.0, aligntment: .center)
        titleLabel.font = UIFont.ActaBook(UIFont.defaultFontSize)
        
        for textField in textFields {
            
            textField.layer.shadowColor = UIColor.black.cgColor
            textField.layer.shadowOpacity = 0.2
            textField.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            textField.layer.shadowRadius = 1.5
            textField.clipsToBounds = false
            textField.delegate = self
        }
        
        selectTextField(forIndex: 0)
    }
}

// MARK: - UITextFieldDelegate
extension TMPhoneVerificationTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let indexOfTextfield = textFields.index(of: textField as! TMPhoneVerificationTextField) else {
            fatalError("Index of Textfield is nil")
        }
        
        selectTextField(forIndex: indexOfTextfield)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let backSpaceUnicodeValue: Int32 = -92
        
        guard let indexOfTextfield = textFields.index(of: textField as! TMPhoneVerificationTextField) else {
            fatalError("Index of Textfield is nil")
        }

        if isBackSpace != backSpaceUnicodeValue {
            textField.text = string

            if indexOfTextfield < textFields.count - 1 {
                selectTextField(forIndex: indexOfTextfield + 1)
            } else {
                checkIfFieldsFilled()
            }
            
            textField.resignFirstResponder()
        } else {
            textField.text = ""
            
            if indexOfTextfield > 0 {
                selectTextField(forIndex: indexOfTextfield - 1)
            }
        }
        
        return false
    }
    
    func checkIfFieldsFilled() {
        
        var result = false
        
        verificationCharactersArray = [String]()
        
        for textField in textFields {
            
            if (textField.text?.length)! > 0 && textField.text != " " {
                
                result = true
                textField.layer.borderColor = UIColor.TMPhoneVerificationGoldColor.cgColor
            }
            else {
                result = false
            }
            
            verificationCharactersArray.append(textField.text!)
        }
        
        verificationString = verificationCharactersArray.joined(separator: "")
        
        delegate?.phoneVerificationFiledsFilled(result, string: verificationString)
    }
    
    fileprivate func selectTextField(forIndex index: Int) {
        for textField in textFields {
            textField.layer.borderWidth = 0
            textField.layer.shadowOpacity = 0.2
        }
        
        let selectedTextField = textFields[index]
        
        selectedTextField.layer.borderColor = UIColor.TMPhoneVerificationGoldColor.cgColor
        selectedTextField.layer.shadowOpacity = 0
        selectedTextField.layer.borderWidth = 1
        selectedTextField.becomeFirstResponder()
    }
}

// MARK: - TMPhoneVerificationViewControllerProtocol
extension TMPhoneVerificationTableViewCell: TMPhoneVerificationViewControllerProtocol {
    func incorrectValidationCode() {
        for textField in textFields {
            textField.text = ""
        }
        
        selectTextField(forIndex: 0)
    }
}
