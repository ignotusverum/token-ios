//
//  TMButtonBuilder.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

// MARK: - UIButton Extension

/// Extension to create custom buttons from conforming styles.
extension UIButton {
    ///Styles for custom buttons.
    enum TMButtonStyle: Int {
        case black = 1
        case darkPink = 2
        case gold = 3
        case darkPurple = 4
        case gift = 5
        case alternateBlack = 6
        case muavePattern = 7
    }
    
    /// Creates a new custom button from a style.
    ///
    /// - Parameter style: Style from enum determining the style type to use.
    /// - Returns: Custom button with specified styling.
    static func button(style: TMButtonStyle) -> UIButton {
        switch style {
        case .black:
            return TMButton(styleDelegate: TMBlackButtonStyle())
        case .darkPink:
            return TMButton(styleDelegate: TMDarkPinkButtonStyle())
        case .gold:
            return TMButton(styleDelegate: TMGoldButtonStyle(), gradientStyleDelegate: TMGoldButtonStyle())
        case .darkPurple:
            return TMButton(styleDelegate: TMDarkPurpleButtonStyle())
        case .gift:
            return TMButton(styleDelegate: TMGiftButtonStyle())
        case .alternateBlack:
            return TMButton(styleDelegate: TMAlternateBlackButtonStyle())
        case .muavePattern:
            return TMButton(styleDelegate: TMMuavePatternButtonStyle())
        }
    }
    
    /// Creates a new custom button from a conforming style object.
    ///
    /// - Parameters:
    ///   - styleDelegate: Object conforming to style protocol.
    ///   - gradientStyleDelegate: Object conforming to gradient protocol.
    /// - Returns: Custom button with specified styling.
    static func button(styleDelegate: TMButtonStyleProtocol, gradientStyleDelegate: TMButtonGradientStyleProtocol? = nil) -> UIButton {
        return TMButton(styleDelegate: styleDelegate, gradientStyleDelegate: gradientStyleDelegate)
    }
}

//MARK: - TMButton

/// Custom button implementation.
private class TMButton: UIButton {
    
    // MARK: - Public iVars
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let newTitle = title?.uppercased() else {
            return
        }
        
        super.setTitle(newTitle, for: state)
        
