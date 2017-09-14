//
//  TMTutorialContainerViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwipeController

class TMTutorialContainerViewController: EZSwipeController {
    
    @IBOutlet weak var skipButton: UIButton! {
        didSet {
            
            skipButton.titleLabel?.attributedText = skipButton.titleLabel!.text?.setCharSpacing(2.4)
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // Tutorial Controllers
    fileprivate var tutorialControllers = [UIViewController]()
    
    // Analytics scroll position
    var oldScrollPosition = 0
    
    // Animation
    var animationInProgress = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        let logoImage = TMLogo.imageOfLogo(CGSize(width: 80.0, height: 15.0), resizing: .aspectFit)
        let logoImageView = UIImageView(image: logoImage)
        
        self.navigationItem.titleView = logoImageView
        
        self.pageControl.numberOfPages = self.tutorialControllers.count + 1
        
        self.view.bringSubview(toFront: self.skipButton)
        view.bringSubview(toFront: pageControl)

        for view in self.pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard var navigationController = navigationController else {
            return
        }
        
        configureNavigationController(navigationController: &navigationController)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tracking screen
        TMAnalytics.trackScreenWithID(.s1)
        
        self.animationInProgress = false
    }
    
    func createTutorialPages() {
        
        let sb = UIStoryboard(name: onboardingStoryboardKey, bundle: nil)
        
        let page1 = sb.instantiateVC(TMTutorialViewController.self)
        page1?.customSetup("Token makes giving gifts as\n wonderful as getting them.", imageName: "Tutorial_1")
        
        let page2 = sb.instantiateVC(TMTutorialViewController.self)
        page2?.customSetup("Give us a few details\n about your recipient…", imageName: "Tutorial_2")
        
        let page3 = sb.instantiateVC(TMTutorialViewController.self)
        page3?.customSetup("Our talented gift experts\n and powerful A.I. tools find\n you amazing gifts.", imageName: "Tutorial_3")
        
        let page4 = sb.instantiateVC(TMTutorialViewController.self)
        page4?.customSetup("From the best brands to local\n experiences, every gift is handchosen\n just for your recipient.", imageName: "Tutorial_4")
        
        let page5 = sb.instantiateVC(TMTutorialViewController.self)
        page5?.customSetup("Choose a gift and we’ll wrap it\n beautifully, with your note\n handwritten on a lovely card.", imageName: "Tutorial_5")
        
        if
            let page1 = page1,
            let page2 = page2,
            let page3 = page3,
            let page4 = page4,
            let page5 = page5
        {
            tutorialControllers = [page1, page2, page3, page4, page5]
        }
    }
    
    // EZSwipeController Delegate
    override func setupView() {
        
        self.createTutorialPages()
        
        super.setupView()
        
        datasource = self
        navigationBarShouldNotExist = true
    }
    
    // MARK: - Actions
    @IBAction func skipButtonPressed() {
        
        TMAnalytics.trackEventWithID(.t_S1_1)
        
        self.performSegue(withIdentifier:"createAccountSegue", sender: nil)
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        backButtonPressed(nil)
    }
}

extension TMTutorialContainerViewController: EZSwipeControllerDataSource {
    
    func viewControllerData()-> [UIViewController] {
        
        return self.tutorialControllers
    }
    
    func changedToPageIndex(_ index: Int) {
        
        self.pageControl.currentPage = index
    }
    
    // Track swiping
    //    override func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    //
    //        super.pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
    //
    //        let newVCIndex = stackPageVC.index(of: pageViewController.viewControllers!.first!)!
    //
    //        // Define swiping direction
    //        var direction = "left"
    //        if self.oldScrollPosition > newVCIndex {
    //            direction = "right"
    //        }
    //
    //        TMAnalytics.trackEventWithID(.t_S1_0, eventParams: ["label": direction])
    //    }
}

extension TMTutorialContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let point = scrollView.contentOffset
        
        var percent: CGFloat = 0.0
        percent = (point.x - self.view.frameWidth())/self.view.frameWidth()
        
        if self.currentVCIndex == self.tutorialControllers.count - 1 && percent > 0.0 {
            
            if !animationInProgress {
                
                self.performSegue(withIdentifier:"createAccountSegue", sender: nil)
                
                self.animationInProgress = true
            }
        }
    }
}

// MARK: - Private UI Configurators
private extension TMTutorialContainerViewController {
    /// Configures navigation controller properties.
    ///
    /// - Parameter navigationController: Navigation controller for which to configure properties.
    func configureNavigationController(navigationController: inout UINavigationController) {
        
        //Transparent navigation bar.
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
    }
}

