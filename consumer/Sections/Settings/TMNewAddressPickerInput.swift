//
//  TMNewAddressPickerInput.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/19/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation
import UIKit

class TMNewAddressPickerInput: NSObject, TMNewAddressInputProtocol {
    typealias T = Int //Type used for selection of items.
    typealias U = [String] //Type used for data backing.
    typealias V = UIPickerView //Type used for input view.
    
    //MARK: - Public iVars
    
    var backingData: U?
    
    var textField: UITextField?
    
    var textEntryAllowed: Bool = false
    
    //MARK: - Private iVars
    
    /// Arrow drop down view.
    private var arrowDropDownView: UIView?
    
    /// Previous text set before selection.
    private var previousText: String?
    
    //MARK: - Public
    
    func generate() -> V {
        let pickerView = V()
        
        pickerView.backgroundColor = UIColor.white
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
        return pickerView
    }
    
    func loadTextfieldSubviews() {
        guard let textField = textField else {
            return
        }
        
        guard let textColor = textField.textColor else {
            return
        }
        
        let arrowSize = CGSize(width: 15, height: 15) //Size of arrow.
        let bottomSpacing: CGFloat = 5 //Space between bottom of text field and arrow.
        let rightSpacing: CGFloat = 20 //Space between right of text field and arrow.
        
        // TODO: change superview bounds / iOS 9 drop
        let frame = CGRect(x: textField.superview!.bounds.width - arrowSize.width - rightSpacing, y: textField.bounds.height - arrowSize.height - bottomSpacing, w: arrowSize.width, h: arrowSize.height)
        
        arrowDropDownView = generateDropDownArrow(color: textColor) //Generate the view that contains the arrow.
        arrowDropDownView?.frame = frame
        
        guard let arrowDropDownView = arrowDropDownView else {
            return
        }
        
        textField.addSubview(arrowDropDownView)
    }
    
    func selectValue(view: V, value: T) {
        view.selectRow(value, inComponent: 0, animated: false)
    }
    
    func selectedValue(view: V) -> T {
        return view.selectedRow(inComponent: 0)
    }
    
    func reloadData(view: V) {
        view.reloadAllComponents()
    }
    
    func textFieldDidBeginEditing() {
        guard let textField = textField else {
            print("Text field is nil.")
            return
        }
        
        guard let text = textField.text else {
            print("Text field is empty.")
            return
        }
        
        guard let backingData = backingData else {
            print("Backing data is nil.")
            return
        }
        
        if let picker = textField.inputView as? UIPickerView {
            reloadData(view: picker) //Reload to get fresh data.
            
            if text == "" { //If the text field is empty select the first item in picker.
                selectValue(view: picker, value: 0)
            } else {
                for (i, item) in backingData.enumerated() { //For each item.
                    if item == text {
                        selectValue(view: picker, value: i) //If item is equal to the text then select it.
                        break
                    }
                    
                    selectValue(view: picker, value: backingData.count) //Otherwise, select the other option.
                }
            }
        }
    }
    
    func textFieldShouldEndEditing() -> Bool {
        guard let textField = textField else {
            print("Text field is nil.")
            return false
        }
        
        arrowDropDownView?.isHidden = false
        
        guard let picker = textField.inputView as? UIPickerView else { //If we are currently dismissing the keyboard.
            textField.inputView = generate() //Use the picker view for input.
            
            if let text = textField.text, let previousText = previousText {
                if text.isEmpty {
                    textField.text = previousText
                    self.previousText = nil
                }
            }
            
            return true
        }
        
        guard let backingData = backingData else {
            print("Backing data is nil.")
            return true
        }
        
        let row = selectedValue(view: picker) //Row that is currently selected.
        
        if textEntryAllowed && row == backingData.count { //if text entry is allowed and the row currently selected is "Other"
            textField.inputView = nil //Set the input view to nil which is the keyboard.
            textField.reloadInputViews() //Reload to display the keyboard.
            previousText = textField.text
            textField.text = "" //Empty the text field.
            arrowDropDownView?.isHidden = true
            return false //Do not dismiss.
            
        } else {
            textField.text = backingData[row] //Text field text is whatever is selected by the picker,
            return true
        }
    }
    
    //MARK: - Private
    
    /// Generates a drop down arrow view.
    ///
    /// - Parameters:
    ///   - color: Color of arrow.
    /// - Returns: A UIView with a sublayer containing an arrow path.
    private func generateDropDownArrow(color: UIColor) -> TMDropDownArrowView {
        let view = TMDropDownArrowView()
        
        view.arrowColor = color
        
        return view
    }
}

// MARK: - UIPickerViewDelegate
extension TMNewAddressPickerInput: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let backingData = backingData else {
            print("Backing data is nil.")
            return nil
        }
        
        if textEntryAllowed && row == backingData.count { //On the last cell display "Other"
            return "Other"
        } else {
            return backingData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let backingData = backingData else {
            print("Backing data is nil.")
            return
        }
        
        guard let textField = textField else {
            print("Text field is nil.")
            return
        }
        
        if row != backingData.count { //If "Other" is not selected.
            textField.text = backingData[pickerView.selectedRow(inComponent: 0)]
        }
    }
}

// MARK: - UIPickerViewDataSource
extension TMNewAddressPickerInput: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let backingData = backingData else {
            print("Backing data is nil.")
            return 0
        }
        
        if textEntryAllowed { //If text entry is allowed then add 1 to the count to display the "Other" option.
            return backingData.count + 1
        } else {
            return backingData.count
        }
    }
}
