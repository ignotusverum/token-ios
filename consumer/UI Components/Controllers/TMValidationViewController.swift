//
//  TMValidationViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/6/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

// Animation Framework
import pop
import EZSwiftExtensions

// MARK: - Input State Enums
// Enums for input state (strings for analytics)

public enum TMValidationInputState: String {
    
    case Empty = "Empty"
    case Filled = "Filled"
    case PatriallyFilled = "PartiallyFilled"
}

class TMValidationViewController: UIViewController {
    
    // MARK: - Input State
    
    var inputState: TMValidationInputState = .Empty
    
    // MARK: - Table View Outlet
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Flat button
    
    @IBOutlet var flatButton: TMStandartButton!
    
    // MARK: - Keyboard height - TODO: update to autolayout
    
    var keyboardHeight: CGFloat?
    var keyboardPresendted = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hideBottomHairline()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(TMValidationViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        nc.addObserver(self, selector: #selector(TMValidationViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.endEditing(true)
        
        self.resetNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.resetNavbar()
        
        ez.runThisAfterDelay(seconds: 0.1, after: {
            
            self.setupViewConroller()
            
        })
    }
    
    // Reset shadow from scrollView
    func resetNavbar() {
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
    }
    
    // MARK: - Custom Controller setup
    
    func setupViewConroller() { }
    
    // MARK: - Keyboard Notifications
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        let keyboardBounds = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        if self.keyboardHeight == nil {
            
            self.keyboardHeight = keyboardBounds?.size.height
        }
        
        self.keyboardPresendted = true
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        
        self.keyboardPresendted = false
    }
    
    // MARK: - Flat button animation
    
    func updateAnimatinForCurrentState() {
        
        switch self.inputState {
        case .Empty:
            print("empty state")
        case .Filled:
            print("filled state")
        case .PatriallyFilled:
            print("partially filled")
        }
    }
    
    // Animate button on top of keyboard
    func showButtonAboveKeyboard() {
        
        if let keyboardHeight = self.keyboardHeight {
            
            self.showButtonWithAnimationForYPos(keyboardHeight + 40.0)
        }
        else {
            
            self.showButtonWithAnimationForYPos(self.flatButton.frame.size.height + 20.0)
        }
        
        self.flatButton.animationPresented = true
    }
    
    // Animate butotn off screen
    func hideButtonFromScreen() {
        
        self.showButtonWithAnimationForYPos(-self.flatButton.frame.size.height)
        self.flatButton.animationPresented = false
    }
    
    // Animate button to bottom of the window
    func hideButtonWithAnimation() {
        
        self.showButtonWithAnimationForYPos(self.flatButton.frame.size.height + 20.0)
        self.flatButton.animationPresented = false
    }
    
    // Utility animation method
    func showButtonWithAnimationForYPos(_ yPos: CGFloat) {
        
        if self.flatButton != nil {
            
            let springAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            springAnimation?.toValue = NSValue(cgPoint: CGPoint(x: self.view.bounds.size.width / 2.0, y: self.view.frame.size.height - yPos))
            springAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 100, y: 10))
            
            self.flatButton.pop_add(springAnimation, forKey: "center")
        }
    }
}

// MARK: - TableView Datasource

extension TMValidationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "creditCardCell", for: indexPath)
        
        return cell
    }
}

// MARK: - ScrollView Shadow logic

extension TMValidationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let shadowOffset = (scrollView.contentOffset.y / 100.0) - 2.0
        
        let shadowRadius = min(max(shadowOffset, 1), 3)
        
        if shadowOffset < 0.2 {
            
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: shadowOffset)
            self.navigationController?.navigationBar.layer.shadowRadius = shadowRadius
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        }
    }
}
