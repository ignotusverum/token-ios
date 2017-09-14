//
//  TMPaymentViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import CoreStore
import PromiseKit
import JDStatusBarNotification

class TMPaymentViewController: UIViewController, ListSectionObserver {
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    // Empty view
    var emptyView: TMEmptyBlackDataset!
    
    // Observers
    let paymentsMonitor: ListMonitor<TMPayment> = {
        
        return TMCoreDataManager.defaultStack.monitorList(From<TMPayment>(),
                                                          OrderBy(.ascending("isDefault")))
    }()
    
    fileprivate var selectedCard: TMPayment?
    
    // Empty state Copy
    let emptyStateCopyString = "When you use a credit card to\n pay for a gift, your info will be\n saved here for your convenience."
    
    // Empty state Title
    let emptyStateTitleString = "No cards saved."
    
    var tap = UITapGestureRecognizer()
    
    // Controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s19, properties: ["style": "black"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let addressNib = UINib(nibName: "TMPaymentListTableViewCell", bundle: nil)
        let buttonNib = UINib(nibName: "TMBlackButtonTableViewCell", bundle: nil)
        
        self.tableView.register(addressNib, forCellReuseIdentifier: "TMPaymentListTableViewCell")
        self.tableView.register(buttonNib, forCellReuseIdentifier: "TMBlackButtonTableViewCell")
        
        // Update list of cards
        TMPaymentAdapter.fetchList().then { response-> Void in
            
            self.tableView.isEditing = false
            self.tableView.reloadData()
            
            }.catch { error in
            
            JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("PAYMENT",color: UIColor.white)
        
        self.emptyView.titleString = emptyStateTitleString
        self.emptyView.detailsCopy = emptyStateCopyString
        self.emptyView.buttonCopy = "ADD CARD"
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(TMPaymentViewController.handleFrontTap(_:)))
        
        self.view.addGestureRecognizer(tap)
        
        // Add payments changes observer
        paymentsMonitor.addObserver(self)
    }
    
    //Make sure this must not be private
    func handleFrontTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let addPaymentViewController = TMAddCreditCardPaymentViewController(theme: .dark) {
            self.popVC()            
        }
        
        navigationController?.pushViewController(addPaymentViewController, animated: true)
        //self.performSegue(withIdentifier: "addPaymentSegue", sender: nil)
    }
    
    // Segue logic
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "creditCardDetailsSegue" {
            
            let destinationController = segue.destination as! TMPaymentDetailsViewController
            destinationController.creditCard = self.selectedCard
        }
    }
    
    // MARK: - Actions
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        
        self.tableView.isEditing = !self.tableView.isEditing
        
        self.tableView.reloadData()
    }
    
    func performAddPaymentTransition() {
     
        let addPaymentViewController = TMAddCreditCardPaymentViewController(theme: .dark) {
            self.popVC()
        }
        navigationController?.pushViewController(addPaymentViewController, animated: true)
    }
}

// MARK: - TableView Datasource
extension TMPaymentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this payment ?", preferredStyle: UIAlertControllerStyle.alert);
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            
            let cell = tableView.cellForRow(at: indexPath) as? TMPaymentListTableViewCell
            
            let card = cell?.card
            
            guard let _card = card else {
                return
            }
            
            // Handle post
            TMPaymentAdapter.deletePayment(_card).catch { error in
                    
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }));
        
        present(alert, animated: true, completion: nil);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return paymentsMonitor.numberOfSections() + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 1
        
        if section == 0 {
            
            numberOfRows = paymentsMonitor.numberOfObjects()
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TMPaymentListTableViewCell", for: indexPath) as! TMPaymentListTableViewCell
            
            let card = paymentsMonitor[indexPath]
            
            cell.card = card
            cell.checkmarkImageView.isHidden = true
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TMBlackButtonTableViewCell", for: indexPath) as! TMBlackButtonTableViewCell
        cell.buttonTitleString = "ADD CARD"
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: ListObjectObserver
    func listMonitorDidChange(_ monitor: ListMonitor<TMPayment>) {
        
        self.tableView.reloadData()
    }
    
    func listMonitor(_ monitor: ListMonitor<TMPayment>, didUpdateObject object: TMPayment, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? TMPaymentListTableViewCell {
            
            let card = paymentsMonitor[indexPath]
            
            cell.card = card
            cell.checkmarkImageView.isHidden = true
        }
    }
}

// MARK: - Table view delegate
extension TMPaymentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 96.0
    }
}

extension TMPaymentViewController: TMEmptyBlackDatasetDelegate {
    internal func buttonPressed(_ sender: Any) {
        // add card segue
        performAddPaymentTransition()
    }
}

extension TMPaymentViewController: TMBlackButtonTableViewCellDelegate {
    func blackButtonPressed(_ sender: UIButton) {
        // add card segue
        performAddPaymentTransition()
    }
}
