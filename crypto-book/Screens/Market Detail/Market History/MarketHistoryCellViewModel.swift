//
//  MarketHistoryCellViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

struct MarketHistoryCellViewModel: Hashable {
    
    let timestamp: TimeInterval
    let price: Double
    let amount: Double
    let isBuyerMaker: Bool
    let precision: Int
    
    // MARK: - Helpers
    
    var timeString: String {
        Date.hoursMinutesSeconds(from: timestamp)
    }
    
    var priceString: String {
        price
            .rounding(decimals: precision)
            .toString()
    }
    
    var amountString: String {
        amount
            .toString()
    }
    
    var priceTextColor: UIColor {
        isBuyerMaker ? .binanceBid : .binanceAsk
    }
}
