//
//  TMCreateAccountViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import pop
import SVProgressHUD
import EZSwiftExtensions
import IQKeyboardManagerSwift
import JDStatusBarNotification

class TMCreateAccountViewController: TMAccountValidationViewController {
    
    // MARK: - View Controller lifecycle
    
    var validatedCells = [TMCreateAccountCell]()
    var validateSuccess = false
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            
            let text = titleLabel.text!.setCharSpacing(1.2)
            self.titleLabel.attributedText = text
        }
    }
    
    var onboardingModel = TMOnboardingModel()
    
    let cellIdentifiers = ["TMDoubleNameCell", "TMEmailCell", "TMPhoneCell", "TMPasswordCell", "TMTermsCell"]
    
    // MARK: - Analytics
    let backAnalytics: [String: Any] = ["CTA": "Back", "screen": "Signup", "type": "type"]
    
    fileprivate lazy var createAccountButton: UIButton = {
        let button = UIButton.button(style: .black)
        
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = TMConsumerConfig.shared
        if let onboardingModel = config.onboardingModel {
            
            self.onboardingModel = onboardingModel
        }
        
        self.addTitleText("SIGN UP", color: UIColor.black)
        
        guard var navigationBar = navigationController?.navigationBar else {
            return
        }
        
        configureNavigationBar(navigationBar: &navigationBar)
        
        //---Get Started Button---//
        
        createAccountButton.isEnabled = false

        view.addSubview(createAccountButton)
        
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: createAccountButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -40),
            NSLayoutConstraint(item: createAccountButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: createAccountButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 94 / 187, constant: 0),
            NSLayoutConstraint(item: createAccountButton, attribute: .height, relatedBy: .equal, toItem: createAccountButton, attribute: .width, multiplier: 34 / 94, constant: 0)
            ])
    }
    
    override func setupViewConroller() {
        super.setupViewConroller()
        
        self.nameCell = self.tableView?.cellForRow(at:IndexPath(row: 0, section: 0)) as? TMDoubleCreateAccountCell
        self.emailCell = self.tableView?.cellForRow(at:IndexPath(row: 1, section: 0)) as? TMCreateAccountCell
        self.passwordCell = self.tableView?.cellForRow(at:IndexPath(row: 2, section: 0)) as? TMCreateAccountCell
        
        self.firstNameTextField = self.nameCell?.textField
        self.lastNameTextField = self.nameCell?.textFieldSecond
        
        self.emailTextField = self.emailCell?.textField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 10.0
        
        if validateSuccess {
           createAccountButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        createAccountButton.isEnabled = false
        
        navigationController?.navigationBar.hideBottomHairline()
        
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 10.0
    }
    
    func doneButton() {
        if validateSuccess {
            
            self.registerNewUser()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    // MARK: - Keyboard notifications
    
    override func keyboardWillShow(_ notification: NSNotification) {
        
        super.keyboardWillShow(notification)
    }
    
    override func keyboardWillHide(_ notification: NSNotification) {
        
        super.keyboardWillHide(notification)
    }
    
    // MARK: - TableView Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.cellIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == self.cellIdentifiers.count - 1 {
            
            if DeviceType.IS_IPHONE_5 {
                return 100.0
            }
            
            return 125.0
        }
        
        if DeviceType.IS_IPHONE_6P {
            return 100.0
        }
        
        if DeviceType.IS_IPHONE_5 {
            
            return 70.0
        }
        
        return 87.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = self.cellIdentifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TMCreateAccountCell

        cell?.placeholderColor = UIColor.TMContactsTextColor
        
        switch indexPath.row {
        case 0:
            
            let fullNameCell = cell as? TMDoubleCreateAccountCell
            fullNameCell?.textField?.text = self.onboardingModel.firstName
            fullNameCell?.textFieldSecond.text = self.onboardingModel.lastName
            
            if TMInputValidation.isValidName(self.onboardingModel.firstName) && TMInputValidation.isValidName(self.onboardingModel.lastName) {
                
                self.validateCheckForCell(fullNameCell!, validationResult: true)
            }
            
        case 1:
            
            if TMInputValidation.isValidEmail(self.onboardingModel.email) {
                
                cell?.textField?.text = self.onboardingModel.email
                
                self.validateCheckForCell(cell!, validationResult: true)
            }
            
        case 2:
            
            if let phone = self.onboardingModel.phone, let countryString = self.onboardingModel.countryString {
                
                if TMInputValidation.isValidPhone(phone, countryCode: countryString) {
                    
                    let phoneKit = PhoneNumberKit()
                    
                    let index = phone.index(phone.startIndex, offsetBy: 2)
                    let phoneNumber = phone.substring(from: index) //Removes first two characters to display which are +'country code'
                    
                    let partialFormatter = PartialFormatter(phoneNumberKit: phoneKit, defaultRegion: countryString)
                    let formatNumber = partialFormatter.formatPartial(phoneNumber)
                    
                    cell?.textField?.text = formatNumber
                    
                    self.validateCheckForCell(cell!, validationResult: true)
                }
            }
            
            let phoneCell = cell as? TMPhoneTableViewCell
            
            self.phoneNumberCell = phoneCell
            
            phoneCell?.delegate = self
            self.phoneNumberTextField = phoneCell?.textField
            
            self.countryInput = phoneCell?.countryInput
            self.countryInput?.delegate = self
            
            self.countryInput?.viewForPicker = self.view
            
            self.countryInput?.delegate = self
            self.countryInput?.updateStyle(true)
            
            return phoneCell!
            
        case 3:
            
            passwordTextField = cell?.textField
            
        default:
            print("default cell logic")
        }
        
        cell?.delegate = self
        
        return cell!
    }
    
    // MARK: - Navigation delegates
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "phoneValidatoinSegue" {
            
            let phoneVerificationController = segue.destination as! TMPhoneVerificationViewController
            phoneVerificationController.onboardingModel = self.onboardingModel
        }
    }
    
    // MARK: - Actions
    override func backButtonPressed(_ sender: Any?) {
        
        let config = TMConsumerConfig.shared
        config.onboardingModel = onboardingModel
        
        self.view.endEditing(true)
        
        self.popVC()
        
        TMAnalytics.trackEventWithID(.t_S2_0)
    }
    
    @IBAction func registerNewUser() {
        
        // track
        TMAnalytics.trackEventWithID(.t_S2_1)
        
        if validateSuccess {
            
            self.view.endEditing(true)
            
            TMUserAdapter.usernameCheck(self.emailTextField!.text!).then { result-> Void in
                
                let consumerConfig = TMConsumerConfig.shared
                consumerConfig.onboardingModel = self.onboardingModel
                
                if result == .avaliable {
                    
                    SVProgressHUD.show()
                    
                    TMUserAdapter.generatePhoneValidation(self.onboardingModel.phoneInternational!).then { response-> Void in
                        
                        self.performSegue(withIdentifier:"phoneValidatoinSegue", sender: nil)
                        
                        SVProgressHUD.dismiss()
                        }.catch { error-> Void in
                            
                            SVProgressHUD.dismiss()
                            JDStatusBarNotification.show(withStatus: "Wrong information", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                    }
                }
                else if result == .unavaliable {
                    
                    JDStatusBarNotification.show(withStatus: "Email is not avaliable", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
                
                }.catch { error-> Void in
                    
                    SVProgressHUD.dismiss()
                    JDStatusBarNotification.show(withStatus: "Wrong information", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
        else {
            
            JDStatusBarNotification.show(withStatus: "Wrong information", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    override func countryInputWillHide(_ picker: TMCountryInput!) {
        
        phoneNumberCell?.countryCode = picker.selectedCountryCode
        
        if picker.selectedCountryCode != self.countryCode {
            
            validateSuccess = false
            onboardingModel.phone = ""
            onboardingModel.countryString = picker.selectedCountryCode
        }
        
        if validateSuccess {
            
            createAccountButton.isEnabled = false

        }
        else {
            
            createAccountButton.isEnabled = false
        }
        
        super.countryInputWillHide(picker)
    }
}

// MARK: - UITableViewDelegate
extension TMCreateAccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Terms index path
        if indexPath.row == cellIdentifiers.count - 1 {
            
            let termsNavigation = UIViewController.viewControllerFromStoryboard("Terms", controllerIdentifier: "termsViewControllerNavigation") as? UINavigationController
            
            let termsController = termsNavigation?.topViewController as? TMTermsViewController
            termsController?.presentedFromMenu = false
            
            if let termsNavigation = termsNavigation {
                self.presentVC(termsNavigation)
            }
        }
        else {
            
            let cell = tableView.cellForRow(at: indexPath) as? TMCreateAccountCell
            
            if !(cell is TMDoubleCreateAccountCell) {
                cell?.textField?.becomeFirstResponder()
            }
        }
    }
}

extension TMCreateAccountViewController: TMCreateAccountCellDelegate {
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool) {
        
        if cell is TMDoubleCreateAccountCell {
            
            let doubleCell = cell as? TMDoubleCreateAccountCell
            
            self.onboardingModel.firstName = doubleCell?.textField?.text
            self.onboardingModel.lastName = doubleCell?.textFieldSecond.text
            
            self.validateCheckForCell(cell, validationResult: success)
        }
        if cell is TMEmailCell {
            
            self.onboardingModel.email = cell.textField?.text
            
            self.validateCheckForCell(cell, validationResult: success)
        }
        if cell is TMPasswordCell {
            
            self.onboardingModel.password = cell.textField?.text
            
            self.validateCheckForCell(cell, validationResult: success)
        }
        if cell is TMPhoneTableViewCell {
            
            let phoneCell = cell as? TMPhoneTableViewCell
            
            self.onboardingModel.phone = phoneCell?.phoneNumber
            self.onboardingModel.countryString = phoneCell?.countryCode
            
            self.validateCheckForCell(cell, validationResult: success)
        }
        
        if self.validatedCells.count == self.cellIdentifiers.count - 1 {
            
            self.validateSuccess = true
            
            self.createAccountButton.isEnabled = true
        }
        else {
            
            self.validateSuccess = false
            
            self.createAccountButton.isEnabled = false
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
    
    func textEditingDidBegin(_ textField: UITextField) {
        
        self.countryInput?.dismissPicker(false)
    }
    
    func textEditingDidEnd(_ textField: UITextField) { }
    
    func textShouldChangeCharacter(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) {
        
        if self.countryInput?.pickerOpen == true {
            self.countryInput?.dismissPicker(false)
        }
    }
    
    func textShouldReturn(_ textField: UITextField) {
        
        if self.firstNameTextField?.isFirstResponder == true {
            
            self.lastNameTextField?.becomeFirstResponder()
        }
        else if self.lastNameTextField?.isFirstResponder == true {
            
            self.emailTextField?.becomeFirstResponder()
        }
        else if self.emailTextField?.isFirstResponder == true {
            
            self.passwordTextField?.becomeFirstResponder()
        }
        else if self.phoneNumberTextField?.isFirstResponder == true {
            
            self.passwordCell?.becomeFirstResponder()
        }
        else if self.passwordTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
        }
    }
}

// MARK: - Private configurators
private extension TMCreateAccountViewController {
    
    /// Configures navigation bar properties.
    ///
    /// - Parameter navigationBar: Navigation bar for which to configure properties.
    func configureNavigationBar(navigationBar: inout UINavigationBar) {
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: .default), for: .default)
        navigationBar.barTintColor = UIColor.TMColorWithRGBFloat(249, green: 249, blue: 249, alpha: 1)
        navigationBar.isTranslucent = false
    }
}
