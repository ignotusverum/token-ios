//
//  TMRequestCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMRequestCollectionViewCell: UICollectionViewCell, RequestCellProtocol {
    // MARK: - Public iVars

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
    
    /// View layer.
    override var layer: CALayer {
        let layer = super.layer
        
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.cornerRadius = 2
        
        return layer
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
    
    // MARK: - Private iVars
    
    /// View representing badge on top of status label.
    private var badgeView: TMBadgeView = {
        let view = TMBadgeView()
        
        view.backgroundColor = .TMColorWithRGBFloat(255.0, green: 103.0, blue: 93.0, alpha: 1.0)
        view.textColor = .white
        
        return view
    }()
    
    /// Label for status of request.
    private var statusLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.layer.cornerRadius = 1
        label.layer.borderWidth = 1
        
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
        
        guard let request = request else {
            print("Request is nil.")
            return
        }
        
        //---Layer---//
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        //---Contact Label---//
        
        if let contactName = request.contact?.fullName {
            let contactAttributedString = generateContactNameLabelAttributedString(text: contactName, textColor: UIColor.TMGrayPlaceholder, textSize: 18)
            nameLabel.attributedText = contactAttributedString
        }
        
        //---Info Label---//
        
        let occasionText = generateOccasionText(from: request)
        infoLabel.attributedText = generateRequestInformationLabelAttributedString(text: occasionText, textColor: UIColor.TMGrayPlaceholder, textSize: 11)
        
        //---Status Label---//
        
        let wasRequestViewed = requestViewed(request: request) //Determines if request was viewed by user.
        
        if let status = request.displayStatus {
            let statusColors = statusLabelColors(for: request.status, requestViewed: wasRequestViewed)
            
            let statusAttributedString = generateStatusLabelAttributedString(text: status.uppercased(), textColor: statusColors.textColor, textSize: 8)
            statusLabel.attributedText = statusAttributedString
            
            statusLabel.backgroundColor = statusColors.backgroundColor
            statusLabel.layer.borderColor = statusColors.borderColor.cgColor
        }
        
        //---Badge View---//
        
        // Set badge text.
        let count = request.recommendationCount + request.conversationNotificationCount
        if count > 0  {
            
            badgeView.isHidden = false
            badgeView.badgeText = "\(count)"
        }
        else {
            
            badgeView.isHidden = true
        }
        
        //---View Layout---//
        let statusLabelSize = statusLabel.textRect(forBounds: bounds, limitedToNumberOfLines: 1) //Size of the label text.
        
        var layout = RequestCellLayout(image: avatarImageView, name: nameLabel, info: infoLabel, status: RequestStatusLayout(layout: statusLabel, width: statusLabelSize.width), badge: badgeView)
        layout.layout(in: bounds)
        
        //---Image View---//
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
    
    // MARK: - Private

    private func customInit() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(infoLabel)
        addSubview(badgeView)
        
        backgroundColor = .white
    }
}
