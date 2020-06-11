//
//  NumberFormatter+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 11/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    static var binance: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter
    }
}
