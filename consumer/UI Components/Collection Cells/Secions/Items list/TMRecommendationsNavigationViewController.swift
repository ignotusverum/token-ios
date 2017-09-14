//
//  TMRecommendationsNavigationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/4/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

// Extensions
import EZSwipeController
import EZSwiftExtensions

// Error Handling + progress bar
import SVProgressHUD
import JDStatusBarNotification

// PromiseKit
import PromiseKit

/// Core data
import CoreStore

/// Spruce
import Spruce

class TMRecommendationsNavigationViewController: UIViewController, ListSectionObserver {
    
    // Request
    var request: TMRequest?
    
    /// Collection View
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        collectionView.register(TMRecommendationItemCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMRecommendationItemCollectionViewCell.self)")
        collectionView.register(TMItemsIndexCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMItemsIndexCollectionViewCell.self)")
        
        return collectionView
    }()
    
    /// Monitor
    lazy var itemsMonitor: ListMonitor<TMItem>? = {
        
        guard let requestID = self.request?.id else {
            return nil
        }
        
        /// Sorting by id, because it's generating ids based on time
        return TMCoreDataManager.defaultStack.monitorList(From<TMItem>(),
                                                          Where("\(TMItemRelationships.recommendation.rawValue).\(TMRecommendationRelationships.request.rawValue).\(TMModelAttributes.id.rawValue) == %@ AND \(TMItemAttributes.rating.rawValue) != %@", requestID, TMFeedbackType.remove.rawValue),
                                                          OrderBy(.ascending("id")))
    }()
    
    // Fetching processing
    var fetchedResultsProcessingOperations = [BlockOperation]()
    
    // Chat Bar Button
    var chatBarButton: ENMBadgedBarButtonItem?
    
    // Navigation View
    @IBOutlet weak var navigationView: TMRecommendationScrollPager! {
        didSet {
            
            navigationView.layer.shadowOffset = CGSize(width: 0, height: -1)
            navigationView.layer.shadowColor = UIColor.black.cgColor
            navigationView.layer.shadowRadius = 1
            navigationView.layer.shadowOpacity = 0.1
            
            if let recommendations = request?.recommendations {
                navigationView.recommendations = recommendations.array as! [TMRecommendation]
            }
        }
    }
    
    // Enable dismiss modal
    var isModal = false {
        didSet {
            
            var backButtonImage = UIImage(named: "backButton")
            
            if isModal {
                
                backButtonImage = UIImage(named: "closeButton")
            }
            
            backButton.image = backButtonImage
        }
    }
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    /// Feedback controller where users can enter further feedback for more gift suggestions.
    lazy var feedbackViewController: TMRecommendationFeedbackViewController? = {
        if let recommendation = self.request?.recommendationArray.last {
            
            let viewController = TMRecommendationFeedbackViewController(recommendation: recommendation)
            
            viewController.delegate = self
            
            return viewController
        }
        
        return nil
    }()
    
    // Card Enabled Bool
    var cartEnabled = false {
        didSet {
            
            navigationView.reloadData()
            navigationView.cartAvaliable = cartEnabled
        }
    }
    
    /// More gifts button, to call up feedback and make a request for new gifts.
    fileprivate lazy var findMoreGiftsButton: UIButton = {
        let button = UIButton.button(style: .muavePattern)
        
        button.setTitle("Find more gifts", for: .normal)
        button.addTarget(self, action: #selector(onFindMoreGiftsButton), for: .touchUpInside)
        
        return button
    }()
    
    /// Bottom constraint for the find more gifts button.
    fileprivate lazy var findMoreGiftsButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.findMoreGiftsButton, attribute: .bottom, relatedBy: .equal, toItem: self.navigationView, attribute: .top, multiplier: 1, constant: 66)
        
        return constraint
    }()
    
    // MARK: - Controller lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Set navigation bar color
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Checking if there's items in cart
        if let cart = request?.cart {
            
            cartEnabled = !cart.cartIsEmpty
        }
        
        if request?.status != .selection && request?.status != .pending {
            cartEnabled = false
        }
        
        // Setup chat button
        chatBarButton = setUpChatBadgeBarButton(request, color: UIColor.black)
        if let customView = chatBarButton?.customView as? UIButton {
            
            customView.block_setAction(block: { button in
                
                /// Call chat presentation
                self.performSegue(withIdentifier:"chatSegue", sender: nil)
                
            }, for: .touchUpInside)
        }
        
        if let feedbackViewController = feedbackViewController {
            switch feedbackViewController.state {
            case .hidden:
                break
            default:
                hideNavigationBar()
            }
        }
        
        /// Observer setup
        itemsMonitor!.addObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Mark recommendation as seen
        if let lastRecom = request?.recommendationArray.last {
            
            TMRecommendationsAdapter.setSeen(recommendation: lastRecom).catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
        
        /// Mark notifications as seen
        TMNotificationAdapter.markAsRead(activities: request?.recommendationActivities).catch { error in
            print(error)
        }
        
        //---Collection View---//
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: collectionView, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .bottomMargin, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)]
        )
        
        //---Navigation View---//
        
        let label = UILabel()
        
        label.numberOfLines = 0
        label.attributedText = TMCopy.navigationTitle(title: "GIFT SELECTION", request: request)
        
        label.sizeToFit()
        navigationItem.titleView = label
        
        navigationController?.navigationBar.hideBottomHairline()
        
        view.addSubview(navigationView)
        
        //---Find more gifts button---//
        
        view.addSubview(findMoreGiftsButton)
        view.bringSubview(toFront: navigationView)
        
        findMoreGiftsButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: findMoreGiftsButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: findMoreGiftsButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            findMoreGiftsButtonBottomConstraint,
            NSLayoutConstraint(item: findMoreGiftsButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66)
            ])
        
        //---Feedback View Controller---//
        
        guard let feedbackViewController = feedbackViewController else {
            return
        }
        
        addChildViewController(feedbackViewController)
        view.addSubview(feedbackViewController.view)
        
        feedbackViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: feedbackViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: feedbackViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: feedbackViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: feedbackViewController.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        )
        
        feedbackViewController.hide(animated: false)
        
        collectionView.reloadData()
        
        navigationView.reloadData()
        navigationView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        itemsMonitor!.removeObserver(self)
    }
    
    /// Hides navigation bar.
    fileprivate func hideNavigationBar() {
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    /// Shows navigation bar.
    fileprivate func showNavigationBar() {
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: .default), for: .default)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    /// Removes feedback view from the screen and sets the correct navigation bar configuration.
    fileprivate func removeFeedbackController() {
        feedbackViewController?.hide(animated: true)
        showNavigationBar()
        extendedLayoutIncludesOpaqueBars = false
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(popViewControllerButtonPressed))
        leftBarButtonItem.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // Back button action
    @IBAction func popViewControllerButtonPressed(_ sender: AnyObject) {
        
        if !self.isModal {
            
            self.popVC()
        }
        else {
            
            self.dismissVC(completion: nil)
        }
    }
    
    /// Find More Gifts Button was tapped. Changes left navigation item to display a back button to exit the feedback view.
    func onFindMoreGiftsButton() {
        hideNavigationBar()
        extendedLayoutIncludesOpaqueBars = true //This is to prevent the feedback view controller view from being pushed down when the chat button is tapped and the navigation bar reappears.
        feedbackViewController?.show(animated: true)
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(onBackButton))
        leftBarButtonItem.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    /// Back bar button item was tapped when entering feedback. Changes the left navigation item to display a close button to exit the modal.
    ///
    /// - Parameter buttonItem: Button item that was tapped.
    func onBackButton(buttonItem: UIBarButtonItem) {
        removeFeedbackController()
    }
    
    /// Monitor did change
    func listMonitorDidChange(_ monitor: ListMonitor<TMItem>) {
        
        /// Reload bottom navigation
        navigationView.reloadData()
        
        /// Start reloading block operations
        collectionView.performBatchUpdates({ () -> Void in
            for operation in self.fetchedResultsProcessingOperations {
                
                operation.start()
            }
        }, completion: { (finished) -> Void in
            
            self.fetchedResultsProcessingOperations = []
        })
    }
    
    /// Handle navigation deletion
    func listMonitor(_ monitor: ListMonitor<TMItem>, didDeleteObject object: TMItem, fromIndexPath indexPath: IndexPath) {
        addFetchedResultsProcessingBlock { self.collectionView.deleteItems(at: [indexPath]) }
        
        if indexPath.row == monitor.objectsInAllSections().count {
            /// Check for feedback button check
            shouldShowForIndex(indexPath.row)
        }
        else {
            
            navigationView.selectedIndex -= 1
        }
    }
    
    /// Handle object insertions
    func listMonitor(_ monitor: ListMonitor<TMItem>, didInsertObject object: TMItem, toIndexPath indexPath: IndexPath) {
        
        UIView.performWithoutAnimation {
            /// Not using animation because it messes up UI
            /// Insert + scroll to current cell
            self.collectionView.insertItems(at: [indexPath])
            /// Update bottom navigation count
            self.navigationView.selectedIndex += 1
            
            self.collectionView.scrollToItem(at: IndexPath(row: self.collectionView.numberOfItems(inSection: 0)-1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        }
    }
    
    /// Reloading handler
    /// Reloading cell if it's not visible
    func listMonitor(_ monitor: ListMonitor<TMItem>, didUpdateObject object: TMItem, atIndexPath indexPath: IndexPath) {
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            addFetchedResultsProcessingBlock {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    /// Move cell handler
    func listMonitor(_ monitor: ListMonitor<TMItem>, didMoveObject object: TMItem, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        addFetchedResultsProcessingBlock {
            
            self.collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
            
            ez.runThisAfterDelay(seconds: 0.1, after: {
                let cell = self.collectionView.cellForItem(at: toIndexPath) as? TMRecommendationItemCollectionViewCell
                cell?.collectionView.reloadData()
            })
        }
    }
    
    private func addFetchedResultsProcessingBlock(processingBlock:@escaping (Void)->Void) {
        fetchedResultsProcessingOperations.append(BlockOperation(block: processingBlock))
    }
    
    // MARK: - Popup logic
    func checkForOverlayTutorial() {
        
        /// Setup Tutorial overlay controller
        let feedbackOverlay = TMFeedbackTutorialOverlayViewController(nibName: "TMFeedbackTutorialOverlayViewController", bundle: nil)
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        
        overlayAppearance.color = UIColor.white
        overlayAppearance.blurRadius = 20
        overlayAppearance.blurEnabled = true
        overlayAppearance.liveBlur = false
        overlayAppearance.opacity = 0.7
        
        let popup = PopupDialog(viewController: feedbackOverlay, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: false)
        
        feedbackOverlay.doneSelected {
            
            popup.dismiss()
        }
        
        /// Config check
        let config = TMConsumerConfig.shared
        if config.isFeedbackOnboardingSeen == nil {
            ez.runThisAfterDelay(seconds: 0.3) {
                
                self.presentVC(popup)
                
                config.isFeedbackOnboardingSeen = "true"
            }
        }
    }
    
    /// Collection scroll handler
    /// Used to reload bottom navigation index
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint)!
        
        navigationView.selectedIndex = visibleIndexPath.row
        
        /// Check for feedback button check
        shouldShowForIndex(visibleIndexPath.row)
        
        if visibleIndexPath.row == itemsMonitor?.objectsInAllSections().count {
            checkForOverlayTutorial()
        }
    }
    
    /// Find more gifts animation
    func shouldShowForIndex(_ index: Int) {
        
        guard let cart = request?.cart, let itemsCount = itemsMonitor?.objectsInAllSections().count else {
            return
        }
        
        if index == itemsCount && cart.isCheckoutAvaliable { //If the user is on the last pane looking at the overview screen and they have not yet bought an item, 'Request new gifts' button.
            findMoreGiftsButtonBottomConstraint.constant = 0
            
        } else {
            findMoreGiftsButtonBottomConstraint.constant = findMoreGiftsButton.bounds.height
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Collection View Datasource
extension TMRecommendationsNavigationViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (itemsMonitor?.numberOfObjectsInSection(section) ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /// Last cell should be itemsIndexCollectionCell
        let numberOfItems = (itemsMonitor?.numberOfObjectsInSection(0) ?? 0)
        if indexPath.row == numberOfItems {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMItemsIndexCollectionViewCell.self)", for: indexPath) as! TMItemsIndexCollectionViewCell
            
            cell.delegate = self
            cell.request = request
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TMRecommendationItemCollectionViewCell", for: indexPath) as! TMRecommendationItemCollectionViewCell
        
        let item = itemsMonitor?[indexPath]
        
        cell.delegate = self
        
        cell.contentView.backgroundColor = UIColor.red
        cell.item = item
        
        cell.addShadow()
        
        return cell
    }
}

// MARK: - Collection view layout
extension TMRecommendationsNavigationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
}

// MARK: - TMRecommendationFeedbackViewControllerProtocol
extension TMRecommendationsNavigationViewController: TMRecommendationFeedbackViewControllerProtocol {
    func feedbackSent(error: Error?) {
        if let error = error {
            JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
        else {
            performSegue(withIdentifier:"suggestionConfirmationSegue", sender: nil)
        }
    }
}

extension TMRecommendationsNavigationViewController: TMRecommendationScrollPagerDelegate {
    
    /// Handle index button selection
    func indexButtonPressed() {
        
        guard let totalCount = itemsMonitor?.numberOfObjectsInSection(0) else {
            return
        }
        
        let lastIndexPath = IndexPath(row: totalCount, section: 0)
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [lastIndexPath])
        }
        
        collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: true)
        
        /// Check for feedback button check
        shouldShowForIndex(totalCount)
    }
    
    func cartButtonPressed() {
        
        SVProgressHUD.show()
        
        TMCartAdapter.fetchCart(request: request).then { response-> Void in
            
            let cartController = self.viewControllerFromStoryboard("Checkout", controllerIdentifier: "cartController") as? TMCartViewController
            cartController?.cart = self.request?.cart
            
            cartController?.delegate = self
            
            SVProgressHUD.dismiss()
            TMAnalytics.trackEventWithID(.t_S7_6)
            
            self.navigationController?.show(cartController!, sender: nil)
            }.catch { error in
                
                SVProgressHUD.dismiss()
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    /// Handle scrolling in collection view
    func scrollPager(_ scrollPager: TMRecommendationScrollPager, changedIndex: Int) {
        
        // Track overview
        TMAnalytics.trackEventWithID(.t_S7_5)
        
        collectionView.scrollToItem(at: IndexPath(row: changedIndex, section: 0), at: .centeredHorizontally, animated: true)
        
        /// Check for feedback button check
        shouldShowForIndex(changedIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chatSegue" {
            
            // Chat
            let chatController = segue.destination as? TMRequestConversationViewController
            chatController?.request = self.request
        }
        else if segue.identifier == "suggestionConfirmationSegue" {
            
            let confimationNavigationController = segue.destination as? UINavigationController
            let confimationController = confimationNavigationController?.topViewController as? TMFeedbackConfirmationViewController
            
            confimationController?.request = request
        }
    }
}

extension TMRecommendationsNavigationViewController: TMCartViewControllerDelegate {
    
    func backButtonPressed() {
        indexButtonPressed()
        
        guard let totalCount = itemsMonitor?.numberOfObjectsInSection(0) else {
            return
        }
        
        navigationView.selectedIndex = totalCount
    }
}

// MARK: - Feedback view delegate
extension TMRecommendationsNavigationViewController: TMItemsIndexCollectionViewCellDelegate {
    
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType) {
        
        /// Check if not last item in set
        if feedback == .remove, let itemsCount = itemsMonitor?.objectsInAllSections().count, itemsCount == 1 {
            
            JDStatusBarNotification.show(withStatus: "Whoops, we're can't remove all items.", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            feedbackView.reloadFeedback()
            
            return
        }
        
        /// Check if item is not in cart
        if feedback == .remove, let cart = request?.cart, let productID = item.productID, cart.isProductInCart(productID) {
            
            /// Show warning
            let alert = UIAlertController(title: "Warning, you have this item in the cart", message: "Are you sure you want to delete this item from the cart ?", preferredStyle: UIAlertControllerStyle.alert);
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler:  { action-> Void in
                
                feedbackView.reloadFeedback()
            }));
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                
                SVProgressHUD.show()
                
                /// Remove item from cart
                TMCartAdapter.removeItem(cart: cart, item: item).then { result-> Promise<TMCart?> in
                    
                    /// Fetch updated cart
                    return TMCartAdapter.fetchCart(request: self.request)
                    }.then { response-> Promise<TMItem?> in
                        
                        /// Update cart UI button
                        if let _response = response, let cart = self.request?.cart, cart.itemsArray.count == 0 {
                            
                            self.cartEnabled = !_response.cartIsEmpty
                        }
                        
                        /// Change feedback
                        return TMItemAdapter.rate(item: item, feedbackType: feedback)
                        
                    }.then { response-> Void in
                        
                        /// Reload UI
                        feedbackView.reloadFeedback()
                        SVProgressHUD.dismiss()
                        
                    }.catch { error-> Void in
                        
                        SVProgressHUD.dismiss()
                        JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }));
            
            present(alert, animated: true, completion: nil);
            
            return
        }
        
        /// Handle feedbackSelection
        /// Chane local model first - to speed up UI updates
        /// If networking call slow
        /// Then update model & UI if response is different
        TMItemAdapter.rate(item: item, feedbackType: feedback).then { itemResult-> Void in
            
            feedbackView.reloadFeedback()
            }.catch { error in
                print("Error")
                
                /// Update to old one
                feedbackView.reloadFeedback()
        }
    }
    
    /// Handle collection scroll from itemsIndex cell selection
    func itemIndexControllerSelectedItem(_ item: TMItem?) {
        
        guard let item = item else {
            return
        }
        
        var requestID = request?.id
        if requestID == nil {
            requestID = "0"
        }
        
        guard let indexPath = itemsMonitor?.indexPathOf(item) else {
            return
        }
        
        // Analytics
        TMAnalytics.trackEventWithID(.t_S8_0, eventParams: ["item": indexPath.row, "position": "Top", "requestID": requestID!])
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        navigationView.selectedIndex = indexPath.row
        
        /// Check for feedback button check
        shouldShowForIndex(indexPath.row)
    }
}

