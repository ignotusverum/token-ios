//
//  TMCartViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreData
import SVProgressHUD
import JDStatusBarNotification

import PromiseKit

import EZSwiftExtensions

protocol TMCartViewControllerDelegate {
    func backButtonPressed()
}

class TMCartViewController: UIViewController {
    
    var delegate: TMCartViewControllerDelegate?
    
    // Table View
    @IBOutlet var tableView: UITableView!
    
    // Cart
    var cart: TMCart?
    
    @IBOutlet weak var editButton: UIButton!
    
    fileprivate lazy var checkoutButton: UIButton = {
        let button = UIButton.button(style: .alternateBlack)
        
        button.setTitle("Checkout", for: .normal)
        button.addTarget(self, action: #selector(onCheckoutButton), for: .touchUpInside)
        
        return button
    }()
    
    var checkoutFlow: UINavigationController?
    
    // Pop VC
    @IBAction override func backButtonPressed(_ sender: Any?) {
        
        delegate?.backButtonPressed()
        
        popVC()
    }
    
    // Controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TMPaymentAdapter.fetchList().catch { error in
            print(error)
        }
        
        let myCellNib = UINib(nibName: "TMCartItemTableViewCell", bundle: nil)
        tableView.register(myCellNib, forCellReuseIdentifier: "TMCartItemTableViewCell")
        
        // Checking request status and disabling button
        checkRequestStatus()
        
        navigationController?.navigationBar.hideBottomHairline()
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 72.0, right: 0.0)
        
        createNavigationTitle()
    }
    
    
    func createNavigationTitle() {
        
        let navigationTitleLabel = UILabel()
        
        navigationTitleLabel.attributedText = TMCopy.navigationTitle(title: "GIFT SELECTION", request: cart?.request)
        navigationTitleLabel.numberOfLines = 0
        navigationTitleLabel.sizeToFit()
        
        navigationItem.titleView = navigationTitleLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting navigation bar color
        navigationController?.navigationBar.barTintColor = self.view.backgroundColor
    }
    
    func checkRequestStatus() {
        
        if let cart = cart, !cart.isCheckoutAvaliable {
            
            editButton.isHidden = true
            checkoutButton.isHidden = true
        } else {
            
            view.addSubview(tableView)
            
            view.addSubview(checkoutButton)
            
            checkoutButton.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints([
                NSLayoutConstraint(item: checkoutButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: checkoutButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: checkoutButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: checkoutButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66)
                ])
        }
    }
    
    func onCheckoutButton(_ sender: UIButton) {
        
        guard let cart = cart, let request = cart.request, cart.isCheckoutAvaliable, let _ = request.contact else {
            
            JDStatusBarNotification.show(withStatus: "Whoops, we're already processing your order.", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            
            return
        }
        
        TMAnalytics.trackEventWithID(.t_S10_0)
        
        // Checking if there's any items in array
        if cart.itemsArray.count > 0 {
            
                var cartAnalytics = [String: Any]()
                
                if let requestID = cart.request?.id {
                    
                    cartAnalytics["requestID"] = requestID
                }
                
                if let cartID = cart.id {
                    
                    cartAnalytics["cartID"] = cartID
                }
                
                var productsIDs = [String]()
                var subtotal: Int = 0
                
                for product in cart.itemsArray {
                    productsIDs.append(product.id!)
                    
                    if let productPrice = product.price {
                        subtotal = subtotal + productPrice.intValue / 100
                    }
                }
                
                cartAnalytics["productsIDs"] = productsIDs
                cartAnalytics["value"] = subtotal
                
                self.performSegue(withIdentifier:"notesSegue", sender: nil)
            }
        else {
            // No items error
            JDStatusBarNotification.show(withStatus: "Whoops, please add something to your cart", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    // MARK: - Actions
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if let cart = cart, !cart.isCheckoutAvaliable {
            tableView.isEditing = !self.tableView.isEditing
            
            tableView.reloadData()
        }
        
        // Analytics
        TMAnalytics.trackEventWithID(.t_S10_2)
    }
    
    // Segue Logic
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "notesSegue" {
            let nextController = segue.destination as? TMNotesViewController
            
            let request = self.cart?.request
            nextController?.request = request
        }
    }
}

extension TMCartViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate

extension TMCartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

// MARK: - TableView Datasource

extension TMCartViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if let cart = cart, cart.isCheckoutAvaliable {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? TMCartItemTableViewCell
        
        let item = cell?.item
        
        guard let _item = item else {
            return
        }
        
        TMAnalytics.trackEventWithID(.t_S10_3, eventParams: ["position": indexPath.row, "text": "TOP"])
        
        if _item.product!.title != nil {
            
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(_item.product!.title!) from your cart", preferredStyle: UIAlertControllerStyle.alert);
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                
                TMCartAdapter.removeCartItem(cart: self.cart!, cartItem: _item).then { result-> Promise<TMCart?> in
                    
                    var productRemovedAnalytics = [String: Any]()
                    
                    if let productID = item?.product?.id {
                        
                        productRemovedAnalytics["productID"] = productID
                    }
                    
                    if let name = item?.product?.title {
                        
                        productRemovedAnalytics["name"] = name
                    }
                    
                    if let quantity = item?.quantity {
                        
                        productRemovedAnalytics["quantity"] = quantity.intValue
                    }
                    
                    if let price = item?.product?.price {
                        
                        productRemovedAnalytics["value"] = price.intValue
                    }
                    
                    TMAnalytics.trackEventWithID(.t_S10_4, eventParams: productRemovedAnalytics)
                    
                    return TMCartAdapter.fetchCart(request: self.cart!.request!)
                    }.then { response-> Void in
                        
                        if self.cart!.itemsArray.count == 0 {
                            self.delegate?.backButtonPressed()
                            self.popVC()
                        }
                        
                        SVProgressHUD.dismiss() 
                        self.tableView.reloadData()
                        
                    }.catch { error-> Void in
                        
                        SVProgressHUD.dismiss()
                        JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }));
            
            present(alert, animated: true, completion: nil);
        }
        else {
            
            self.popVC()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let cart = cart else {
            return 0
        }
        
        return (cart.itemsArray.count > 0) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cart?.itemsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TMCartItemTableViewCell", for: indexPath) as? TMCartItemTableViewCell
        
        cell?.delegate = self
        
        cell?.editingAvaliable = self.tableView.isEditing
        let cartItem = cart?.itemsArray[indexPath.row]
        
        cell?.item = cartItem
        
        return cell!
    }
}

// Cart quantity button Delegate
extension TMCartViewController: TMCartItemTableViewCellDelegate {
    func updateItemQuantityButtonPressed(_ item: TMCartItem, quantity: Int) {
        
        SVProgressHUD.show()
        
        // Updating cart with new quantity - save only if it returns success
        TMCartAdapter.updateQuantity(cart: self.cart!, cartItem: item, quantity: quantity).then { result-> Void in
            
            SVProgressHUD.dismiss()
            }.catch { error in
                
                SVProgressHUD.dismiss()
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}

// MARK: - ScrollView Shadow logic

extension TMCartViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let shadowOffset = (scrollView.contentOffset.y / 100.0) - 2.0
        
        let shadowRadius = min(max(shadowOffset, 1), 3)
        
        if shadowOffset < 0.2 {
            
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: shadowOffset)
            self.navigationController?.navigationBar.layer.shadowRadius = shadowRadius
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        }
    }
}
