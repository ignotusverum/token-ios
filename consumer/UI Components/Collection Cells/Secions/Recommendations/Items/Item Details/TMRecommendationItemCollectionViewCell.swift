//
//  TMRecommendationItemCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/6/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit
import EZSwiftExtensions
import JDStatusBarNotification

// Protocol
protocol TMRecommendationItemCollectionViewCellDelegate {
    
    func purchaseButtonPressedForItem(_ item: TMItem)
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType)
}

class TMRecommendationItemCollectionViewCell: UICollectionViewCell {
    
    struct ItemDetailsSections {
        
        var item: TMItem?
        
        var headerSection: Int?
        var tokenSection: Int?
        var productImagesSection: Int?
        var detailsSection: Int?
        var ratingSection: Int?
        
        var numberOfSections: Int
        
        var numberOfImages: Int? {
            
            if let _itemImagesArray = item?.product?.images.array {
                return _itemImagesArray.count
            }
            
            return nil
        }
        
        init() {
            
            numberOfSections = 0
        }
        
        init(item: TMItem?) {
            
            guard let item = item else {
                
                numberOfSections = 0
                
                return
            }
            
            self.item = item
            
            headerSection = 0
            numberOfSections = 1
            
            if let tokenDescription = item.itemDescription, tokenDescription.length > 0 {
                numberOfSections += 1
                tokenSection = numberOfSections - 1
            }
            
            if let imagesCount = item.product?.imagesArray.count, imagesCount > 1 {
                numberOfSections += 1
                productImagesSection = numberOfSections - 1
            }
            
            if let productDescription = item.product?.productDescription, productDescription.length > 0 {
                numberOfSections += 1
                detailsSection = numberOfSections - 1
            }
            
            /// Rating section
            numberOfSections += 1
            ratingSection = numberOfSections - 1
        }
    }
    
    let kCellIdentifier = "ItemDescriptionCell"
    
    // Delegate
    var delegate: TMRecommendationItemCollectionViewCellDelegate?
    
    // Item Object
    var item: TMItem? {
        didSet {
            /// Update only if item is not removed
            /// Af it's removed and collection reloaded datasource won't be updated
            if item?.feedbackType != .remove {
                collectionView.reloadData()
            }
        }
    }
    
    // Item Details section logic
    var itemDetailsSection = ItemDetailsSections()
    
    // Collection view
    lazy var collectionView: UICollectionView = {
       
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        let myCellNib = UINib(nibName: "TMItemDetailsCollectionViewCell", bundle: nil)
        collectionView.register(myCellNib, forCellWithReuseIdentifier: "ItemDescriptionCell")
        
        let tokenDescription = UINib(nibName: "TMTokenDescriptionCollectionViewCell", bundle: nil)
        collectionView.register(tokenDescription, forCellWithReuseIdentifier: "TMTokenDescriptionCollectionViewCell")
        
        let itemTitle = UINib(nibName: "TMItemDetailTitleCollectionViewCell", bundle: nil)
        collectionView.register(itemTitle, forCellWithReuseIdentifier: "TMItemDetailTitleCollectionViewCell")
        
        let itemImage = UINib(nibName: "TMRecommendationItemImageCollectionViewCell", bundle: nil)
        collectionView.register(itemImage, forCellWithReuseIdentifier: "TMRecommendationItemImageCollectionViewCell")
        
        collectionView.register(TMItemDetailsFeedbackCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMItemDetailsFeedbackCollectionViewCell.self)")
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        return collectionView
    }()
    
    // A dictionary of offscreen cells that are used within the sizeForItemAtIndexPath method to handle the size calculations. These are never drawn onscreen. The dictionary is in the format:
    // { NSString *reuseIdentifier : UICollectionViewCell *offscreenCell, ... }
    var offscreenCells = Dictionary<String, UICollectionViewCell>()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(
            [NSLayoutConstraint(item: collectionView, attribute: .topMargin, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .bottomMargin, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: 0)]
        )
     
        // Product viewed
        TMCommerceAnalytics.trackViewedForProduct(item?.product)
        
        if item?.product == nil {
            
            // Pulling prodzuct, if it's still loading
            if let productID = item?.productID {
                
                TMProductAdapter.fetch(productID: productID).then { result-> Void in
                    
                    self.item?.product = result
                    
                    if self.itemDetailsSection.numberOfSections == 0 {
                        self.itemDetailsSection = ItemDetailsSections(item: self.item)
                    }
                    
                    self.collectionView.reloadData()
                }.catch { error in
                        
                        JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }
        }
        else {
            
            itemDetailsSection = ItemDetailsSections(item: item)
            
            ez.runThisAfterDelay(seconds: 0.1) {
                self.collectionView.reloadData()
            }
        }
    }
    
