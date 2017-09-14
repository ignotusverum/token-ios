//
//  TMForgotPasswordViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import SVProgressHUD
import JDStatusBarNotification

class TMForgotPasswordViewController: TMAccountValidationViewController {
    
    // Cell identifiers datasource
    let cellIdentifiers = ["TMDescriptionCell", "TMPhoneCell"]
    
    var validation = false
    
    fileprivate lazy var continueButton: UIButton = {
        let button = UIButton.button(style: .black)
        
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(onContinueButton), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s24)
        
        if validation {
            continueButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("NEW PASSWORD", color: UIColor.black)
        
        if !DeviceType.IS_IPHONE_5 {
            self.tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        
        view.addSubview(tableView)
        
        //---Continue Button---//
        
        view.addSubview(continueButton)
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: continueButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: continueButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: continueButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 94 / 187, constant: 0),
            NSLayoutConstraint(item: continueButton, attribute: .height, relatedBy: .equal, toItem: continueButton, attribute: .width, multiplier: 34 / 94, constant: 0)
            ])
        
        continueButton.isEnabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func showStatusBarBorder() -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifiers[indexPath.row])!
        
        if indexPath.row == 1 {
            
            if self.countryInput == nil {
                
                let phoneCell = cell as? TMPhoneTableViewCell
                
                phoneNumberTextField = phoneCell?.textField
                
                self.countryInput = phoneCell?.countryInput
                self.countryInput?.delegate = self
                
                phoneCell?.delegate = self
                
                cell = phoneCell!
            }
        }
        
        return cell
    }
    
    // MARK: - Utility
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changePasswordSegue" {
            
            let controller = segue.destination as? TMForgotPasswordValidationViewController
            controller?.phoneNumber = self.phoneNumber
        }
    }
    
    // MARK: - Actions
    func onContinueButton(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        TMUserAdapter.generatePhoneToken(self.phoneNumber!).then { result-> Void in
            
            SVProgressHUD.dismiss()
            
            if result! {
                
                self.performSegue(withIdentifier:"changePasswordSegue", sender: nil)
            }
            else {
                
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
            }.catch { error-> Void in
                
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    override func backButtonPressed(_ sender: Any?) {
        
        self.popVC()
    }
}

extension TMForgotPasswordViewController: TMCreateAccountCellDelegate {
    
    func validationSuccessForCell(_ cell: TMCreateAccountCell, success: Bool) {
        if cell is TMPhoneTableViewCell {
            
            let phoneCell = cell as? TMPhoneTableViewCell
            
            if let phoneCell = phoneCell {
                self.phoneNumber = phoneCell.phoneNumber
                self.countryCode = phoneCell.countryCode
                
                self.validation = success
                
                if success {
                    
                    continueButton.isEnabled = true
                }
                else {
                    continueButton.isEnabled = false
                }
            }
        }
    }
}

// MARK: - TableView Delegate
extension TMForgotPasswordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            
            if DeviceType.IS_IPHONE_6P {
                return 120.0
            }
            
            if DeviceType.IS_IPHONE_5 {
                
                return 70.0
            }
            
            return 85.0
        }
        
        if DeviceType.IS_IPHONE_6P {
            return 90.0
        }
        
        if DeviceType.IS_IPHONE_5 {
            return 65.0
        }
        
        return 70.0
    }
}