extension TMRecommendationsNavigationViewController: TMRecommendationItemCollectionViewCellDelegate {
    
    /// Handle purchase button selection
    func purchaseButtonPressedForItem(_ item: TMItem) {
        
        guard let _cart = self.request?.cart, self.request?.status == .selection || self.request?.status == .pending else {
            
            JDStatusBarNotification.show(withStatus: "Whoops, we're already processing your order.", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            
            return
        }
        
        let itemNumber = self.navigationView.selectedIndex
        
        SVProgressHUD.show()
        
        if !_cart.isProductInCart(item.productID!) {
            
            TMAnalytics.trackEventWithID(.t_S7_3, eventParams: ["value": itemNumber, "text": "PURCHASE"])
            
            TMCartAdapter.addItem(cart: _cart, item: item).then { result-> Promise<TMCart?> in
                
                var itemAddedAnalytics = [String: Any]()
                
                if let itemID = item.id {
                    itemAddedAnalytics["itemID"] = itemID
                }
                
                if let name = item.title {
                    itemAddedAnalytics["name"] = name
                }
                
                itemAddedAnalytics["quantity"] = 1
                
                if let price = item.product?.price {
                    itemAddedAnalytics["value"] = price
                }
                
                // Analytics
                TMAnalytics.trackEventWithID(.t_S7_2, eventParams: itemAddedAnalytics)
                TMCommerceAnalytics.trackAddedForProduct(item.product)
                
                return TMCartAdapter.fetchCart(request: self.request)
                }.then { response-> Void in
                    
                    if let _response = response {
                        
                        self.cartEnabled = !_response.cartIsEmpty
                    }
                    
                    SVProgressHUD.dismiss()
                    
                    self.cartButtonPressed()
                    
                }.catch { error-> Void in
                    
                    SVProgressHUD.dismiss()
                    JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
            
            return
        }
        
        var itemRemovedAnalytics: [String: Any] = ["item": itemNumber, "text": "REMOVE"]
        
        if let price = item.product?.price {
            itemRemovedAnalytics["value"] = price
        }
        
        // Analytics
        TMAnalytics.trackEventWithID(.t_S7_3, eventParams: itemRemovedAnalytics)
        TMCommerceAnalytics.trackRemovedForProduct(item.product)
        
        TMCartAdapter.removeItem(cart: _cart, item: item).then { result-> Promise<TMCart?> in
            
            return TMCartAdapter.fetchCart(request: self.request)
            }.then { response-> Void in
                
                if let _response = response {
                    
                    self.cartEnabled = !_response.cartIsEmpty
                }
                
                SVProgressHUD.dismiss()
                
            }.catch { error-> Void in
                
                SVProgressHUD.dismiss()
                JDStatusBarNotification.show(withStatus: "Something went wrong", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}
