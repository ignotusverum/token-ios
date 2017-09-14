//
//  TMEmptyDataset.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMEmptyDataset: UIView {
    
    //MARK: - Strings
    
    /// String for description.
    private var descriptionString: String? {
        set {
            if let newValue = newValue {
                let attributeString = NSMutableAttributedString(string: newValue)
                let style = NSMutableParagraphStyle()
                
                style.lineSpacing = 7
                style.alignment = .center
                
                attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, newValue.characters.count))
                descriptionLabel.attributedText = attributeString
            }
        }
        
        get {
            return descriptionLabel.text
        }
    }
    
    // MARK: - Public iVars
    
    /// Top Constraing for content view.
    var topConstraint: CGFloat!
    
    /// True if confetti should be enabled for view.
    var confettiEnabled = true {
        didSet {
            if !confettiEnabled {
                confettiView.stopConfetti()
            }
        }
    }
    
    /// Background confetti view.
    lazy var confettiView: TMConfettiView = {
        let view = TMConfettiView()
        
        return view
    }()
    
    //MARK: - Private iVars
    
    /// Content view in center.
    private lazy var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear //Background is clear because a shape layer will define the background color.
        
        return view
    }()
    
    /// Custom shape layer defining content view shape.
    private lazy var customShapeLayer: CAShapeLayer = TMBubble.generateBubble()

    /// Top banner image in content view.
    private var bannerImageView: UIImageView?
    
    /// Title label in content view.
    private var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.ActaBold(24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    /// Description label in content view.
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = DeviceType.IS_IPHONE_5 ? UIFont.ActaBook(13) : UIFont.ActaBook(16)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    //MARK: - Public.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(title: String, body: String, image: UIImage? = nil, topLayout: CGFloat = 340) {
        self.init(frame: CGRect.zero)
        
        titleLabel.text = title
        descriptionString = body
        topConstraint = topLayout
    
        if let image = image {
            bannerImageView = UIImageView(image: image)
        }
        
        customInit()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //---Confetti View---//
        
        //These are flags on seperate views, isActive is whether confetti is already running. (In which case we dont need more). Confetti enabled is whether confetti should run on the empty state at all.
        if !confettiView.isActive() && confettiEnabled {
            confettiView.startConfetti()
        }
        
        //---Custom Shape Layer---//
        
        backgroundColor = UIColor.clear
        customShapeLayer.path = TMBubble.generateBubble(frame: contentView.bounds)
        customShapeLayer.shadowPath = TMBubble.generateBubble(frame: contentView.bounds)
    }
    
    //MARK: - Private
    
    private func customInit() {
        //---Confetti View---//
        
        addSubview(confettiView)
        
        confettiView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: confettiView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: confettiView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: confettiView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: confettiView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Content View---//
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentViewSideMargin: CGFloat = 17
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: contentViewSideMargin))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -contentViewSideMargin))
        
        //---Custom Shape Layer---//
        
        contentView.layer.addSublayer(customShapeLayer)
        
        //---Description Label---//
        
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabelSideMargin: CGFloat = 25

        contentView.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: descriptionLabelSideMargin))
        contentView.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -descriptionLabelSideMargin))
        
        //---Title Label---//
        
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabelLabelSideMargin: CGFloat = 25
        
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: descriptionLabel, attribute: .top, multiplier: 1, constant: -20))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: titleLabelLabelSideMargin))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -titleLabelLabelSideMargin))
        
        //---Banner Image View---//
        
        guard let bannerImageView = bannerImageView else {
            
            // calculate size
            
            let descriptionSize = self.descriptionLabel.attributedText?.heightWithConstrainedWidth(ScreenSize.SCREEN_WIDTH - 50) ?? 0
            let titleSize = self.titleLabel.attributedText?.heightWithConstrainedWidth(ScreenSize.SCREEN_WIDTH - 50) ?? 0
            
            let contentSize = descriptionSize + titleSize + 100
            
            addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: topConstraint + contentSize - 10))
            addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant:
                contentSize))
            contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 35))
            
            return
        }
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 170/223, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -60)) //Allows for the desctription label to move down on smaller phones.
        
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: bannerImageView, attribute: .bottom, multiplier: 1, constant: 15))

        contentView.addSubview(bannerImageView)
        
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let bannerImageViewMargin = customShapeLayer.cornerRadius //Using the corner radius of the custom shape layer because the banner image view will cover the corners since it is not the view setting the corner radius.
        
        contentView.addConstraint(NSLayoutConstraint(item: bannerImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: bannerImageViewMargin))
        contentView.addConstraint(NSLayoutConstraint(item: bannerImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: bannerImageViewMargin))
        contentView.addConstraint(NSLayoutConstraint(item: bannerImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -bannerImageViewMargin))
        contentView.addConstraint(NSLayoutConstraint(item: bannerImageView, attribute: .width, relatedBy: .equal, toItem: bannerImageView, attribute: .height, multiplier: 680/528, constant: 0))
    }
}
