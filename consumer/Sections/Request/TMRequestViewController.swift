//
//  TMRequestViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import StoreKit
import IGListKit
import EZSwiftExtensions
import IQKeyboardManagerSwift
import JDStatusBarNotification
import Spruce

protocol TMRequestViewControllerCoordinatorDelegate {
    
    /// Tells coordinator that a new request button was tapped.
    func onNewRequest()
    
    /// Tells coordinator that requests exist. (Not empty state).
    func newRequestExists()
}

class TMRequestViewController: UIViewController, SlideMenuControllerDelegate, TMNavigationThemeProtocol {
    
    // MARK: - Public iVars
    var loading = false
    
    var newRequestButton: UIButton?
    
    var navigationThemeHandler: ((NavigationTheme) -> Void)?
    
    /// Delegate representing the TMRequestViewControllerCoordinatorDelgate protocol.
    var coordinatorDelegate: TMRequestViewControllerCoordinatorDelegate?
    
    // MARK: - Private iVars
    
    /// Empty view to display when there are no requests to display in the collection view.
    fileprivate lazy var emptyView: TMEmptyDataset? = {
        let emptyView = self.generateEmptyView()
        
        return emptyView
    }()
    
    fileprivate func generateEmptyView()-> TMEmptyDataset {
        let emptyView = TMEmptyDataset(title: "Welcome to Token", body: "Let’s get started:\nThink of someone important to you.\nLet’s find them a gift.", image: UIImage(named: "EmptyStateBanner"), topLayout: 0)
        
        emptyView.confettiEnabled = false
        
        return emptyView
    }
    
    /// Collection view displaying requests.
    fileprivate lazy var collectionView: IGListCollectionView = {
        
        var gridCollection = IGListGridCollectionViewLayout()
        gridCollection.minimumLineSpacing = 10.0
        gridCollection.minimumInteritemSpacing = 10.0
        
        let collectionView = IGListCollectionView(frame: .zero, collectionViewLayout: gridCollection)
        
        self.adapter.collectionView = collectionView
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 200, right: 0) //Makes room for new request button overlay.
        
        return collectionView
    }()
    
    /// Adapter to keep collection view in sync with data model.
    fileprivate lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 4)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        return adapter
    }()
    
    /// Requests to use as data model for collection view sections.
    fileprivate var requests: [TMRequest] = [] {
        didSet {
            if requests.count == 0 {
                updateNavigationBar(navigationTheme: .hidden)
            } else {
                updateNavigationBar(navigationTheme: .gray)
            }
        }
    }
    
    /// Model for view controller. Provides access to database to fetch requests.
    fileprivate lazy var model: TMRequestViewModel = {
        let viewModel = TMRequestViewModel()
        viewModel.delegate = self
        
        return viewModel
    }()
    
    // MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Collection View---//
        
        collectionView.frame = view.frame
        view.addSubview(collectionView)
        emptyView?.frame = view.frame
        
        //---Wake---//
        NotificationCenter.default.addObserver(self, selector: #selector(TMRequestViewController.applicationDidWake(_:)), name: NSNotification.Name(rawValue: TMAppWakeNotificationKey), object: nil)
        
        /// Check if it contains shipped products before showing rate view
        ez.runThisAfterDelay(seconds: 15, after: {
            if self.requests.contains(where: { $0.status == .shipment }) {
                
                if #available(iOS 10.3, *) {
                    
                    SKStoreReviewController.requestReview()
                } else {
                    // Fallback on earlier versions
                }
            }
        })
    }
    
    func applicationDidWake(_ notification: NSNotification) {
        
        //---Fetches requests---//
        
        model.fetchRequest { result in
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //---Requests adapter---//
        
        TMRequestAdapter.getTotalCount().then { totalCount-> Void in
            let screenAnalytics = ["Requests": self.model.totalCount]
            TMAnalytics.trackScreenWithID(.s4, properties: screenAnalytics)
            }.catch { error in
                print(error)
        }
        
        //---Request button---//
        
        newRequestButton?.isHidden = false
        
        //---Menu button---//
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "AccountIcon"), style: .plain, target: self, action: #selector(TMRequestViewController.toggleMenu(_:)))
        menuButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = menuButton
        
        //---Logo image---//
        
        let logoImage: UIImage = TMLogo.imageOfLogo(CGSize(width: 80.0, height: 15.0), resizing: .aspectFit)
        
        let button = UIButton(x: 0.0, y: 0.0, w: 120, h: 33, target: self, action: #selector(TMRequestViewController.navigationBarButtonPressed))
        button.setImage(logoImage, for: .normal)
        button.setImage(logoImage, for: .highlighted)
        
        //---Navigation title---//
        
        navigationItem.titleView = button
        
        //---Keyboard---//
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        //---Fetches requests---//
        
        model.fetchRequest { () -> ()? in
            
            DispatchQueue.main.async {
                if self.model.totalCount == 0 {
                    self.updateNavigationBar(navigationTheme: .hidden)
                    self.emptyView?.frame.y = -64
                    self.emptyView?.setNeedsLayout()
                }
            }
            
            return nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //---Keyboard---//
        IQKeyboardManager.sharedManager().enable = true
        
        //---Request button---//
        
        newRequestButton?.addTarget(self, action: #selector(TMRequestViewController.newRequestPressed(_:)), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //---Request button---//
        newRequestButton?.isHidden = true
    }
    
    // MARK: - Actions
    
    /// When navigation bar button was tapped.
    @IBAction func navigationBarButtonPressed() {
        if collectionView.numberOfSections > 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
    }
    
    /// When new request button has been tapped.
    ///
    /// - Parameter sender: Request button.
    @IBAction func newRequestPressed(_ sender: UIButton) {
        
        coordinatorDelegate?.onNewRequest()
    }
    
    /// When menu bar button has been tapped, toggles user setting menu.
    ///
    /// - Parameter sender: Menu button
    func toggleMenu(_ sender: AnyObject) {
        TMMenuViewController.sharedMenu.toggleLeft()
        TMAnalytics.trackEventWithID(.t_S4_0)
    }
    
    /// Moving back in navigation controller.
    ///
    /// - Parameter segue: Segue between current and previous controller.
    @IBAction func unwindToRequestController(_ segue: UIStoryboardSegue) {}
}

// MARK: - IGListAdapterDataSource
extension TMRequestViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        
        return requests as [IGListDiffable]
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        
        let sectionController = TMRequestSectionController()
        
        sectionController.request = object as? TMRequest
        sectionController.delegate = self
        
        return sectionController
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        if TMRequestAdapter.totalCount == 0 { //If empty use the empty view.
            if emptyView == nil {
                emptyView = generateEmptyView()
            }
            
            return emptyView
        } else { //If the collection view is not empty set empty view to nil. If this is not done then the confetti view will spin out of control and create too much confetti creating lag and other bits of terror. 🎉 🎊
            coordinatorDelegate?.newRequestExists()
            emptyView = nil
            return nil
        }
        
        emptyView?.frame = view.bounds
    }
}

