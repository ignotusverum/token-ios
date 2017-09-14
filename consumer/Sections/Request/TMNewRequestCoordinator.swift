//
//  TMNewRequestCoordinator.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/14/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit
import Contacts

class TMNewRequestCoordinator {
    
    /// Navigation controller to set as root.
    let navigationController: TMRequestNavigationController
    
    init(with navigationController: TMRequestNavigationController) {
        self.navigationController = navigationController
    }
    
    /// Starts coordinator with navigation root view controller.
    ///
    /// - Parameter menuViewController: Controller to set the delegate as the root view controller.
    func start(with menuViewController: SlideMenuController) {
        let requestsViewController = TMRequestViewController()
        
        requestsViewController.coordinatorDelegate = self
        menuViewController.delegate = requestsViewController
        
        //Navigation theme.
        requestsViewController.navigationThemeHandler = { theme in
            self.navigationController.navigationBar.applyTheme(navigationTheme: theme)
        }
        
        // New request button
        let newRequestButton = UIButton.button(style: .gold)
        newRequestButton.setTitle("Find a Gift", for: .normal)
        
        let requestButtonWidth = requestsViewController.view.bounds.width * (94 / 187)
        newRequestButton.frame = CGRect(x: requestsViewController.view.frame.width/2.0 - (requestButtonWidth) / 2, y: requestsViewController.view.frame.height - 110.0, w: requestButtonWidth, h: requestButtonWidth * (34 / 94))
        menuViewController.view.insertSubview(newRequestButton, at: 1)
        
        requestsViewController.newRequestButton = newRequestButton
        
        navigationController.pushViewController(requestsViewController, animated: false)
        
        // Starts and stops confetti for the empty state of the requests view controller.
        TMRequestAdapter.getTotalCount().then { totalCount -> Void in
            DispatchQueue.main.async {
                if totalCount == 0 {
                    self.navigationController.startConfetti()
                } else {
                    self.navigationController.stopConfetti()
                }
            }
        }.catch { error in
            print(error)
        }
    }
}

// MARK: - TMRequestViewControllerCoordinatorDelegate
extension TMNewRequestCoordinator: TMRequestViewControllerCoordinatorDelegate {
    func onNewRequest() {
        TMAnalytics.trackEventWithID(.t_S4_2)
        
        // Present a view controller based on contact access permissions.
        let viewController: UIViewController? = {
            if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
                let contactInfoViewController = TMContactInfoPopUpViewController(blurViewHidden: true, contentHidden: false)
                
                contactInfoViewController.coordinatorDelegate = self
                contactInfoViewController.addTitleText("Find a Gift", color: .black)
                let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(onContactInfoPromptControllerBackButton))
                backBarButtonItem.tintColor = .black
                contactInfoViewController.navigationItem.leftBarButtonItem = backBarButtonItem
                
                return contactInfoViewController
            } else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let selectContactController = sb.instantiateViewController(withIdentifier: "TMContactsSelectionViewController") as? TMContactsSelectionViewController {
                    selectContactController.coordinatorDelegate = self
                    
                    return selectContactController
                }
            }
            
            return nil
        }()
        
        guard let nextViewController = viewController else {
            print("Next view controller could not be determined.")
            return
        }
        
        navigationController.pushViewController(nextViewController, animated: true)
    }
}

// MARK: - TMContactsSelectionViewControllerCoordinatorDelegate
extension TMNewRequestCoordinator: TMContactsSelectionViewControllerCoordinatorDelegate {
    func localContactWasSelected(_ contact: CNContact) {
        pushNewRequestViewController(localContact: contact)
    }
    
    func tokenContactWasSelected(_ contact: TMContact) {
        pushNewRequestViewController(tokenContact: contact)
    }
    
    func newContactSelectedWithName(_ name: String) {
        pushNewRequestViewController(textContact: name)
    }
    
    @objc func onContactInfoPromptControllerBackButton() {
        navigationController.popViewController(animated: true)
    }
    
    /// Pushes a new request view controller.
    ///
    /// - Parameter newRequestViewController: Contains parameter with the newly created TMNewRequestViewController.
    private func pushNewRequestViewController(localContact: CNContact? = nil, tokenContact: TMContact? = nil, textContact: String? = nil) {
        
        let newRequestController = TMNewRequestViewController()
        newRequestController.coordinatorDelegate = self
        
        newRequestController.newRequestModel.localContact = localContact
        newRequestController.newRequestModel.tokenContact = tokenContact
        newRequestController.newRequestModel.freeFormContact = textContact
    
        //Navigation theme.
        newRequestController.navigationThemeHandler = { theme in
                self.navigationController.navigationBar.applyTheme(navigationTheme: theme)
        }
        
        navigationController.pushViewController(newRequestController, animated: true)
    }
    
    func newRequestExists() {
        navigationController.stopConfetti()
    }
}

// MARK: - TMNewRequestViewControllerCoordinatorDelegate
extension TMNewRequestCoordinator: TMNewRequestViewControllerCoordinatorDelegate {
    func onBackButton(_ viewController: TMNewRequestViewController) {
        TMAnalytics.trackEventWithID(.t_S5_0)        
    }
}

// MARK: - TMContactInfoPopUpViewControllerCoordinatorDelegate
extension TMNewRequestCoordinator: TMContactInfoPopUpViewControllerCoordinatorDelegate {
    func onChooseContactButton() {
        CNContactStore().requestAccess(for: .contacts) { (success: Bool, error: Error?) in
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let selectContactController = sb.instantiateViewController(withIdentifier: "TMContactsSelectionViewController") as? TMContactsSelectionViewController {
                    selectContactController.coordinatorDelegate = self
                    
                    CATransaction.begin()
                    self.navigationController.pushViewController(selectContactController, animated: true)
                    CATransaction.setCompletionBlock({ 
                        self.navigationController.viewControllers.remove(at: self.navigationController.viewControllers.count - 2) //Removes the ContactInfoPopUpViewController, when an action has been taken on contacts.
                    })
                    CATransaction.commit()
                }
            }
        }
    }
    
    func onManualContactButton() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let selectContactController = sb.instantiateViewController(withIdentifier: "TMContactsSelectionViewController") as? TMContactsSelectionViewController {
            selectContactController.coordinatorDelegate = self
            self.navigationController.pushViewController(selectContactController, animated: true)
        }    }

}
