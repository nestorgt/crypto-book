//
//  Double+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
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
}
