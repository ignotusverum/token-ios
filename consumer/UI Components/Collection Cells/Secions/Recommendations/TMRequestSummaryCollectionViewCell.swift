//
//  TMRequestSummaryCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//



class TMRequestSummaryCollectionViewCell: UICollectionViewCell, NestedCollectionViewCell {
    
    @IBOutlet internal var collectionView: TMIndexedCollectionView?
    
    var imagesArray: [TMImage] = []
    
    @IBOutlet var _pageControl: UIPageControl!
    
    // MARK: - Accessors
    
    fileprivate var _item: TMItem?
    var item: TMItem? {
        get {
            return _item
        }
        set {
            
            _item = newValue
            
            let config = TMConsumerConfig.shared
            //            self._paymentLabel.text = config.currentUser?.defaultCreditCard?.last4
            
            let titleString = String(format: "To: %@\nFrom: %@", "friend", (config.currentUser?.firstName)!)
            self._summaryTitleLabel.text = titleString
            
            self._summaryDescriptionLabel.text = "test etst\n test test]m test test"
            
            if (_item?.product?.imagesArray.count)! > 0 {
                
                imagesArray = (_item?.product?.imagesArray)!
                self.collectionView?.reloadData()
            }
        }
    }
    
    @IBOutlet fileprivate var _paymentLabel: UILabel!
    @IBOutlet fileprivate var _summaryTitleLabel: UILabel!
    @IBOutlet fileprivate var _summaryDescriptionLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        
        layout.scrollDirection = .horizontal
        
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.reloadData()
    }
}

// MARK: - CollectionView Datasource - image slider

extension TMRequestSummaryCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"itemImageCell", for: indexPath) as! TMItemImageCollectionViewCell
        
        if cell.image == nil {
            cell.image = item?.product?.imagesArray[indexPath.row]
        }
        
        return cell
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = self.collectionView?.frame.size.width
        var currentPage: Int = Int((self.collectionView?.contentOffset.x)! / pageWidth!)
        
        if fmodf(Float(currentPage), 1.0) != 0.0 {
            
            if currentPage <= (self.item?.product?.imagesArray.count)! {
                currentPage += 1
            }
        }
        
        self._pageControl.currentPage = currentPage
    }
}

extension TMRequestSummaryCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellW = collectionView.frame.size.width
        let cellH: CGFloat = collectionView.frame.size.height
        
        return CGSize(width: cellW, height: cellH)
    }
}
 
