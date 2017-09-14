//
//  TMRecommendationScrollPager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 10/21/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

protocol TMRecommendationScrollPagerDelegate: NSObjectProtocol {
    
    func cartButtonPressed()
    func indexButtonPressed()
    
    func scrollPager(_ scrollPager: TMRecommendationScrollPager, changedIndex: Int)
}

class TMRecommendationScrollPager: UIView, UIScrollViewDelegate{
    
    var selectedIndex = 0 {
        didSet {
            var loopingIndex = 0
            var sectionIndex = 0
            
            for recommendation in self.recommendations {
                
                for _ in 0..<recommendation.notRemovedItems.count {
                    
                    if loopingIndex == self.selectedIndex {
                        
                        UIView.animate(withDuration: 0.0, animations: {
                            
                            self.scrollView?.contentOffset = CGPoint(x: CGFloat(sectionIndex) * (self.frame.width - self.cartWidth.constant - self.indexWidth.constant), y: 0.0)
                        })
                    }
                    
                    loopingIndex = loopingIndex + 1
                }
                
                sectionIndex = sectionIndex + 1
            }
            
            moveToIndex(self.selectedIndex, animated: true)
        }
    }
    
    var buttons = [UIButton]()
    var visibleButtons = [UIButton]()
    
    var recommendations = [TMRecommendation]()
    
    fileprivate var animationInProgress = false
    weak var delegate: TMRecommendationScrollPagerDelegate!
    
    @IBOutlet weak var scrollView: TMScrollView?
    
    // Additional buttons constraint
    @IBOutlet weak var cartWidth: NSLayoutConstraint!
    @IBOutlet weak var indexWidth: NSLayoutConstraint!
    
    // Additional buttons
    @IBOutlet weak var indexButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!
    
    // Setup appearance
    var setupUI = false
    
