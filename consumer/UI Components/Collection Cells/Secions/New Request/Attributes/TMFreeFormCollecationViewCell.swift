//
//  TMFreeFormCollecationViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/18/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMFreeFormCollecationViewCellDelegate {
    
    func occasionFormSelected()
    
    func occasionTextDidEndEditing(_ text: String?)
    func occasionTextDidChanged(_ textField: UITextField)
}

class TMFreeFormCollecationViewCell: TMAttributeCollectionViewCell {

    var delegate: TMFreeFormCollecationViewCellDelegate?
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var pencilImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.textField.delegate = self
        
        let textAttributes = [
            NSFontAttributeName: UIFont.ActaBook(17.0),
            NSForegroundColorAttributeName: UIColor.TMPinkColor,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ] as [String : Any]
        
        self.textField.attributedPlaceholder = NSAttributedString(string: self.textField.placeholder!, attributes: textAttributes)

        NotificationCenter.default.addObserver(self, selector: #selector(TMFreeFormCollecationViewCell.textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
}

extension TMFreeFormCollecationViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        textField.placeholder = ""
        
        self.delegate?.occasionFormSelected()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        textField.placeholder = "Other"
        
        let textAttributes = [
            NSFontAttributeName: UIFont.ActaBook(17.0),
            NSForegroundColorAttributeName: UIColor.TMPinkColor,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ] as [String : Any]
        
        self.textField.attributedPlaceholder = NSAttributedString(string: self.textField.placeholder!, attributes: textAttributes)
        
        self.delegate?.occasionTextDidEndEditing(textField.text)
    }
    
    func textFieldDidChange(_ notificatoin: NSNotification) {
        self.delegate?.occasionTextDidChanged(self.textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        delegate?.occasionTextDidChanged(self.textField)
        return true
    }
}
