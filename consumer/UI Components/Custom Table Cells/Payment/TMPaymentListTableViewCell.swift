//
//  TMPaymentListTableViewCell.swift
//  consumer
//
//  Created by Vlad Zagorodnyuk on 6/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMPaymentListTableViewCell: UITableViewCell {

    // Light style
    var isLightStyle = false {
        didSet {
            
            // Card name label
            self.nameLabel.textColor = UIColor.black
            
            // Cart tint
            self.cardTypeImageView.tintColor = UIColor.black
            
            // Checkmark tint
            self.checkmarkImageView.tintColor = UIColor.black
        }
    }
    
    // Payment
    var card: TMPayment? {
        didSet {
            guard let _card = card else {
                return
            }
            
            self.checkmarkImageView.isHidden = false
            
            // Name label
            if _card.label?.length == 0 || _card.label == nil {
                
                // Set card brand, if there's no label
                self.nameLabel.text = _card.brand?.uppercased()
            }
            else {
                
                self.nameLabel.text = _card.label?.uppercased()
            }
            
            // Details label
            self.detailsLabel.text = "ENDING IN \(_card.last4!)"
            
            // Setting custom images for cc image view
            let imageName = "\(_card.brand!)"
            
            // Setting card image
            self.cardTypeImageView.image = UIImage(named: imageName)
        }
    }
    
    var selectedCard: TMPayment? {
        didSet {
            
            guard let _selectedCard = selectedCard, let _card = self.card else { return }
            
            if _selectedCard.id == _card.id {
                
                self.checkmarkImageView.isHidden = false
            }
            else {
                
                self.checkmarkImageView.isHidden = true
            }
        }
    }
    
    // Moving view container
    @IBOutlet weak var movingView: UIView!
    
    // Payment name label
    @IBOutlet weak var nameLabel: UILabel!
    
    // Payment details label
    @IBOutlet weak var detailsLabel: UILabel!
    
    // Card type image view
    @IBOutlet weak var cardTypeImageView: UIImageView!
    
    // Checkmark
    @IBOutlet weak var checkmarkImageView: UIImageView!
}
