//
//  TMRequestNavigationAnimator.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

class TMRequestNavigationAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// Transition duration.
    private let duration = 0.3
    
    private let operation: UINavigationControllerOperation
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView //Container view containing from and to view controllers.
        
        guard
            let fromViewController = transitionContext.viewController(forKey: .from), //View controller coming from.
            let toViewController = transitionContext.viewController(forKey: .to) //View controller moving to.
            else {
                print("Container view controllers are invalid.")
                return
        }
        
        
        /// Offset for the toViewController for push and pop actions.
        let toViewControllerStartingXOffset: CGFloat = operation == .push ? fromViewController.view.bounds.width : -fromViewController.view.bounds.width
        
        /// Offset for the fromViewController for push and pop actions.
        let fromViewControllerEndingXOffset: CGFloat = operation == .push ? -fromViewController.view.bounds.width : fromViewController.view.bounds.width
        
        toViewController.view.frame = transitionContext.initialFrame(for: fromViewController).offsetBy(dx: toViewControllerStartingXOffset, dy: 0)
        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: duration, animations: { 
            fromViewController.view.frame = transitionContext.initialFrame(for: fromViewController).offsetBy(dx: fromViewControllerEndingXOffset, dy: 0)
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        }) { (Bool) in
            transitionContext.completeTransition(true)
        }
    }
}
