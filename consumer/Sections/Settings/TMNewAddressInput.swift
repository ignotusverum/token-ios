//
//  TMNewAddressInput.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/19/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// This class handles type erasure for TMNewAddressInputProtocol. For information on type erasure check out this article: https://krakendev.io/blog/generic-protocols-and-their-shortcomings
class TMNewAddressInput<view, selectionValue, data>: TMNewAddressInputProtocol {
    typealias T = selectionValue
    typealias U = data
    typealias V = view
    
    private let _generate: ((Void) -> V)
    private let _selectedValue: ((V) -> T)
    private let _selectValue: ((V, T) -> Void)
    private let _reloadData: ((V) -> Void)
    private let _textFieldDidBeginEditing: ((Void) -> Void)
    private let _textFieldShouldEndEditing: ((Void) -> Bool)
    private let _setBackingData: ((U) -> Void)
    private let _getBackingData: ((Void) -> U?)
    private let _setTextField: ((UITextField) -> Void)
    private let _getTextField: ((Void) -> UITextField?)
    private let _setTextEntryAllowed: ((Bool) -> Void)
    private let _getTextEntryAllowed: ((Void) -> Bool)
    private let _loadTextfieldSubviews: ((Void) -> Void)
    
    var backingData: U? {
        set { _setBackingData(newValue!) }
        get { return _getBackingData() }
    }
    
    var textField: UITextField? {
        set { _setTextField(newValue!) }
        get { return _getTextField() }
    }
    
    var textEntryAllowed: Bool {
        set { _setTextEntryAllowed(newValue) }
        get { return _getTextEntryAllowed() }
    }
    
    required init<X: TMNewAddressInputProtocol>(_ addressInput: X) where X.T == selectionValue, X.U == data, X.V == view{
        _generate = addressInput.generate
        _selectedValue = addressInput.selectedValue
        _selectValue = addressInput.selectValue
        _reloadData = addressInput.reloadData
        _textFieldDidBeginEditing = addressInput.textFieldDidBeginEditing
        _textFieldShouldEndEditing = addressInput.textFieldShouldEndEditing
        _setBackingData = addressInput.setBackingData
        _getBackingData = addressInput.getBackingData
        _setTextField = addressInput.setTextField
        _getTextField = addressInput.getTextField
        _setTextEntryAllowed = addressInput.setTextEntryAllowed
        _getTextEntryAllowed = addressInput.getTextEntryAllowed
        _loadTextfieldSubviews = addressInput.loadTextfieldSubviews
    }
    
    func generate() -> V {
        return _generate()
    }
    
    func loadTextfieldSubviews() {
        return _loadTextfieldSubviews()
    }
    
    func selectedValue(view: V) -> T {
        return _selectedValue(view)
    }
    
    func selectValue(view: V, value: T) {
        _selectValue(view, value)
    }
    
    func reloadData(view: V) {
        _reloadData(view)
    }
    
    func textFieldDidBeginEditing() {
        _textFieldDidBeginEditing()
    }
    
    func textFieldShouldEndEditing() -> Bool {
        return _textFieldShouldEndEditing()
    }
}

// MARK: - Backing data
private extension TMNewAddressInputProtocol {
    func setBackingData(data: U) {
        backingData = data
    }
    
    func getBackingData() -> U? {
        guard let backingData = backingData else {
            return nil
        }
        
        return backingData
    }
}

// MARK: - Text Field
private extension TMNewAddressInputProtocol {
    func setTextField(textField :UITextField) {
        self.textField = textField
    }
    
    func getTextField() -> UITextField? {
        guard let textField = textField else {
            return nil
        }
        
        return textField
    }
}

// MARK: - Text Field
private extension TMNewAddressInputProtocol {
    func setTextEntryAllowed(allowed :Bool) {
        textEntryAllowed = allowed
    }
    
    func getTextEntryAllowed() -> Bool {
        return textEntryAllowed
    }
}
