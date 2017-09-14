//
//  TMPopInAndOutAnimator.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMPopInAndOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let _operationType: UINavigationControllerOperation
    fileprivate let _transitionDuration: TimeInterval
    
    init(operation: UINavigationControllerOperation) {
        
        _operationType = operation
        _transitionDuration = 0.2
    }
    
    init(operation: UINavigationControllerOperation, andDuration duration: TimeInterval) {
        
        _operationType = operation
        _transitionDuration = duration
    }
    
    // MARK: - Push and Pop animation performers
    internal func performPushTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            
            // Something really bad happend and it is not possible to perform the transition
            print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
            return
        }
        
        toView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        let container = transitionContext.containerView
        
        container.backgroundColor = UIColor.TMGrayBackgroundColor
        
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? TMCollectionPushAndPoppable,
            let currentCell = fromViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        // Add to continaer te destination view
        container.addSubview(toView)
        
        // Prepare the screenshot of the destination view for animation
        let screenshotToView = UIImageView(image: toView.screenshot)
        
        // set frame of the screenshot equal to cell
        screenshotToView.frame = currentCell.frame
        
        let fromView = fromViewController.collectionView
        
        fromView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        // get coordinates of container
        let containerCoord = fromView.convert(screenshotToView.frame.origin, from: container)
        // set a new origin for the screenshotToView to overlat in to the cell
        screenshotToView.frame.origin = containerCoord
        
        // Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: currentCell.screenshot)
        screenshotFromView.frame = screenshotToView.frame
        
        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.addSubview(screenshotFromView)
        
        // Set views initial states
        toView.isHidden = true
        screenshotToView.isHidden = true
        
        // Delay to guarantee smooth effects
        //        let delayTime = DispatchTime.now(dispatch_time_t(DispatchTime.now()),
        //            Int64(0.08 * Double(NSEC_PER_SEC)))
        //        dispatch_after(delayTime, DispatchQueue.main) {
        screenshotToView.isHidden = false
        //        }
        
        UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            screenshotFromView.alpha = 0.0
            screenshotToView.frame = UIScreen.main.bounds
            screenshotToView.frame.origin = CGPoint(x: 0.0, y: 0.0)
            screenshotFromView.frame = screenshotToView.frame
            
        }) { _ in
            
            screenshotToView.removeFromSuperview()
            screenshotFromView.removeFromSuperview()
            toView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    internal func performPopTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            // Something really bad happend and it is not possible to perform the transition
            print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
            return
        }
        
        let container = transitionContext.containerView
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? TMCollectionPushAndPoppable,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromViewController.view,
            let currentCell = toViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let toCollectionView = toViewController.collectionView
        
        // Add destination view to the container view
        container.addSubview(toView)
        
        // Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: fromView.screenshot)
        screenshotFromView.frame = fromView.frame
        
        // Prepare the screenshot of the destination view for animation
        let screenshotToView = UIImageView(image: currentCell.screenshot)
        screenshotToView.frame = screenshotFromView.frame
        
        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.insertSubview(screenshotFromView, belowSubview: screenshotToView)
        
        // Set views initial states
        screenshotToView.alpha = 0.0
        fromView.isHidden = true
        currentCell.isHidden = true
        
        let containerCoord = toCollectionView.convert(currentCell.frame.origin, to: container)
        
        UIView.animate(withDuration: _transitionDuration, delay: 0.2, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            screenshotToView.alpha = 1.0
            screenshotFromView.alpha = 0.0
            
            screenshotFromView.frame = currentCell.frame
            screenshotFromView.frame.origin = containerCoord
            
            screenshotToView.frame = screenshotFromView.frame
            
        }) { _ in
            
            currentCell.isHidden = false
            screenshotFromView.removeFromSuperview()
            screenshotToView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    //MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return _transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if _operationType == .push {
            performPushTransition(transitionContext)
        } else if _operationType == .pop {
            performPopTransition(transitionContext)
        }
    }
}
