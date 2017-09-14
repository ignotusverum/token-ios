//
//  TMHorizontalCollectionViewLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/14/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMHorizontalCollectionViewLayout: UICollectionViewFlowLayout {
    
    var cellWidth = 90
    var cellHeight = 90
    
    override var collectionViewContentSize: CGSize {
        
        let numberOfPages = Int(ceilf(Float(cellCount) / Float(cellsPerPage)))
        let width = numberOfPages * Int(boundsWidth)
        return CGSize(width: CGFloat(width), height: boundsHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        
        for i in 0 ..< cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = createLayoutAttributesForCellAtIndexPath(indexPath)
            allAttributes.append(attr)
        }
        
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return createLayoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    fileprivate func createLayoutAttributesForCellAtIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        layoutAttributes.frame = createCellAttributeFrame(indexPath.row)
        return layoutAttributes
    }
    
    fileprivate var boundsWidth:CGFloat {
        return self.collectionView!.bounds.size.width
    }
    
    fileprivate var boundsHeight:CGFloat {
        return self.collectionView!.bounds.size.height
    }
    
    fileprivate var cellCount:Int {
        return self.collectionView!.numberOfItems(inSection: 0)
    }
    
    fileprivate var verticalCellCount:Int {
        
        return Int(floorf(Float(boundsHeight) / Float(cellHeight)))
    }
    
    fileprivate var horizontalCellCount:Int {
        
        var cellCount = Int(floorf(Float(boundsWidth) / Float(cellWidth)))
        
        if cellCount == 0 {
            cellCount = 1
        }
        
        return cellCount
    }
    
    fileprivate var cellsPerPage:Int {
        
        return verticalCellCount * horizontalCellCount
    }
    
    fileprivate func createCellAttributeFrame(_ row:Int) -> CGRect {
        
        let frameSize = CGSize(width: cellWidth, height: cellHeight)
        let frameX = calculateCellFrameHorizontalPosition(row)
        let frameY = calculateCellFrameVerticalPosition(row)
        return CGRect(x: frameX, y: frameY, w: frameSize.width, h: frameSize.height)
    }
    
    fileprivate func calculateCellFrameHorizontalPosition(_ row:Int) -> CGFloat {
        
        let columnPosition = row % horizontalCellCount
        let cellPage = Int(floorf(Float(row) / Float(cellsPerPage)))
        return CGFloat(cellPage * Int(boundsWidth) + columnPosition * Int(cellWidth))
    }
    
    fileprivate func calculateCellFrameVerticalPosition(_ row:Int) -> CGFloat {
        
        let rowPosition = (row / horizontalCellCount) % verticalCellCount
        return CGFloat(rowPosition * Int(cellHeight))
    }
}
