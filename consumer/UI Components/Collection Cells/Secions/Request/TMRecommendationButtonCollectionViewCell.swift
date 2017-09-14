//
//  TMRecommendationButtonCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMRecommendationButtonCollectionViewCellDelegate {
    func recommendationButtonPressed(_ recommendation: TMRecommendation?)
}

class TMRecommendationButtonCollectionViewCell: UICollectionViewCell {

    
    // Delegate
    var delegate: TMRecommendationButtonCollectionViewCellDelegate?
    
    // Recommendation
    var recommendation: TMRecommendation?
    
    // Recommendation action passing to delegate
    @IBAction func recommendationButtonPressed(_ sender: AnyObject) {
        delegate?.recommendationButtonPressed(self.recommendation)
    }
    
    fileprivate lazy var browseGiftSetButton: UIButton = {
        let button = UIButton.button(style: .gold)
        
        button.setTitle("Browse Gift Set", for: .normal)
        button.addTarget(self, action: #selector(recommendationButtonPressed), for: .touchUpInside)
        
        return button
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
    
    // MARK: - Private
    
    private func customInit() {
        addSubview(browseGiftSetButton)
        
        browseGiftSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: browseGiftSetButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: browseGiftSetButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: browseGiftSetButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 94 / 187, constant: 0),
            NSLayoutConstraint(item: browseGiftSetButton, attribute: .height, relatedBy: .equal, toItem: browseGiftSetButton, attribute: .width, multiplier: 34 / 94, constant: 0)
            ])
    }

}