// MARK: - TMRequestViewModelProtocol
extension TMRequestViewController: TMRequestViewModelProtocol {
    func newRequestsFetched(requests: [TMRequest]) {
        
        self.requests = requests
        adapter.performUpdates(animated: true)
    }
    
    func reloadRequestsFetched(request: TMRequest) {
        
        adapter.reloadObjects([request])
    }
    
    func requestFetchError(error: Error) {
        JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
    }
}

// MARK: - TMRequestSectionControllerProtocol
extension TMRequestViewController: TMRequestSectionControllerProtocol {
    func cellTapped(request: TMRequest) {
        updateNavigationBar(navigationTheme: .gray)
        
        TMRequestRouteHandler.recomFlow(requestID: request.id, alwaysShowRecommendations: false).then { resultController -> Void in
            
            if let controller = resultController {
                self.presentVC(controller)
            }
            }.catch { error in
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}

private extension TMRequestViewController {
    
    /// Generates a layer containing a fading gradient to use as a fake navigation bar.
    ///
    /// - Returns: Gradient layer to fade scrolling elements.
    func generateGradientMask() -> CAGradientLayer {
        let maskLayer = CAGradientLayer()
        
        let color: UIColor = .TMGrayBackgroundColor
        
        let outerColor = color.cgColor //Solid color
        let innerColor = color.cgColor.copy(alpha: 0) //Transparent color
        
        maskLayer.colors = [outerColor, innerColor!] //set gradient colors
        
        maskLayer.locations = [0.6, 1] //Gradient positions
        
        let navigationBarMaskPadding :CGFloat = 30 //Extra pixels over the navigation bar height that makes for a better looking effect while scrolling
        
        maskLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64 + navigationBarMaskPadding) //Size of the navigation bar + status bar + the padding
        
        maskLayer.anchorPoint = CGPoint.zero
        
        return maskLayer
    }
}

// MARK: - Scroll view delegate
// Paging logic
extension TMRequestViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        
        // Calculate distance + add page if needed
        if !loading && distance < 200 {
            loading = true
            
            model.fetchRequest { result-> Void in
                
                self.loading = false
            }
        }
    }
}
