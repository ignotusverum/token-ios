//
//  TMAddCreditCardPaymentCollectionViewCell.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

@objc protocol TMAddCreditCardPaymentCollectionViewCellProtocol {
    
    /// Text editing has begun for text field in cell.
    ///
    /// - Parameter indexPath: Index path of cell.
    func textEditingBeganForIndexPath(_ indexPath: IndexPath)
    
    /// Next button has been tapped on keyboard when editing the text field.
    ///
    /// - Parameter indexPath: Index path of cell.
    func nextButtonTappedForIndexPath(_ indexPath: IndexPath)
    
    /// Text has changed for text field in cell.
    ///
    /// - Parameter indexPath: Index path of cell.
    /// - Parameter newString: New string in text field.
    func textFieldDidChange(indexPath: IndexPath, newString: String)
    
    /// Checks if other cells are verified based on entered text.
    ///
    /// - Returns: True if all other cells are verified.
    func allTextFieldsVerified() -> Bool
    
    /// Save button on top of keyboard was tapped.
    func onSaveButton()
    
    /// Determines if it is ok to change characters in the text field.
    ///
    /// - Parameters:
    ///   - indexPath: Index path of cell.
    ///   - text: Current text field text.
    /// - Returns: True if it is ok to change characters in the text field.
    func shouldChangeCharacters(_ indexPath: IndexPath, text: String) -> Bool
}

class TMAddCreditCardPaymentCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public iVars

    /// Payment field represented by cell.
    var paymentField: TMAddCreditCardPaymentDataType! {
        didSet {
            let titleAttributedString = NSMutableAttributedString(string: paymentField.rawValue.uppercased())
            titleAttributedString.addAttribute(NSKernAttributeName, value: 0.6, range: NSMakeRange(0, paymentField.rawValue.length))
            
            titleLabel.attributedText = titleAttributedString
            
            textField.placeholder = paymentField.placeholderText()
            textField.keyboardType = paymentField.keyboardType()
            
            if let autocapitalizationType = paymentField.autocapitalizationType() {
                textField.autocapitalizationType = autocapitalizationType
            }
        }
    }
    
    /// Index path of cell from the colleciton view.
    var indexPath: IndexPath!
    
    /// Delegate for text field actions.
    var delegate: TMAddCreditCardPaymentCollectionViewCellProtocol?
    
    /// Theme for cell.
    var theme: TMAddCreditCardPaymentTheme! {
        didSet {
            titleLabel.textColor = theme.titleColor()
            textField.textColor = theme.textColor()
            textField.tintColor = theme.textColor()
            textField.keyboardAppearance = self.theme.keyboardAppearance()
            textField.attributedPlaceholder = NSAttributedString(string: paymentField.placeholderText(), attributes: [NSForegroundColorAttributeName : theme.placeholderColor()])
        }
    }
    
    /// Text field for content.
    lazy var textField: UITextField = {
        let textField = UITextField()
        
        let font = UIFont.ActaBook(18)
        textField.font = font
        textField.textAlignment = .center
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = font.pointSize / 0.7
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        self.saveButton.frame = CGRect(x: 0, y: 0, w: self.bounds.width, h: 66)
        textField.inputAccessoryView = self.saveButton
        
        textField.returnKeyType = .next
        
        return textField
    }()
    
    /// Boolean to tell the cell if a right side border should be displayed to use as a seperator.
    var displaySideBorder = false
    
    // MARK: - Private iVars
    
    /// Label representing which cell this is.
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.MalloryMedium(12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        return label
    }()
    
    /// Save button above keyboard.
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton.button(style: .alternateBlack)
        
        button.setTitle("Save", for: .normal)
        button.addTarget(self.delegate, action: #selector(TMAddCreditCardPaymentCollectionViewCellProtocol.onSaveButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        addSubview(titleLabel)
        addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setLineWidth(2)
        context.setStrokeColor(theme.lineColor().cgColor)
        context.move(to: CGPoint(x: 0, y: bounds.height))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        if displaySideBorder {
            
            let sideBorderVerticalSpace: CGFloat = bounds.height / 7.3 //Space between the top and bottom of the border.
            
            context.move(to: CGPoint(x: bounds.width, y: sideBorderVerticalSpace))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - sideBorderVerticalSpace))
        }
        
        context.strokePath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var cellLayout = VerticalLayout(contents: [titleLabel, textField], verticalSeperatingSpace: 9).withInsets(top: (bounds.height / 2.75) - 9, bottom: bounds.height / 9.7)
        cellLayout.layout(in: bounds)
    }
    
    //MARK: - Actions
    
    @objc private func textFieldDidChange() {
        guard let delegate = self.delegate else {
            return
        }
        
        if let text = textField.text {
            delegate.textFieldDidChange(indexPath: indexPath, newString: text) //Updates delegate with every character change.
        }
        
        saveButton.isEnabled = delegate.allTextFieldsVerified() //Enables save button if all other text fields in the collection view are verfied and ready to be submitted.
    }
}

// MARK: - UITextFieldDelegate
extension TMAddCreditCardPaymentCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textEditingBeganForIndexPath(indexPath)
        
        guard let delegate = self.delegate else {
            return false
        }
        
        saveButton.isEnabled = delegate.allTextFieldsVerified() //Enables save button if all other text fields in the collection view are verfied and ready to be submitted.

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //Backspace detection.
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let backSpaceUnicodeValue: Int32 = -92

        guard
            let text = textField.text,
            let delegate = delegate else {
            return true
        }
        
        if isBackSpace == backSpaceUnicodeValue { //Checks if backspace was tapped.
            return true
        } else if !delegate.shouldChangeCharacters(indexPath, text: text) {
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded() //Fixes iOS bug where text field bounces after editing when in a collection view cell. http://stackoverflow.com/questions/9674566/text-in-uitextfield-moves-up-after-editing-center-while-editing
        
        if let text = textField.text {
            delegate?.textFieldDidChange(indexPath: indexPath, newString: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.nextButtonTappedForIndexPath(indexPath) //When next button has been tapped in keyboard.
        
        return true
    }
}
