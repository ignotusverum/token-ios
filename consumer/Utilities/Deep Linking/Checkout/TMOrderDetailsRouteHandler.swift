//
//  TMOrderDetailsRouteHandler.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/3/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit

class TMOrderDetailsRouteHandler {
    
    /// Transition to Order Details Controller for cart
    /// 1. Fetch all order types
    /// 2. Assign !Unwrapped to cart
    /// 3. Perform transition
    class func orderDetails(for cart: TMCart?)-> Promise<UIViewController?> {
        
        // Safety check
        guard let cart = cart else {
            return Promise(value: nil)
        }
        
        var shippingTypes: [TMShippingType] = []
        
        /// Shipping not set - do no change
        guard let _ = cart.orderType else {
            
            // Perform logic check
            return TMShippingAdapter.fetch().then { response-> Promise<TMCart?> in
                
                let firstWrapped = response.filter { $0.wrappingType == .wrapped && $0.active?.boolValue == true }.first
                
                shippingTypes = response
                
                return TMCartAdapter.setShippingTypeID(cart: cart, shippingType: firstWrapped)
                }.then { response-> Promise<UIViewController?> in
                    
                    return paymentCheck(cart: cart, shippingTypes: shippingTypes)
                }
        }
        
        /// Shipping set - check for payments
        return TMShippingAdapter.fetch().then { response-> Promise<UIViewController?> in
    
            return paymentCheck(cart: cart, shippingTypes: response)
        }
    }
    
    /// Transition to payment / Order details controller
    private class func paymentCheck(cart: TMCart, shippingTypes: [TMShippingType])-> Promise<UIViewController?> {
    
        /// Payment not set path
        guard let _ = cart.payment else {
    
            return TMPaymentAdapter.fetchList().then { response-> Promise<TMPayment?> in
                
                return TMCoreDataManager.fetchExisting(response.first)
                }.then { response-> Promise<TMCart?> in
            
                    return TMCartAdapter.setPayment(cart: cart, card: response)
                }.then { response-> UIViewController? in
                    
                    guard let _ = response else {
                        
                        return noPaymentTransition(cart: cart, shippingTypes: shippingTypes)
                    }
                    
                    return orderDetailsTransition(cart: cart, shippingTypes: shippingTypes)
            }
        }
        
        return Promise(value: orderDetailsTransition(cart: cart, shippingTypes: shippingTypes))
    }
    
    private class func noPaymentTransition(cart: TMCart, shippingTypes: [TMShippingType])-> UIViewController {
                
        /// No payment path
        let noPaymentController = TMAddCreditCardPaymentViewController(theme: .light)
        
        noPaymentController.saveAction = {
            
            paymentCheck(cart: cart, shippingTypes: shippingTypes).then { controller-> Void in
                
                guard let controller = controller else {
                    return
                }
                
                noPaymentController.pushVC(controller)
                }.catch { error in
                    print("ERROR!")
            }
        }
        
        return noPaymentController
    }
    
    private class func orderDetailsTransition(cart: TMCart, shippingTypes: [TMShippingType])-> UIViewController {
        
        let checkoutSB = UIStoryboard.init(name: "Checkout", bundle: nil)
        
        /// Order details controller path
        let orderDetailsController = checkoutSB.instantiateViewController(withIdentifier: "TMOrderDetailsViewController") as! TMOrderDetailsViewController
        
        orderDetailsController.request = cart.request
        orderDetailsController.shippingTypes = shippingTypes
        
        return orderDetailsController
    }
}
