//
//  TMPopUpInfoViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Presents pop up view controller as a modal.
    ///
    /// - Parameters:
    ///   - viewController: View controller to present.
    ///   - animated: True if modal should be animated in.
    func presentPopUpInfoViewController(viewController: TMPopUpInfoViewController, animated: Bool) {
        viewController.modalPresentationStyle = .custom
        
        present(viewController, animated: false) {
            viewController.showContent(animated: animated, completion: nil)

        }
    }
    
    /// Dismisses pop up view controller modal.
    ///
    /// - Parameters:
    ///   - viewController: View controller to dismiss.
    ///   - animated: True if modal should be animated out.
    func dismissPopUpInfoViewController(viewController: TMPopUpInfoViewController, animated: Bool) {
        viewController.hideContent(animated: animated) {
            viewController.dismiss(animated: false, completion: nil)
        }
    }
}

class TMPopUpInfoViewController: UIViewController {

    // MARK: - Public iVars

    /// Content view that contains all content subviews including the content shape layer.
    lazy var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        
        return view
    }()
    
    // MARK: - Private iVars

    /// Background blur view.
    private var blurView = UIVisualEffectView(effect: nil)
    
    /// Y constraint of the content view when centered.
    private var contentViewCenterYConstraint: NSLayoutConstraint?
    
    /// Y constraint of the content view when it is a the bottom.
    private var contentViewTopConstraint: NSLayoutConstraint?

    
    /// Shape layer that defines the custom shape within the content view.
    private lazy var contentShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowOffset = CGSize(width: 0, height: 1)
        shapeLayer.shadowRadius = 2
        
        return shapeLayer
    }()
    
    // MARK: - Public
    
    init(blurViewHidden: Bool, contentHidden: Bool) {
        blurView.isHidden = blurViewHidden
        
        super.init(nibName: nil, bundle: nil)
        
        contentViewCenterYConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        contentViewTopConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        
        if contentHidden {
            contentViewCenterYConstraint?.priority = 500 //Set the priority lower so when animating the content view in, there will not be a constraint conflict.
            contentViewCenterYConstraint?.isActive = false
            blurView.effect = nil
        } else {
            contentViewTopConstraint?.priority = 500 //Set the priority lower so when animating the content view in, there will not be a constraint conflict.
            contentViewTopConstraint?.isActive = false
            blurView.effect = UIBlurEffect(style: .light)

        }
        
        if
            let contentViewCenterYConstraint = contentViewCenterYConstraint,
            let contentViewTopConstraint = contentViewTopConstraint {
            
            view.addConstraints([contentViewCenterYConstraint, contentViewTopConstraint])
        } else {
            print("A Content Constraint is nil")
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---View Controller---//
        
        edgesForExtendedLayout = []
        
        //---View---//
        
        view.backgroundColor = .clear

        //---Blur View---//
        
        view.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        //---Content View---//
        
        view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 17),
            NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.96, constant: 0),
            ])
        
        
        //---Content Shape Layer---//
        
        contentView.layer.addSublayer(contentShapeLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //---Content Shape Layer---//
        
        contentShapeLayer.frame = contentView.bounds
        contentShapeLayer.path = generateContentPath(in: contentShapeLayer.frame).cgPath
        contentShapeLayer.shadowPath = contentShapeLayer.path
    }
    
    func addSubviewToContentView(view: UIView) {
        
    }
    
    /// Displays content and blur view.
    ///
    /// - Parameter animated: True if the content should animate in.
    func showContent(animated: Bool, completion: (() -> Void)?) {
        let duration = animated ? 0.3 : 0
        
        contentViewTopConstraint?.isActive = false
        contentViewCenterYConstraint?.isActive = true
        
        UIView.animate(withDuration: duration, animations: { 
            self.blurView.effect = UIBlurEffect(style: .light)
            self.view.layoutIfNeeded()
        }) { (Bool) in
            if let completion = completion {
                completion()
            }
        }
    }
    
    /// Removes content and blur view.
    ///
    /// - Parameter animated: True if the content should animate out.
    func hideContent(animated: Bool, completion: (() -> Void)?) {
        let duration = animated ? 0.3 : 0
        
        contentViewCenterYConstraint?.isActive = false
        contentViewTopConstraint?.isActive = true
        
        UIView.animate(withDuration: duration, animations: {
            self.blurView.effect = nil
            self.view.layoutIfNeeded()
        }) { (Bool) in
            if let completion = completion {
                completion()
            }
        }
    }
    
    // MARK: - Private
    
    /// Generates content view shape path for frame.
    ///
    /// - Parameter frame: Frame of the content view.
    /// - Returns: Bezier path of custom shape.
    private func generateContentPath(in frame: CGRect) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00053 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99912 * frame.width, y: frame.minY + 0.00566 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.00152 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.00334 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.01371 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.00779 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.00976 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.95042 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99923 * frame.width, y: frame.minY + 0.95812 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.95436 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.95634 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99257 * frame.width, y: frame.minY + 0.96345 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.96078 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.96261 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + 0.96413 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + 0.96413 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + 0.96413 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.04118 * frame.width, y: frame.minY + 0.96413 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 1.00000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95516 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95964 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95042 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95392 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95242 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.01371 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00077 * frame.width, y: frame.minY + 0.00601 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.00976 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.00779 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00743 * frame.width, y: frame.minY + 0.00067 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00199 * frame.width, y: frame.minY + 0.00334 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00439 * frame.width, y: frame.minY + 0.00152 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.01798 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01022 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01281 * frame.width, y: frame.minY + -0.00000 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + -0.00000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99212 * frame.width, y: frame.minY + 0.00059 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + -0.00000 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00053 * frame.height))
        bezierPath.close()
        
        return bezierPath
    }

}
