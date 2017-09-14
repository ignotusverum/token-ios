//
//  TMForgotPasswordValidationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import SVProgressHUD
import JDStatusBarNotification

class TMForgotPasswordValidationViewController: TMAccountValidationViewController {
    
    // Fields
    var passwordText: String?
    
    var validatedCells = [TMCreateAccountCell]()
    
    var phoneValidationText: String?
    var phoneValidationTextField: UITextField?
    
    var emailValidationText: String?
    
    // Cell Identifiers - datasource
    let cellIdentifiers = ["TMPhoneValidationCell", "TMEmailCell", "TMPasswordCell", "TMResendCodeCell"]
    
    fileprivate lazy var signInButton: UIButton = {
        let button = UIButton.button(style: .black)
        
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(onResetButton), for: .touchUpInside)
        
        return button
    }()
    
    override var keyboardHeight: CGFloat? {
        didSet {
            guard let keyboardHeight = keyboardHeight else {
                return
            }
            
            //Set up constraints for the sign in button once keyboard is up. Allows the button to be placed above keyboard.
            
            view.addSubview(signInButton)
            
            signInButton.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints([
                NSLayoutConstraint(item: signInButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -keyboardHeight - 10),
                NSLayoutConstraint(item: signInButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: signInButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 94 / 187, constant: 0),
                NSLayoutConstraint(item: signInButton, attribute: .height, relatedBy: .equal, toItem: signInButton, attribute: .width, multiplier: 34 / 94, constant: 0)
                ])
        }
    }
    
    // MARK: - Controller lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("PHONE VERIFICATION", color: UIColor.black)
        
        signInButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s24)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifiers[indexPath.row], for: indexPath) as! TMCreateAccountCell
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Reset Password
    @IBAction func onResetButton(_ sender: Any) {
        
        if let phoneNumber = self.phoneNumber, let phoneToken = self.phoneValidationText, let email = self.emailValidationText, let password = self.passwordText {
            
            do {
                
                let phoneNumberKit = PhoneNumberKit()
                
                let phoneNumber = try phoneNumberKit.parse(phoneNumber, withRegion: self.countryCode)
                let formattedPhone = phoneNumberKit.format(phoneNumber, toType: .e164)
                
                SVProgressHUD.show()
                
                let netman = TMNetworkingManager.shared
                
                TMUserAdapter.resetPassword(phoneToken, phoneNumber: formattedPhone, email: email, newPassword: password).then { result-> Promise<Any?> in
                    
                    return netman.promiseAuthenticate(email, password: password)
                    }.then { result-> Promise<TMUser?> in
                        
                        self.view.endEditing(true)
                        
                        return TMUserAdapter.fetchMe()
                    }.then { result-> Void in
                        
                        netman.postLoginNotificaitonWithSuccess(true)
                        
                        self.view.endEditing(true)
                    }.always {
                        
                        SVProgressHUD.dismiss()
                    }.catch { error-> Void in
                        
                        JDStatusBarNotification.show(withStatus: "Someting went wrong, please try again later.", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
                
                return
                
            } catch {
                
                JDStatusBarNotification.show(withStatus: "Wrong Verification code, please check your code", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
    
    override func backButtonPressed(_ sender: Any?) {
        
        self.popVC()
    }
}

// MARK: - Validation
extension TMForgotPasswordValidationViewController: TMCreateAccountCellDelegate {
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool) {
        
        if cell is TMPasswordCell {
            
            let passwordCell = cell as? TMPasswordCell
            
            if let passwordCell = passwordCell {
                
                
                self.passwordText = passwordCell.textField!.text
                
                self.validateCheckForCell(cell, validationResult: success)
                
            }
        }
        else if cell is TMEmailCell {
            
            let emailCell = cell as? TMEmailCell
            
            if let emailCell = emailCell {
                
                self.emailValidationText = emailCell.textField!.text
                
                self.validateCheckForCell(cell, validationResult: success)
            }
        }
            // Code Verification cell
        else if cell is TMPhoneValidationTableViewCell {
            
            self.phoneValidationText = cell.textField?.text
            
            self.validateCheckForCell(cell, validationResult: success)
        }
        
        if self.validatedCells.count == self.cellIdentifiers.count - 1 {
            
            if !DeviceType.IS_IPHONE_5 {
                signInButton.isEnabled = true
            }
            else {
                signInButton.isEnabled = false
            }
        }
    }
    
    func validateCheckForCell(_ cell: TMCreateAccountCell, validationResult: Bool) {
        
        if validationResult {
            if !self.validatedCells.contains(cell) {
                self.validatedCells.append(cell)
            }
        }
        else {
            if self.validatedCells.contains(cell) {
                self.validatedCells.removeFirst(cell)
            }
        }
    }
}

// MARK: - TableView Delegate
extension TMForgotPasswordValidationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if DeviceType.IS_IPHONE_6P {
            return 100.0
        }
        
        if DeviceType.IS_IPHONE_5 {
            
            return 70.0
        }
        
        return 87.0
    }
}
