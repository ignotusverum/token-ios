//
//  TMCreateAccountCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import JDStatusBarNotification

protocol TMCreateAccountCellDelegate {
    
    func textEditingDidBegin(_ textField: UITextField)
    func textEditingDidEnd(_ textField: UITextField)
    func textShouldReturn(_ textField: UITextField)
    func textShouldChangeCharacter(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String)
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool)
}

extension TMCreateAccountCellDelegate {
    
    func textEditingDidBegin(_ textField: UITextField) {}
    func textEditingDidEnd(_ textField: UITextField) {}
    func textShouldReturn(_ textField: UITextField) {}
    func textShouldChangeCharacter(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) {}
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool) {}
}

class TMCreateAccountCell: UITableViewCell {
    
    var delegate: TMCreateAccountCellDelegate?
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            
            titleLabel.font = titleLabel.font!.withSize(getFontSize())
            
            if let titleText = titleLabel.text {
                
                let textWithSpaces = titleText.setCharSpacing(1.0)
                titleLabel.attributedText = textWithSpaces
            }
        }
    }
    @IBOutlet var textField: PhoneNumberTextField?
    
    @IBOutlet var validationLineView: UIView!
    
    fileprivate var customNibView: UIView?
    var placeholderColor = UIColor.TMGrayPlaceholder
    
    var customTextColor = UIColor.TMGrayColor
    var validationDefaultColor = UIColor.TMGrayCell
    var validationLineSelectedColor = UIColor.black
    var textFieldPlaceholderColor = UIColor.TMColorWithRGBFloat(204, green: 204, blue: 204, alpha: 1)
    
    var oldPlaceholder: String?
    
    // MARK: - Custom initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customInit() {
        
        if let textField = textField  {
            
            textField.addTarget(self, action: #selector(TMCreateAccountCell.textFieldDidChange), for: .editingChanged)
            
            oldPlaceholder = textField.placeholder
            
            titleLabel.textColor = UIColor.TMColorWithRGBFloat(170, green: 170, blue: 170, alpha: 1)
            validationLineView.backgroundColor = UIColor.TMGrayCell

            if DeviceType.IS_IPHONE_6P {
                
                titleLabel.font = UIFont.MalloryMedium(15.0)
                textField.font = UIFont.ActaBook(20.0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard
            let textField = textField,
            let placeholder = textField.placeholder
        else {
            return
        }
        
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : textFieldPlaceholderColor])
    }
    
    func validateTextField(_ textField: UITextField) {
        
        if textField.text?.length == 0 {
            return
        }
    }
    
    // MARK: - Utilities
    
    func getFontSize()-> CGFloat {
        
        var fontSize: CGFloat = 12.0
        
        if DeviceType.IS_IPHONE_5 {
            fontSize = 10.0
        }
        else if DeviceType.IS_IPHONE_6P {
            fontSize = 15.0
        }
        
        return fontSize
    }
}

extension TMCreateAccountCell: UITextFieldDelegate {
    
    func textFieldDidChange(_ textField: UITextField) {
        validateTextField(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let textField = self.textField {
            
            delegate?.textEditingDidEnd(textField)
        
            textField.attributedPlaceholder = oldPlaceholder?.color(placeholderColor)
            
            makeHighlighted(false)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let textField = self.textField {
            
            delegate?.textEditingDidBegin(textField)
            
            textField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName : textFieldPlaceholderColor])
            
            makeHighlighted(true)
        }
    }
    
    func makeHighlighted(_ highlighted: Bool) {
        if highlighted {
            validationLineView.backgroundColor = validationLineSelectedColor
        } else {
            validationLineView.backgroundColor = validationDefaultColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        delegate?.textShouldReturn(textField)
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        delegate?.textShouldChangeCharacter(textField, shouldChangeCharactersInRange: range, replacementString: string)
        
        return true
    }
}
