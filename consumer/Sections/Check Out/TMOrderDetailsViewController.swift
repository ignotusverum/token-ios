//
//  TMOrderDetailsViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import SwiftyJSON
import SVProgressHUD
import JDStatusBarNotification

class TMOrderDetailsViewController: UIViewController {

    /// Array of shipping types
    var shippingTypes: [TMShippingType] = []
    
    /// Order details cell identifiers
    enum TMOrderDetailsCells: String {
        
        case itemCell = "TMOrderItemTableViewCell"
        case shippingTypeCell = "TMShippingTypeTableViewCell"
        case noteCell = "TMOrderNoteTableViewCell"
        case addressCell = "TMOrderAddressTableViewCell"
        case paymentCell = "TMOrderPaymentTableViewCell"
        case feeCell = "TMCartFeeTableViewCell"
        case totalCell = "TMTotalTableViewCell"
    }
    
    // Request
    var request: TMRequest?
    
    var orderSections = TMOrderDetailsSections()
    
    // Note cell
    var noteCell: TMOrderNoteTableViewCell?
    
    // Table View
    @IBOutlet var tableView: UITableView!

    fileprivate lazy var checkoutButton: UIButton = {
        let button = UIButton.button(style: .gift)
        
        button.setTitle("Send Gift", for: .normal)
        button.addTarget(self, action: #selector(onCheckoutButton), for: .touchUpInside)
        
        return button
    }()
    
    // Controller lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /// Navigation title
        let label = UILabel()
        
        label.numberOfLines = 0
        label.attributedText = TMCopy.navigationTitle(title: "GIFT SELECTION", request: request)
        
        label.sizeToFit()
        navigationItem.titleView = label
        
        orderSections = TMOrderDetailsSections(cart: request?.cart)
        
        tableView.reloadData()
        
        view.addSubview(tableView)
        
        // Update checkout button
        checkoutButton.setAttributedTitle(self.generateTotalButtonTitle(), for: .normal)
        
        // TableView insets
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
        
        // Setup tableView datasource
        setupCells()
        
        view.addSubview(checkoutButton)
        
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: checkoutButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkoutButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkoutButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkoutButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarColor = view.backgroundColor
        
        checkAndRemovePaymentController()
        
        if let _ = request {
            
            TMCartAdapter.fetchCart(request: request).then { response-> Void in

                self.orderSections = TMOrderDetailsSections(cart: self.request?.cart)
                // Update checkout button
                self.checkoutButton.setAttributedTitle(self.generateTotalButtonTitle(), for: .normal)
                
                self.tableView.reloadData()
                
                }.catch { error in
                    
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }

    // Check For Payment in Flow
    func checkAndRemovePaymentController() {
        
        var navigationArray = navigationController!.viewControllers
        
        // Enumerating to find payment controller
        for (index, controller) in navigationArray.enumerated() {
            
            if controller is TMAddCreditCardPaymentViewController {
                navigationArray.remove(at: index)
            }
        }
        
        // Setting updated flow
        navigationController?.viewControllers = navigationArray
    }
    
    // Setup cells
    func setupCells() {
        
        // Order note cell
        let noteCellNib = UINib(nibName: TMOrderDetailsCells.noteCell.rawValue, bundle: nil)
        
        // Order item Cell Nib
        let itemDetailsCellNib = UINib(nibName: TMOrderDetailsCells.itemCell.rawValue, bundle: nil)
        
        // Shipping Type Cell Nib
        let shippingTypeCellNib = UINib(nibName: TMOrderDetailsCells.shippingTypeCell.rawValue, bundle: nil)
        
        // Order Payment Cell Nib
        let paymentCellNib = UINib(nibName: TMOrderDetailsCells.paymentCell.rawValue, bundle: nil)
        
        // Order Address Cell Nib
        let addressCellNib = UINib(nibName: TMOrderDetailsCells.addressCell.rawValue, bundle: nil)
        
        // Order line item prices
        let priceCellNib = UINib(nibName: TMOrderDetailsCells.totalCell.rawValue, bundle: nil)
        
        // Item Price cell
        let feeCell = UINib(nibName: TMOrderDetailsCells.feeCell.rawValue, bundle: nil)
        
        // Registering nibs
        tableView.register(noteCellNib, forCellReuseIdentifier: TMOrderDetailsCells.noteCell.rawValue)
        tableView.register(shippingTypeCellNib, forCellReuseIdentifier: TMOrderDetailsCells.shippingTypeCell.rawValue)
        tableView.register(itemDetailsCellNib, forCellReuseIdentifier: TMOrderDetailsCells.itemCell.rawValue)
        tableView.register(addressCellNib, forCellReuseIdentifier: TMOrderDetailsCells.addressCell.rawValue)
        tableView.register(paymentCellNib, forCellReuseIdentifier: TMOrderDetailsCells.paymentCell.rawValue)
        tableView.register(priceCellNib, forCellReuseIdentifier: TMOrderDetailsCells.totalCell.rawValue)
        tableView.register(feeCell, forCellReuseIdentifier: TMOrderDetailsCells.feeCell.rawValue)
    }
    
    // Segue overriding
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shippingInfoSegue" {
            
            let controller = segue.destination as? TMShippingInformationViewController
            controller?.request = request
        }
        else if segue.identifier == "paymentSegue" {
            
            let controller = segue.destination as? TMWhitePaymentViewController
            
            controller?.shouldHideEdit = true
            controller?.request = request
        }
        else if segue.identifier == "confirmationSegue" {
            
            let controller = segue.destination as? TMOrderConfirmedViewController
            controller?.request = request
        }
    }
    
