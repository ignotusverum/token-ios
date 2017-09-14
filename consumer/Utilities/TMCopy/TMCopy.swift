//
//  TMCopy.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMCopy: NSObject {

    public struct EmptyRequestState {
        
        static let title = "Welcome to Token."
        static let body = "Let’s get started:\nThink of someone important to you.\nLet’s find them a gift."
    }
    
    public struct RequestConfirmation {
        
        static let title = "We are on it."
        static var replaceName = "them"
        
        static var body: String {
            
            return "We’ll report back promptly\nwith wonderful gifts for \(replaceName).\nMeanwhile, chat with us should\nyou have any questions."
        }
    }
    
    public struct OrderConfirmation {
        
        static let title = "How thoughtful!"
        static var replaceName = "They"
        
        static var body: String {
            
            return "\(replaceName) will love your gift.\nWe’ll update you when it ships\nand when it arrives. Cheers!"
        }
    }
    
    public struct FeedbackConfirmation {
        
        static let title = "Stand by for more gifts!"
        
        static var body: String {
            
            return "Thanks for the thoughtful feedback.\nToken's gift experts will use it to refine\nyour gift selection. Check back soon."
        }
    }
    
    // MARK: - Empty States
    open class var TMEptyStateTitle: UIColor {
        return UIColor.TMColorWithRGBFloat(243.0, green: 190.0, blue: 135.0, alpha: 1.0)
    }
    
    // Shared
    static let sharedCopy = TMCopy()
    
    var privaryHTMLCode: NSAttributedString?
    
    var faqHTMLCode: NSAttributedString?
    
    static var termsCopy: NSAttributedString {
        
        let copy = "By pressing continue, you are\nagreeing to be bound by Token’s\n"
        
        let resultString = NSMutableAttributedString.initWithString(copy, lineSpacing: 6.0, aligntment: .center)
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Terms of Use & Privacy Policy.", attributes: underlineAttribute)
        
        resultString.append(underlineAttributedString)
        
        resultString.addAttribute(NSFontAttributeName, value: UIFont.ActaBook(UIFont.defaultFontSize + 2), range: NSMakeRange(0, resultString.length))
        
        return resultString
    }
    
    static var relationArray = ["Professional", "Friend", "Spouse/Partner", "Mother", "Father", "Sister", "Brother", "Son", "Daughter"]
    
    static var ageArray =
        ["0 - 1", "1 - 2", "3 - 4", "5 - 7", "8 - 10", "11 - 13", "14 - 15", "16 - 18", "18 - 24", "25 - 34", "35 - 44", "45 - 54", "55 - 64", "65+"]
    
    static var genderArray = ["Female", "Male", "Other"]
    
    /// Navigation title for request
    ///
    /// - Parameters:
    ///   - title: title for section
    ///   - request: request
    /// - Returns: attirbuted string with format (section \n fullName | occasion)
    class func navigationTitle(title: String, request: TMRequest?)-> NSMutableAttributedString {
        
        guard let request = request else {
            return "".with(lineSpacing: 0.0, alignment: .center)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        paragraphStyle.alignment = .center
        
        let titleAttributes = NSMutableAttributedString(string: "\(title)\n", attributes: [NSFontAttributeName: UIFont.MalloryBook(), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName : paragraphStyle])
        
        var resultString = ""
        
        var resultAttributedString = titleAttributes
        
        let fullName = request.receiverNameDisplay
        
        let occasion = request.occasion
        
        let dividerString = " | "
        
        if let fullName = fullName {
            resultString = resultString + fullName + dividerString
        }
        
        if let occasion = occasion {
            resultString = resultString + occasion
        }
        
        let textColor = UIColor.TMColorWithRGBFloat(113.0, green: 112.0, blue: 115.0, alpha: 1.0)
        resultAttributedString = NSMutableAttributedString.initWithString(resultString, lineSpacing: 5.0, aligntment: .center)
        resultAttributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryBook(UIFont.defaultFontSize - 2.0), range: NSRange(location: 0, length: resultString.utf16.count))
        resultAttributedString.addAttributes([NSFontAttributeName: UIFont.MalloryBook(UIFont.defaultFontSize - 2.0), NSForegroundColorAttributeName: textColor], range: NSRange(location: 0, length: resultString.utf16.count))
        
        titleAttributes.append(resultAttributedString)
        
        return titleAttributes
    }
}
