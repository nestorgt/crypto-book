//
//  WSEventTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class WSEventTests: XCTestCase {

    func testDecoder() {
        let jsonString =
        """
        {
            "e": "aggTrade",
            "E": 123456789,
            "s": "BNBBTC",
        }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(WSEvent.self, from: jsonData)
        
        XCTAssertEqual(sut.type, .aggTrade)
        XCTAssertEqual(sut.timeInterval, 123456789)
        XCTAssertEqual(sut.symbol, "BNBBTC")
    }
}
