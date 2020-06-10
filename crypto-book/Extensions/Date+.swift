//
//  Date+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension Date {
    
    static func hoursMinutesSeconds(from timeIntervalSince1970: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeIntervalSince1970)
        return date.string(format: "HH:mm:ss")
    }
    
    func string(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func date(from dateString: String, withFormat format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = formatter.date(from: dateString)
        return date
    }
}