    var cartAvaliable: Bool = false {
        didSet {
            if cartAvaliable {
                
                self.indexWidth.constant = 55.0
                self.cartWidth.constant = 55.0
            }
            else {
                
                self.indexWidth.constant = 60.0
                self.cartWidth.constant = 0.0
            }
            
            // Update constraints
            
            self.layoutIfNeeded()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.lightGray {
        didSet { redrawComponents() }
    }
    
    @IBInspectable var selectedTextColor: UIColor = UIColor.darkGray {
        didSet { redrawComponents() }
    }
    
    @IBInspectable var font: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet { redrawComponents() }
    }
    
    @IBInspectable var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 13) {
        didSet { redrawComponents() }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet { self.layer.borderColor = borderColor?.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var animationDuration: CGFloat = 0.2
    
    // MARK: - UIView Methods -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Content size for pages
        let contentWidth = (self.frame.width - (self.cartWidth.constant + self.indexWidth.constant)) * CGFloat(self.recommendations.count)
        scrollView?.contentSize = CGSize(width: contentWidth, height: self.frame.height)
        
        redrawComponents()
        
        if self.recommendations.count > 1 {
            
            if !setupUI {
                var lastItemIndex = 0
                
                for i in 0..<self.recommendations.count {
                    
                    let recom = self.recommendations[i]
                    
                    for _ in 0..<recom.notRemovedItems.count {
                        
                        if i == self.recommendations.count - 1 {
                            
                            UIView.performWithoutAnimation({
                                self.selectedIndex = lastItemIndex
                                
                                self.delegate.scrollPager(self, changedIndex: lastItemIndex + 1)
                                
                                self.delegate.scrollPager(self, changedIndex: lastItemIndex)
                            })
                            
                            //                            ez.runThisAfterDelay(seconds: 0.2, after: {
                            self.setupUI = true
                            //                            })
                            
                            return
                        }
                        
                        lastItemIndex = lastItemIndex + 1
                    }
                }
            }
            
            let index = self.selectedIndex
            UIView.performWithoutAnimation {
                self.selectedIndex = index
            }
        }
    }
    
    func reloadData() {
        
        for view in scrollView!.subviews {
            view.removeFromSuperview()
        }
        
        addButtons()
        redrawComponents()
    }
    
    fileprivate func addViews(_ segmentViews: [UIView]) {
        for view in scrollView!.subviews {
            view.removeFromSuperview()
        }
        
        for i in 0..<segmentViews.count {
            let view = segmentViews[i]
            scrollView!.addSubview(view)
        }
    }
    
    fileprivate func addButtons() {
        
        for button in buttons {
            
            button.removeFromSuperview()
        }
        
        buttons.removeAll(keepingCapacity: true)
        visibleButtons.removeAll(keepingCapacity: true)
        
        var index = 0
        
        for recommendation in self.recommendations {
            
            for _ in 0..<recommendation.notRemovedItems.count {
                
                let button = UIButton(type: .custom)
                let visibleButton = UIButton(type: .custom)
                
                button.tag = index
                visibleButton.tag = index
                
                button.titleLabel?.textAlignment = .center
                visibleButton.titleLabel?.textAlignment = .center
                
                button.addTarget(self, action: #selector(ScrollPager.buttonSelected(_:)), for: .touchUpInside)
                visibleButton.addTarget(self, action: #selector(ScrollPager.buttonSelected(_:)), for: .touchUpInside)
                
                self.buttons.append(button)
                self.visibleButtons.append(visibleButton)
                
                visibleButton.setTitle(String(index + 1), for: UIControlState())
                
                self.scrollView?.addSubview(button)
                button.addSubview(visibleButton)
                
                index = index + 1
            }
        }
    }
    
    fileprivate func moveToIndex(_ index: Int, animated: Bool) {
        animationInProgress = true
        
        UIView.animate(withDuration: animated ? TimeInterval(animationDuration) : 0.0, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            
            self?.redrawButtons()
            
            }, completion: { [weak self] finished in
                // Storyboard crashes on here for some odd reasons, do a nil check
                if self != nil {
                    self!.animationInProgress = false
                }
        })
    }
    
    func redrawComponents() {
        redrawButtons()
        
        if buttons.count > 0 {
            moveToIndex(selectedIndex, animated: false)
        }
    }
    
    fileprivate func redrawButtons() {
        if buttons.count == 0 {
            return
        }
        
        var buttonIndex = 0
        
        self.cartButton.setImage(UIImage(named: "cart"), for: UIControlState())
        self.indexButton.setImage(UIImage(named: "SummaryIcon"), for: UIControlState())
        
        if selectedIndex == buttons.count {
            self.indexButton.setImage(UIImage(named: "SummaryIcon_dark"), for: UIControlState())
            self.cartButton.setImage(UIImage(named: "cart"), for: UIControlState())
        }
        
        for (index,recom) in self.recommendations.enumerated() {
            
            let width = (frame.size.width - (self.cartWidth.constant + self.indexWidth.constant)) / CGFloat(recom.notRemovedItems.count)
            
            let height = frame.size.height
            
            for i in 0..<recom.notRemovedItems.count {
                if buttonIndex < buttons.count && buttonIndex < visibleButtons.count {
                    
                    let button = buttons[buttonIndex]
                    let visibleButton = visibleButtons[buttonIndex]
                    
                    let xPosition = CGFloat(index) * (frame.size.width - (self.cartWidth.constant + self.indexWidth.constant)) + width * CGFloat(i)
                    
                    button.frame = CGRect(x: xPosition, y: 0, width: width, height: height)
                    
                    button.setTitleColor((buttonIndex == selectedIndex) ? selectedTextColor : textColor, for: UIControlState())
                    button.titleLabel?.font = (buttonIndex == selectedIndex) ? selectedFont : font
                    
                    visibleButton.frame = CGRect(x: (button.frameWidth() / 2.0) - 20.0/2.0, y: 0.0, width: 20.0, height: 27.0)
                    
                    visibleButton.setTitleColor((buttonIndex == selectedIndex) ? selectedTextColor : textColor, for: UIControlState())
                    visibleButton.backgroundColor = (buttonIndex == selectedIndex) ? UIColor.black : UIColor.clear
                    visibleButton.titleLabel?.font = (buttonIndex == selectedIndex) ? selectedFont : font
                    
                    visibleButton.layer.cornerRadius = 2.0
                    visibleButton.setFrameY(20.0)
                    
                    buttonIndex = buttonIndex + 1
                }
            }
        }
    }
    
    func buttonSelected(_ sender: UIButton) {
        if sender.tag == selectedIndex {
            return
        }
        
        delegate?.scrollPager(self, changedIndex: sender.tag)
        
        self.selectedIndex = sender.tag
    }
    
    // MARK: - Actions
    @IBAction func cartButtonPressed(_ sender: UIButton) {
        
        self.selectedIndex = -1
        self.redrawButtons()
        
        sender.setImage(UIImage(named: "cart_dark"), for: UIControlState())
        self.indexButton.setImage(UIImage(named: "SummaryIcon"), for: UIControlState())
        
        self.delegate?.cartButtonPressed()
    }
    
    @IBAction func indexButtonPressed(_ sender: UIButton) {
        
        self.selectIndexButton()
        
        self.delegate?.indexButtonPressed()
    }
    
    func selectIndexButton() {
        
        self.selectedIndex = self.buttons.count
        self.redrawButtons()
        
        self.indexButton.setImage(UIImage(named: "SummaryIcon_dark"), for: UIControlState())
        self.cartButton.setImage(UIImage(named: "cart"), for: UIControlState())
    }
}
