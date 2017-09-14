
//
//  TMAccountValidationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import pop
import EZSwiftExtensions

class TMAccountValidationViewController: TMValidationViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    var phoneNumber: String?
    var rawPhoneInput: String?
    
    // MARK: - Country code
    
    var countryCode = "US"
    var countryInput: TMCountryInput?
    
    // MARK: - Text fields for delegation
    
    var passwordTextField: UITextField?
    
    var lastNameTextField: UITextField?
    var firstNameTextField: UITextField?
    
    var emailTextField: UITextField?
    var phoneNumberTextField: PhoneNumberTextField?
    
    // MARK: - Cells
    fileprivate let udentifiersCellsForDisplay = ["firstNameCell", "lastNameCell", "emailCell", "phoneCell", "zipCodeCell"]
    
    var emailCell: TMCreateAccountCell?
    var nameCell: TMDoubleCreateAccountCell?
    var phoneNumberCell: TMPhoneTableViewCell?
    
    var passwordCell: TMCreateAccountCell?
    
    // MARK: - Profile image
    fileprivate var profileImage: UIImage?
    fileprivate var profileImageView: UIImageView?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        
        self.countryInput?.dismissPicker(true)
    }
}

// MARK: - TextField Delegate

extension TMAccountValidationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.countryInput?.dismissPicker(true)
    }
}

// MARK: - CountryInput delegate

extension TMAccountValidationViewController: TMCountryInputDelegate {
    
    func countryInputWillShow(_ picker: TMCountryInput!) {
        
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.21) { () in
            
            self.tableView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: CGFloat(TMCOUNTRYINPUTHEIGHT), right: 0.0)
            self.tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: CGFloat(TMCOUNTRYINPUTHEIGHT), right: 0.0)
        }
        
        self.tableView?.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
    }
    
    func countryInputWillHide(_ picker: TMCountryInput!) {
        
        UIView.animate(withDuration: 0.21) { () in
            
            self.tableView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            self.tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        
        if picker.selectedCountryCode != self.countryCode {
            
            self.countryCode = picker.selectedCountryCode
            self.rawPhoneInput = ""
            self.phoneNumberTextField?.text = ""
            self.phoneNumberTextField?.defaultRegion = self.countryCode
        }
    }
}
