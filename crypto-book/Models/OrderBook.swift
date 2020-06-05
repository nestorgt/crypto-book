//
//  OrderBook.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

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
struct OrderBook: CustomStringConvertible {
    let lastUpdateId: TimeInterval
    let bids: [Offer]
    let asks: [Offer]
    
    struct Offer: CustomStringConvertible {
        let price: Double
        let amount: Double
        
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