    // Override back button actions
    override func backButtonPressed(_ sender: Any?) {
        
        popVC()
    }
    
    func onCheckoutButton() {
        
        guard let cart = request?.cart else {
            return
        }
        
        SVProgressHUD.show()
        
        TMCartAdapter.checkout(cart: cart).then { cartObject-> Promise<TMOrder?> in
            
            return TMOrderAdapter.fetch(orderID: cart.orderID!)
            
            }.then { order-> Promise<TMRequest?> in
                
                var checkoutAnalytics = [String: Any]()
                
                if let orderID = order?.id {
                    checkoutAnalytics["orderID"] = orderID
                }
                
                if let cartID = cart.id {
                    checkoutAnalytics["cartID"] = cartID
                }
                
                if let subtotal = order?.subTotal {
                    
                    checkoutAnalytics["subtotal"] = subtotal.intValue / 100
                }
                
                if let shippingState = order?.shippingAddress?.state {
                    checkoutAnalytics["shippingState"] = shippingState
                }
                
                if let shippingCountry = order?.shippingAddress?.country {
                    checkoutAnalytics["shippingCountry"] = shippingCountry
                }
                
                if let shippingPostCode = order?.shippingAddress?.zip {
                    checkoutAnalytics["shippingPostCode"] = shippingPostCode
                }
                
                var arrayOfProductID = [String]()
                
                var arrayOfProducts = [[String: Any]]()
                
                for item in cart.itemsArray {
                    if let productID = item.productID {
                        arrayOfProductID.append(productID)
                        if let product = item.product {
                            arrayOfProducts.append(product.getAnalyticsDict())
                        }
                    }
                }
                
                checkoutAnalytics["products"] = arrayOfProductID
                
                TMAnalytics.trackEventWithID(.t_S14_2, eventParams: checkoutAnalytics)
                TMCommerceAnalytics.trackFinishedForOrder(order, productArray: arrayOfProducts)
                
                return TMRequestAdapter.fetch(requestID: self.request!.id)
                
            }.then { request-> Void in
                
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier:"confirmationSegue", sender: nil)
            }.always {
                
                SVProgressHUD.dismiss()
            }.catch { error in
                
                SVProgressHUD.dismiss()
                
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    // MARK: - Utilities
    func generateTotalButtonTitle()-> NSAttributedString {
        
        guard let total = request?.cart?.total else {
            return NSMutableAttributedString(string: "SEND GIFT", attributes: [NSFontAttributeName: UIFont.MalloryMedium(15.0), NSForegroundColorAttributeName: UIColor.white, NSKernAttributeName: 1.2])
        }
        
        let totalString = String(format: "%.2f", total.floatValue)
        
        let attributedString = NSMutableAttributedString(string: "SEND GIFT - $\(totalString)", attributes: [NSFontAttributeName: UIFont.MalloryMedium(15.0), NSForegroundColorAttributeName: UIColor.white, NSKernAttributeName: 1.2])
        
        return attributedString
    }
}

// MARK: - TableView Delegate
extension TMOrderDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == orderSections.addressesSection {
            
            let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
            
            // New view controller so a user can edit their shipping address.
            guard let shippingInformationViewController = storyboard.instantiateVC(TMShippingInformationViewController.self) else {
                print("View Controller is nil")
                return
            }
            
            shippingInformationViewController.request = request
            shippingInformationViewController.loadedFromConfirmationViewController = true
            
            navigationController?.pushViewController(shippingInformationViewController, animated: true)
            
