//
//  TMCartItemTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMCartItemTableViewCellDelegate {
    func updateItemQuantityButtonPressed(_ item: TMCartItem, quantity: Int)
}

class TMCartItemTableViewCell: UITableViewCell {
    
    // Delegate
    var delegate: TMCartItemTableViewCellDelegate?
    
    // Cart item
    var item: TMCartItem? {
        didSet {
            
            guard let _item = item else {
                return
            }
            
            // Set Image
            if let _imageURL = _item.product?.primaryImage?.imageURL {
                
                // Download Item image
                self.itemImageView.downloadImageFrom(link: _imageURL, contentMode: .scaleAspectFit)
            }
            
            // Set Price
            if let _product = _item.product {
                self.priceLabel.text = _product.copyPriceString
                
                // Set title
                self.titleLabel.attributedText = NSMutableAttributedString.initWithString(_product.title!, lineSpacing: 6.0, aligntment: .left)
                
            }
            
            self.quantityView.quantity = _item.quantity!.intValue
            
            self.quantityView.delegate = self
        }
    }
    
    // Editing Avaliable
    var editingAvaliable = true {
        didSet {
            
            if editingAvaliable {
                UIView.animate(withDuration: 0.1, animations: {
                    self.movingView.setFrameX(40.0)
                })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.movingView.setFrameX(20.0)
                })
            }
        }
    }
    
    // Animation View
    @IBOutlet weak var movingView: UIView!
    
    // Item Image View
    @IBOutlet var itemImageView: UIImageView!
    
    var itemImageInitialPosition:CGFloat = 0.0
    
    // Item Title Label
    @IBOutlet var titleLabel: UILabel!
    
    // Item Price Label
    @IBOutlet var priceLabel: UILabel!
    
    // Item Quantity contol view
    @IBOutlet var quantityView: TMCartQuantityControl!
    
    // Font setup
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.itemImageInitialPosition = self.itemImageView.frameX()
        
        if DeviceType.IS_IPHONE_5 {
            
            self.titleLabel.font = UIFont.ActaBook(13.0)
            self.priceLabel.font = UIFont.MalloryBook(11.0)
        }
    }
}

extension TMCartItemTableViewCell: TMCartQuantityControlDelegate {
    
    // Add item to cart button pressed
    func addButtonPressedWithItem() {
        
        guard let _item = self.item else {
            
            return
        }
        
        let addedQuantity = _item.quantity!.intValue + 1
        
        self.delegate?.updateItemQuantityButtonPressed(_item, quantity: addedQuantity)
    }
    
    // Remove item from cart button pressed
    func removeButtonPressedWithItem() {
        
        guard let _item = self.item else {
            
            return
        }
        
        let removedQuantity = _item.quantity!.intValue - 1
        
        self.delegate?.updateItemQuantityButtonPressed(_item, quantity: removedQuantity)
    }
}
