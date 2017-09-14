//
//  TMRequestStatusViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

class TMRequestStatusViewController: UIViewController {
    
    // Request Accessor - Populates controller UI
    var request:TMRequest? {
        didSet {
            
            /// Safety check
            guard let request = request else {
                return
            }
            
            /// Setup progressViewModel
            progressViewModel = TMProgressViewModel(request: request)
            
            /// If request has more that 1 recommendation
            /// Show "Gifts for x ->"
            if request.recommendationArray.count > 0, let avaliableName = request.contact?.availableName {
                
                recommendationsButton = UIButton.button(style: .gold)
                recommendationsButton.setAttributedTitle(generateButtonTitle(avaliableName), for: .normal)
                recommendationsButton.addTarget(self, action: #selector(presentRecommendations), for: .touchUpInside)
                
                return
            }
        }
    }
    
    /// Status Datasource 
    var progressViewModel: TMProgressViewModel?
    
    /// Request info view
    @IBOutlet weak var requestInfoView: TMRequestInfoStatusView! {
        didSet {
            
            /// Setup datasource
            requestInfoView.request = request
        }
    }
    
    /// Progress view
    @IBOutlet weak var statusProgressView: TMProgressView?
    
    // Chat Bar Button
    private weak var chatBarButton: ENMBadgedBarButtonItem?
    
    /// Recommendations button
    fileprivate lazy var recommendationsButton: UIButton = {
        let button = UIButton.button(style: .darkPurple)
        
        button.setImage(UIImage(named: "LargeCheck"), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Controller lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// Screen analytics
        TMAnalytics.trackScreenWithID(.s25)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Set navigation bar color
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        /// Remove divider
        navigationController?.navigationBar.hideBottomHairline()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Adding title
        addTitleText("GIFT FOR")
        
        // Setup chat button
        chatBarButton = setUpChatBadgeBarButton(self.request, color: UIColor.TMTitleBlackColor)
        if let customView = chatBarButton?.customView as? UIButton {

            customView.block_setAction(block: { button in
                
                self.performSegue(withIdentifier:"chatSegue", sender: nil)
            }, for: .touchUpInside)
        }
        
        /// Setup custom constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        /// Recommendation button setup
        view.addSubview(recommendationsButton)
        
        recommendationsButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: recommendationsButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: recommendationsButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: recommendationsButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -40),
            NSLayoutConstraint(item: recommendationsButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68)
            ])
        
        /// Setup status progress view
        statusProgressView?.contentInsetPoint = CGPoint(x: -20.0, y: -10.0)
        statusProgressView?.setup(progressModel: progressViewModel)
    }
    
    // MARK: - Button actions
    /// Dismiss VC
    func dismissViewController() {
        
        dismissVC(completion: nil)
    }
    
    /// Present recommendations
    func presentRecommendations() {
     
        /// Safety check
        guard let request = request else {
            return
        }
        
        let sb = UIStoryboard.init(name: "Recommendation", bundle: nil)
        let controller = sb.instantiateViewController(withIdentifier: "TMRecommendationsNavigationViewController") as? TMRecommendationsNavigationViewController
        
        if let recomNavigation = controller {
            
            if recomNavigation.request != request {
                
                recomNavigation.request = request
            }
            
            self.show(recomNavigation, sender: nil)
        }
    }
    
    // MARK: - Utility
    private func generateButtonTitle(_ name: String)-> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSAttributedString(string: "GIFTS FOR \(name.uppercased())", attributes: [NSFontAttributeName: UIFont.MalloryMedium(14.0), NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName : paragraphStyle, NSKernAttributeName: 1.4])
        
        return attributedString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chatSegue" {
            
            // Chat
            let chatController = segue.destination as? TMRequestConversationViewController
            chatController?.request = self.request
        }
    }
}
