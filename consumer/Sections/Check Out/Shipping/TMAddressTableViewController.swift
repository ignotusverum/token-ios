//
//  TMAddressTableViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/25/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import CoreStore
import EZSwiftExtensions

protocol TMAddressTableViewControllerDelegate {
    func switchToAddAddress()
    func switchToEditAddress(_ address: TMContactAddress)
    
    // Tableview cell selected with address object
    func didSelectAddress(_ address: TMContactAddress)
}

class TMAddressTableViewController: UIViewController, ListSectionObserver {

    // Selected Address - refactor
    var selectedAddress: TMContactAddress? {
        didSet {

            guard let address = selectedAddress else { return }
            delegate?.didSelectAddress(address)
            tableView.reloadData()
        }
    }
    
    // Table View
    @IBOutlet var tableView: UITableView!
    
    // Observers
    let addressMonitor: ListMonitor<TMContactAddress> = {
        
        let config = TMConsumerConfig.shared
        let currentUser = config.currentUser!
        
        return TMCoreDataManager.defaultStack.monitorList(From<TMContactAddress>(),
                                                          Where("\(TMContactAddressAttributes.userID.rawValue) == %@", currentUser.id),
                                                          OrderBy(.ascending("createdAt")))
    }()
    
    // Selected datasource (current user - recepient)
    var selectedUser: TMUser? {
        didSet {
            if let selectedUser = selectedUser {
                // Resetting selected index path if datasource  changes
                selectedAddress = nil
                selectedContact = nil

                addressMonitor.refetch(Tweak { fetchRequest-> Void in
                    
                    let predicate = NSPredicate(format: "\(TMContactAddressAttributes.userID.rawValue) == %@", selectedUser.id)
                    fetchRequest.predicate = predicate
                })
            }
        }
    }
    
    var selectedContact: TMContact? {
        didSet {
            if let selectedContact = selectedContact {
                // Resetting selected index path if datasource  changes
                selectedAddress = nil
                selectedUser = nil
                
                addressMonitor.refetch(Tweak { fetchRequest-> Void in
                    
                    let predicate = NSPredicate(format: "\(TMContactAddressRelationships.contact.rawValue).\(TMModelAttributes.id.rawValue) == %@", selectedContact.id)
                    fetchRequest.predicate = predicate
                })
            }
        }
    }
    
    var onAddressSelect: (() -> ())?
    
    // Selected Address
    var delegate: TMAddressTableViewControllerDelegate?
    
    // Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addressNib = UINib(nibName: "TMAddressTableViewCell", bundle: nil)
        tableView.register(addressNib, forCellReuseIdentifier: "addressCell")
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
        
        // Add address changes observer
        addressMonitor.addObserver(self)
    }
    
    // MARK: ListObjectObserver
    func listMonitorDidChange(_ monitor: ListMonitor<TMContactAddress>) {
        
        tableView.reloadData()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<TMContactAddress>) {
        
        tableView.reloadData()
        
        if addressMonitor.numberOfObjects() > 0 {
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        
        if selectedAddress == nil {
        
            selectedAddress = addressMonitor.objectsInAllSections().first
        }
    }
}

// MARK: - TableView Delegate
extension TMAddressTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let cell = tableView.cellForRow(at: indexPath) as! TMAddressTableViewCell
            
            // Cell selecting logic
            selectedAddress = cell.address
            
            guard let onAddressSelect = onAddressSelect else {
                return
            }
            
            onAddressSelect()
        }
        else {
            // Switching to add address
            delegate?.switchToAddAddress()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 135.0
        }
        
        return 75.0
    }
}

// MARK: - TableView Datasource
extension TMAddressTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return addressMonitor.numberOfSections() + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (section == 0) ? addressMonitor.numberOfObjects() : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            // Cell Dequeue
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! TMAddressTableViewCell
            cell.delegate = self
            
            // Populating address Object
            let address = addressMonitor[indexPath]
            cell.address = address
            
            // Setting to initial state
            if address.id! == selectedAddress?.id {
                
                cell.selectedCell = true
            }
            else {
            
                cell.selectedCell = false
            }
            
            return cell
        }
        else {
            
            let cellIdentifier = "addAddressButton"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            return cell
        }
    }
}

extension TMAddressTableViewController: TMAddressTableViewCellDelegate {
    
    func addressSelected(_ address: TMContactAddress?, cell: TMAddressTableViewCell) { }
    
    func editingSelectedForAddress(_ address: TMContactAddress?, cell: TMAddressTableViewCell) {
    
        delegate?.switchToEditAddress(address!)
    }
}