    // Actions
    func purchaseButtonPressed() {
        
        guard let _item = item else {
            return
        }
        
        delegate?.purchaseButtonPressedForItem(_item)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if collectionView.numberOfSections > 0 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - CollectionView Datasource
extension TMRecommendationItemCollectionViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return itemDetailsSection.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfRows = 1
        
        // Count of product images
        if section == itemDetailsSection.productImagesSection {
            numberOfRows = itemDetailsSection.numberOfImages ?? 0
        }
        
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if indexPath.section == itemDetailsSection.headerSection {
            
            let itemTitleCell = collectionView.dequeueReusableCell(withReuseIdentifier:"TMItemDetailTitleCollectionViewCell", for: indexPath) as? TMItemDetailTitleCollectionViewCell
            
            itemTitleCell?.cart = item?.recommendation?.request?.cart
            itemTitleCell?.item = item
            itemTitleCell?.buttonAction = {
                self.purchaseButtonPressed()
            }
            
            cell = itemTitleCell!
        }
        else if indexPath.section == itemDetailsSection.tokenSection {
            
            let descriptionCell = collectionView.dequeueReusableCell(withReuseIdentifier:"TMTokenDescriptionCollectionViewCell", for: indexPath) as? TMTokenDescriptionCollectionViewCell
            
            descriptionCell?.item = item
            
            if DeviceType.IS_IPHONE_6P {
                
                descriptionCell?.configCell(self.item?.itemDescription, contentFont: UIFont.MalloryBook(15.0))
            }
            else {
                descriptionCell?.configCell(self.item?.itemDescription, contentFont: UIFont.MalloryBook(14.0))
            }
            
            // Make sure layout subviews
            descriptionCell?.layoutIfNeeded()
            
            cell = descriptionCell!
        }
        else if indexPath.section == itemDetailsSection.productImagesSection {
            
            let itemImageCell = collectionView.dequeueReusableCell(withReuseIdentifier:"TMRecommendationItemImageCollectionViewCell", for: indexPath) as? TMRecommendationItemImageCollectionViewCell
            
            if let imagesArray = self.item?.product?.imagesArray {
                if indexPath.row < imagesArray.count {
                    
                    itemImageCell?.image = imagesArray[indexPath.row]
                }
            }
            
            cell = itemImageCell!
        }
        else if indexPath.section == itemDetailsSection.detailsSection {
            
            let descriptionCell = collectionView.dequeueReusableCell(withReuseIdentifier:kCellIdentifier, for: indexPath) as? TMItemDetailsCollectionViewCell
            
            if DeviceType.IS_IPHONE_6P {
                
                descriptionCell?.configCell(self.item?.product?.productDescription, contentFont: UIFont.ActaBook(17.0))
            }
            else {
                descriptionCell?.configCell(self.item?.product?.productDescription, contentFont: UIFont.ActaBook(16.0))
            }
            
            // Make sure layout subviews
            descriptionCell?.layoutIfNeeded()
            
            cell = descriptionCell!
        }
        else if indexPath.section == itemDetailsSection.ratingSection {
            
            let ratingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMItemDetailsFeedbackCollectionViewCell.self)", for: indexPath) as! TMItemDetailsFeedbackCollectionViewCell
            ratingCell.item = item
            ratingCell.delegate = self
            
            cell = ratingCell
        }
        
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return cell
    }
}

extension TMRecommendationItemCollectionViewCell: TMItemDetailsFeedbackCollectionViewCellDelegate {
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType) {
        self.delegate?.feedbackView(feedbackView, ratedItem: item, feedback: feedback)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TMRecommendationItemCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == itemDetailsSection.headerSection {
            
            let cellW = collectionView.frame.size.width - 22.0
            let cellH: CGFloat = 410.0
            
            return CGSize(width: cellW, height: cellH)
        }
        else if indexPath.section == itemDetailsSection.tokenSection ||  indexPath.section == itemDetailsSection.detailsSection {
            
            // Set up desired width
            let targetWidth: CGFloat = collectionView.frame.size.width - 22.0
            
            // Use fake cell to calculate height
            
            var cell: TMDynamicHeightCollectionViewCell?
            
            if indexPath.section == itemDetailsSection.tokenSection {
                
                cell = Bundle.main.loadNibNamed("TMTokenDescriptionCollectionViewCell", owner: self, options: nil)?[0] as? TMDynamicHeightCollectionViewCell
            }
            else {
                
                cell = Bundle.main.loadNibNamed("TMItemDetailsCollectionViewCell", owner: self, options: nil)?[0] as? TMDynamicHeightCollectionViewCell
            }
            
            // Config cell and let system determine size
            
            if indexPath.section == itemDetailsSection.tokenSection {
                
                if DeviceType.IS_IPHONE_6P {
                    
                    cell?.configCell(self.item?.itemDescription, contentFont: UIFont.MalloryBook(15.0))
                }
                else {
                    cell?.configCell(self.item?.itemDescription, contentFont: UIFont.MalloryBook(14.0))
                }
            }
            else {
                
                if DeviceType.IS_IPHONE_6P {
                    
                    cell?.configCell(self.item?.product?.productDescription, contentFont: UIFont.ActaBook(17.0))
                }
                else {
                    cell?.configCell(self.item?.product?.productDescription, contentFont: UIFont.ActaBook(16.0))
                }
            }
            
            // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
            cell!.bounds = CGRect(x: 0, y: 0, w: targetWidth, h: cell!.bounds.height)
            cell!.contentView.bounds = cell!.bounds
            
            // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
            cell!.setNeedsLayout()
            cell!.layoutIfNeeded()
            
            var size = cell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            // Still need to force the width, since width can be smalled due to break mode of labels
            size.width = targetWidth
            
            return size
        }
            /// Rating size
        else if indexPath.section == itemDetailsSection.ratingSection{
            return CGSize(width: collectionView.frame.size.width - 22.0, height: 60.0)
        }
        
        // Product images section
        return CGSize(width: collectionView.frame.size.width - 22.0, height: 336.0)
    }
}
