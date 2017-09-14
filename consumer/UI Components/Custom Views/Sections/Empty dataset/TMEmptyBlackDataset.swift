//
//  TMEmptyBlackDataset.swift
//  consumer
//
//  Created by Vlad Zagorodnyuk on 6/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMEmptyBlackDatasetDelegate {
    func buttonPressed(_ sender: Any)
}

class TMEmptyBlackDataset: UIView {
    
    // Initial view
    @IBOutlet var view: UIView!
    
    // delegate
    var delegate: TMEmptyBlackDatasetDelegate?
    
    // Title String
    var titleString: String? {
        didSet {
            // Safety check
            guard let _titleString = titleString else {
                return
            }
            
            // Checking
            self.titleLabel.text = _titleString
        }
    }
    @IBOutlet var titleLabel: UILabel!
    
    // Details copy
    var detailsCopy: String? {
        didSet {
            guard let _detailsCopy = detailsCopy else {
                return
            }
            
            // Spacing
            self.detailsLabel.attributedText = NSMutableAttributedString.initWithString(_detailsCopy, lineSpacing: 8.0, aligntment: .center)
        }
    }
    @IBOutlet var detailsLabel: UILabel!
    
    // Button copy
    var buttonCopy: String? {
        didSet {
            // Safety check
            guard let _buttonCopy = buttonCopy else {
                return
            }
            
            // Set button copy
            self.button.setTitle(_buttonCopy, for: .normal)
        }
    }
    
    @IBOutlet var button: UIButton!
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.delegate?.buttonPressed(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("TMEmptyBlackDataset", owner: self, options: nil)
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
}
