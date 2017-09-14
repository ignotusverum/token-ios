//
//  TMNewAddressTableViewCell.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/12/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMNewAddressTableViewCellProtocol {
    
    /// Text field in cell has become the first responder.
    ///
    /// - Parameter cell: Cell where text field was selected.
    func textFieldSelected(cell: TMNewAddressTableViewCell)
    
    /// Text field is no longer the first responder.
    ///
    /// - Parameters:
    ///   - cell: Cell where text field will no longer be the first responder.
    ///   - text: Text from text field.
    func textFieldEndedEditing(cell: TMNewAddressTableViewCell, text: String)
}

class TMNewAddressTableViewCell: UITableViewCell {
    
    //MARK: - Public iVars
    var isDarkStyle = false
    
    /// Title label displaying on top of cell.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Cell text field content with a placeholder value.
    @IBOutlet weak var textField: UITextField!

    /// Validation view line on bottom of cell.
    @IBOutlet weak var validationView: UIView!
    
    /// Row index of this cell. Should be set by table datasource.
    var addressField: AddressField? {
        didSet {
            switch addressField!.fieldType() {
            case let .picker(items, textEntryAllowed):
                let picker = TMNewAddressPickerInput()
                pickerInput = TMNewAddressInput(picker)
                pickerInput?.backingData = items
                pickerInput?.textEntryAllowed = textEntryAllowed
                pickerInput?.textField = textField
                textField.inputView = picker.generate()
                break
            default:
                textField.inputView = nil
                break
            }
        }
    }
    
    /// Delegate for table view cell.
    var delegate: TMNewAddressTableViewCellProtocol?
    
    //MARK: - Private iVars
    
    /*  These are input views. Currently there must be a reference for every input aside from the standard keyboard that we support for text fields.
        This is because Swift does not currently support covariance with generics yet. In the future when this is supported a more ideal solution would be.
        
        private var input: TMNewAddressInput<Any, Any, Any>?
     
        With the above, you would be able to cast one input object to fit any type.
     */
    
    /// Picker input complying with TMNewAddressInputProtocol.
    var pickerInput: TMNewAddressInput<UIPickerView, Int, [String]>?
    
    //MARK: - Public
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        titleLabel.textColor = UIColor.TMGrayColor
        
        if DeviceType.IS_IPHONE_6P {
            
            textField.font = UIFont.ActaBook(20.0)
            titleLabel.font = UIFont.MalloryMedium(14.0)
        }
        else {
            textField.font = UIFont.ActaBook(18.0)
            titleLabel.font = UIFont.MalloryMedium(12.0)
        }

        guard let text = titleLabel.text else {
            return
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: 1.2, range: NSMakeRange(0, text.characters.count))
        titleLabel.attributedText = attributedString
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        
        guard let addressField = addressField else {
            return
        }
        textField.removeSubviews()
        
        switch addressField.fieldType() {
        case .picker(_):
            guard let pickerInput = pickerInput else {
                print("Picker input is nil.")
                return
            }
            
            pickerInput.loadTextfieldSubviews()
            
        default:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            
            if !isDarkStyle {
            
                titleLabel.textColor = UIColor.TMTitleBlackColor
                validationView.backgroundColor = UIColor.TMTitleBlackColor
            }
            else {
                
                titleLabel.textColor = UIColor.TMPinkColor
                validationView.backgroundColor = UIColor.TMPinkColor
            }
        }
        else {
            
            if isDarkStyle {
            
                titleLabel.textColor = UIColor.TMGrayCell
                validationView.backgroundColor = UIColor.TMGrayCell
            }
            else {
                
                titleLabel.textColor = UIColor.TMLightGrayPlaceholder
                validationView.backgroundColor = UIColor.TMColorWithRGBFloat(74.0, green: 74.0, blue: 74.0, alpha: 0.1)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension TMNewAddressTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let addressField = addressField else {
            return
        }
        
        switch addressField.fieldType() {
        case .picker(_):
            guard let pickerInput = pickerInput else {
                print("Picker input is nil.")
                return
            }
            
            pickerInput.textFieldDidBeginEditing()
            
        default:
            break
        }
        
        delegate?.textFieldSelected(cell: self)
    }
    
    
    /// Determines if text editing should complete editing. This function should go in textFieldDidEndEditing but an issue with IQKeyboardManager makes it so that the keyboard is stuck do to a not functioning done button. This is do to the order in which text field notifications are called and how IQKeyboardManager handles them.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let addressField = addressField else {
            return true
        }
        
        switch addressField.fieldType() {
        case .picker(_):
            guard let pickerInput = pickerInput else {
                print("Picker input is nil.")
                return true
            }
            
            if pickerInput.textFieldShouldEndEditing() {
                guard let text = textField.text else { //Text is set in textFieldShouldEndEditing function. So text must be referenced here.
                    print("Text field is empty.")
                    return true
                }
                
                delegate?.textFieldEndedEditing(cell: self, text: text)
                return true
            } else {
                return false
            }
            
        default:
            guard let text = textField.text else {
                print("Text field is empty.")
                return true
            }
            
            delegate?.textFieldEndedEditing(cell: self, text: text)
            return true
        }
        
    }
}
