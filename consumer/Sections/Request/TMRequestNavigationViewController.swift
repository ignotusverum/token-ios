//
//  TMRequestNavigationController.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMRequestNavigationController: UINavigationController {

    // MARK: - Private iVars

    /// Confetti view behind each child view controller.
    private let confettiView = TMConfettiView()
    
    // MARK: - Public

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        rootViewController.view.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        //---View---//
        
        view.backgroundColor = .TMGrayBackgroundColor
        
        //---Confetti View---//
        
        view.addSubview(confettiView)
        view.sendSubview(toBack: confettiView)
        
        confettiView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: confettiView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: confettiView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: confettiView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: confettiView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        )
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        for viewController in viewControllers {
            viewController.view.backgroundColor = .clear
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        viewController.view.backgroundColor = .clear
    }
    
    /// Starts confetti in navigation view background.
    func startConfetti() {
        if !confettiView.isActive() {
            confettiView.startConfetti()
        }
    }
    
    /// Stops confetti in navigation view background.
    func stopConfetti() {
        confettiView.stopConfetti()
    }
}

// MARK: - UINavigationControllerDelegate
extension TMRequestNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return TMRequestNavigationAnimatedTransitioning(operation: operation)
    }
}
