//
//  File.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

protocol RequestCellProtocol {
    /// Request object to display in cell.
    var request: TMRequest? { get set }
    
    /// Image view for contact. Can be a profile pic or wax initial image.
    var avatarImageView: UIImageView { get set }
    
    /// Label for contact name.
    var nameLabel: UILabel { get set }
    
    /// Label for info about request such as price and occasion.
    var infoLabel: UILabel { get set }
}

extension RequestCellProtocol {
    
    /// Retreives colors from request to use in status label.
    ///
    /// - Parameters:
    ///   - requestStatus: Status of the request.
    ///   - requestViewed: Has the request been viewed by the user.
    /// - Returns: Text color, border color and background color to use for status label.
    func statusLabelColors(for requestStatus: RequestStatus, requestViewed: Bool) -> (textColor: UIColor, borderColor: UIColor, backgroundColor: UIColor) {
        var textColor: UIColor = .TMGrayPlaceholder
        var borderColor: UIColor = .clear
        var backgroundColor: UIColor = .clear
        
        switch requestStatus {
        case .pending:
            
            textColor = .white
            backgroundColor = UIColor(patternImage: UIImage(named: "gradient-status")!)
            
        case .selection:
            let selectionColor: UIColor = .TMColorWithRGBFloat(255.0, green: 103.0, blue: 93.0, alpha: 1.0)
            
            if requestViewed == true {
                textColor = selectionColor
                borderColor = selectionColor
            } else {
                textColor = .white
                backgroundColor = selectionColor
            }
            
        case .purchase:
            let purchaseColor: UIColor = .TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
            
            textColor = purchaseColor
            borderColor = purchaseColor
            
        case .shipment:
            let shipmentColor: UIColor = .TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
            
            textColor = shipmentColor
            borderColor = shipmentColor
            
        case .delivery:
            let deliveryColor: UIColor = .TMColorWithRGBFloat(61.0, green: 37.0, blue: 50.0, alpha: 1.0)
            
            textColor = deliveryColor
            borderColor = deliveryColor
        }
        
        return (textColor, borderColor, backgroundColor)
    }
    
    /// Determines if request has been viewed by user for a request.
    ///
    /// - Parameter request: Request to determine view status.
    /// - Returns: True if the request was viewed
    func requestViewed(request: TMRequest) -> Bool {
        let recom = request.recommendationArray.first
        
        var seen = recom?.seen
        if recom?.seen == nil {
            seen = false
        }
        
        if let _ = recom, seen!.boolValue == true {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Private Generators
extension RequestCellProtocol {
    
    /// Generates occassion text from a request. Includes occassion and price.
    ///
    /// - Parameter request: Request to get occassion text.
    /// - Returns: String of text of the occassion details.
    func generateOccasionText(from request: TMRequest) -> String {
        var occasionResult = ""
        
        if var occasion = request.occasion {
            // Cut off
            if occasion.length > 18 {
                let index = occasion.characters.index(occasion.startIndex, offsetBy: 15)
                occasion = "\(occasion.substring(to: index))..."
            }
            
            occasionResult = occasion
        }
        
        if request.priceRangeString.length > 1 {
            occasionResult = "\(occasionResult) | \(request.priceRangeString)"
        }
        
        return occasionResult
    }
    
    /// Generates an avatar image from a request. If no image exists, a wax initial image will be used instead.
    ///
    /// - Parameters:
    ///   - request: Request to get image from contact.
    ///   - avatarImage: Closure returning image for request.
    func generateAvatarImage(from request: TMRequest, avatarImage: @escaping (UIImage?) -> Void) {
        
        /// Generates a wax image for contact
        ///
        /// - Parameter fullName: Name of contact. First initial will be used for wax image.
        /// - Returns: Wax image representing contact.
        func generateWaxAvatarImage(from fullName: String) -> UIImage? {
            guard fullName.length != 0 else {
                return nil
            }
            
            let firstNameInitial = fullName[0]
            
            let sealName = "\(firstNameInitial)-wax"
            
            guard let image = UIImage(named: sealName) else {
                return UIImage(named: "default-wax")
            }
            
            return image
        }
        
        let name = request.contact?.availableName.uppercased() ?? request.contact?.fullName ?? ""
        
        request.contact?.getImage({ (image) in
            if let image = image {
                avatarImage(image)
            } else {
                avatarImage(generateWaxAvatarImage(from: name))
            }
        }, failure: {
            print("Could not fetch image for contact \(String(describing: request.contact?.fullName))")
        })
    }
    
    /// Generates contact name label attributes.
    ///
    /// - Parameter text: Text to use to set attributes.
    /// - Returns: Attributed string with provided text.
    func generateContactNameLabelAttributedString(text: String, textColor: UIColor, textSize: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.ActaBook(textSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
    
    /// Generates request information label attributes.
    ///
    /// - Parameter text: Text to use to set attributes.
    /// - Returns: Attributed string with provided text.
    func generateRequestInformationLabelAttributedString(text: String, textColor: UIColor, textSize: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.MalloryExtraLight(textSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
    
    /// Generates status label attributes.
    ///
    /// - Parameter text: Text to use to set attributes.
    /// - Returns: Attributed string with provided text.
    func generateStatusLabelAttributedString(text: String, textColor: UIColor, textSize: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.MalloryMedium(textSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName : paragraphStyle, NSKernAttributeName: 0.8])
        
        return attributedString
    }
}
