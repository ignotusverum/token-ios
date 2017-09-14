//
//  TMWhitePaymentViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/21/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions
import JDStatusBarNotification

class TMWhitePaymentViewController: TMPaymentViewController {
    
    // Request
    var request: TMRequest?
    
    // Should hide edit Button
    var shouldHideEdit = false {
        didSet {
            
            // Hiding edit button
            if shouldHideEdit {
                
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("SELECT PAYMENT", color: UIColor.black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBarColor = self.view.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        TMAnalytics.trackScreenWithID(.s19, properties: ["style": "white"])
    }
    
    // Prepare for segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? TMPaymentListTableViewCell
        let card = cell?.card
        
        if let card = card {
            TMCartAdapter.setPayment(cart: request?.cart, card: card).then { response-> Void in
        
                ez.runThisAfterDelay(seconds: 0.1) {
                    
                    self.popVC()
                }
                
                }.catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TMPaymentListTableViewCell", for: indexPath) as! TMPaymentListTableViewCell
            
            let card = paymentsMonitor[indexPath]
            
            cell.card = card
            cell.isLightStyle = true
            cell.selectedCard = self.request?.cart?.payment
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TMBlackButtonTableViewCell", for: indexPath) as! TMBlackButtonTableViewCell
        cell.buttonTitleString = "ADD CARD"
        
        cell.delegate = self
        
        return cell
    }
    
    // overriding back action
    override func backButtonPressed(_ sender: Any?) {
        self.popVC()
    }
    
    // MARK: - Transitions
    override func performAddPaymentTransition() {
        
        let addPaymentViewController = TMAddCreditCardPaymentViewController(theme: .light) {
            self.popVC()
        }
        navigationController?.pushViewController(addPaymentViewController, animated: true)
    }

}
