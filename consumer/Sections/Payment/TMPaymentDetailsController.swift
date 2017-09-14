//
//  TMPaymentDetailsViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMPaymentDetailsViewController: UIViewController {

    var creditCard: TMPayment?
    
    @IBOutlet var creditCardView: TMCreditCardView?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditCardView?.creditCard = self.creditCard
    }
}
