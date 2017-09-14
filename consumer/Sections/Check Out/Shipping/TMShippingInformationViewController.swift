//
//  TMShippingInformationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/13/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import SVProgressHUD
import EZSwiftExtensions
import JDStatusBarNotification

enum ShippingInformationStyle {
    
    case addressSelection
    case addressEditing
    case addressAdding
}

class TMShippingInformationViewController: UIViewController {
    
    // View to select address.
    @IBOutlet weak var addressView: UIView!
    
    // Address Request
    var request: TMRequest?
    
    // Selected address
    var selectedAddress: TMContactAddress?
    
    // Container view controller
    var containerViewController: TMAddressContainerViewController?
    
    // Contacts selection view
    var contactsSelectionView: TMContactsSelectionView!
    
    // Selected Contact
    var contact: TMContact?
    
    // Appearance Style
    var shippingInfoStyle: ShippingInformationStyle = .addressSelection
    
    // Address Prams For request
    var paramsForRequest: [String: Any]?
    
    // Next button
    fileprivate lazy var nextButton: UIButton = {
        let button = UIButton.button(style: .alternateBlack)
        
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        return button
    }()
    
    /// True if the next button be displayed.
    var loadedFromConfirmationViewController = false
    
    var shipToRecipient = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // Controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s11)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loadedFromConfirmationViewController {
            navigationBarColor = view.backgroundColor
        }
        
        // Check Status
        checkRequestStatus()
        
        populateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("DELIVERY")
        
        self.customInit()
        
        if loadedFromConfirmationViewController {
            nextButton.isHidden = true
            containerViewController?.addressTableViewController?.onAddressSelect = {
                
                // Analytics
                TMAnalytics.trackEventWithID(.t_S11_0, eventParams: ["shipToRecipient": self.shipToRecipient])
                
                if let address = self.selectedAddress, let cart = self.request?.cart {
                    
                    TMCartAdapter.setAddress(cart: cart, address: address).then { response-> Void in
                        
                        self.popVC()
                        
                        }.catch { error in
                            
                            JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                    }
                }
                else {
                    
                    JDStatusBarNotification.show(withStatus: "Please select an address", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }
        }
        else {
            containerViewController?.addressAddingViewContoller?.tableViewFooterHeight = nextButton.bounds.height
        }
        
        self.populateUI()
        
        view.addSubview(addressView)
        
        view.addSubview(nextButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: nextButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66),
            NSLayoutConstraint(item: nextButton, attribute: .top, relatedBy: .equal, toItem: addressView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    
    func populateUI() {
        
        guard let address = self.request?.cart?.address else {
            return
        }
        
        if let contact = address.contact {
            
            contactsSelectionView.contactButtonPressed(contact)
        }
        else {
            
            contactsSelectionView.currentProfileButtonPressed()
        }
        
        containerViewController?.selectedAddress = address
    }
    
    func showStatusBarBorder() -> Bool {
        return true
    }
    
    func checkRequestStatus() {
        
        if self.request?.status != .selection && self.request?.status != .pending  {
            
            self.dismissVC(completion: nil)
        }
    }
    
    // Custom controller setup
    func customInit() {
        // Safety check
        guard let _request = request else {
            return
        }
        
        // Setting contact object
        self.contactsSelectionView.contact = _request.contact
        
        self.contactsSelectionView.delegate = self
        
        // Setting current user object
        let config = TMConsumerConfig.shared
        self.contactsSelectionView.currentContact = config.currentUser
        
        self.contactsSelectionView.currentProfileButtonPressed()
    }
    
    // Pop VC
    @IBAction override func backButtonPressed(_ sender: Any?) {
        
        // Checking style to define action
        if self.shippingInfoStyle == .addressSelection {
            
            self.popVC()
        }
            // Cancel adding/editing - switch to selecting
        else {

            self.containerViewController?.swapToAddressTable(withState: .canceled)
        }
    }
    
    // Next Button
    func onNextButton(_ sender: AnyObject) {
        
        // Checking state
        if self.shippingInfoStyle == .addressAdding {
            
            // Checking if contact != nil, if == nil then we're adding to current user
            guard let _contact = self.contact else {
                
                SVProgressHUD.show()
                
                // Calling child controller method to add address
                self.containerViewController?.promiseAddAddressForCurrentUser().then { result-> Promise<[TMContactAddress]> in
            
                    return TMUserAdapter.fetchAddressList()
                    
                    }.then { response-> Void in
                     
                        SVProgressHUD.dismiss()
                        
                        self.reloadContainerCheck()
                        
                        if self.loadedFromConfirmationViewController {
                            
                            self.popVC()
                        }
                        
                        return
                    }.catch { error in
                        
                        SVProgressHUD.dismiss()
                }
                
                
                return
            }
            
            SVProgressHUD.show()
            self.containerViewController?.promiseCheckAndSubmitForContact(contact: _contact).then { result-> Void in
                
                SVProgressHUD.dismiss()
                
                self.reloadContainerCheck()
                
                if self.loadedFromConfirmationViewController {

                    self.popVC()
                }
                
                
            }.catch { error in
                
                SVProgressHUD.dismiss()
            }
        }
        else {
            
            // Analytics
            TMAnalytics.trackEventWithID(.t_S11_0, eventParams: ["shipToRecipient": self.shipToRecipient])
            
            if let address = self.selectedAddress, let cart = self.request?.cart {
                
                SVProgressHUD.show()
                
                TMCartAdapter.setAddress(cart: cart, address: address).then { response-> Promise<UIViewController?> in
                 
                    return TMOrderDetailsRouteHandler.orderDetails(for: cart)
                    }.then { resultController-> Void in
                        
                        SVProgressHUD.dismiss()
                        
                        guard let controller = resultController else {
                            
                            JDStatusBarNotification.show(withStatus: "Error: 1000, please try again", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                            return
                        }
                        
                        self.pushVC(controller)
                        
                        
                        
                    }.catch { error in
                        
                        JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                        SVProgressHUD.dismiss()
                }
            }
            else {
                
                JDStatusBarNotification.show(withStatus: "Please select an address", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
    
    // Segue logic overriding
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embedContainer" {
            self.containerViewController = segue.destination as? TMAddressContainerViewController
            
            self.containerViewController?.delegate = self
        }
    }
    
    // Utilities
    // Changing navigation bar button icon
    func changeNavigationBarButtonItem() {
        
        // Cleaning old buttons
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        // Creating custom left button for nav bar
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        backButton.addTarget(self, action: #selector(TMShippingInformationViewController.backButtonPressed(_:)), for: .touchUpInside)
        
        // Setting custom left button for nav bar
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = backButton
        
        if self.shippingInfoStyle == .addressSelection {
            
            backButton.setImage(UIImage(named: "backButton"), for: .normal)
        }
        else {
            
            backButton.setImage(UIImage(named: "closeButton"), for: .normal)
        }
        
        // Setting navbar
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    // reload container check
    func reloadContainerCheck() {
        
        if self.shippingInfoStyle != .addressSelection {
            self.containerViewController?.swapToAddressTable(withState: .normal)
        }
    }
    
    // Unwind segue
    @IBAction func unwindToShippingInformation(_ segue: UIStoryboardSegue) { }
}

// MARK: - Address container delegate methods
extension TMShippingInformationViewController: TMAddressContainerViewControllerDelegate {
    
    // Switched to add address controller
    func containerSwitchedToAddAddress() {
        
        self.shippingInfoStyle = .addressAdding
        
        // Updating navigation
        self.changeNavigationBarButtonItem()
        
        if loadedFromConfirmationViewController {
            nextButton.isHidden = false
            
            nextButton.setTitle("Done", for: .normal)
            containerViewController?.addressAddingViewContoller?.tableViewFooterHeight = nextButton.bounds.height
        }
    }
    
    // Switched to address table controller
    func containerSwitchedToAddressTable() {
        
        self.shippingInfoStyle = .addressSelection
        
        // Updating navigation
        self.changeNavigationBarButtonItem()
        
        if loadedFromConfirmationViewController {
            nextButton.isHidden = true
        }
    }
    
    // State picker did show
    func statePickerDidShow() {
        self.nextButton.isHidden = true
    }
    
    // State picker did hide
    func statePickerDidHide() {
        self.nextButton.isHidden = false
    }
    
    // Address selection delegame method
    func didSelectAddress(_ address: TMContactAddress) {
        self.selectedAddress = address
    }
}

extension TMShippingInformationViewController: TMContactsSelectionViewDelegate {
    
    func contactButtonPressed()  {
        
        guard let _contact = self.request?.contact else {
            return
        }
        
        // Reloading table with new datasource
        guard let _containerConroller = self.containerViewController else {
            return
        }
        
        selectedAddress = nil
        
        self.shipToRecipient = true
        
        _containerConroller.selectedContact = _contact
        _containerConroller.selectedUser = nil
        
        self.contact = _contact
        
        // Check if needs to reload to address selection
        self.reloadContainerCheck()
    }
    
    func currentUserButtonPressed() {
        
        let config = TMConsumerConfig.shared
        
        // Reloading table with new datasource
        guard let _containerConroller = self.containerViewController else {
            return
        }
        
        selectedAddress = nil
        
        self.shipToRecipient = false
        
        let user = config.currentUser
        
        _containerConroller.selectedUser = user
        _containerConroller.selectedContact = nil
        
        self.contact = nil
        
        // Check if needs to reload to address selection
        self.reloadContainerCheck()
    }
}
