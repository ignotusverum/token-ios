//
//  TMRequestStatusContactCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMRequestStatusContactCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Pubblic iVars
    var request: TMRequest? {
        didSet {
         
            requestStatusView?.request = request
        }
    }
    
    // Status view
    @IBOutlet weak var requestStatusView: TMRequestInfoStatusView?
    
}
