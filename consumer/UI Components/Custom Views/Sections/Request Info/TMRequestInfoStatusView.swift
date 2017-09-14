//
//  TMRequestInfoStatusView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMRequestInfoStatusView: UIView, RequestCellProtocol {

    // MARK: - Pubblic iVars
    
    var request: TMRequest? {
        didSet {
            setNeedsLayout()
            
            //Sets up contact image for request.
            if let request = request {
                generateAvatarImage(from: request) { (image: UIImage?) in
                    DispatchQueue.main.async { () -> Void in
                        self.avatarImageView.image = image
                    }
                }
            }
        }
    }
    
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        
        return label
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        
        return label
    }()
    
    // MARK: - Public
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let request = request else {
            print("Request is nil.")
            return
        }
        
        //---Layer---//
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath

        //---Contact Label---//
        
        if let contactName = request.contact?.fullName {
            
            let textSize: CGFloat = DeviceType.IS_IPHONE_5 ? 20 : 24
            let contactAttributedString = generateContactNameLabelAttributedString(text: contactName, textColor: UIColor.TMBlackColor, textSize: textSize)
            nameLabel.attributedText = contactAttributedString
        }
        
        //---Info Label---//
        
        let occasionText = generateOccasionText(from: request)
        
        let textSize: CGFloat = DeviceType.IS_IPHONE_5 ? 12 : 14
        infoLabel.attributedText = generateRequestInformationLabelAttributedString(text: occasionText, textColor: UIColor.TMGrayCell, textSize: textSize)
        
        //---View Layout---//
        
        var layout = RequestStatusCellLayout(image: avatarImageView, name: nameLabel, info: infoLabel)
        layout.layout(in: bounds)
        
        //---Image View---//
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
    
    // MARK: - Private
    
    private func customInit() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(infoLabel)
        
        backgroundColor = .clear
    }
}
