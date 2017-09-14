//
//  TMAccountViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import SVProgressHUD
import AlamofireImage
import EZSwiftExtensions
import JDStatusBarNotification

class TMAccountViewController: TMAccountValidationViewController {
    
    // Reusable cell identifiers
    let cellIdentifiers = ["TMProfileImageTableViewCell", "TMDoubleNameCell", "TMEmailCell", "TMPhoneCell"]
    
    // Validation logic
    var validatedCells = [TMCreateAccountCell]()
    var validateSuccess = false
    
    var onboardingModel = TMOnboardingModel()
    
    // Image picker controller
    var imagePicker = UIImagePickerController()
    var profileImageView: UIImageView?
    
    // MARK: - Controller lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s18)
        
        ez.runThisAfterDelay(seconds: 0.1) {
            
            self.populateData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addTitleText("ACCOUNT", color: UIColor.white)
        
        self.resetNavbar()
        
        // Setting custom content inset
        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI initialization
    
    func populateData() {
        
        let config = TMConsumerConfig.shared
        
        let currentUser = config.currentUser!
        
        self.firstNameTextField?.text = currentUser.firstName
        self.lastNameTextField?.text = currentUser.lastName
        
        self.emailTextField?.text = currentUser.email
        
        if let profileImageURL = currentUser.profileURLString {
            
            self.profileImageView?.downloadImageFrom(link: URL(string: profileImageURL), contentMode: .scaleAspectFill)
        }
        
        do {
            
            let phoneNumberKit = PhoneNumberKit()
            
            let numberPhone = try phoneNumberKit.parse(currentUser.phoneNumberRaw!)
            
            let countryCodeNumber = numberPhone.countryCode
            var countryCode = phoneNumberKit.mainCountry(forCode: countryCodeNumber)
            
            if let countryCode = countryCode {
                
                self.countryCode = countryCode
                self.countryInput?.setSelectedCountryCode(countryCode, animated: false)
                
                self.rawPhoneInput = currentUser.phoneNumberRaw
                
                let format1 = currentUser.phoneNumberFormatted!.replacingOccurrences(of: "(", with: "")
                let format2 = format1.replacingOccurrences(of: ") ", with: ".")
                let format3 = format2.replacingOccurrences(of: "-", with: ".")
                
                self.phoneNumberTextField!.text = format3
                
                self.phoneNumberTextField?.defaultRegion = countryCode
            }
            else {
                
                let locale = NSLocale.current as NSLocale
                countryCode = locale.object(forKey: .countryCode) as? String
            }
        }
        catch {
            
            print("line 122 account section")
        }
    }
    
    // MARK: - TableView Delegates Override
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let config = TMConsumerConfig.shared
        let currentUser = config.currentUser
        
        if indexPath.row == 0 {
            
            let cellIdentifier = self.cellIdentifiers[indexPath.row]
            let buttonCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TMProfileImageTableViewCell
            buttonCell.delegate = self
            
            let config = TMConsumerConfig.shared
            let user = config.currentUser
            
            if let image = user?.userImage {
                
                buttonCell.profileImage.image = image
                self.profileImageView = buttonCell.profileImage
            }
            
            buttonCell.user = user
            
            return buttonCell
        }
        else {
            
            let cellIdentifier = self.cellIdentifiers[indexPath.row]
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TMCreateAccountCell
            cell?.validationLineSelectedColor = UIColor.TMPinkColor

            if indexPath.row == 1 {
                
                let fullNameCell = cell as? TMDoubleCreateAccountCell
                fullNameCell?.textField?.text = currentUser?.firstName
                fullNameCell?.textFieldSecond.text = currentUser?.lastName
                fullNameCell?.delegate = self

                self.firstNameTextField = fullNameCell?.textField
                
                self.lastNameTextField = fullNameCell?.textFieldSecond
                
                cell = fullNameCell!
            }
            else if indexPath.row == 2 {
                
                self.emailTextField = cell?.textField
                
                cell?.textField?.text = currentUser?.email
            }
            else if indexPath.row == 3 {
                
                let phoneCell = cell as? TMPhoneTableViewCell
                
                phoneNumberTextField = cell?.textField
                
                self.phoneNumberCell = phoneCell
                
                self.countryInput = phoneCell?.countryInput
                self.countryInput?.delegate = self
                
                self.countryInput?.viewForPicker = self.view
                
                self.countryInput?.delegate = self
                
                cell?.textField?.text = currentUser?.phoneNumberFormatted
                
                cell = phoneCell!
            }
            
            cell!.delegate = self
            cell?.placeholderColor = UIColor.TMGrayPlaceholder
            
            return cell!
        }
    }
    
