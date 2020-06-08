//
//  ArrayTests.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class ArrayTests: XCTestCase {

    func testSafeIndex() {
        let a = ["a","b","c"]
        
        XCTAssertEqual(a[safe: 0], "a")
        XCTAssertEqual(a[safe: 1], "b")
        XCTAssertEqual(a[safe: 2], "c")
        
        XCTAssertNil(a[safe: -1])
        XCTAssertNil(a[safe: 10])
        XCTAssertNil(a[safe: 100])
    }
}
