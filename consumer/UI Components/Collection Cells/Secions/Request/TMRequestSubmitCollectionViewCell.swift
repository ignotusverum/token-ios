//
//  TMRequestSubmitCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/27/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMRequestSubmitCollectionViewCellDelegate {
    
    func onSubmitButton()
}

class TMRequestSubmitCollectionViewCell: UICollectionViewCell {
    
    var delegate: TMRequestSubmitCollectionViewCellDelegate?
    
    // MARK: - Private iVars

    fileprivate lazy var requestGiftButton: UIButton = {
        let button = UIButton.button(style: .gold)
        
        button.setTitle("Submit Request", for: .normal)
        button.addTarget(self, action: #selector(onRequestButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Public

    override func layoutSubviews() {
        super.layoutSubviews()
        
        customInit()
    }
    
    // MARK: - Private
    private func customInit() {
        addSubview(requestGiftButton)
        
        requestGiftButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: requestGiftButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: requestGiftButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: requestGiftButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 108 / 187, constant: 0),
            NSLayoutConstraint(item: requestGiftButton, attribute: .height, relatedBy: .equal, toItem: requestGiftButton, attribute: .width, multiplier: 34 / 94, constant: 0)
            ])
    }
    
    // MARK: - Actions
    func onRequestButton(_ sender: UIButton) {
        delegate?.onSubmitButton()
    }
}
