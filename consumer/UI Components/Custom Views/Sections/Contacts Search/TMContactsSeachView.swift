//
//  TMContactsSeachView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts

@objc protocol TMContactsSeachViewDelegate {
    
    // Return
    func textFieldShouldReturn(_ textField: UITextField)
    
    // Text Changed
    @objc optional func changedToEmptySearch(_ contactPickerView: UITextField)
    
    // Search
    func searchWithText(_ text: String, shouldReset: Bool)
    
    // Selection
    func contactNameSelected(_ name: String)
}

class TMContactsSeachView: UIView {
    
    // Delegate
    var delegate: TMContactsSeachViewDelegate?
    
    // TO:
    @IBOutlet weak var toLabel: UILabel!
    
    // Contact picker
    @IBOutlet weak var contactNameInput: UITextField!
    
    // Initial View
    @IBOutlet weak var view: UIView!
    
    var contactName: String {
        
        var text = ""
        if let textFieldText = contactNameInput.text {
            text = textFieldText
        }
        
        return text
    }
    
    // Init from xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("TMContactsSeachView", owner: self, options: nil)
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customSetup()
    }
    
    func customSetup() {
        
        contactNameInput.delegate = self
        contactNameInput.tintColor = UIColor.TMBlackColor
        contactNameInput.backgroundColor = UIColor.clear
        contactNameInput.font = UIFont.ActaBook(18.0)
        contactNameInput.autocorrectionType = .no
        
        contactNameInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

// MARK: - Contact picker delegate
extension TMContactsSeachView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.delegate?.textFieldShouldReturn(textField)
        
        if let text = textField.text {
            if text.length > 0 {
                self.delegate?.contactNameSelected(text)
            }
        }
        
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        guard let text = textField.text, text.length > 0 else {
            
            delegate?.changedToEmptySearch?(textField)
            return
        }
        
        delegate?.searchWithText(text, shouldReset: false)
    }
}
