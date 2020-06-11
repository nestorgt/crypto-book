//
//  MarketHistoryCellViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

struct MarketHistoryCellViewModel {
    
    let id: UInt64
    let timestamp: TimeInterval
    let price: Double
    let amount: Double
    let isBuyerMaker: Bool
    let precision: Precision?
    
    // MARK: - Helpers
    
    var timeString: String {
        Date.hoursMinutesSeconds(from: timestamp/1000)
    }
    
    var priceString: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = precision?.max ?? 8
        formatter.minimumFractionDigits = precision?.min ?? 0
        formatter.numberStyle = .decimal
        return formatter.string(for: price) ?? "\(price)"
    }
    
    var amountString: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = amount.maxNumberOfDecimals
        formatter.numberStyle = .decimal
        return formatter.string(for: amount) ?? ""
    }
    
    var priceTextColor: UIColor {
        isBuyerMaker ? .binanceAsk : .binanceBid
    }
}
