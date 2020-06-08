//
//  OrderBookTests.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class OrderBookTests: XCTestCase {

    func testDecoder() {
        let jsonString =
        """
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
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(OrderBook.self, from: jsonData)
        
        XCTAssertEqual(sut.lastUpdateId, 4405135474)
        XCTAssertEqual(sut.bids,
                       [OrderBook.Offer(price: 9728.18000000, amount: 0.12808100),
                        OrderBook.Offer(price: 9728.17000000, amount: 0.04472000)])
        XCTAssertEqual(sut.asks,
                       [OrderBook.Offer(price: 9728.99000000, amount: 0.25704700),
                       OrderBook.Offer(price: 9729.07000000, amount: 2.02563600)])
    }
}
