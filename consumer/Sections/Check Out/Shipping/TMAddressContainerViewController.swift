//
//  TMAddressContainerViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/25/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit

protocol TMAddressContainerViewControllerDelegate {
    // switching to address table controller
    func containerSwitchedToAddressTable()
    // switching to add addresss controller
    func containerSwitchedToAddAddress()
    
    // State picker did show
    func statePickerDidShow()
    // State picker did hide
    func statePickerDidHide()
    
    // Did select address
    func didSelectAddress(_ address: TMContactAddress)
}

class TMAddressContainerViewController: UIViewController {

    // Selected address - Refactor
    var selectedAddress: TMContactAddress? {
        didSet {
            
            guard let _addressTable = self.addressTableViewController else {
                return
            }
            
            _addressTable.selectedAddress = selectedAddress
        }
    }
    
    // First segue
    let addressTableSegueIdentifier = "TMAddressTableSegue"
    
    // Second segue
    let addressAddingSegueIdentifier = "TMAddAddressSegue"
    
    // Current segue id
    var currentSegueIdentifier: String?
    
    // Address table view controller - first
    var addressTableViewController: TMAddressTableViewController?
    
    // Adress Adding view controller - second
    var addressAddingViewContoller: TMNewAddressViewController?
    
    // Delegate
    var delegate: TMAddressContainerViewControllerDelegate?
    
    // Selected DataSource
    // Selected datasource (current user - recepient)
    var selectedUser: TMUser? {
        didSet {
            
            guard let _addressTable = self.addressTableViewController else {
                return
            }
            
            _addressTable.selectedUser = selectedUser
        }
    }
    
    var selectedContact: TMContact? {
        didSet {
            guard let _addressTable = self.addressTableViewController else {
                return
            }
            
            _addressTable.selectedContact = selectedContact
        }
    }

    // Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup controllers for switching
        self.addressTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "addressTableController") as? TMAddressTableViewController
        
        self.addressAddingViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "newAddressController") as? TMNewAddressViewController
        
        self.currentSegueIdentifier = addressTableSegueIdentifier
        self.performSegue(withIdentifier:self.currentSegueIdentifier!, sender: nil)
    }
    
    // Segue logic overriding
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == self.addressTableSegueIdentifier {
            self.addressTableViewController = segue.destination as? TMAddressTableViewController
            self.addressTableViewController!.delegate = self
        }
        
        if segue.identifier == addressAddingSegueIdentifier {

            self.addressAddingViewContoller = segue.destination as? TMNewAddressViewController
        }
        
        // If we're doing the first view controller
        if segue.identifier == addressTableSegueIdentifier {
            
            // If it's not the first time we're loading this
            if self.childViewControllers.count > 0 {
                self.swaptFromViewController(self.childViewControllers[0], toViewController: self.addressTableViewController!)
            }
            else {
                // If this the very first time we're loading this, we need to do initial load
                self.addChildViewController(segue.destination)
                
                let destView = segue.destination.view
                destView?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frameWidth(), height: self.view.frameHeight())
                self.view.addSubview(destView!)
                segue.destination.didMove(toParentViewController: self)
            }
        }
            // swap second
        else if segue.identifier == self.addressAddingSegueIdentifier {
            self.swaptFromViewController(self.childViewControllers[0], toViewController: self.addressAddingViewContoller!)
        }
    }
    
    // Swapping logic
    func swaptFromViewController(_ fromController: UIViewController, toViewController: UIViewController) {
        
        toViewController.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        fromController.willMove(toParentViewController: nil)
        self.addChildViewController(toViewController)
        
        self.transition(from: fromController, to: toViewController, duration: 0.0, options: .transitionCrossDissolve, animations: nil) { finished in
            fromController.removeFromParentViewController()
            toViewController.didMove(toParentViewController: self)
        }
    }
    
    // Swap to first one
    func swapToAddressTable(withState state: AddressViewControllerState = .normal) {
        
        currentSegueIdentifier = addressTableSegueIdentifier
        
        // Call delegate method to trigger UI updates
        delegate?.containerSwitchedToAddressTable()
        
        guard let addressAddingViewContoller = addressAddingViewContoller else {
            performSegue(withIdentifier: currentSegueIdentifier!, sender: nil)
            return
        }
        
        guard let addressTableViewController = addressTableViewController else {
            print("AddressTableViewController is nil")
            return
        }
        
        addressAddingViewContoller.state = state
        addressAddingViewContoller.stateDidChange()
        swaptFromViewController(addressAddingViewContoller, toViewController: addressTableViewController)
        return
    }
    
    // Swapping to second one
    func swapToAddAddress() {
        
        self.currentSegueIdentifier = self.addressAddingSegueIdentifier
        
        // Call delegate method to trigger UI updates
        self.delegate?.containerSwitchedToAddAddress()
        
        if self.addressTableViewController != nil {
            self.swaptFromViewController(self.addressTableViewController!, toViewController: self.addressAddingViewContoller!)
            return
        }
        
        self.performSegue(withIdentifier:self.currentSegueIdentifier!, sender: nil)
    }
    
    // Validate And Submit Address for current user
    func promiseAddAddressForCurrentUser()-> Promise<TMContactAddress?> {
        return self.addressAddingViewContoller!.model.promiseCheckAndSubmitForCurrentUser().then { address-> TMContactAddress? in
            
            let config = TMConsumerConfig.shared
            let user = config.currentUser
            
            self.addressTableViewController!.selectedAddress = user?.addressesArray.last
            return address
        }
    }
    
    // Validate And Submit Address for contact
    func promiseCheckAndSubmitForContact(contact: TMContact)-> Promise<TMContactAddress?> {
        return self.addressAddingViewContoller!.model.promiseCheckAndSubmitForContact(contact: contact).then { address-> TMContactAddress? in
            
            self.addressTableViewController!.selectedAddress = contact.addressesArray.last
            return address
        }
    }
}

// MARK: - AddressTableViewControllerDelegate
extension TMAddressContainerViewController: TMAddressTableViewControllerDelegate {
    // Switching delegate triggering
    func switchToAddAddress() {
        
        self.addressAddingViewContoller?.model.address = nil
        addressAddingViewContoller?.state = .normal
        addressAddingViewContoller?.stateDidChange()
        self.swapToAddAddress()
    }
    
    func switchToEditAddress(_ address: TMContactAddress) {
        
        self.addressAddingViewContoller?.model.address = address
        addressAddingViewContoller?.state = .normal
        addressAddingViewContoller?.stateDidChange()
        
        self.swapToAddAddress()
    }
    
    func didSelectAddress(_ address: TMContactAddress) {
        self.delegate?.didSelectAddress(address)
    }
}
