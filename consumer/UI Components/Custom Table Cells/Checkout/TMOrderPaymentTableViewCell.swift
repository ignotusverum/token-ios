//
//  TMOrderPaymentTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMOrderPaymentTableViewCell: UITableViewCell {

    // Payment
    var card: TMPayment? {
        didSet {
            guard let _card = card else {
                return
            }
            
            var nameString = _card.label?.capitalizedFirst()
            
            // Name label
            if _card.label?.length == 0 || _card.label == nil {
                
                // Set card brand, if there's no label
                nameString = _card.brand?.capitalizedFirst()
            }
            
            self.nameLabel.attributedText = nameString?.setCharSpacing(0.4)
            
            // Details label
            if let detailsText = _card.last4 {
                let detailsText = "Ending In \(detailsText)"
                self.detailsLabel.attributedText = detailsText.setCharSpacing(1.0)
            }
            else {
                self.detailsLabel.text = ""
            }
        }
    }
    
    // Payment name label
    
    
    @IBOutlet var nameLabel: UILabel!
    
    // Payment details label
    @IBOutlet var detailsLabel: UILabel!
}
