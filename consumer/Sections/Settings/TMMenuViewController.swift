//
//  TMMenuViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import MessageUI
import AsyncDisplayKit
import EZSwiftExtensions
import JDStatusBarNotification

let accountStoryboardKey = "Account"
let paymentStoryboardKey = "Payment"
let onboardingStoryboardKey = "Onboarding"
let termsStoryboardKey = "Terms"

let onboardingInitialControllerID = "onboardingSectionRoot"

enum MenuRows: Int {
    
    case accountCell = 0
    case paymentsCell = 1
    case addressesCell = 2
    case feedbackCell = 3
    case termsCell = 4
    case helpCell = 5
    case faqCell = 6
    case logoutCell = 7
    case versionCell = 8
}

struct MenuItems {
    
    let cellIdentifiers = ["AccountCell", "PaymentsCell", "AddressesCell", "FeedbackCell", "TermsCell", "HelpCell", "FAQCell", "LogoutCell", "VersionCell"]
    let controllerIdentifiers = ["accountViewController", "paymentViewController", "addressViewController", "helpViewController", "termsViewController", "helpViewController", "faqViewcontroller"]
    
    let accountViewController = UIViewController.viewControllerFromStoryboard("Account", controllerIdentifier: "profileViewController")
    let paymentViewController = UIViewController.viewControllerFromStoryboard("Payment", controllerIdentifier: "paymentViewController")
    let addressViewController = UIViewController.viewControllerFromStoryboard("Address", controllerIdentifier: "addressViewContoller")
    
    let faqViewController = UIViewController.viewControllerFromStoryboard("About", controllerIdentifier: "faqViewController")
    
    let termsViewController = UIViewController.viewControllerFromStoryboard("Terms", controllerIdentifier: "termsViewController")
    let helpViewController = UIViewController()
}

class TMMenuViewController: SlideMenuController {
    
    static var sharedMenu = TMMenuViewController.initMenu()
    
    @IBOutlet fileprivate var tableView: UITableView?
    
    fileprivate let menuItems = MenuItems()
    fileprivate var menuControllers = [UIViewController]()
    
    private var requestNavigationController = UINavigationController()
    
    var selectedSection = NSString()
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleText("ACCOUNT", color: UIColor.white)
        
        menuControllers = [menuItems.accountViewController, menuItems.paymentViewController, menuItems.addressViewController, menuItems.helpViewController, menuItems.termsViewController, menuItems.helpViewController, menuItems.faqViewController]
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessfulLoginNotification), name: NSNotification.Name(rawValue: TMNetworkingManagerLoginSuccessfulNotificationKey), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s17)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView?.scrollToRow(at: IndexPath(row: MenuRows.accountCell.rawValue, section: 0), at: .top, animated: false)
        
        TMUserAdapter.fetchMe().then { Void in
            
            self.tableView?.reloadData()
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    class func initMenu()-> SlideMenuController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuNavigationController")
        
        let requestNavigationController = storyboard.instantiateViewController(withIdentifier: "requestSectionRoot") as! TMRequestNavigationController
        
        let requestCoordinator = TMNewRequestCoordinator(with: requestNavigationController)
        
        let slideMenuController = TMMenuViewController(mainViewController: requestNavigationController, leftMenuViewController: menuViewController)
        
        requestCoordinator.start(with: slideMenuController)
        
        return slideMenuController
    }
    
    func onSuccessfulLoginNotification() {
        TMMenuViewController.sharedMenu = TMMenuViewController.initMenu()
    }
    
    @IBAction func unwindToRequestController(_ segue: UIStoryboardSegue) { }
    
    // MARK: - Menu Selection logic
    
    func selectMenuItem(_ index: Int, completion:()-> Void) {
        
        if index != MenuRows.logoutCell.rawValue && index != MenuRows.helpCell.rawValue &&  index != MenuRows.versionCell.rawValue && index != MenuRows.feedbackCell.rawValue {
            navigationController?.pushViewController(menuControllers[index], animated: true)
        }
            // Help section
        else if index == MenuRows.helpCell.rawValue {
            presentMail(true)
        }
        else if index == MenuRows.feedbackCell.rawValue {
            presentMail(false)
        }
    }

    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        
        TMNetworkingManager.shared.promiseLogout().then { result -> Void in
            
            TMMenuViewController.sharedMenu.toggleLeft()
            
            // Return to initial onboarding
            TMOnboardingRouteHandler.initialTransition()
            
            TMMenuViewController.sharedMenu = TMMenuViewController.initMenu()
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    @IBAction func accountEditButtonPressed(_ sender: Any) {
        
        selectMenuItem(0) { }
    }
    
    @IBAction func accountSectionButtonPressed(_ sender: UIButton) {
        
        TMConsumerConfig.checkForUpdates(forced: true).catch { error in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func toggleMenuButtonPressed(_ sender: Any) {
       
        TMMenuViewController.sharedMenu.toggleLeft()
    }
    
    // Mail Methods
    func presentMail(_ forHelp: Bool) {
        
        var mailComposeViewController = configureHelpMailController()
        if !forHelp {
            mailComposeViewController = configureFeedbackMailController()
        }
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configureHelpMailController()-> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["help@token.ai"])
        mailComposerVC.setSubject("Help")
        
        return mailComposerVC
    }
    
    func configureFeedbackMailController()-> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["feedback@token.ai"])
        mailComposerVC.setSubject("Feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert);
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil));
        
        present(alert, animated: true, completion: nil);
    }
}

// MARK: - Mail Composer delegate
extension TMMenuViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView Delegate

extension TMMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        if indexPath.row == MenuRows.versionCell.rawValue {
            
            let cell = tableView.cellForRow(at: indexPath)
            
            let versionCell = cell as! TMMenuTableViewTableViewCell
            
            var cellText = versionCell.titleLabel?.text
            if cellText == "V " + ez.appVersion! {
                
                cellText = "V ( \(ez.appBuild!) )"
            }
            else {
                
                cellText = "V \(ez.appVersion!)"
            }
            
            versionCell.titleLabel?.text = cellText
        }
        else {
            
            selectMenuItem(indexPath.row) { () in }
        }
    }
}

// MARK: - TableView Datasource

extension TMMenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.cellIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = menuItems.cellIdentifiers[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.row == menuItems.cellIdentifiers.count - 1 {
            
            let versionCell = cell as? TMMenuTableViewTableViewCell
            
            versionCell?.titleLabel?.text = "V " + ez.appVersion!
            cell = versionCell!
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 410.0
        }
        
        return 63.0
    }
}
