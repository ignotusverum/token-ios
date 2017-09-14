//
//  TMNewAddressParentViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/23/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import SVProgressHUD
import EZSwiftExtensions

class TMNewAddressParentViewController: UIViewController {
    //MARK: - Public iVars
    
    /// Selected address for user.
    var selectedAddress: TMContactAddress?
    
    //MARK: - Private iVars
    
    /// View controller containing table view to edit address.
    private var newAddressViewController: TMNewAddressViewController?
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        
        newAddressViewController = storyboard.instantiateViewController(withIdentifier: "newAddressController") as? TMNewAddressViewController
        
        guard let newAddressViewController = newAddressViewController else {
            print("TMNewAddressViewController is nil or not correct type.")
            return
        }
        
        if let selectedAddress = selectedAddress {
            newAddressViewController.model.address = selectedAddress
        }
        
        newAddressViewController.style = .dark
        
        addChildViewController(newAddressViewController)
        view.addSubview(newAddressViewController.view)
        
        newAddressViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: newAddressViewController.view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: newAddressViewController.view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: newAddressViewController.view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: newAddressViewController.view, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - Actions
    
    /// Action when back bar button is tapped.
    ///
    /// - Parameter sender: Back button object.
    @IBAction func onBackButton(_ sender: AnyObject) {
        self.popVC()
    }
    
    /// Action when save button embedded in bar button is tapped.
    ///
    /// - Parameter sender: Sender button.
    @IBAction func onSaveButton(sender: AnyObject) {
        SVProgressHUD.show()
        
        newAddressViewController?.model.promiseCheckAndSubmitForCurrentUser().then { (result) -> Void in
            self.popVC()
        }.always {
            SVProgressHUD.dismiss()
        }
    }
}
