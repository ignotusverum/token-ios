//
//
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SlideMenuControllerDelegate {
    @objc optional func leftWillOpen()
    @objc optional func leftDidOpen()
    @objc optional func leftWillClose()
    @objc optional func leftDidClose()
}

public struct SlideMenuOptions {
    public static var leftViewWidth: CGFloat = 270.0
    public static var leftBezelWidth: CGFloat? = 16.0
    public static var contentViewScale: CGFloat = 0.96
    public static var contentViewOpacity: CGFloat = 0.5
    public static var shadowOpacity: CGFloat = 0.0
    public static var shadowRadius: CGFloat = 0.0
    public static var shadowOffset: CGSize = CGSize(width: 0,height: 0)
    public static var panFromBezel: Bool = true
    public static var animationDuration: CGFloat = 0.4
    public static var hideStatusBar: Bool = false
    public static var pointOfNoReturnWidth: CGFloat = 44.0
    public static var simultaneousGestureRecognizers: Bool = true
    public static var opacityViewBackgroundColor: UIColor = UIColor.black
}

open class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    public enum SlideAction {
        case open
        case close
    }
    
    public enum TrackAction {
        case leftTapOpen
        case leftTapClose
        case leftFlickOpen
        case leftFlickClose
    }
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    open weak var delegate: SlideMenuControllerDelegate?
    
    open var opacityView = UIView()
    open var mainContainerView = UIView()
    open var leftContainerView = UIView()
    open var mainViewController: UIViewController?
    open var leftViewController: UIViewController?
    open var leftPanGesture: UIPanGestureRecognizer?
    open var leftTapGesture: UITapGestureRecognizer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        initView()
    }
    
    open override func awakeFromNib() {
        initView()
    }
    
    deinit { }
    
    open func initView() {
        
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clear
        mainContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(mainContainerView, at: 0)
        
        var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = SlideMenuOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, at: 1)
        
        if leftViewController != nil {
            var leftFrame: CGRect = view.bounds
            leftFrame.origin.y = view.bounds.size.height
            
            leftContainerView = UIView(frame: leftFrame)
            leftContainerView.backgroundColor = UIColor.clear
            leftContainerView.autoresizingMask = .flexibleHeight
            
            let backgroundView = UIView(frame: self.view.bounds)
            backgroundView.alpha = 0.98
            backgroundView.backgroundColor = UIColor.TMBlackColor
            leftContainerView.addSubview(backgroundView)
            
            view.insertSubview(leftContainerView, at: 2)
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        leftContainerView.isHidden = true
        
        coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()
            self.leftContainerView.isHidden = false
            
            if self.leftPanGesture != nil && self.leftPanGesture != nil {
                self.removeLeftGestures()
                //                self.addLeftGestures()
            }
        })
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let mainController = self.mainViewController{
            return mainController.supportedInterfaceOrientations
        }
        return UIInterfaceOrientationMask.all
    }
    
    open override func viewWillLayoutSubviews() {
        // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
    }
    
    open override func openLeft() {
        
        guard let _ = leftViewController else { // If leftViewController is nil, then return
            return
        }
        
        self.delegate?.leftWillOpen?()
        
        setOpenWindowLevel()
        // for call viewWillAppear of leftViewController
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        openLeftWithVelocity(0.0)
        
        track(.leftTapOpen)
    }
    
    open override func closeLeft() {
        guard let _ = leftViewController else { // If leftViewController is nil, then return
            return
        }
        
        self.delegate?.leftWillClose?()
        
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLebel()
    }
    
    open func addLeftGestures() {
        
        if (leftViewController != nil) {
            if leftPanGesture == nil {
                leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleLeftPanGesture(_:)))
                leftPanGesture!.delegate = self
                view.addGestureRecognizer(leftPanGesture!)
            }
            
            if leftTapGesture == nil {
                leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleLeft))
                leftTapGesture!.delegate = self
                view.addGestureRecognizer(leftTapGesture!)
            }
        }
    }
    
    open func removeLeftGestures() {
        
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
        
        if leftTapGesture != nil {
            view.removeGestureRecognizer(leftTapGesture!)
            leftTapGesture = nil
        }
    }
    
    open func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    open func track(_ trackAction: TrackAction) {
        // function is for tracking
        // Please to override it if necessary
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
        static var lastState : UIGestureRecognizerState = .ended
    }
    
    func handleLeftPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            if LeftPanState.lastState != .ended &&  LeftPanState.lastState != .cancelled &&  LeftPanState.lastState != .failed {
                return
            }
            
            if isLeftHidden() {
                self.delegate?.leftWillOpen?()
            } else {
                self.delegate?.leftWillClose?()
            }
            
            LeftPanState.frameAtStartOfPan = leftContainerView.frame
            LeftPanState.startPointOfPan = panGesture.location(in: view)
            LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
            LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
            
            leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
            addShadowToView(leftContainerView)
            setOpenWindowLevel()
        case UIGestureRecognizerState.changed:
            if LeftPanState.lastState != .began && LeftPanState.lastState != .changed {
                return
            }
            
            let translation: CGPoint = panGesture.translation(in: panGesture.view!)
            leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
            applyLeftOpacity()
            applyLeftContentViewScale()
        case UIGestureRecognizerState.ended, UIGestureRecognizerState.cancelled:
            if LeftPanState.lastState != .changed {
                return
            }
            
            let velocity:CGPoint = panGesture.velocity(in: panGesture.view)
            let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
            
            if panInfo.action == .open {
                if !LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(true, animated: true)
                }
                openLeftWithVelocity(panInfo.velocity)
                
                track(.leftFlickOpen)
            } else {
                if LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(false, animated: true)
                }
                closeLeftWithVelocity(panInfo.velocity)
                setCloseWindowLebel()
                
                track(.leftFlickClose)
                
            }
        case UIGestureRecognizerState.failed, UIGestureRecognizerState.possible:
            break
        }
        
        LeftPanState.lastState = panGesture.state
    }
    
    open func openLeftWithVelocity(_ velocity: CGFloat) {
        let yOrigin: CGFloat = leftContainerView.frame.origin.y
        let finalYOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame;
        frame.origin.y = finalYOrigin;
        
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(yOrigin - finalYOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        addShadowToView(leftContainerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: SlideMenuOptions.contentViewScale, y: SlideMenuOptions.contentViewScale)
                
                strongSelf.leftViewController?.endAppearanceTransition()
                self!.setNeedsStatusBarAppearanceUpdate()
            }
        }) { [weak self](Bool) -> Void in
            if let strongSelf = self {
                strongSelf.disableContentInteraction()
                strongSelf.delegate?.leftDidOpen?()
            }
        }
    }
    
    open func closeLeftWithVelocity(_ velocity: CGFloat) {
        
        let yOrigin: CGFloat = leftContainerView.frame.origin.y
        let finalYOrigin: CGFloat = self.view.frame.size.height
        
        var frame: CGRect = leftContainerView.frame;
        frame.origin.y = finalYOrigin
        
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(yOrigin - finalYOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                self!.setNeedsStatusBarAppearanceUpdate()
            }
        }) { [weak self](Bool) -> Void in
            if let strongSelf = self {
                strongSelf.removeShadow(strongSelf.leftContainerView)
                strongSelf.enableContentInteraction()
                strongSelf.leftViewController?.endAppearanceTransition()
                strongSelf.delegate?.leftDidClose?()
            }
        }
    }
    
    open override func toggleLeft() {
        if isLeftOpen() {
            closeLeft()
            setCloseWindowLebel()
            // Tracking of close tap is put in here. Because closeMenu is due to be call even when the menu tap.
            
            track(.leftTapClose)
        } else {
            openLeft()
        }
    }
    
    open func isLeftOpen() -> Bool {
        
        return leftContainerView.frame.origin.y == 0.0
    }
    
    open func isLeftHidden() -> Bool {
        
        return leftContainerView.frame.origin.y == self.view.frame.size.height
    }
    
    open func changeMainViewController(_ mainViewController: UIViewController,  close: Bool) {
        
        removeViewController(self.mainViewController)
        self.mainViewController = mainViewController
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        if (close) {
            closeLeft()
        }
    }
    
    open func changeLeftViewWidth(_ width: CGFloat) {
        
        SlideMenuOptions.leftViewWidth = width;
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = width
        leftFrame.origin.x = leftMinOrigin();
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView.frame = leftFrame;
    }
    
    open func changeLeftViewController(_ leftViewController: UIViewController, closeLeft:Bool) {
        
        removeViewController(self.leftViewController)
        self.leftViewController = leftViewController
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        if closeLeft {
            self.closeLeft()
        }
    }
    
    fileprivate func leftMinOrigin() -> CGFloat {
        return  -self.view.frame.size.width
    }
    
    fileprivate func panLeftResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + SlideMenuOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .close : .open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func applyLeftTranslation(_ translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func getOpenedLeftRatio() -> CGFloat {
        
        let width: CGFloat = leftContainerView.frame.size.width
        let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    fileprivate func applyLeftOpacity() {
        
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedLeftRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    fileprivate func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedLeftRatio);
        mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    fileprivate func addShadowToView(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = SlideMenuOptions.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(SlideMenuOptions.shadowOpacity)
        targetContainerView.layer.shadowRadius = SlideMenuOptions.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).cgPath
    }
    
    fileprivate func removeShadow(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        mainContainerView.layer.opacity = 1.0
    }
    
    fileprivate func removeContentOpacity() {
        opacityView.layer.opacity = 0.0
    }
    
    fileprivate func addContentOpacity() {
        opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
    }
    
    fileprivate func disableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = false
    }
    
    fileprivate func enableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = true
    }
    
    fileprivate func setOpenWindowLevel() {
        if (SlideMenuOptions.hideStatusBar) {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    fileprivate func setCloseWindowLebel() {
        if (SlideMenuOptions.hideStatusBar) {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        
        var statusBarStyle: UIStatusBarStyle = .default
        
        if self.isLeftOpen() {
            
            statusBarStyle = .lightContent
        }
        
        return statusBarStyle
    }
    
    fileprivate func setUpViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            viewController.view.frame = targetView.bounds
            targetView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.view.layer.removeAllAnimations()
            _viewController.willMove(toParentViewController: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    open func closeLeftNonAnimation(){
        setCloseWindowLebel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(leftContainerView)
        enableContentInteraction()
    }
    
    // returning true here helps if the main view is fullwidth with a scrollview
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return SlideMenuOptions.simultaneousGestureRecognizers
    }
    
    fileprivate func slideLeftForGestureRecognizer( _ gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || SlideMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isLeftPointContainedWithinBezelRect(_ point: CGPoint) -> Bool{
        if SlideMenuOptions.leftBezelWidth != nil {
            let leftBezelRect: CGRect = CGRect.zero
//            var tempRect: CGRect = CGRect.zero
            
            //            CGRectDivide(view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.minXEdge)
            return leftBezelRect.contains(point)
        } else {
            return true
        }
    }
    
    fileprivate func isPointContainedWithinLeftRect(_ point: CGPoint) -> Bool {
        return leftContainerView.frame.contains(point)
    }
}


extension UIViewController {
    
    public func slideMenuController() -> SlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideMenuController {
                return viewController as? SlideMenuController
            }
            viewController = viewController?.parent
        }
        return nil;
    }
    
    public func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    public func addLeftBar() {
        
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "AccountIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toggleLeft))
        leftButton.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    public func toggleLeft() {
        slideMenuController()?.toggleLeft()
    }
    
    public func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    public func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    public func addPriorityToMenuGesuture(_ targetScrollView: UIScrollView) {
        guard let slideController = slideMenuController(), let recognizers = slideController.view.gestureRecognizers else {
            return
        }
        for recognizer in recognizers where recognizer is UIPanGestureRecognizer {
            targetScrollView.panGestureRecognizer.require(toFail: recognizer)
        }
    }
}
