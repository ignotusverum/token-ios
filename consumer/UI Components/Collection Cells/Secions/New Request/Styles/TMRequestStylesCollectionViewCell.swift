//
//  TMRequestStylesCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

protocol TMRequestStylesCollectionViewCellDelegate {
    
    func selectedStylesUpdated(cell: TMRequestStylesCollectionViewCell, _ styles: [TMRequestAttribute])
}

class TMRequestStylesCollectionViewCell: UICollectionViewCell, NestedCollectionViewCell {

    /// Delegate
    var delegate: TMRequestStylesCollectionViewCellDelegate?
    
    @IBOutlet internal var collectionView: TMIndexedCollectionView?
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel?
    
    var selectedStyles: [TMRequestAttribute] = []
    
    private var _contentSize: CGSize?
    var contentSize: CGSize? {

        get {
            let defaultSize = contentView.size

            /// Collection view size
            guard let collectionView = collectionView else {
                return defaultSize
            }
            
            /// If already set
            guard let _contentSize = _contentSize else {
                
                /// Update content height
                /// Title + Collection view + inset
                let height = collectionView.collectionViewLayout.collectionViewContentSize.height
                
                /// Title Height
                let titleHeight: CGFloat = 15
                
                /// Top constraint
                let top: CGFloat = 15
                
                size = CGSize(width: collectionView.frameWidth(), height: height + titleHeight + top)
                
                /// Update setter
                self._contentSize = size
                
                return size
            }
            
            return _contentSize
        }
        set {
            
            _contentSize = newValue
        }
    }
    
    /// Static data - for testing
    var stylesArray: [TMRequestAttribute] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom flow
    var flow: TMStyleCollectionFlowLayout?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "TMRequestStyleCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "TMRequestStyleCollectionViewCell")
        
        let result = TMStyleCollectionFlowLayout()
        result.alignment = .center
        result.estimatedItemSize = CGSize(width: 90.0, height: 50.0)
        result.sectionInset = UIEdgeInsetsMake(15.0, 10, 45.0, 10)
        
        collectionView?.collectionViewLayout = result
        
        collectionView?.reloadData()
    }
}

// MARK: - CollectionView Datasource
extension TMRequestStylesCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return stylesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TMRequestStyleCollectionViewCell", for: indexPath) as! TMRequestStyleCollectionViewCell
        
        let leftInset = flow?.sectionInset.left ?? 10
        let rightInset = flow?.sectionInset.right ?? 10
        cell.maxWidthConstraint.constant = collectionView.bounds.width - leftInset - rightInset - cell.layoutMargins.left - cell.layoutMargins.right - 10
        
        let attributes = stylesArray[indexPath.row]
        cell.styleTitleLabel.text = attributes.name
        
        return cell;
    }
}

// MARK: - CollectionView Delegate
extension TMRequestStylesCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! TMRequestStyleCollectionViewCell
        
        let style = stylesArray[indexPath.row]
        
        if !selectedStyles.contains(style) {
            
            selectedStyles.append(style)
            cell.addCellGradientBorder()
            
            delegate?.selectedStylesUpdated(cell: self, selectedStyles)
            
            return
        }
        
        
        cell.removeGradientLayer()
        
        if let index = selectedStyles.index(of: style) {
            selectedStyles.remove(at: index)
            delegate?.selectedStylesUpdated(cell: self, selectedStyles)
        }
    }
}
