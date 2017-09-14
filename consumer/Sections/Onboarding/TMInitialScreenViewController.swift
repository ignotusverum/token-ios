//
//  TMInitialScreenViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/20/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import Analytics

class TMInitialScreenViewController: UIViewController {
    
    @IBOutlet var signInLabel: UILabel!
    
    /// Description Label
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// Get Started Button
   // @IBOutlet weak var startButton: TMStandartButton!
    
    private lazy var startButton: UIButton = {
        let button = UIButton.button(style: .darkPink)
        
        button.setTitle("Get Started", for: .normal)
        button.addTarget(self, action: #selector(onGetStartedButton), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Private iVars

    /// Button Color
    private let buttonColor = UIColor.TMColorWithRGBFloat(61.0, green: 37.0, blue: 50.0, alpha: 1.0)
    
    /// Button Text Color
    private let buttonTextColor = UIColor.white
    
    /// Confetti view
    lazy private var confettiView: TMConfettiView = self.generateConfettiView()
    
    
    // MARK: - Public
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Confetti view---//
        
        confettiView.frame = view.bounds
        view.insertSubview(confettiView, at: 0)
        confettiView.startConfetti()
        
        //---Description label---//
        
        configureDescriptionLabel(label: &descriptionLabel!)
        
        //---Sign in Label---//
        
        configureSignInLabel(label: &signInLabel!)
        view.addSubview(signInLabel) //This should be added in the storyboard earlier but isn't for some reason 😠
        
        //---Get Started Button---//
        
        view.addSubview(startButton)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: startButton, attribute: .bottom, relatedBy: .equal, toItem: signInLabel, attribute: .top, multiplier: 1, constant: -22),
            NSLayoutConstraint(item: startButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 94 / 187, constant: 0),
            NSLayoutConstraint(item: startButton, attribute: .height, relatedBy: .equal, toItem: startButton, attribute: .width, multiplier: 34 / 94, constant: 0)
            ])
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
        
        TMAnalytics.trackScreenWithID(.s0)
    }
    
    // MARK: - Actions
    
    func onGetStartedButton(_ sender: UIButton?) {
        TMAnalytics.trackEventWithID(.t_S0_0)
        performSegue(withIdentifier: "GET_STARTED", sender: sender)
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton?) {
        TMAnalytics.trackEventWithID(.t_S0_1)
    }
}

// MARK: - Private Generators
private extension TMInitialScreenViewController {
    
    /// Private generator for confetti view.
    ///
    /// - Returns: A new TMConfettiView object.
    func generateConfettiView() -> TMConfettiView {
        let view = TMConfettiView()
        
        return view
    }
}

// MARK: - Private UI Configurators
private extension TMInitialScreenViewController {
    
    /// Configures properties for description label.
    ///
    /// - Parameter label: Label to configure.
    func configureDescriptionLabel(label: inout UILabel) {
        let fontSize = UIFont.defaultFontSize
        
        guard let text = label.text else {
            return
        }
        
        let descriptionString = NSMutableAttributedString.initWithString(text, lineSpacing: 12.0, aligntment: .center)
        descriptionString.addAttributes([NSFontAttributeName: UIFont.MalloryBook(fontSize)], range: NSMakeRange(0, text.length))
        label.attributedText = descriptionString
    }
    
    /// Configures properties for sign in label.
    ///
    /// - Parameter label: Label to configure.
    func configureSignInLabel(label: inout UILabel) {
        let fontSize = UIFont.defaultFontSize
        
        let firstAttributedString = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.gray])
        let secondAttributedString = NSMutableAttributedString(string: "Sign in", attributes: [NSFontAttributeName: UIFont.MalloryBold(fontSize)])
        
        firstAttributedString.append(secondAttributedString)
        
        label.attributedText = firstAttributedString
    }
    
    /// Configures navigation controller properties.
    ///
    /// - Parameter navigationController: Navigation controller for which to configure properties.
    func configureNavigationController(navigationController: inout UINavigationController) {
        
        //Transparent navigation bar.
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        
        navigationController.view.backgroundColor = UIColor.TMColorWithRGBFloat(249, green: 249, blue: 249, alpha: 1) //Set the navigation controllre view background color because its navigation bar is transparent and pushing a new view controller will result in a brief glimpse of the background because of the transparency. The default is normally black. This sets it to a more consistent color.
        
    }
}
