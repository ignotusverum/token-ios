//
//  TMNewRequestLocationCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import Foundation

protocol TMNewRequestLocationCollectionViewCellDelegate {
    
    func locationDidEnter(text: String)
}

class TMNewRequestLocationCollectionViewCell: UICollectionViewCell {
    
    /// Delegate
    var delegate: TMNewRequestLocationCollectionViewCellDelegate?
    
    /// Old gradient button
    private var oldGradientLayer: CAGradientLayer?
    
    /// Location input
    lazy var locationInput: UITextField = {
       
        let textField = UITextField(frame: .zero)
        textField.font = UIFont.ActaMedium(16)
        textField.textAlignment = .center
        textField.borderStyle = .none
        
        /// Placeholder
        let placeholder = NSAttributedString(string: "Brooklyn, NY", attributes: [NSFontAttributeName: UIFont.ActaBook(16), NSForegroundColorAttributeName: UIColor.TMLightGrayPlaceholder])
        textField.attributedPlaceholder = placeholder
        
        return textField
    }()
    
    /// Cell title
    lazy var titleLabel: UILabel = {
       
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 1
        
        label.text = "RECIPIENT’S LOCATION"
        label.textColor = UIColor.lightGray
        label.font = UIFont.MalloryBook(12)
        
        return label
    }()
    
    /// Input container view
    lazy var containerView: UIView = {
       
        let view = UIView(frame: .zero)
        
        return view
    }()
    
    /// Location icon image view
    lazy var locationImageView: UIImageView = {
       
        let imageView = UIImageView(image: #imageLiteral(resourceName: "location-icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Bottom divider view
    lazy var bottomDivider: UIView = {
       
        let view = UIView(frame: .zero)
        
        return view
    }()
    
    /// Clear button
    lazy var clearButton: UIButton = {
        
        let button = UIButton(frame: .zero)
        
        button.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
        
        /// Add action
        button.addTarget(self, action: #selector(onCrossButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    /// Location buttons
    lazy var locationButtons: [TMLocationButton] = {
       
        var result: [TMLocationButton] = []
        for location in ButtonLocations.allData {
            
            let button = TMLocationButton(frame: .zero)
            button.location = location
            result.append(button)
            
            /// Color
            button.backgroundColor = UIColor.white
            
            /// Deselect all buttons
            button.isSelected = false
            
            /// Add button selector
            button.addTarget(self, action: #selector(onLocationButton(_:)), for: .touchUpInside)
        }
        
        return result
    }()
    
    /// Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Background
        backgroundColor = UIColor.white
        
        /// Title
        addSubview(titleLabel)
        
        /// Container
        addSubview(containerView)
        
        /// Text input
        containerView.addSubview(locationInput)
        
        /// Cross button
        containerView.addSubview(clearButton)
        
        /// Pin icon
        containerView.addSubview(locationImageView)
        
        /// Container divider
        containerView.addSubview(bottomDivider)
        
        /// Location buttons
        let _ = locationButtons.map { addSubview($0) }
        
        /// Layout setup
        var containerLayout = TMNewRequestLocationInputLayout(locationInput: locationInput, clearButton: clearButton, locationImageView: locationImageView, dividerView: bottomDivider)
        var layout = TMNewRequestLocationCollectionViewLayout(title: titleLabel, container: containerView, containerLayout: containerLayout, locationButtons: locationButtons)
        
        layout.layout(in: bounds)
        containerLayout.layout(in: containerView.bounds)
        
        /// Text input
        locationInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        /// Add shadow
        let _ = locationButtons.map { $0.addShadow() }
        
        /// Gradient
        bottomDivider.addGradient()
    }
    
    /// Text did change
    func textFieldDidChange(_ textField: UITextField) {
        
        delegate?.locationDidEnter(text: textField.text ?? "")
    }
    
    // MARK: - Actions
    func onLocationButton(_ sender: TMLocationButton) {
        
        /// Unselect other buttons
        let _ = locationButtons.map { $0.isSelected = false }
        
        /// Set selected
        sender.isSelected = true
        
        /// Apply copy
        locationInput.text = sender.location.locationCopy()
        
        /// Remove old gradient
        oldGradientLayer?.removeFromSuperlayer()
        
        /// Apply grandient
        oldGradientLayer = sender.addGradienBorder()
        
        /// Call delegate method
        delegate?.locationDidEnter(text: sender.location.locationCopy())
    }
    
    func onCrossButton(_ sender: UIButton) {
        
        /// Unselect other buttons
        let _ = locationButtons.map { $0.isSelected = false }
        
        /// Clear text input
        locationInput.text = ""
        
        /// Clear gradient
        oldGradientLayer?.removeFromSuperlayer()
        
        /// Call delegate method
        delegate?.locationDidEnter(text: "")
    }
}
