//
//  TMItemImageCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMItemImageCollectionViewCell: UICollectionViewCell {
    
    fileprivate var _image: TMImage?
    var image: TMImage? {
        set {
            
            _image = newValue
            
            self.imageView.downloadImageFrom(link: _image?.imageURL, frame: self.frame, contentMode: .scaleAspectFit)
        }
        get {
            
            return _image
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.setFrameWidth(self.frame.width)
        self.imageView.setFrameHeight(self.frame.height)
    }
}
