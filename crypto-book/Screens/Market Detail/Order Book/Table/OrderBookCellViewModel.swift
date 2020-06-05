//
//  OrderBookCellViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct OrderBookCellViewModel: Hashable {
    let price: Double
    let pricePrecision: Int
    let amount: Double
    
    /// Represents the backfround progress view. Value between `0` and `1`.
    let progress: Double = .random(in: 0...1)
    
    // MARK: - Helpers
    
    var priceString: String {
        price
            .rounding(decimals: pricePrecision)
            .toString()
    }
    
    var amountString: String {
        amount
            .rounding(decimals: 1)
            .toString()
    }
}
