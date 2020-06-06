//
//  OrderBook.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Order book model from API
struct OrderBook: CustomStringConvertible {
    let lastUpdateId: TimeInterval
    let bids: [Offer]
    let asks: [Offer]
    
    // MARK: - Decodable
    
    /*
    {
        "lastUpdateId": 4405135474,
        "bids": [
            [
                "9728.18000000",
                "0.12808100"
            ],
            [
                "9728.17000000",
                "0.04472000"
            ]
        ],
        "asks": [
            [
                "9728.99000000",
                "0.25704700"
            ],
            [
                "9729.07000000",
                "2.02563600"
            ]
        ]
    }
    */
    
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
    
    var description: String {
        """
        \n- lastUpdateId: \(lastUpdateId)
        - bids: \(bids)
        - tasks: \(asks)
        """
    }
}
