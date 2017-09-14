//
//  TMLoginViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import SVProgressHUD
import KeychainAccess
import EZSwiftExtensions
import IQKeyboardManagerSwift
import JDStatusBarNotification

class TMLoginViewController: TMValidationViewController {
    
    //MARK: - Public iVars
    
    /// Cell for email address.
    weak var emailCell: TMCreateAccountCell?
    
    /// Text field for email address.
    weak var emailTextField: UITextField?
    
    /// Cell for password.
    weak var passwordCell: TMCreateAccountCell?
    
    /// Text field for password.
    weak var passwordTextField: UITextField?
    
    /// Cell identifiers.
    let cellIdentifiers = ["TMEmailCell", "TMPasswordCell", "TMResetPasswordCell"]
    
    /// Validated cells.
    var validatedCells = [TMCreateAccountCell]()
    
    /// Validation success status.
    var validateSuccess = false
    
    /// Model for view controller.
    var onboardingModel = TMOnboardingModel()
    
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
                NSLayoutConstraint(item: signInButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DeviceType.IS_IPHONE_4_OR_LESS ? 40 : 60)
                ])
        }
    }
    
    // MARK: - Private iVars

    fileprivate lazy var signInButton: UIButton = {
        let button = UIButton.button(style: .black)
        
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(onSignInButton), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: Public
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("SIGN IN", color: UIColor.black)
        
        //---Sign In Button---//
        
        signInButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s16)
    }
    
    func showStatusBarBorder() -> Bool {
        return true
    }
    
    override func setupViewConroller() {
        
        emailCell = tableView?.cellForRow(at:IndexPath(row: 0, section: 0)) as? TMEmailCell
        passwordCell = tableView?.cellForRow(at:IndexPath(row: 1, section: 0)) as? TMPasswordCell
        
        emailTextField = emailCell?.textField
        passwordTextField = passwordCell?.textField
        
        NotificationCenter.default.addObserver(self, selector: #selector(TMLoginViewController.dataSourceLoadedWithNotification(_:)), name: NSNotification.Name(rawValue: TMSynchronizerHandlerSynchronizedNotificationKey), object: nil)
        
        emailTextField?.becomeFirstResponder()
    }
    
    func dataSourceLoadedWithNotification(_ notification: NSNotification) {
        
        // Transition to requets flow
        TMDeepLinkHandler.requestFlow()
        
        SVProgressHUD.dismiss()
    }
    
    // MARK: - TableView Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if DeviceType.IS_IPHONE_6P {
            return 100.0
        }
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            return 70.0
        }
        
        return 87.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = cellIdentifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TMCreateAccountCell
        
        cell?.delegate = self
        
        return cell!
    }
    
    // MARK: - Keyboard notifications
    
    override func keyboardWillShow(_ notification: NSNotification) {
        
        super.keyboardWillShow(notification)
        
        if validateSuccess {
            
            signInButton.isEnabled = true
        }
    }
    
    override func keyboardWillHide(_ notification: NSNotification) {
        
        super.keyboardWillHide(notification)
    }
    
    // MARK: - Actions
    
    @IBAction func dismissButtonPressed() {
        
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func onSignInButton(_ sender: UIButton) {
        
        if self.validateSuccess {
            
            let netman = TMNetworkingManager.shared
            
            SVProgressHUD.show()
            
            let email = onboardingModel.email!.lowercased()
            let password = onboardingModel.password!
            
            netman.promiseAuthenticate(email, password: password).then { response-> Promise<TMUser?> in
                
                self.view.endEditing(true)
                
                return TMUserAdapter.fetchMe()
                }.then { response-> Void in
                    
                    // Cleaning onboarding model
                    let consumerConfig = TMConsumerConfig.shared
                    consumerConfig.onboardingModel = nil
                    
                    netman.postLoginNotificaitonWithSuccess(true)
                    
                }.catch { error in
                    
                    SVProgressHUD.dismiss()
                    
                    JDStatusBarNotification.show(withStatus: "Wrong credentials", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
}


// MARK: - TableView Delegate

extension TMLoginViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 2 {
            
            self.performSegue(withIdentifier: "forgotPasswordSegue", sender: nil)
        }
        else {
            let cell = tableView.cellForRow(at: indexPath) as? TMCreateAccountCell
            cell?.textField?.becomeFirstResponder()
        }
    }
}

// MARK: - Text Field delegate

extension TMLoginViewController: TMCreateAccountCellDelegate {
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool) {
        if cell is TMEmailCell {
            
            onboardingModel.email = cell.textField?.text
            
            validateCheckForCell(cell, validationResult: success)
        } else if cell is TMPasswordCell {
            
            onboardingModel.password = cell.textField?.text
            
            validateCheckForCell(cell, validationResult: success)
        }
        
        if self.validatedCells.count == cellIdentifiers.count - 1 {
            
            validateSuccess = true
            
            signInButton.isEnabled = true
        } else {
            
            validateSuccess = false
            
            signInButton.isEnabled = false
        }
    }
    
    func validateCheckForCell(_ cell: TMCreateAccountCell, validationResult: Bool) {
        
        if validationResult {
            if !validatedCells.contains(cell) {
                validatedCells.append(cell)
            }
        } else {
            if validatedCells.contains(cell) {
                validatedCells.removeFirst(cell)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if emailTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
            passwordTextField?.becomeFirstResponder()
        } else if passwordTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
        }
        
        return false
    }
}
