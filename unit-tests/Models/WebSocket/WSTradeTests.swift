//
//  WSTradeTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class WSTradeTests: XCTestCase {

    func testDecoder() {
        let jsonString =
        """
        {
            "e": "aggTrade",
            "E": 123456789,
            "s": "BNBBTC",
            "a": 12345,
            "p": "0.001",
            "q": "100",
            "f": 100,
            "l": 105,
            "T": 123456785,
            "m": true,
            "M": true
        }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(WSTrade.self, from: jsonData)
        
        XCTAssertEqual(sut.event.type, .aggTrade)
        XCTAssertEqual(sut.event.timeInterval, 123456789)
        XCTAssertEqual(sut.event.symbol, "BNBBTC")
        XCTAssertEqual(sut.trade.id, 12345)
        XCTAssertEqual(sut.trade.price, 0.001)
        XCTAssertEqual(sut.trade.amount, 100)
        XCTAssertEqual(sut.trade.firstTradeId, 100)
        XCTAssertEqual(sut.trade.lastTradeId, 105)
        XCTAssertEqual(sut.trade.timestamp, 123456785)
        XCTAssertEqual(sut.trade.isBuyerMaker, true)
        XCTAssertEqual(sut.trade.isBestPriceMatch, true)
    }
}
