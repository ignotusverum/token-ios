//
//  TMFeedbackConfirmationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMFeedbackConfirmationViewController: TMConfirmedRequestViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setup chat button
        navigationItem.rightBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func setupEmptyView() {
        
        emptyStateView = TMEmptyDataset(title: TMCopy.FeedbackConfirmation.title, body: TMCopy.FeedbackConfirmation.body, topLayout: requestInfoView.frame.y + requestInfoView.frame.height + (DeviceType.IS_IPHONE_6P ? 80 : 0))
        
        view.addSubview(emptyStateView)
    }
    
    override func dismissViewController(_ sender: UIButton) {
        super.dismissViewController(sender)
        
        performSegue(withIdentifier: "unwindToRequestController", sender: self)
    }
}
