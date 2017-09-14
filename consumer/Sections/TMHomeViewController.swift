//
//  TMHomeViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/8/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

enum TabTitles: String, CustomStringConvertible {
    case gifts
    case contacts
    
    internal var description: String {
        return rawValue.uppercasedPrefix(0)
    }
    
    static let allValues = [gifts, contacts]
}

private var tabIcons = [
    TabTitles.gifts: "gifts_tab_icon",
    TabTitles.contacts: "contacts_tab_icon"
]

class TMHomeViewController: UITabBarController {

    let tabHeight: CGFloat = 0//60
    
    /// Tab bar controllers
    lazy var controllers: [UIViewController] = {
        
        /// Gifts view controller
        /// Set navigation controller with custom bar
        let requestNavigation = TMRequestNavigationController(rootViewController: TMRequestViewController())
        
        /// Set navigation controllers
        requestNavigation.navigationBar.isTranslucent = false
        requestNavigation.navigationBar.barTintColor = UIColor.TMGrayBackgroundColor
        
        /// Coordinator setup
        let requestCoordinator = TMNewRequestCoordinator(with: requestNavigation)
        requestCoordinator.start()
        
        /// Contacts view controller
        let contactsVC = TMContactsViewController()
        
        let contactsNavigation = UINavigationController(navigationBarClass: TMNavigationBar.self, toolbarClass: nil)
        
        contactsNavigation.viewControllers = [contactsVC]
        
        /// Set navigation controllers
        contactsNavigation.navigationBar.isTranslucent = false
        contactsNavigation.navigationBar.barTintColor = UIColor.TMGrayBackgroundColor
        
        return [requestNavigation, contactsNavigation]
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = controllers
        
        /// Setup UI
        setupTabBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Setup tabBar appearance
    private func setupTabBar() {
        
        /// Make it solid

        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor.notSelected
        
        /// Tab bar colors
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.notSelected, NSFontAttributeName: UIFont.MalloryMedium(11)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.notSelected, NSFontAttributeName: UIFont.MalloryMedium(11)], for: .selected)
        
        for (index, tabBarItem) in TabTitles.allValues.enumerated() {
            
            /// Safety check
            guard let item = tabBar.items?[index] else {
                return
            }
            
            /// Make text closer to icons
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
            
            item.title = tabBarItem.description.capitalizedFirst()
          //  item.image = UIImage(named: "\(tabBarItem.description)_tab_icon")?.withRenderingMode(.alwaysOriginal)
            //item.selectedImage = UIImage(named: "\(tabBarItem.description)_tab_icon")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }
    
    override func viewDidLayoutSubviews() {
        var tabFrame = tabBar.frame
        tabFrame.size.height = tabHeight
        tabFrame.origin.y = view.frame.size.height - tabHeight
        tabBar.frame = tabFrame
    }
}
