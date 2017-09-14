//
//  TMAttributeCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMAttributeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    
    @IBOutlet var selectedImage: UIImageView?
    @IBOutlet var attributeImage: UIImageView?
    
    let strokeTextAttributes: [String: Any] = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName : -0.1,
        NSFontAttributeName: UIFont.ActaMedium(16)
        ]
    
    var attribute: TMRequestAttribute? {
        didSet {
            
            if attribute != nil {
                
                if let attributeName = attribute?.name {
                    
                    self.nameLabel?.attributedText = NSAttributedString(string: attributeName, attributes: strokeTextAttributes)
                }
            }
        }
    }
    
    var attributeSelected: Bool = false {
        didSet {
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                
                if self.attributeSelected {
                    
                    self.selectedImage?.alpha = 1.0
                    
                    self.transform = CGAffineTransform(translationX: 0.0, y: -5.0)
                }
                else {
                    self.selectedImage?.alpha = 0.0
                    
                    self.transform = CGAffineTransform.identity
                }
                
            }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.layer.cornerRadius != 2.0 {
            self.layer.cornerRadius = 2.0
        }
        
        nameLabel?.adjustsFontSizeToFitWidth = true
        nameLabel?.minimumScaleFactor = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()

        if let originalImageURL = attribute?.imageURL {
            
            self.attributeImage?.downloadImageFrom(link: originalImageURL, contentMode: .scaleAspectFill)
        }
        else {
            
            self.attributeImage?.image = UIImage()
        }
    }
}
