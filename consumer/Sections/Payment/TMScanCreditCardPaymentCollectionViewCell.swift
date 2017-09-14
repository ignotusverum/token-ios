//
//  TMScanCreditCardPaymentCollectionViewCell.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/13/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMScanCreditCardPaymentCollectionViewCellProtocol {
    
    /// When the scan control button is tapped in the cell.
    func scanControlTapped()
}

class TMScanCreditCardPaymentCollectionViewCell: TMAddCreditCardPaymentCollectionViewCell {
    
    //MARK: - Public iVars
    
    override var theme: TMAddCreditCardPaymentTheme! {
        didSet {
            scanCreditCardControl.titleLabel.textColor = theme.accessoryColor()
            scanCreditCardControl.imageView.tintColor = theme.accessoryColor()
            scanCreditCardControl.backgroundColor = theme.backgroundColor()
        }
    }
    
    /// Delegate for TMScanCreditCardPaymentCollectionViewCellProtocol.
    var scanDelegate: TMScanCreditCardPaymentCollectionViewCellProtocol?
    
    //MARK: - Private iVars
    
    /// Scan credit card control in cell.
    private lazy var scanCreditCardControl: ScanControl = {
        let control = ScanControl()
        
        control.addTarget(self, action: #selector(onScanControl), for: .touchUpInside)
        
        return control
    }()
    
    /// Determines if the cell has enough space to display the full scan control.
    private var largeCellWidth: Bool {
        if bounds.width >= 280 {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scanCreditCardControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !largeCellWidth { //If the cell is too small, we only want the image to be displayed without the 'SCAN' text.
            scanCreditCardControl.controlState = .image
        }
        
        var scanButtonWidth: CGFloat = 65 //Width of cell with scan text.
        
        switch scanCreditCardControl.controlState {
        case .image:
            scanButtonWidth = 20 //If the image is the only thing displaying.
        default:
            break
        }
        
        let scanButtonFrame = CGRect(x: bounds.width - scanButtonWidth, y: textField.frame.origin.y, width: scanButtonWidth, height: 20)
        scanCreditCardControl.frame = scanButtonFrame
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard largeCellWidth else {
            return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        
        //Detects backspace.
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let backSpaceUnicodeValue: Int32 = -92
        
        if string.length != 0 {
            scanCreditCardControl.hideTitleLabel(hidden: true, animated: true, completion: { 
                self.setNeedsLayout() //We want the frame change to happen after animation completes, so this gets called in the completion block.
            })
        }
        
        if isBackSpace == backSpaceUnicodeValue && textField.text?.length == 1 { //Checks if backspace was tapped.
            scanCreditCardControl.hideTitleLabel(hidden: false, animated: true, completion: {
            })
            self.setNeedsLayout() //We want the frame to change before the animation completes, so this gets called outside of the completion block.
        }
        
        
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    //MARK: - Actions
    
    /// When scan control is tapped.
    @objc private func onScanControl() {
        scanDelegate?.scanControlTapped()
    }
}

//MARK: - Scan Control

/// Possible states for the scan control.
///
/// - titleAndImage: When title and image are displayed.
/// - image: When only image is displayed.
private enum ScanControlState {
    case titleAndImage
    case image
}

private class ScanControl: UIControl {
    
    // MARK: - Public iVars
    
    /// Camera image view.
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "scan")
        imageView.contentMode = .right
        
        return imageView
    }()
    
    /// Title label of control.
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        let text = "SCAN"
        let labelAttributedString = NSMutableAttributedString(string: text)
        labelAttributedString.addAttribute(NSKernAttributeName, value: 0.6, range: NSMakeRange(0, text.length))
        
        label.attributedText = labelAttributedString
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.font = UIFont.MalloryMedium(12)
        
        return label
    }()
    
    /// State of the scan control.
    var controlState: ScanControlState = .titleAndImage
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(titleLabel)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch controlState {
        case .titleAndImage:
            var horizontalLayout = HorizontalLayout(contents: [titleLabel.withInsets(right: -(bounds.height / 2)), imageView], horizontalSeperatingSpace: 0) //Title label has an inset because it needs more room than the image.
            horizontalLayout.layout(in: bounds)
        case .image:
            imageView.frame = bounds //If image is the only thing displaying then it can take the whole frame.
        }

        imageView.frame.origin.y -= 2 //The image we use for the camera scan creates an illusion where it seems to be off center with the title label. This minor adjustment accounts for that.
    }
    
    /// Handles state changes.
    func stateDidChange() {
        switch controlState {
        case .titleAndImage:
            titleLabel.alpha = 1
        case .image:
            titleLabel.alpha = 0
        }
    }
    
    /// Toggles title label visibility.
    ///
    /// - Parameter hidden: Should the title label be hidden or not.
    /// - Parameter animated: Should the title label animate when hiding or showing.
    /// - Parameter completion: When hidden animation has completed.
    func hideTitleLabel(hidden: Bool, animated: Bool, completion: @escaping () -> Void) {
        var duration: Double = 0
        
        if animated { duration = 0.3 }

        if hidden {
            controlState = .image
        } else {
            controlState = .titleAndImage
        }

        UIView.animate(withDuration: duration, animations: {
            self.stateDidChange()
        }) { (Bool) in
            completion()
        }
    }
}
