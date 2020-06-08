//
//  OrderBookDiffTests.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class OrderBookDiffTests: XCTestCase {
    
    func testDecoder() {
        let jsonString =
        """
        {
          "e": "depthUpdate",
          "E": 123456789,
          "s": "BNBBTC",
          "U": 157,
          "u": 160,
          "b": [
            [
              "0.0024",
              "10"
            ],
            [
              "0.0023",
              "9.9"
            ],
          ],
          "a": [
            [
              "0.0026",
              "100"
            ],
            [
              "0.0027",
              "33.3"
            ]
          ]
        }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(OrderBook.Diff.self, from: jsonData)
        
        XCTAssertEqual(sut.eventType, .depthUpdate)
        XCTAssertEqual(sut.eventTimeInterval, 123456789)
        XCTAssertEqual(sut.symbol, "BNBBTC")
        XCTAssertEqual(sut.firstUpdateId, 157)
        XCTAssertEqual(sut.finalUpdateId, 160)
        XCTAssertEqual(sut.bids,
                       [OrderBook.Offer(price: 0.0024, amount: 10),
                        OrderBook.Offer(price: 0.0023, amount: 9.9)])
        XCTAssertEqual(sut.asks,
                       [OrderBook.Offer(price: 0.0026, amount: 100),
                       OrderBook.Offer(price: 0.0027, amount: 33.3)])
    }
}
