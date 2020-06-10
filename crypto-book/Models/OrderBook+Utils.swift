//
//  OrderBook+Merge.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension OrderBook {
    
    /*
    How to manage a local order book correctly
    1- Open a stream to wss://stream.binance.com:9443/ws/bnbbtc@depth.
    2- Buffer the events you receive from the stream.
    3- Get a depth snapshot from https://www.binance.com/api/v3/depth?symbol=BNBBTC&limit=1000 .
    4- Drop any event where u is <= lastUpdateId in the snapshot.
    5- The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1.
    6- While listening to the stream, each new event's U should be equal to the previous event's u+1.
    7- The data in each event is the absolute quantity for a price level.
    8- If the quantity is 0, remove the price level.
    9- Receiving an event that removes a price level that is not in your local order book can happen and is normal.
    */
    func merging(diffs: [OrderBook.Diff]) -> OrderBook {
//        Log.message("Merging diffs: \(diffs)", level: .debug, type: .orderBook)
        // Ignore any old update Id
        let validDiffs = diffs.filter { $0.lastUpdateId > lastUpdateId }
        
        // Merge with current order book
        guard !validDiffs.isEmpty, let lastUpdateId = validDiffs.last?.lastUpdateId
            else { Log.message("Nothing to merge", level: .debug, type: .orderBook); return self }
        
        var orderBook = self
        var orderBookAsks = orderBook.asks
        var orderBookBids = orderBook.bids
        for diff in validDiffs {
            for offer in diff.bids {
                let index: Int? = orderBookBids.firstIndex(where: { $0.price == offer.price })
                if let index = index {
                    // Index exist -> update item
                    if offer.amount == 0.0 {
                        orderBookBids.remove(at: index)
                    } else {
                        orderBookBids[index] = offer
                    }
                } else {
                    // Index does not exist -> add to the array
                    if offer.amount > 0.0 {
                        let index: Int? = orderBookBids.firstIndex(where: { $0.price < offer.price })
                        orderBookBids.insert(offer, at: index ?? orderBookBids.count)
                    }
                }
            }
            for offer in diff.asks {
                let index: Int? = orderBookAsks.firstIndex(where: { $0.price == offer.price })
                if let index = index {
                    // Index exist -> update item
                    if offer.amount == 0.0 {
                        orderBookAsks.remove(at: index)
                    } else {
                        orderBookAsks[index] = offer
                    }
                } else {
                    // Index does not exist -> add to the array
                    if offer.amount > 0.0 {
                        let index: Int? = orderBookAsks.firstIndex(where: { $0.price > offer.price })
                        orderBookAsks.insert(offer, at: index ?? orderBookAsks.count)
                    }
                }
            }
        }
        orderBook.bids = orderBookBids
        orderBook.asks = orderBookAsks
        orderBook.lastUpdateId = lastUpdateId
        Log.message("Merged! bids (\(bids.count) -> \(orderBook.bids.count)), asks (\(asks.count) -> \(orderBook.asks.count))",
            level: .debug, type: .orderBook)
        return orderBook
    }
    
    /// Returns a copy of the order book filtering all bids & asks that have a 0 amount.
    var filteringZeroAmounts: OrderBook {
        var orderBook = self
        orderBook.bids = bids.filter { $0.amount > 0.0 }
        orderBook.asks = asks.filter { $0.amount > 0.0 }
        return orderBook
    }
    
    struct MaxMinData: Equatable {
        let minBidAmount: Double
        let maxBidAmmount: Double
        let minAskAmount: Double
        let maxAskAmmount: Double
    }
    
    /// Represents the max and min bid & ask offer amounts.
    func maxMinData(prefixElements: Int) -> MaxMinData {
        var minBidAmount = Double.greatestFiniteMagnitude
        var maxBidAmmount = Double.zero
        for bid in bids.prefix(prefixElements) {
            if bid.amount < minBidAmount {
                minBidAmount = bid.amount
            }
            if bid.amount > maxBidAmmount {
                maxBidAmmount = bid.amount
            }
        }
        var minAskAmount = Double.greatestFiniteMagnitude
        var maxAskAmmount = Double.zero
        for ask in asks.prefix(prefixElements) {
            if ask.amount < minAskAmount {
                minAskAmount = ask.amount
            }
            if ask.amount > maxAskAmmount {
                maxAskAmmount = ask.amount
            }
        }
        return MaxMinData(minBidAmount: minBidAmount,
                         maxBidAmmount: maxBidAmmount,
                         minAskAmount: minAskAmount,
                         maxAskAmmount: maxAskAmmount)
    }

    /// Value between `0...1` representing the weight in the bid book for that order.
    static func bidWeight(for amount: Double, with maxMinData: MaxMinData) -> Double {
        scale(amount: amount, min: maxMinData.minBidAmount, max: maxMinData.maxBidAmmount)
    }
    
    /// Value between `0...1` representing the weight in the bid book for that order.
    static func askWeight(for amount: Double, with maxMinData: MaxMinData) -> Double {
        scale(amount: amount, min: maxMinData.minAskAmount, max: maxMinData.maxAskAmmount)
    }
    
    private static func scale(amount: Double, min: Double, max: Double) -> Double {
        let value = (amount - min) * 100 / (max - min) / 100
        return .maximum(0.0, .minimum(1.0, value))
    }
}
