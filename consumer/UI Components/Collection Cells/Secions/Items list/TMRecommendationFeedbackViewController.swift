//
//  TMRecommendationFeedbackViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import SVProgressHUD

/// State of TMRecommendationFeedbackViewController.
///
/// - normal: Feedback cell is showing but not editing.
/// - editingFeedback: Feedback cell is showing and editing.
/// - hidden: Feedback cell is hidden from view.
enum TMRecommendationFeedbackViewControllerState {
    
    case normal
    case editingFeedback
    case hidden
}

protocol TMRecommendationFeedbackViewControllerProtocol {
    
    /// Feedback was sent.
    ///
    /// - Parameter error: Error if feedback was sent unsuccessfully, nil if it was successful.
    func feedbackSent(error: Error?)
}

class TMRecommendationFeedbackViewController: UIViewController {
    
    // MARK: - Public iVars
    
    /// State of the view controller.
    var state: TMRecommendationFeedbackViewControllerState = .normal
    
    /// TMRecommendationFeedbackViewControllerProtocol delegate.
    var delegate: TMRecommendationFeedbackViewControllerProtocol?
    
    // MARK: - Private iVars
    
    /// Background blur view.
    private lazy var backgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        return view
    }()
    
    /// Collection view displaying feedback cell.
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = TMRecommendationFeedbackCollectionViewLayout(with: self.state)
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TMRequestNotesCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMRequestNotesCollectionViewCell.self)")
        
        return collectionView
    }()
    
    /// String contained in feedback cell.
    fileprivate var feedbackString = ""
    
    /// Done button to display when entering feedback text.
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton.button(style: .muavePattern)
        
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(onDoneButton), for: .touchUpInside)
        
        return button
    }()
    
    /// Current keyboard height.
    fileprivate var keyboardHeight: CGFloat = 0
    
    /// Recommendation to use for feedback.
    fileprivate var recommendation: TMRecommendation
    
    // MARK: - Public
    
    init(recommendation: TMRecommendation) {
        self.recommendation = recommendation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Background View---//
        
        view.addSubview(backgroundView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: backgroundView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: backgroundView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: backgroundView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        )
        
        //---Collection View---//
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 90),
             NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        )
        
        //---Done Button---//
        
        doneButton.frame = CGRect(x: 0, y: 0, w: view.bounds.width, h: view.bounds.height / 11)
        
        //---Keyboard---//
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    /// Shows the view controller and coressponding views.
    ///
    /// - Parameter animated: True if showing should be animated.
    func show(animated: Bool) {
        let duration = animated ? 0.3 : 0
        
        state = .editingFeedback
        UIView.animate(withDuration: duration, animations: {
            self.stateDidChange()
        })
    }
    
    /// Hides the view controller and coressponding views.
    ///
    /// - Parameter animated: True if hiding should be animated.
    func hide(animated: Bool) {
        let duration = animated ? 0.3 : 0
        
        state = .hidden
        UIView.animate(withDuration: duration, animations: {
            self.stateDidChange()
        })
    }
    
    // MARK: - Private
    
    /// Changes UI state based on the set state property.
    fileprivate func stateDidChange() {
        let newLayout = TMRecommendationFeedbackCollectionViewLayout(with: state) //New collection view layout based on state of the view controller.
        newLayout.delegate = self
        
        switch state {
        case .normal:
            view.isUserInteractionEnabled = true
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TMRequestNotesCollectionViewCell {
                let _ = cell.bodyView.resignFirstResponder()
            }
            
        case .editingFeedback:
            
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TMRequestNotesCollectionViewCell {
                if !cell.bodyView.isFirstResponder {
                    let _ = cell.bodyView.becomeFirstResponder()
                    
                    view.isUserInteractionEnabled = true
                    backgroundView.effect = UIBlurEffect(style: .light)
                    collectionView.setCollectionViewLayout(newLayout, animated: true)
                }
            }

            view.isUserInteractionEnabled = true
            backgroundView.effect = UIBlurEffect(style: .light)
            collectionView.setCollectionViewLayout(newLayout, animated: true)
        case .hidden:
            
            if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TMRequestNotesCollectionViewCell {
                let _ = cell.bodyView.resignFirstResponder()
            }
            
            view.isUserInteractionEnabled = false
            backgroundView.effect = nil
            collectionView.setCollectionViewLayout(newLayout, animated: true)
        }
    }
    
    // MARK: - Notifications
    
    /// Notification when keyboard shows.
    ///
    /// - Parameter notification: Notification object.
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.keyboardHeight = keyboardHeight
        }
    }
    
    // MARK: - Actions
    
    /// Done button was tapped.
    ///
    /// - Parameter button: Button tapped.
    @objc private func onDoneButton(button: UIButton) {
        SVProgressHUD.show()
        
        TMRecommendationsAdapter.rate(recommendation: recommendation, feedback: feedbackString).then { result -> Void in
            SVProgressHUD.dismiss()
            self.delegate?.feedbackSent(error: nil)
            }.catch { error -> Void in
                SVProgressHUD.dismiss()
                self.delegate?.feedbackSent(error: error)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TMRecommendationFeedbackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 //Single feedback cell.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestNotesCollectionViewCell.self)", for: indexPath) as? TMRequestNotesCollectionViewCell else {
            fatalError("Cell is incorrect type.")
        }
        
        cell.backgroundColor = UIColor.white
        cell.sizeDelegate = self
        cell.delegate = self
        cell.indexPath = indexPath
        cell.bodyView.inputAccessoryView = doneButton

        cell.title = "Help us crush this gift!"
        cell.subtitle = ""
        cell.placeholder = "Right / Wrong item categories? Different styles? Other info about recipient?"
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TMRecommendationFeedbackViewController: TMRecommendationFeedbackCollectionViewLayoutProtocol {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width - 22
        let minimumHeight = collectionView.bounds.height - keyboardHeight - 10 //10 provices a little padding between bottom of text view and keyboard.
        let height = TMRequestNotesCollectionViewCell.calculatedCellHeight(cellWidth: width, bodyViewData: feedbackString, minHeight: minimumHeight)
        return CGSize(width: width, height: height)
    }
}

// MARK: - TMRequestNotesCollectionViewCellProtocol
extension TMRecommendationFeedbackViewController: TMRequestNotesCollectionViewCellProtocol {
    func textCaretPositionChanged(caretRect: CGRect, textView: UITextView) {
        var convertedCaretRect = collectionView.convert(caretRect, from: textView)
        
        let caretPadding: CGFloat = 50 //Padding at the bottom of the caret location, so when we scroll to the caret there is a little spacing underneath.
        convertedCaretRect.origin.y += caretPadding
        collectionView.scrollRectToVisible(convertedCaretRect, animated: true)
        
        feedbackString = textView.text

        /// Setting done button to enable when there's text
        doneButton.isEnabled = feedbackString != ""
    }
}

// MARK: - TMRequestCellSizeProtocol
extension TMRecommendationFeedbackViewController: TMRequestCellSizeProtocol {
    func sizeDidUpdate(_ indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout as? TMRecommendationFeedbackCollectionViewLayout else {
            return
        }
        
        layout.reset()
    }
}
