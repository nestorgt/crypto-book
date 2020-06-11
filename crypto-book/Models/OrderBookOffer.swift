//
//  OrderBookOffer.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension OrderBook {
    
    /// A price an amount of an offer in the order book.
    struct Offer: Equatable, CustomStringConvertible {
        let price: Double
        let amount: Double
        
        static func make(from array: [[String]]) -> [Offer] {
            array.compactMap { pair in
                guard let priceString = pair[safe: 0], let amountString = pair[safe: 1],
                    let price = Double(priceString), let amount = Double(amountString) else {
                        return nil
                }
                return Offer(price: price, amount: amount)
            }
        }
        
        func roundingPrice(to decimals: Int) -> Offer {
            Offer(price: price.rounding(decimals: decimals), amount: amount)
        }
        
        var description: String {
            "(price: \(price), amount: \(amount))"
        }
    }
}

extension Array where Element == OrderBook.Offer {

    /// Merges the same prices  on asks and bids offers.
    func mergingSamePrices() -> [OrderBook.Offer] {
        var offers = [OrderBook.Offer]()
        var amountSum: Double?
        var currentPrice: Double?
        for item in self {
            if item.price == currentPrice {
                amountSum = amountSum ?? 0 + item.amount
            } else {
                if let amountSum = amountSum, let currentPrice = currentPrice {
                    offers.append(OrderBook.Offer(price: currentPrice, amount: amountSum))
                }
                currentPrice = item.price
                amountSum = item.amount
            }
        }
        return offers
    }
}
