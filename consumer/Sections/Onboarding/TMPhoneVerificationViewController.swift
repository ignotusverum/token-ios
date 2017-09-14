//
//  TMPhoneVerificationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import pop
import Analytics
import PromiseKit
import SVProgressHUD
import EZSwiftExtensions
import IQKeyboardManagerSwift
import JDStatusBarNotification

protocol TMPhoneVerificationViewControllerProtocol {
    func incorrectValidationCode()
}

class TMPhoneVerificationViewController: TMAccountValidationViewController {
    
    var onboardingModel: TMOnboardingModel?
    
    var verificationString: String?
    
    var allFieldsFilled = false
    
    var delegate: TMPhoneVerificationViewControllerProtocol?
    
    /// If the first validation attempt failed when entering a code into the verification fields.
   //fileprivate var firstValidationFailed = false
    
    @IBOutlet var resendCodeButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("VERIFY YOUR PHONE", color: UIColor.black)
        
        let phoneVerificationCellNib = UINib(nibName: "TMPhoneVerificationTableViewCell", bundle: nil)
        self.tableView.register(phoneVerificationCellNib, forCellReuseIdentifier: "TMPhoneVerificationTableViewCell")
        
        self.view.bringSubview(toFront: self.flatButton)
        self.view.bringSubview(toFront:self.resendCodeButton)
    }
    
    func keyboardDidShow(_ notification: NSNotification) {
        
        let keyboardBounds = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        if self.keyboardHeight == nil {
            self.keyboardHeight = keyboardBounds?.size.height
        }
    }
    
    // MARK: - TableView Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 170.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "TMPhoneVerificationTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! TMPhoneVerificationTableViewCell
        cell.delegate = self
        delegate = cell
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction override func backButtonPressed(_ sender: Any?) {
        
        self.popVC()
    }
    
    @IBAction func validatePhoneNumber() {
        
        // Track click
        TMAnalytics.trackEventWithID(.t_S3_2)
        
        SVProgressHUD.show()

        TMUserAdapter.validateToken(self.verificationString!, phoneNumber: self.onboardingModel!.phone!).then { result-> Void in
            
            if result == true {
                TMUserAdapter.register(params: self.onboardingModel!.dictionary).then { response-> Promise<TMUser?> in
                    
                    TMAnalytics.trackEventWithID(.t_S3_0, eventParams: TMAnalytics.traitsDict())
                    
                    return TMUserAdapter.fetchMe()
                    
                    }.then { response-> Void in
                        
                        let appDelegate = TMAppDelegate.appDelegate
                        
                        appDelegate!.setupSynchronizeAdapters(nil)
                        TMAnalytics.trackingIdentity()
                        
                        if let user = TMConsumerConfig.shared.currentUser {
                            // Alias deviceID + userID
                            SEGAnalytics.shared().alias(UIDevice.idForVendor() ?? "0", options: ["userID": user.id])
                        }
                        
                        self.view.endEditing(true)
                        
                        // Cleaning onboarding model
                        let consumerConfig = TMConsumerConfig.shared
                        consumerConfig.onboardingModel = nil
                        
                        // Transition to requets flow
                        TMDeepLinkHandler.requestFlow()
                        
                    }.always {
                        
                        SVProgressHUD.dismiss()
                    }.catch { error in
                        
                        self.delegate?.incorrectValidationCode()
                        
                        let _error = error as NSError
                        
                        if _error.localizedDescription.range(of: "invalid whitelist") != nil {
                            
                            // Handle not whitelisted user
                            self.whitelistPresentation()
                        }
                        else {
                            self.delegate?.incorrectValidationCode()
                            
                            JDStatusBarNotification.show(withStatus: _error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                            
                            // Account created error analytics
                            TMAnalytics.trackEventWithID(.t_S3_1, eventParams: ["errorStatus": 500, "message": "Submitting request error", "label": "Register user failure"])
                        }
                }
            } else {
                
                JDStatusBarNotification.show(withStatus: "Wrong Verification code, please check your code", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                
                // error handle
                SVProgressHUD.dismiss()
                
                // Account created error analytics
                TMAnalytics.trackEventWithID(.t_S3_1, eventParams: ["errorStatus": 500, "message": "Validation error", "label": "Wrong Validation Code"])
            }
            }.catch { error in
                self.delegate?.incorrectValidationCode()
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                
                SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Actions
    // Whitelist check
    func whitelistPresentation() {
        
        let whitelistedVC = TMWhiteListViewController(nibName: "TMWhiteListViewController", bundle: nil)
        
        let popup = PopupDialog(viewController: whitelistedVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: false)
        
        whitelistedVC.closeSelected {
            
            popup.dismiss()
        }
        
        whitelistedVC.inviteSelected {
            
            UIApplication.shared.openURL(URL(string: "http://token.ai")!)
        }
        
        self.presentVC(popup)
    }
    
    @IBAction func resendCodeButtonPressed() {
        
        TMUserAdapter.generatePhoneValidation((self.onboardingModel!.phone)!).then { response in
            
            self.showOneButtonAlertController("Phone Verification", message: "Please check your message for new code", cancelButtonText: "Ok")
            
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: "Something went wrong, please try again later", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}

extension TMPhoneVerificationViewController: TMPhoneVerificationTableViewCellDelegate {
    
    func phoneVerificationFiledsFilled(_ filled: Bool, string: String?) {
        
        if filled {
            resendCodeButton.isHidden = true
            
            self.verificationString = string
            
            validatePhoneNumber()

            self.allFieldsFilled = true
            
        }
        else {
            resendCodeButton.isHidden = false
            
            self.allFieldsFilled = false
        }
    }
}

