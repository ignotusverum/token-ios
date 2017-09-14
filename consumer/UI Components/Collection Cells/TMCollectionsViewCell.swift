//
//  TMCollectionsViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//


protocol NestedCollectionViewCell {
    
    var collectionView: TMIndexedCollectionView? { get set }
}

class TMIndexedCollectionView: UICollectionView {
    
    var indexPath: NSIndexPath?
}

class TMCollectionsViewCell: UICollectionViewCell {

    var collectionView: TMIndexedCollectionView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.customInit()
    }
    
    func customInit() {
        
        self.collectionView?.backgroundColor = UIColor.white
        
        self.collectionView?.reloadData()
    }
}
