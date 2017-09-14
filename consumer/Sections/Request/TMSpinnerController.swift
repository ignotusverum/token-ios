//
//  TMSpinnerController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/22/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import IGListKit

func spinnerSectionController() -> IGListSingleSectionController {
    let configureBlock = { (item: Any, cell: UICollectionViewCell) in
        guard let cell = cell as? SpinnerCell else { return }
        cell.activityIndicator.startAnimating()
    }
    
    let sizeBlock = { (item: Any, context: IGListCollectionContext?) -> CGSize in
        guard let context = context else { return .zero }
        return CGSize(width: context.containerSize.width, height: 100)
    }
    
    return IGListSingleSectionController(cellClass: SpinnerCell.self,
                                         configureBlock: configureBlock,
                                         sizeBlock: sizeBlock)
}

class SpinnerCell: UICollectionViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
