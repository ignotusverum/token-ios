//
//  TMAddressViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/24/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import JDStatusBarNotification

class TMAddressViewController: UIViewController, ListSectionObserver {
    
    // Table View
    @IBOutlet var tableView: UITableView!
    
    // Observers
    let addressMonitor: ListMonitor<TMContactAddress> = {
        
        let config = TMConsumerConfig.shared

        return TMCoreDataManager.defaultStack.monitorList(From<TMContactAddress>(),
                                                          Where("\(TMContactAddressAttributes.userID.rawValue) == %@", config.currentUser!.id),
                                                          OrderBy(.ascending("label")))
    }()
    
    // Empty view
    var emptyView: TMEmptyBlackDataset!
    
    // Selected address
    var selectedAddress: TMContactAddress?
    
    // Empty state Copy
    let emptyStateCopyString = "When you ship something to\nyourself, your address will be\nsaved here for your convenience."
    
    // Empty state Title
    let emptyStateTitleString = "No address saved."
    
    var tap = UITapGestureRecognizer()
    
    // MARK: - Controller lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Pull all addresses
        TMUserAdapter.fetchAddressList().then { result -> Void in
            
            self.tableView.isEditing = false
            self.tableView.reloadData()
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s21)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("ADDRESS", color: UIColor.white)
        
        // Clear ui
        self.tableView.tableFooterView = UIView()
        
        // Setup table datasource
        let addressNib = UINib(nibName: "TMAddressBlackTableViewCell", bundle: nil)
        let buttonNib = UINib(nibName: "TMBlackButtonTableViewCell", bundle: nil)
        
        self.tableView.register(addressNib, forCellReuseIdentifier: "TMAddressBlackTableViewCell")
        self.tableView.register(buttonNib, forCellReuseIdentifier: "TMBlackButtonTableViewCell")
        
        // Empty view setup
        self.emptyView.titleString = emptyStateTitleString
        self.emptyView.detailsCopy = emptyStateCopyString
        self.emptyView.buttonCopy = "ADD ADDRESS"
        self.emptyView.delegate = self
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(TMAddressViewController.handleFrontTap(_:)))
        
        self.view.addGestureRecognizer(tap)
        
        // Add address changes observer
        self.addressMonitor.addObserver(self)
    }
    
    //Make sure this must not be private
    func handleFrontTap(_ gestureRecognizer: UITapGestureRecognizer?) {
        
        // add address segue
        guard let storyboard = storyboard else {
            print("Storyboard is nil")
            return
        }
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: "newAddressParentViewController") as? TMNewAddressParentViewController else {
            print("TMNewAddressParentViewController is not correct type.")
            return
        }
        
        controller.selectedAddress = selectedAddress
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func editButtonPressed(_ sender: Any) {
        
        self.tableView.isEditing = !self.tableView.isEditing
        
        self.tableView.reloadData()
    }
}

// MARK: - TableView Delegate

extension TMAddressViewController: UITableViewDelegate {
    
    // Did Select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? TMAddressBlackTableViewCell
        
        self.selectedAddress = cell?.address

        guard let storyboard = storyboard else {
            print("Storyboard is nil")
            return
        }
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: "newAddressParentViewController") as? TMNewAddressParentViewController else {
            print("TMNewAddressParentViewController is not correct type.")
            return
        }
        
        controller.selectedAddress = selectedAddress
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - TableView Datasource

extension TMAddressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this address ?", preferredStyle: .alert);
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil));
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action:UIAlertAction) in
            
            let cell = tableView.cellForRow(at: indexPath) as? TMAddressBlackTableViewCell
            
            let address = cell?.address
            
            guard let _address = address else {
                return
            }
            
            // Handle post
            TMUserAdapter.deleteAddress(_address).then { result-> Promise<[TMContactAddress]> in
                
                return TMUserAdapter.fetchAddressList()
                }.then { result-> Void in

                    self.tableView.reloadData()
                }.catch { error in
                    
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }));
        
        present(alert, animated: true, completion: nil);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSection = 1
        if addressMonitor.numberOfSections() > 0 {
            numberOfSection = numberOfSection + 1
        }
        
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 1
        
        if section == 0 {
            
            numberOfRows = addressMonitor.numberOfObjects()
        }
        
        if numberOfRows == 0 {
            self.emptyView.isHidden = false
            self.tap.isEnabled = true
        }
        else {
            self.emptyView.isHidden = true
            self.tap.isEnabled = false
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"TMAddressBlackTableViewCell", for: indexPath) as! TMAddressBlackTableViewCell
            
            let address = addressMonitor[indexPath.row]
            
            cell.address = address
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"TMBlackButtonTableViewCell", for: indexPath) as! TMBlackButtonTableViewCell
        cell.buttonTitleString = "ADD ADDRESS"
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 140.0
        }
        else {
            return 90.0
        }
    }
    
    // MARK: ListObserver
    func listMonitorDidChange(_ monitor: ListMonitor<TMContactAddress>) {
        
        self.tableView.reloadData()
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<TMContactAddress>, didUpdateObject object: TMContactAddress, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? TMAddressBlackTableViewCell {
            
            let address = self.addressMonitor[indexPath]
            cell.address = address
        }
    }
}

extension TMAddressViewController: TMEmptyBlackDatasetDelegate {
    func buttonPressed(_ sender: Any) {
        // add address segue
        guard let storyboard = storyboard else {
            print("Storyboard is nil")
            return
        }
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: "newAddressParentViewController") as? TMNewAddressParentViewController else {
            print("TMNewAddressParentViewController is not correct type.")
            return
        }
        
        controller.selectedAddress = selectedAddress
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TMAddressViewController: TMBlackButtonTableViewCellDelegate {
    func blackButtonPressed(_ sender: UIButton) {
        // add address segue
        handleFrontTap(nil)
    }
}
