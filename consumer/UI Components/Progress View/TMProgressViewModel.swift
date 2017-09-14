//
//  TMProgressViewModel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Datasource for status info
struct TMStatusData {
    
    var status: RequestStatus
    
    var title: NSAttributedString
    var dateString: NSAttributedString
    
    var description: NSAttributedString
    
    var active: Bool = false
    
    var color: UIColor
}

struct TMProgressViewModel {
    
    /// Request
    var request: TMRequest
    
    /// Current State
    var activeStatus: RequestStatus
    
    /// All statuses
    var statuses: [TMStatusData] {
        
        return generateStaticStatuses()
    }
    
    init(request: TMRequest) {
        
        self.request = request
        activeStatus = request.status
    }
    
    // MARK: - Utilities
    
    /// Generates statuses objects for progress view
    ///
    /// - Returns: array of statuses
    private func generateStaticStatuses()-> [TMStatusData] {
        
        guard let requestDate = request.updatedAt else {
            return []
        }
        
        var resultArray: [TMStatusData] = []
        
        /// Enumerate through all static statuses
        /// Define index and status associated with it
        /// Create status data structures and return array
        for (index, status) in RequestStatus.allValues.enumerated() {
            
            /// Checking if status is active
            let isActive = status == activeStatus
            
            /// Status title
            /// Safety check with count
            let statusTitle = RequestStatus.allDisplayStatuses.count > index ? RequestStatus.allDisplayStatuses[index].uppercased() : ""
            
            /// Status description
            /// Safety check with count
            var statusDescription = RequestStatus.allCopies.count > index ? RequestStatus.allCopies[index] : ""
            if statusDescription.contains("____") {
                let name = request.contact?.availableName ?? ""
                statusDescription = statusDescription.replacingOccurrences(of: "____", with: name)
            }
            
            /// Status color
            /// Safety check with count
            let statusColor = RequestStatus.allColors.count > index ? RequestStatus.allColors[index] : UIColor.black
            
            /// Title Color
            let titleColor = isActive ? statusColor : UIColor.TMContactsTextColor
            
            /// Creating status data objects
            let statusData = TMStatusData(status: status, title: generateTitle(statusTitle, titleColor), dateString: generateDate(requestDate), description: generateDescription(statusDescription), active: isActive, color: statusColor)
            resultArray.append(statusData)
        }
        
        return resultArray
    }
    
    /// Generate title for cell
    private func generateTitle(_ string: String, _ color: UIColor)-> NSAttributedString {
        
        var fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 14.0 : 12.0
        if DeviceType.IS_IPHONE_5 {
            fontSize = 10.0
        }
        
        let attributedString = NSAttributedString(string: "\(string)", attributes: [NSFontAttributeName: UIFont.MalloryMedium(fontSize), NSForegroundColorAttributeName: color, NSKernAttributeName: 1.2])
        
        return attributedString
    }
    
    /// Generate title date
    private func generateDate(_ date: Date)-> NSAttributedString {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "h:mma, MMMM d"

        dateFormat.amSymbol = "am"
        dateFormat.pmSymbol = "pm"
        
        var fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 14.0 : 12.0
        if DeviceType.IS_IPHONE_5 {
            fontSize = 10.0
        }
        
        // Date + suffix
        let attributedString = NSAttributedString(string: "\(dateFormat.string(from: date))\(date.daySuffix())", attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.greyishBrown, NSKernAttributeName: 1.2])
        
        return attributedString
    }
    
    /// Generate description
    private func generateDescription(_ string: String)-> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 7.0
        
        var fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 14.0 : 12.0
        if DeviceType.IS_IPHONE_5 {
            fontSize = 10.0
        }
        
        let attributedString = NSAttributedString(string: "\n\(string)", attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMGrayCell, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
}
