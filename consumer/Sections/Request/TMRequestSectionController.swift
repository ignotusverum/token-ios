//
//  TMRequestSectionController.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/13/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import IGListKit

protocol TMRequestSectionControllerProtocol {
    
    /// Cell has been tapped within TMRequestSectionController section.
    ///
    /// - Parameter request: Request representing cell tapped.
    func cellTapped(request: TMRequest)
}

class TMRequestSectionController: IGListSectionController {
    
    //MARK: - Public iVars
    
    /// Request to display in cell.
    var request: TMRequest?
    
    /// Delegate representing TMRequestSectionControllerProtocol.
    var delegate: TMRequestSectionControllerProtocol?
}

// MARK: - IGListSectionType
extension TMRequestSectionController: IGListSectionType {
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        var cellW: CGFloat = 172.0
        var cellH: CGFloat = 220.0
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            cellW = 145.0
            cellH = 200.0
        }
        else if DeviceType.IS_IPHONE_6P {
            cellW = 192.0
            cellH = 215.0
        }
        
        let size = CGSize(width: cellW, height: cellH)
        
        return size
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: TMRequestCollectionViewCell.self, for: self, at: index) as? TMRequestCollectionViewCell else {
            fatalError("Cell is incorrect type.")
        }
        
        guard let request = self.request else {
            fatalError("No request found for cell.")
        }
        
        cell.request = request
        
        return cell
    }
    
    func didSelectItem(at index: Int) {
        guard let request = self.request else {
            fatalError("No request found for cell.")
        }
        
        delegate?.cellTapped(request: request)
    }
    
    func didUpdate(to object: Any) {
        request = object as? TMRequest
    }
}
