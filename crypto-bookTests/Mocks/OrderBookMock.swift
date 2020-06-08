//
//  OrderBookMock.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
@testable import crypto_book

struct OrderBookMock {
    
    static var sample: OrderBook {
        OrderBook(lastUpdateId: 1000,
                  bids: [OrderBook.Offer(price: 5, amount: 10),
                         OrderBook.Offer(price: 3, amount: 30),
                         OrderBook.Offer(price: 1, amount: 50)],
                  asks: [OrderBook.Offer(price: 6, amount: 60),
                         OrderBook.Offer(price: 8, amount: 80),
                         OrderBook.Offer(price: 10, amount: 100)])
    }
    
    static var sampleBig: OrderBook {
        OrderBook(lastUpdateId: 1000,
                  bids: [OrderBook.Offer(price: 5, amount: 10),
                         OrderBook.Offer(price: 4, amount: 20),
                         OrderBook.Offer(price: 3, amount: 30),
                         OrderBook.Offer(price: 2, amount: 40),
                         OrderBook.Offer(price: 1, amount: 50)],
                  asks: [OrderBook.Offer(price: 6, amount: 60),
                         OrderBook.Offer(price: 7, amount: 70),
                         OrderBook.Offer(price: 8, amount: 80),
                         OrderBook.Offer(price: 9, amount: 90),
                         OrderBook.Offer(price: 10, amount: 100)])
    }
}

struct OrderBookDiffMock {
    
    static func make(firstUpdateId: UInt64,
                     finalUpdateId: UInt64,
                     bids: [OrderBook.Offer] = [],
                     asks: [OrderBook.Offer] = []) -> OrderBook.Diff {
        OrderBook.Diff(eventType: .depthUpdate,
                      eventTimeInterval: Date().timeIntervalSince1970,
                      symbol: "BTCUSDT",
                      firstUpdateId: firstUpdateId,
                      finalUpdateId: finalUpdateId,
                      bids: bids,
                      asks: asks)
    }
}
