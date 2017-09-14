
//  TMOrderDetailsSections.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/2/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

struct TMOrderDetailsSections {
    
    var cart: TMCart?
    
    // Items section + wrapping
    var items: [TMCartItem] = []
    var itemsSection: Int = 0
    
    // Cart notes section
    var notes: [TMCartLabel] = []
    var notesSection: Int {
        
        // Notes section should be after payments + addresses + items
        return notes.count > 0 ? itemsSection + 1 : 0
    }
    
    // Cart address section
    var addresses: [TMContactAddress] = []
    var addressesSection: Int {
        
        // Addresses section should be after items
        return addresses.count > 0 ? notesSection + 1 : 0
    }
    
    // Cart payment section
    var payments: [TMPayment] = []
    var paymentsSection: Int {
        
        // Payments section should be after address + items section
        return payments.count > 0 ? addressesSection + 1 : 0
    }
    
    // Cart subtotal section
    var subTotals: [NSNumber] = []
    var subTotalsSection: Int {
        
        // Fees should be after payments + addresses + items + notes
        return subTotals.count > 0 ? paymentsSection + 1 : 0
    }
    
    // Cart fees section
    var fees: [TMFee] = []
    var feesSection: Int {
        
        // Fees should be after payments + addresses + items + notes + subtotal
        return fees.count > 0 ? subTotalsSection + 1 : 0
    }
    
    // Cart total section
    var totals: [NSNumber] = []
    var totalsSection: Int {
        
        return allIndexes.count
    }
    
    // Datasource
    var allIndexes: [[Any]] {
        
        let result: [[Any]] = [items, notes, addresses, payments, subTotals, fees, totals]
        
        return result.filter { $0.count > 0 }
    }
    
    init() { }
    
    init(cart: TMCart?) {
        
        guard let cart = cart else {
            return
        }
        
        self.cart = cart
        
        // Creating items dataSource
        items = cart.itemsArray
        
        // Setting notes dateSource
        if let note = cart.label {
            notes = [note]
        }
        
        // Setting address dataSource
        if let address = cart.address {
            addresses = [address]
        }
        
        // Setting payment dataSource
        if let payment = cart.payment {
            payments = [payment]
        }
        
        // Subtotal
        if let subTotal = cart.subtotal {
            subTotals = [subTotal]
        }
        
        // Creating fees dataSource
        fees = cart.fees
        
        // Totals
        if let total = cart.total {
            totals = [total]
        }
    }
}
