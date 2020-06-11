//
//  Double+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 11/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension Double {
    
    /// Rounds the double to the number of decimals.
    func rounding(decimals: Int) -> Double {
        let divisor = pow(10.0, Double(decimals))
        return (self * divisor).rounded() / divisor
    }
    
    /// Returns the Double in form of String.
    func toString() -> String {
        "\(self)"
    }
     
    /// Returns the number of decimals to the right of the `.`, excluding 0's
    var maxNumberOfDecimals: Int {
        let components = NumberFormatter.binance
            .string(for: self)?
            .components(separatedBy: ".")
        guard components?.count == 2, let digits = components?.last else { return 0 }
        var count = digits.count
        var isExcludingZeros = true
        digits.reversed().forEach { digit in
            if digit == "0" && isExcludingZeros {
                count -= 1
            } else {
                isExcludingZeros = false
            }
        }
        return count
    }
    
    /// Returns the number of `0` after the `.` if the number is `< 0`.
    var zerosAfterDot: Int {
        if self >= 1.0 { return 0 }
        if self == 0.00000000 { return 0 }
        let components = NumberFormatter.binance
            .string(for: self)?
            .components(separatedBy: ".")
        guard components?.count == 2, let digits = components?.last else { return 0 }
        var count = 0
        for digit in digits {
            if digit == "0" {
                count += 1
            } else {
                return count
            }
        }
        return count
    }
}