        titleLabel?.attributedText = styleDelegate?.titleAttributedString(text: newTitle)
    }
    
    override var isHighlighted: Bool {
        didSet {
            
            //Because isHighlighted is called multiple times per toggle; a secondary iVar is set here to toggle just once when isHighlighted changes.
            
            if isHighlighted && !highlighting {
                highlighting = true
            } else if !isHighlighted && highlighting {
                highlighting = false
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                styleDelegate?.normalState(button: { () -> TMButton in
                    return self
                })
            } else {
                styleDelegate?.inactiveState(button: { () -> TMButton in
                    return self
                })
            }
        }
    }

    // MARK: - Private iVars
    
    /// Secondary highlighting flag to complement isHighlighted. Is set just once when highlight state changes
    fileprivate var highlighting = false {
        didSet {
            if highlighting { //When button is being tapped.

                if #available(iOS 10.0, *) {
                    feedbackGenerator?.impactOccurred()
                } else {
                }
                
                styleDelegate?.highlightedState(button: { () -> TMButton in
                    return self
                })
                
                setGradientHighlighted() //If a gradient is present, set the gradient's highlighted state.
               
            } else { //When the button is no longer being tapped.
                styleDelegate?.normalState(button: { () -> TMButton in
                    return self
                })
                
                setGradientNormal() //If a gradient is present, set the gradient's normal state.
            }
        }
    }
    
    /// Flag for the state of the gradient when highlighted. When tapping this button with a gradient enabled, we want the animation to complete a back and forth cycle between a normal and highlighted state. However, the user can keep their finger on the button and if that happens, animating back to initial state does not make sense until they lift their finger. This flag tracks the highlighted state based on animation progress rather than just pure user interaction.
    fileprivate var gradientInHighlightedState = false
    
    /// Gradient overlay layer for button. This is transparent until colors are added. Note: This layer overlaps everything except the text label and image view in this button.
    fileprivate lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        return gradientLayer
    }()
    
    /// Animation that toggles gradient colors to their reverse positions. Note: This will also set the gradient layer colors on the layer itself.
    fileprivate var toggleGradientAnimation: CABasicAnimation? {
        let fromColors = gradientLayer.presentation()?.colors
        
        var toColors: [CGColor] = []
        
        guard let reversedColors = gradientLayer.colors?.reversed() else {
            print("Gradient colors is nil.")
            return nil
        }
        
        for color in reversedColors {
            toColors.append(color as! CGColor)
        }
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 0.5
        animation.fillMode = kCAFillModeForwards
        
        gradientLayer.colors = toColors
        
        return animation
    }
    
    /// This stupid combo is necessary to check if the iVar type can be used on this version of iOS. Solution here: 
    private var _feedbackGenerator: AnyObject?
    
    @available(iOS 10.0, *)
    /// Feedback generator for haptic feedback for phones that contain a taptic engine.
    var feedbackGenerator: UIImpactFeedbackGenerator? {
        get {
            return _feedbackGenerator as? UIImpactFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    /// Delegate for styling.
    private var styleDelegate: TMButtonStyleProtocol?
    
    /// Delegate for gradient styling.
    private var gradientStyleDelegate: TMButtonGradientStyleProtocol?
    
    // MARK: - Public
    
    init(styleDelegate: TMButtonStyleProtocol, gradientStyleDelegate: TMButtonGradientStyleProtocol? = nil) {
        super.init(frame: CGRect.zero)
        
        self.styleDelegate = styleDelegate
        self.gradientStyleDelegate = gradientStyleDelegate
        
        customInit()
    }
    
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
        
        //---Gradient Layer---//
        
        gradientLayer.frame = bounds
    }
    
    // MARK: - Private
    
    private func customInit() {
        //---View---//
        
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        //---Layer---//
        
        layer.cornerRadius = 2
        layer.addSublayer(gradientLayer)
        
        //---Image View---//
        
        imageView?.contentMode = .scaleAspectFill
        
        //---Feedback---//
        
        if #available(iOS 10.0, *) {
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator?.prepare()
        } else {
        }
        
        //---Style---//
        
        styleDelegate?.initialState(button: { () -> TMButton in
            return self
        })
        
        titleLabel?.textColor = .white
        
        //---Gradient Layer---//
        
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.colors = gradientStyleDelegate?.gradientColors()
    }
    
    /// Animates the gradient layer to its highlighted (colors reversed) state.
    private func setGradientHighlighted() {
        if gradientLayer.colors != nil { //If there is a gradient to animate.
            guard let gradientAnimation = toggleGradientAnimation else {
                return
            }
            
            gradientAnimation.delegate = self //Set the delegate because we are going to want to animate back to the original normal state in the completion method.
            gradientLayer.add(gradientAnimation, forKey: "toggleColors")
        }
    }
    
    /// Animates the gradient layer to its normal state.
    private func setGradientNormal() {
        if gradientLayer.colors != nil { //If there is a gradient to animate.
            if gradientInHighlightedState { //If the button was highlighted (user holding down button). Then execute the animation here.
                guard let gradientAnimation = toggleGradientAnimation else {
                    return
                }
                
                gradientLayer.add(gradientAnimation, forKey: "toggleColors")
                gradientInHighlightedState = false //Gradient is no longer in a highlighted state.
            }
        }
    }
}

// MARK: - CAAnimationDelegate
extension TMButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if highlighting { //If the button is highlighted (user holding down button) then skip the animation and set the gradient highlighted flag. The animation will execute later when the user lets go of the button.
            gradientInHighlightedState = true
        } else { //Execute animation to bring gradient back to original state.
            guard let gradientAnimation = toggleGradientAnimation else {
                return
            }
            gradientLayer.add(gradientAnimation, forKey: "toggleColors")
        }        
    }
}
