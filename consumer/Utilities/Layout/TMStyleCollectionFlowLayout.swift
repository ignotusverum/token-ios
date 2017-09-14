//
//  TMStyleCollectionFlowLayout.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import Foundation

enum TMStyleFlowAlignment {
    case justyfied
    case left
    case right
    case center
}

class TMStyleCollectionFlowLayout: UICollectionViewFlowLayout {

    /// Cache
    private var cache = NSCache<NSIndexPath, UICollectionViewLayoutAttributes>()
    
    /// Default flow alignment
    var alignment: TMStyleFlowAlignment = .center {
        didSet {
            
            /// Invalidate layout
            invalidateLayout()
        }
    }
    
    override func prepare() {
        super.prepare()
        
        cache = NSCache()
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        cache = NSCache()
    }
    
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        if alignment == .justyfied {
            return attributes
        }
        
        return layoutAttributesFor(elements: attributes)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if alignment == .justyfied {
            return super.layoutAttributesForItem(at: indexPath)
        }
        
        return self.attributesAt(indexPath: indexPath)
    }
    
    // MARK: - Utilities
    private func layoutAttributesFor(elements: [UICollectionViewLayoutAttributes])-> [UICollectionViewLayoutAttributes] {
        
        var alignedAttributes: [UICollectionViewLayoutAttributes] = []
        
        for item in elements {
            if item.representedElementKind != nil {
                alignedAttributes.append(item)
            }
            else {
                alignedAttributes.append(layoutAttributesFor(item: item, at: item.indexPath))
            }
        }
        
        return alignedAttributes
    }
    
    private func layoutAttributesFor(item: UICollectionViewLayoutAttributes, at indexPath: IndexPath)-> UICollectionViewLayoutAttributes {
        return self.attributes(item, at: indexPath)
    }
    
    private func attributesAt(indexPath: IndexPath)-> UICollectionViewLayoutAttributes {
        
        let attributes = super.layoutAttributesForItem(at: indexPath)!
        return self.attributes(attributes, at: indexPath)
    }
    
    private func attributes(_ attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath)-> UICollectionViewLayoutAttributes {
        
        /// Checking for caching attributes
        if let catchedAttributes = cache.object(forKey: NSIndexPath(row: indexPath.row, section: indexPath.section)) {
            return catchedAttributes
        }
        
        /// Aligning items
        var itemsInRow: [UICollectionViewLayoutAttributes] = []
        
        let totalInSection = collectionView?.numberOfItems(inSection: indexPath.section) ?? 0
        let width = collectionView?.bounds.width ?? 0.0
        let rowFrame = CGRect(x: 0.0, y: attributes.frame.minY, w: width, h: attributes.frame.height)
        
        /// Go forward to the end of the row or section items
        var index = indexPath.row
        
        // Check forward
        // Go though items in section and adjust them if they intersect with new row frame
        /// Adjusts them by left border
        while index < totalInSection - 1 {
            
            index += 1
            
            let next = super.layoutAttributesForItem(at: IndexPath(row: index, section: indexPath.section))
            
            guard let _next = next else {
                return attributes
            }
            
            if !_next.frame.intersects(rowFrame) {
                break
            }
            
            itemsInRow.append(_next)
        }
        
        /// Current item
        itemsInRow.append(attributes)
        
        /// Go though items in section and adjust them if they intersect with new row frame
        /// Adjusts them by right border
        index = indexPath.row
        while index > 0 {
            
            index -= 1
            
            let previous = super.layoutAttributesForItem(at: IndexPath(row: index, section: indexPath.section))
            
            guard let _previous = previous else {
                return attributes
            }
            
            if !_previous.frame.intersects(rowFrame) {
                break
            }
            
            itemsInRow.append(_previous)
        }
        
        /// Total items width include spacings
        var totalWidth = minimumInteritemSpacing * CGFloat((itemsInRow.count - 1))
        for item in itemsInRow {
            totalWidth += item.frame.width
        }
        
        /// Correct sorting in row
        itemsInRow.sort { $0.0.indexPath.row > $0.1.indexPath.row }
        
        var rect = CGRect.zero
        for item in itemsInRow {
            
            var frame = item.frame
            var x = frame.origin.x
            
            if rect.isEmpty {
                switch alignment {
                case .left:
                    x = sectionInset.left
                case .center:
                    x = (width - totalWidth) / 2.0
                case .right:
                    x = width - totalWidth - sectionInset.right
                default:
                    break
                }
            }
            else {
                x = rect.maxX + minimumInteritemSpacing
            }
            
            frame.origin.x = x
            item.frame = frame
            rect = frame
            
            cache.setObject(attributes, forKey: NSIndexPath(item: indexPath.row, section: indexPath.section))
        }
        
        cache.setObject(attributes, forKey: NSIndexPath(item: indexPath.row, section: indexPath.section))
        
        return attributes
    }
}
