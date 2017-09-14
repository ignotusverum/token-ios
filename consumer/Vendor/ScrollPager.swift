//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

@objc public protocol ScrollPagerDelegate: NSObjectProtocol {
    @objc optional func scrollPager(_ scrollPager: ScrollPager, changedIndex: Int)
}

@IBDesignable open class ScrollPager: UIView, UIScrollViewDelegate{
    
    fileprivate var selectedIndex = 0
    fileprivate let indicatorView = UIView()
    var buttons = [UIButton]()
    
    fileprivate var visibleButtons = [UIButton]()
    fileprivate var views = [UIView]()
    fileprivate var animationInProgress = false
    @IBOutlet open weak var delegate: ScrollPagerDelegate!
    
    @IBOutlet open var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
            scrollView?.isPagingEnabled = true
            scrollView?.showsHorizontalScrollIndicator = false
        }
    }
    
    @IBInspectable open var textColor: UIColor = UIColor.lightGray {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var selectedTextColor: UIColor = UIColor.darkGray {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var font: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 13) {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var indicatorColor: UIColor = UIColor.black {
        didSet { indicatorView.backgroundColor = indicatorColor }
    }
    
    @IBInspectable open var indicatorSizeMatchesTitle: Bool = false {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var indicatorHeight: CGFloat = 2.0 {
        didSet { redrawComponents() }
    }
    
    @IBInspectable open var borderColor: UIColor? {
        didSet { self.layer.borderColor = borderColor?.cgColor }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    
    @IBInspectable open var animationDuration: CGFloat = 0.2
    
    // MARK: - Initializarion -
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    fileprivate func initialize() {
        #if TARGET_INTERFACE_BUILDER
            addSegmentsWithTitles(["One", "Two", "Three", "Four"])
        #endif
    }
    
    // MARK: - UIView Methods -
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        redrawComponents()
        //moveToIndex(selectedIndex, animated: false, moveScrollView: true)
    }
    
    // MARK: - Public Methods -
    
    open func addSegmentsWithTitlesAndViews(_ segments: [(title: String, view: UIView)]) {
        
        addButtons(segments.map { $0.title })
        addViews(segments.map { $0.view })
        
        redrawComponents()
    }
    
    open func addSegmentsWithImagesAndViews(_ segments: [(image: UIImage, view: UIView)]) {
        
        addButtons(segments.map { $0.image })
        addViews(segments.map { $0.view })
        
        redrawComponents()
    }
    
    open func addSegmentsWithTitles(_ segmentTitles: [Any]) {
        addButtons(segmentTitles)
        redrawComponents()
    }
    
    open func addSegmentsWithTitles(_ segmentTitles: [String], segmentImages: [UIImage]) {
        addButtons(segmentTitles as [AnyObject])
        redrawComponents()
    }
    
    open func addSegmentsWithImages(_ segmentImages: [UIImage]) {
        addButtons(segmentImages)
        redrawComponents()
    }
    
    open func setSelectedIndex(_ index: Int, animated: Bool) {
        setSelectedIndex(index, animated: animated, moveScrollView: true)
    }
    
    // MARK: - Private -
    
    fileprivate func setSelectedIndex(_ index: Int, animated: Bool, moveScrollView: Bool) {
        selectedIndex = index
        
        moveToIndex(index, animated: animated, moveScrollView: moveScrollView)
    }
    
    fileprivate func addViews(_ segmentViews: [UIView]) {
        for view in scrollView!.subviews {
            view.removeFromSuperview()
        }
        
        for i in 0..<segmentViews.count {
            let view = segmentViews[i]
            scrollView!.addSubview(view)
            views.append(view)
        }
    }
    
    fileprivate func addButtons(_ titleOrImages: [Any]) {
        for button in buttons {
            button.removeFromSuperview()
        }
        
        buttons.removeAll(keepingCapacity: true)
        visibleButtons.removeAll(keepingCapacity: true)
        
        for i in 0..<titleOrImages.count {
            let button = UIButton(type: .custom)
            let visibleButton = UIButton(type: .custom)
            
            button.tag = i
            visibleButton.tag = i
            
            button.addTarget(self, action: #selector(ScrollPager.buttonSelected(_:)), for: .touchUpInside)
            visibleButton.addTarget(self, action: #selector(ScrollPager.buttonSelected(_:)), for: .touchUpInside)
            
            buttons.append(button)
            visibleButtons.append(visibleButton)
            
            if let title = titleOrImages[i] as? String {
                button.setTitle(title, for: UIControlState())
            }
            else if let image = titleOrImages[i] as? UIImage {
                button.setImage(image, for: UIControlState())
            }
            
            addSubview(button)
            button.addSubview(visibleButton)
            addSubview(indicatorView)
        }
    }
    
    fileprivate func moveToIndex(_ index: Int, animated: Bool, moveScrollView: Bool) {
        animationInProgress = true
        
        UIView.animate(withDuration: animated ? TimeInterval(animationDuration) : 0.0, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            
            let width = self!.frame.size.width / CGFloat(self!.buttons.count)
            let button = self!.buttons[index]
            
            self?.redrawButtons()
            
            if self!.indicatorSizeMatchesTitle {
                let string: NSString? = button.titleLabel?.text as NSString?
                let size = string?.size(attributes: [NSFontAttributeName: button.titleLabel!.font])
                let x = width * CGFloat(index) + ((width - size!.width) / CGFloat(2))
                self!.indicatorView.frame = CGRect(x: x, y: self!.frame.size.height - self!.indicatorHeight, width: size!.width, height: self!.indicatorHeight)
            }
            else {
                self!.indicatorView.frame = CGRect(x: width * CGFloat(index), y: self!.frame.size.height - self!.indicatorHeight, width: button.frame.size.width, height: self!.indicatorHeight)
            }
            
            if self!.scrollView != nil && moveScrollView {
                self!.scrollView?.contentOffset = CGPoint(x: CGFloat(index) * self!.scrollView!.frame.size.width, y: 0)
            }
            
            }, completion: { [weak self] finished in
                // Storyboard crashes on here for some odd reasons, do a nil check
                if self != nil {
                    self!.animationInProgress = false
                }
        })
    }
    
    fileprivate func redrawComponents() {
        redrawButtons()
        
        if buttons.count > 0 {
            moveToIndex(selectedIndex, animated: false, moveScrollView: false)
        }
        
        if scrollView != nil {
            scrollView!.contentSize = CGSize(width: scrollView!.frame.size.width * CGFloat(buttons.count), height: scrollView!.frame.size.height)
            
            for i in 0..<views.count {
                views[i].frame = CGRect(x: scrollView!.frame.size.width * CGFloat(i), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
            }
        }
    }
    
    fileprivate func redrawButtons() {
        if buttons.count == 0 {
            return
        }
        
        let width = frame.size.width / CGFloat(buttons.count)
        let height = frame.size.height - indicatorHeight
        
        for i in 0..<buttons.count {
            let button = buttons[i]
            let visibleButton = visibleButtons[i]
            
            button.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
            button.setTitleColor((i == selectedIndex) ? selectedTextColor : textColor, for: UIControlState())
            button.titleLabel?.font = (i == selectedIndex) ? selectedFont : font
            
            visibleButton.frame = CGRect(x: (button.frameWidth() / 2.0) - 20.0/2.0, y: 0.0, width: 20.0, height: 27.0)
            visibleButton.setTitleColor((i == selectedIndex) ? selectedTextColor : textColor, for: UIControlState())
            
            if button.currentImage == nil {
                visibleButton.backgroundColor = (i == selectedIndex) ? UIColor.black : UIColor.clear
            }
            else {
                
                var imageName = button.imageView?.image?.accessibilityIdentifier
                
                if imageName != nil {
                    
                    if i != selectedIndex {
                        if imageName!.contains("_dark") {
                            
                            imageName = imageName!.replacingOccurrences(of: "_dark", with: "")
                        }
                        else {
                            imageName = imageName!
                        }
                    }
                    else {
                        if !imageName!.contains("_dark") {
                            imageName = imageName! + "_dark"
                        }
                    }
                    
                    let image = UIImage(named: imageName!)
                    image?.accessibilityIdentifier = imageName!
                    
                    button.setImage(image, for: UIControlState())
                }
            }
            
            visibleButton.titleLabel?.font = (i == selectedIndex) ? selectedFont : font
            
            visibleButton.layer.cornerRadius = 2.0
            visibleButton.setFrameY(20.0)
        }
    }
    
    func buttonSelected(_ sender: UIButton) {
        if sender.tag == selectedIndex {
            return
        }
        
        delegate?.scrollPager?(self, changedIndex: sender.tag)
        
        setSelectedIndex(sender.tag, animated: true, moveScrollView: true)
    }
    
    // MARK: - UIScrollView Delegate -
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !animationInProgress {
            var page = scrollView.contentOffset.x / scrollView.frame.size.width
            
            if page.truncatingRemainder(dividingBy: 1) > 0.5 {
                page = page + CGFloat(1)
            }
            
            if Int(page) != selectedIndex {
                setSelectedIndex(Int(page), animated: true, moveScrollView: false)
                delegate?.scrollPager?(self, changedIndex: Int(page))
            }
        }
    }
}
