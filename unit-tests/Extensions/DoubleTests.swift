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
        
        XCTAssertEqual(a.rounding(decimals: 0), 1)
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
    
    func testmaxNumberOfDecimals() {
        XCTAssertEqual(Double(1).maxNumberOfDecimals, 0)
        XCTAssertEqual(1.1.maxNumberOfDecimals, 1)
        XCTAssertEqual(1.12.maxNumberOfDecimals, 2)
        XCTAssertEqual(1.123.maxNumberOfDecimals, 3)
        XCTAssertEqual(1.1234.maxNumberOfDecimals, 4)
        XCTAssertEqual(1.12345.maxNumberOfDecimals, 5)
        XCTAssertEqual(1.123456.maxNumberOfDecimals, 6)
        XCTAssertEqual(1.1234567.maxNumberOfDecimals, 7)
        XCTAssertEqual(1.12345678.maxNumberOfDecimals, 8)
        XCTAssertEqual(1.0.maxNumberOfDecimals, 0)
        XCTAssertEqual(1.02.maxNumberOfDecimals, 2)
        XCTAssertEqual(1.003.maxNumberOfDecimals, 3)
        XCTAssertEqual(1.0004.maxNumberOfDecimals, 4)
        XCTAssertEqual(1.00005.maxNumberOfDecimals, 5)
        XCTAssertEqual(1.000006.maxNumberOfDecimals, 6)
        XCTAssertEqual(1.0000007.maxNumberOfDecimals, 7)
        XCTAssertEqual(1.00000008.maxNumberOfDecimals, 8)
    }
    
    func testZerosAfterDot() {
        XCTAssertEqual(Double(1).zerosAfterDot, 0)
        XCTAssertEqual((1.1).zerosAfterDot, 0)
        XCTAssertEqual((1.12).zerosAfterDot, 0)
        XCTAssertEqual((1.123).zerosAfterDot, 0)
        XCTAssertEqual((1.1234).zerosAfterDot, 0)
        XCTAssertEqual((1.12345).zerosAfterDot, 0)
        XCTAssertEqual((1.123456).zerosAfterDot, 0)
        XCTAssertEqual((1.1234567).zerosAfterDot, 0)
        XCTAssertEqual((1.12345678).zerosAfterDot, 0)
        XCTAssertEqual((1.123456789).zerosAfterDot, 0)
        XCTAssertEqual((1.0).zerosAfterDot, 0)
        XCTAssertEqual((1.02).zerosAfterDot, 0)
        XCTAssertEqual((1.003).zerosAfterDot, 0)
        XCTAssertEqual((1.0004).zerosAfterDot, 0)
        XCTAssertEqual((1.00005).zerosAfterDot, 0)
        XCTAssertEqual((1.000006).zerosAfterDot, 0)
        XCTAssertEqual((1.0000007).zerosAfterDot, 0)
        XCTAssertEqual((1.00000008).zerosAfterDot, 0)
        XCTAssertEqual((1.000000009).zerosAfterDot, 0)
        XCTAssertEqual((0.0).zerosAfterDot, 0)
        XCTAssertEqual((0.02).zerosAfterDot, 1)
        XCTAssertEqual((0.003).zerosAfterDot, 2)
        XCTAssertEqual((0.0004).zerosAfterDot, 3)
        XCTAssertEqual((0.00005).zerosAfterDot, 4)
        XCTAssertEqual((0.000006).zerosAfterDot, 5)
        XCTAssertEqual((0.0000007).zerosAfterDot, 6)
        XCTAssertEqual((0.00000008).zerosAfterDot, 7)
    }
}