            // Analytics
            TMAnalytics.trackEventWithID(.t_S14_0)
        }
        else if indexPath.section == orderSections.paymentsSection {
            
            performSegue(withIdentifier:"paymentSegue", sender: nil)
            
            // Analytics
            TMAnalytics.trackEventWithID(.t_S14_1)
        }
        else if indexPath.section == orderSections.notesSection {
            
            let checkoutSB = UIStoryboard(name: "Checkout", bundle: nil)
            let notesController = checkoutSB.instantiateViewController(withIdentifier: "TMNotesViewController") as! TMNotesViewController
            
            notesController.request = self.request
            
            self.pushVC(notesController)
            
            /// Next button selected
            notesController.onNextButtonSelection = {
                
                print("DEFINE + ADD ANALYTICS TO NOTES SELECTION")
            }
        }
        else if indexPath.section == orderSections.itemsSection, indexPath.row == orderSections.items.count {
            
            let shippingTypeCell = tableView.cellForRow(at: indexPath) as? TMShippingTypeTableViewCell
            
            let currentShippingType = shippingTypeCell?.shippingType
            
            // Get different shippingType
            let filteredShippingType = shippingTypes.filter { $0 != currentShippingType }.first
            
            guard let shippingType = filteredShippingType, let cart = request?.cart else {
                return
            }
            
            SVProgressHUD.show()
            
            TMCartAdapter.setShippingTypeID(cart: cart, shippingType: shippingType).then { result-> Promise<TMCart?> in
            
                return TMCartAdapter.fetchCart(request: self.request)
                }.then { response-> Void in
            
                    self.orderSections = TMOrderDetailsSections(cart: self.request?.cart)
                    
                    // Update checkout button
                    self.checkoutButton.setAttributedTitle(self.generateTotalButtonTitle(), for: .normal)

                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }.catch { error in
                
                    SVProgressHUD.dismiss()
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == orderSections.itemsSection {

            return 132.0
        }
        
        if indexPath.section == orderSections.addressesSection || indexPath.section == orderSections.paymentsSection {
            return DeviceType.IS_IPHONE_5 ? 76.0 : 90.0
        }
        
        if indexPath.section == orderSections.notesSection {
            
            // Note
            let note = request?.cart?.label?.note
            let noteWidth = noteCell?.descriptionLabel?.frame.width ?? 0.0
            
            let titleHeight: CGFloat = 25 + 25 + 25 + 25 // Inset + To: + From: + Inset
            
            let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 13.0 : 12.0
            
            let noteHeight = (note?.heightWithConstrainedWidth(noteWidth, font: UIFont.MalloryBook(fontSize), spacing: 7) ?? 0) + titleHeight
            
            return noteHeight
        }
        
        if indexPath.section == orderSections.subTotalsSection {
            return 50.0
        }
        
        if indexPath.section == orderSections.totalsSection - 1 {
            return 70.0
        }
        
        return 40.0
    }
}

// MARK: - TableView Datasource
extension TMOrderDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return orderSections.allIndexes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = orderSections.allIndexes[section].count
        
        if section == 0 {
            numberOfRows += 1
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        // Order type logic
        if indexPath.section == 0 {
            
            if indexPath.row == orderSections.items.count {
            
                let orderTypeCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.shippingTypeCell.rawValue, for: indexPath) as! TMShippingTypeTableViewCell
                
                orderTypeCell.shippingType = request?.cart?.orderType
                
                return orderTypeCell
            }
        
            let itemCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.itemCell.rawValue, for: indexPath) as! TMOrderItemTableViewCell
            
            let item = orderSections.items[indexPath.row]
            
            itemCell.cartItem = item
            
            return itemCell
        }
        
        if indexPath.section == orderSections.notesSection {
            
            let orderNotesCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.noteCell.rawValue, for: indexPath) as! TMOrderNoteTableViewCell
            
            orderNotesCell.note = request?.cart?.label
            
            noteCell = orderNotesCell
            
            cell = orderNotesCell
        }
        else if indexPath.section == orderSections.addressesSection {
            
            // Order Address cell logic
            let orderAddressCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.addressCell.rawValue, for: indexPath) as! TMOrderAddressTableViewCell
            
            orderAddressCell.address = orderSections.addresses[indexPath.row]
            
            cell = orderAddressCell
        }
        else if indexPath.section == orderSections.paymentsSection {
            
            let orderPaymentCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.paymentCell.rawValue, for: indexPath) as! TMOrderPaymentTableViewCell
            
            orderPaymentCell.card = orderSections.payments[indexPath.row]
            
            cell = orderPaymentCell
        }
        else if indexPath.section == orderSections.subTotalsSection {
            
            let subtotalCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.feeCell.rawValue, for: indexPath) as! TMCartFeeTableViewCell
            
            subtotalCell.setupCopy(cart: request?.cart, fee: request?.cart?.subTotalFee)
            
            subtotalCell.lastRow = tableView.numberOfRows(inSection: indexPath.section)
            subtotalCell.indexPath = indexPath
            
            cell = subtotalCell
        }
        // Service fee / shipping / tax
        else if indexPath.section == orderSections.feesSection {
        
            let shippingFeeCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.feeCell.rawValue, for: indexPath) as! TMCartFeeTableViewCell
            
            let fee = orderSections.fees[indexPath.row]
            shippingFeeCell.setupCopy(cart: request?.cart, fee: fee)
            
            shippingFeeCell.lastRow = tableView.numberOfRows(inSection: indexPath.section)
            shippingFeeCell.indexPath = indexPath
            
            cell = shippingFeeCell
        }
            // Subtotal
        else {
            let orderPriceCell = tableView.dequeueReusableCell(withIdentifier: TMOrderDetailsCells.totalCell.rawValue, for: indexPath) as! TMTotalTableViewCell
            
            orderPriceCell.total = request?.cart?.total
            
            cell = orderPriceCell
        }
        
        cell.backgroundColor = UIColor.white
        
        return cell
    }
}
