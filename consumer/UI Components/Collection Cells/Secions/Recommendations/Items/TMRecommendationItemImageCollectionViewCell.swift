//
//  TMRecommendationItemImageCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMRecommendationItemImageCollectionViewCell: UICollectionViewCell {
    
    // Image View
    @IBOutlet var imageView: UIImageView!
    
    var image: TMImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let _image = image else {
            return
        }
        
        imageView.downloadImageFrom(link: _image.imageURL, contentMode: .scaleAspectFit)
    }
}
