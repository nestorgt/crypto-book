//
//  TradeTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class TradeTests: XCTestCase {

    func testDecoder() {
        let jsonString =
        """
        {
            "a": 310457166,
            "p": "9688.37000000",
            "q": "0.15000000",
            "f": 337848570,
            "l": 337848570,
            "T": 1591719325224,
            "m": true,
            "M": true
        }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(Trade.self, from: jsonData)
        
        XCTAssertEqual(sut.id, 310457166)
        XCTAssertEqual(sut.price, 9688.37000000)
        XCTAssertEqual(sut.amount, 0.15000000)
        XCTAssertEqual(sut.firstTradeId, 337848570)
        XCTAssertEqual(sut.lastTradeId, 337848570)
        XCTAssertEqual(sut.timestamp, 1591719325224)
        XCTAssertEqual(sut.isBuyerMaker, true)
        XCTAssertEqual(sut.isBestPriceMatch, true)
    }
}
