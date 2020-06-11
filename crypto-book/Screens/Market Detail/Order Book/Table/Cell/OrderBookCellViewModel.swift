//
//  OrderBookCellViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct OrderBookCellViewModel {
    
    let price: Double
    let pricePrecision: Precision?
    let amount: Double
    
    /// Represents the backfround progress view. Value between `0` and `1`.
    let progress: Double
    
    // MARK: - Helpers
    
    var priceString: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = pricePrecision?.max ?? 8
        formatter.minimumFractionDigits = pricePrecision?.min ?? 0
        formatter.numberStyle = .decimal
        return formatter.string(for: price) ?? ""
    }
    
    var amountString: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = amount.maxNumberOfDecimals
        formatter.numberStyle = .decimal
        return formatter.string(for: amount) ?? ""
    }
}
