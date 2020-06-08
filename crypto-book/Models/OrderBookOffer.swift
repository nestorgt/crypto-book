//
//  OrderBookOffer.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension OrderBook {
    
    struct Offer: Equatable, CustomStringConvertible {
        let price: Double
        let amount: Double
        
        static func make(from array: [[String]]) -> [OrderBook.Offer] {
            array.compactMap { pair in
                guard let priceString = pair[safe: 0], let amountString = pair[safe: 1],
                    let price = Double(priceString), let amount = Double(amountString) else {
                        return nil
                }
                return OrderBook.Offer(price: price, amount: amount)
            }
        }
        
        var description: String {
            "(price: \(price), amount: \(amount))"
        }
    }
}
