//
//  DoubleTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class DoubleTests: XCTestCase {

    func testRounding() {
        let a = 1.123456789
        
        XCTAssertEqual(a.rounding(decimals: 1), 1.1)
        XCTAssertEqual(a.rounding(decimals: 2), 1.12)
        XCTAssertEqual(a.rounding(decimals: 3), 1.123)
        XCTAssertEqual(a.rounding(decimals: 4), 1.1235)
        XCTAssertEqual(a.rounding(decimals: 5), 1.12346)
        XCTAssertEqual(a.rounding(decimals: 6), 1.123457)
        XCTAssertEqual(a.rounding(decimals: 7), 1.1234568)
        XCTAssertEqual(a.rounding(decimals: 8), 1.12345679)
        XCTAssertEqual(a.rounding(decimals: 9), 1.123456789)
    }
    
    func testToString() {
        let a = 1.123456789
        
        XCTAssertEqual(a.toString(), "1.123456789")
    }
}
