//
//  TMPriceInfoViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 11/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMPriceInfoViewController: UIViewController {

    // Close handler
    var closeHandler: (() -> ())?
    
    // Invitation Handler
    var checkmarkHandler: (() -> ())?
    
    // Price inf label
    @IBOutlet weak var priceInfoLabel: UILabel!
    
    // Shipping label
    @IBOutlet weak var shippingLabel: UILabel!
    
    // Expert label
    @IBOutlet weak var expertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.priceInfoLabel.font = UIFont.ActaBook(14.0)
        let priceString = NSMutableAttributedString(attributedString: self.priceInfoLabel.attributedText!)
        priceString.setFontForStr("with a $15 maximum per order.", font: UIFont.ActaBookItalic(14.0))
        self.priceInfoLabel.attributedText = priceString
        
        let shippingCopy = self.shippingLabel.text!
        self.shippingLabel.font = UIFont.ActaBook(14.0)
        self.shippingLabel.attributedText = NSMutableAttributedString.initWithString(shippingCopy, lineSpacing: 5.0, aligntment: .center)
        
        let expertCopy = self.expertLabel.text!
        self.expertLabel.font = UIFont.ActaBook(14.0)
        self.expertLabel.attributedText = NSMutableAttributedString.initWithString(expertCopy, lineSpacing: 5.0, aligntment: .center)
    }
    
    func checkmarkSelected(_ completion: (()->())?) {
        
        self.checkmarkHandler = completion
    }
    
    func closeSelected(_ completion: (()->())?) {
        
        self.closeHandler = completion
    }
    
    // MARK: - Actions
    @IBAction func checkmarkButtonPressed(_ sender: UIButton) {
        
        // Passing invitation handler
        self.checkmarkHandler?()
    }
}
