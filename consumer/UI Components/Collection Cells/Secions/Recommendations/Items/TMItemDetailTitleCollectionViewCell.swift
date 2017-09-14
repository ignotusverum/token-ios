//
//  TMItemDetailTitleCollectionViewCell.swift
//  consumer
//
//  Created by Vlad Zagorodnyuk on 5/4/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMItemDetailTitleCollectionViewCell: UICollectionViewCell {
    
    // Text Color
    let textColor = UIColor.TMColorWithRGBFloat(151.0, green: 149.0, blue: 152.0, alpha: 1.0)
    
    let grayColor = UIColor.TMColorWithRGBFloat(245.0, green: 245.0, blue: 245.0, alpha: 1.0)
    
    // Cart
    var cart: TMCart?
    
    var itemInCart = false {
        didSet {
            if itemInCart {
                purchaseButton.setBackgroundColor(.TMColorWithRGBFloat(227, green: 227, blue: 227, alpha: 1), forState: .normal)
                purchaseButton.setTitleColor(UIColor.darkGray, for: .normal)
                self.purchaseButton.setTitle("Remove", for: .normal)
            } else {
                let initialButton = UIButton.button(style: .black) //This is a new button in its initial state made so that we can set the purchase button to its background and text color.
                guard let initialButtonBackgroundColor = initialButton.backgroundColor else {
                    return
                }
                purchaseButton.setBackgroundColor(initialButtonBackgroundColor, forState: .normal)
                purchaseButton.setTitleColor(initialButton.titleLabel?.textColor, for: .normal)
                self.purchaseButton.setTitle("Gift This", for: .normal)
            }
        }
    }
    
    // Item object
    var item: TMItem? {
        didSet {
            
            // Safety check
            guard let _item = self.item else {
                
                return
            }
            
            if let _imageURL = _item.product?.primaryImage?.imageURL {
                
                // Download Item image
                self.imageView.downloadImageFrom(link: _imageURL, contentMode: .scaleAspectFit)
            }
            
            // Item title
            self.displayNameLabel.text = _item.title
            
            // Price
            if let _product = _item.product {
                self.priceLabel.text = _product.copyPriceString
            }
            
            if let itemsCount = self.cart?.itemsArray.count, itemsCount > 0 {
                // Checking if item is already in cart
                self.itemInCart = self.cart!.isProductInCart(_item.productID!)
            }
            else {
                self.itemInCart = false
            }
            
            if self.item?.recommendation?.request?.status == .selection || self.item?.recommendation?.request?.status == .pending {
                
                self.purchaseButton.isHidden = false
            }
            else {
                
                self.purchaseButton.isHidden = true
            }
        }
    }
    
    // Item primary image view
    @IBOutlet var imageView: UIImageView!
    
    // Item display name label
    @IBOutlet var displayNameLabel: TMCopyLabel!
    
    // Item price label
    @IBOutlet var priceLabel : UILabel!
    
    var buttonAction: (() -> ())?
    
    fileprivate lazy var purchaseButton: UIButton = {
        let button = UIButton.button(style: .black)
        
        button.setTitle("Gift This", for: .normal)
        button.addTarget(self, action: #selector(addToCartButtonPressed), for: .touchUpInside)
        button.clipsToBounds = true
        
        return button
    }()
    
    // Add to cart button pressed
    func addToCartButtonPressed(_ sender: Any) {
        
        self.itemInCart = !self.itemInCart
        if let buttonAction = self.buttonAction {
            buttonAction()
        }
    }
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.displayNameLabel.delegate = self
    }
    
    // MARK: - Private
    
    private func customInit() {
        addSubview(purchaseButton)
        
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: purchaseButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: purchaseButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: purchaseButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 96 / 210, constant: 0),
            NSLayoutConstraint(item: purchaseButton, attribute: .height, relatedBy: .equal, toItem: purchaseButton, attribute: .width, multiplier: 30 / 96, constant: 0)
            ])
    }
}

extension TMItemDetailTitleCollectionViewCell: TMCopyLabelDelegate {
    func labelCopied(_ label: TMCopyLabel) {
        
        if let product = self.item?.product {
            
            var analyticsDict = [String: String]()
            
            if let productID = product.id {
                
                analyticsDict["product_id"] = productID
            }
            
            if let productName = product.title {
                
                analyticsDict["product_title"] = productName
            }
            
            TMAnalytics.trackEventWithID(.t_S7_7, eventParams: analyticsDict)
        }
    }
}