    // MARK: - Keyboard logic
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if self.firstNameTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
            self.lastNameTextField?.becomeFirstResponder()
        }
        else if self.lastNameTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
            self.emailTextField?.becomeFirstResponder()
        }
        else if self.emailTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
            self.passwordTextField?.becomeFirstResponder()
        }
        else if self.passwordTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
            self.phoneNumberTextField?.becomeFirstResponder()
        }
        else if self.phoneNumberTextField?.isFirstResponder == true {
            
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func updateProfileButtonPressed(_ sender: Any) {
        
        do {
            let phoneNumberKit = PhoneNumberKit()
            
            let phone = try phoneNumberKit.parse(self.phoneNumberTextField!.text!, withRegion: self.countryCode)
            
            let phoneNumber = phoneNumberKit.format(phone, toType: .e164)
            
            let paramsDictionary = ["first_name": (self.firstNameTextField?.text)!, "last_name": (self.lastNameTextField?.text)!, "phone_number": phoneNumber, "email": (self.emailTextField?.text)!]
            
            TMUserAdapter.update(paramsDictionary).catch { error in
                
                SVProgressHUD.dismiss()
            }
        }
        catch { }
        
        TMUserAdapter.fetchMe().catch { error-> Void in
            print(error)
        }
        
        // Hide keyboard
        self.view.endEditing(true)
        
        self.popVC()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    override func countryInputWillHide(_ picker: TMCountryInput!) {
        
        phoneNumberCell?.countryCode = picker.selectedCountryCode
        
        if picker.selectedCountryCode != self.countryCode {
            
            validateSuccess = false
            phoneNumberTextField?.attributedPlaceholder = "".color(UIColor.TMGrayPlaceholder)
        }

        super.countryInputWillHide(picker)
    }
}

extension TMAccountViewController: TMCreateAccountCellDelegate {
    
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
        
        if self.validatedCells.count == self.cellIdentifiers.count {
            
            self.validateSuccess = true
        }
        else {
            
            self.validateSuccess = false
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
    
    func textEditingDidEnd(_ textField: UITextField) {
        
    }
    
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

extension TMAccountViewController: TMProfileImageTableViewCellDelegate {
    
    internal func profileImageButtonPressed(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension TMAccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row != 0 {
            
            if DeviceType.IS_IPHONE_6P {
                return 100.0
            }
            
            if DeviceType.IS_IPHONE_5 {
                
                return 70.0
            }
            
            return 87.0
        }
        
        return 181.0
    }
}

extension TMAccountViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            // Post request
        })
        
        // Set image
        SVProgressHUD.show()
        
        let netman = TMNetworkingManager.shared
        netman.upload(.post, "me/image", image: image).then { result-> Void in
         
            TMUserAdapter.fetchMe().then { user-> Void in
    
                if let resultMessage = result["message"].string {
                    
                    JDStatusBarNotification.show(withStatus: resultMessage, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
                else {
                    
                    if let imageIdentifier = user?.profileURLString {
                        
                        let imageCache = AutoPurgingImageCache()
                        imageCache.add(image, withIdentifier: imageIdentifier)
                    }
                    
                    user?.userImage = image
                    self.profileImageView?.image = image
                    
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
                
                SVProgressHUD.dismiss()
                
                }.catch { error-> Void in
                    SVProgressHUD.dismiss()
            }
            }.catch { error-> Void in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                SVProgressHUD.dismiss()
        }
    }
}
