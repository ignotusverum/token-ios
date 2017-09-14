//
//  TMRecommendationsCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

// MARK: - Delegate

protocol TMRecommendationsCollectionViewCellDelegate {
    
    func buyButtonPressed(forItem item: TMItem?)
    func chatButtonPressed(_ sender: AnyObject)
}

class TMRecommendationsCollectionViewCell: UICollectionViewCell, NestedCollectionViewCell {
    
    @IBOutlet internal var collectionView: TMIndexedCollectionView?
    
    @IBOutlet var _pageControl: UIPageControl!
    
    var delegate: TMRecommendationsCollectionViewCellDelegate?
    
    var imagesArray: [TMImage] = []
    
    // MARK: - Accessors
    
    fileprivate var _item: TMItem?
    var item: TMItem? {
        get {
            return _item
        }
        set {
            
            _item = newValue
            
            if (_item?.product?.imagesArray.count)! > 0 {
                
                imagesArray = (item?.product?.imagesArray)!
                collectionView?.reloadData()
            }
            
            _recommendationDescriptionTitleLabel.text = _item?.title
            _recommendationDescriptionLabel.text = _item?.itemDescription
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet fileprivate var _recommendationDescriptionLabel: UILabel!
    @IBOutlet fileprivate var _recommendationDescriptionTitleLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func buyButtonPressed(_ sender: AnyObject) {
        
        if delegate != nil {
            delegate?.buyButtonPressed(forItem: self.item)
        }
    }
    
    @IBAction func chatButtonPressed(_ sender: AnyObject) {
        
        if delegate != nil {
            delegate?.chatButtonPressed(sender)
        }
    }
    
    func customInit() {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        
        layout.scrollDirection = .horizontal
        
        collectionView?.collectionViewLayout = layout
        collectionView?.reloadData()
    }
}

// MARK: - CollectionView Datasource

extension TMRecommendationsCollectionViewCell: UICollectionViewDataSource {
    
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

extension TMRecommendationsCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellW = collectionView.frame.size.width
        let cellH: CGFloat = collectionView.frame.size.height
        
        return CGSize(width: cellW, height: cellH)
    }
}
