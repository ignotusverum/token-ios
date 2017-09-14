//
//  TMDate.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/13/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

extension Date {
    
    func daySuffix() -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
