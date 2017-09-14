//
//  TMBadgeView.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/16/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMBadgeView: UIView {
    
    // MARK: - Public iVars

    /// Text to display in badge.
    var badgeText: String? {
        didSet {
            badgeLabel.text = badgeText
        }
    }
    
    /// Color of badge text.
    var textColor: UIColor = .black {
        didSet {
            badgeLabel.textColor = textColor
        }
    }
    
    /// View layer.
    override var layer: CALayer {
        let layer = super.layer
        
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.cornerRadius = bounds.height / 2
        
        return layer
    }
    
    // MARK: - Private iVars
    
    /// Label in badge.
    private let badgeLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = UIFont.MalloryMedium(10)
        
        return label
    }()
    
    
    // MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //---Layer---//
    
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        //---Badge Label---//
        
        badgeLabel.frame = bounds
    }
    
    // MARK: - Private
    
    private func customInit() {
        addSubview(badgeLabel)
    }
}
