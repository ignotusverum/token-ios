//
//  TMConfirmedRequestViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMConfirmedRequestViewController: UIViewController {

    // Chat Bar Button
    var chatBarButton: ENMBadgedBarButtonItem?
    
    var logoCount = 0
    
    // Request info View
    @IBOutlet var requestInfoView: TMRequestInfoView!
    
    @IBOutlet weak var requestInfoHeight: NSLayoutConstraint?
    @IBOutlet weak var requestInfoWidth: NSLayoutConstraint?
    
    // Request
    var request: TMRequest?
    
    fileprivate lazy var checkmarkButton: UIButton = {
        let button = UIButton.button(style: .darkPurple)
        
        button.setImage(UIImage(named: "LargeCheck"), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        return button
    }()

    // Empty state view
    var emptyStateView: TMEmptyDataset!
    
    // MARK: - controller lifecycle

    override func viewDidLayoutSubviews() {
        
        var cellW: CGFloat = 172.0
        var cellH: CGFloat = 200.0
        
        if DeviceType.IS_IPHONE_5 {
            
            cellW = 145.0
            cellH = 185.0
        }
        
        if DeviceType.IS_IPHONE_6P {
            
            cellW = 202.0
            cellH = 225.0
        }
        
        requestInfoWidth?.constant = cellW
        requestInfoHeight?.constant = cellH
        
        view.updateConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let logoImage: UIImage = TMLogo.imageOfLogo(CGSize(width: 80.0, height: 15.0), resizing: .aspectFit)
        let button = UIButton(x: 0.0, y: 0.0, w: 120, h: 33, target: self, action: #selector(onTokenLogo))
        button.setImage(logoImage, for: .normal)
        button.setImage(logoImage, for: .highlighted)
        
        navigationItem.titleView = button
        
        if let name = request?.contact?.availableName {
            
            TMCopy.RequestConfirmation.replaceName = name
        }
        
        // Set request info view
        requestInfoView.request = request
        
        setupEmptyView()
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: -1, constant: 0)) //Allows the view to show underneath the navigation bar.
        view.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0))
        
        requestInfoView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        requestInfoView.layer.shadowColor = UIColor.black.cgColor
        requestInfoView.layer.shadowRadius = 1
        requestInfoView.layer.shadowOpacity = 0.15
        
        view.bringSubview(toFront: requestInfoView)
        view.bringSubview(toFront: checkmarkButton)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(checkmarkButton)
        
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: checkmarkButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: checkmarkButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkmarkButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 94 / 187, constant: 0),
            NSLayoutConstraint(item: checkmarkButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68)
            ])
    }
    
    func setupEmptyView() {
        
        emptyStateView = TMEmptyDataset(title: TMCopy.RequestConfirmation.title, body: TMCopy.RequestConfirmation.body, topLayout: requestInfoView.frame.y + requestInfoView.frame.height + (DeviceType.IS_IPHONE_6P ? 30 : 0))
        
        view.addSubview(emptyStateView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async(execute: {
            
            // Register for push
            let appDelegate = TMAppDelegate.appDelegate
            appDelegate?.registerForPushNotificationsAndUpdateToken()
        })
        
        // Setup chat button
        chatBarButton = setUpChatBadgeBarButton(request, color: UIColor.black)
        if let customView = chatBarButton?.customView as? UIButton {
            
            customView.block_setAction(block: { button in
            
            self.showChatVC()
            TMAnalytics.trackEventWithID(.t_S6_0, eventParams: ["position": "Top"])
                
            }, for: .touchUpInside)
        }
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
    
        dismissVC(completion: nil)
        
        TMAnalytics.trackEventWithID(.t_S6_1)
    }
    
    func showChatVC() {
        
        let chatViewController = UIViewController.viewControllerFromStoryboard("Recommendation", controllerIdentifier: "conversationViewController") as! TMRequestConversationViewController
        chatViewController.request = request
        chatViewController.showButtonDown = true
        
        navigationController?.navigationBar.backgroundColor = UIColor.TMColorWithRGBFloat(249, green: 249, blue: 249, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.show(chatViewController, sender: nil)
    }
    
    func onTokenLogo(_ sender: UIButton) {
        
    }
}
