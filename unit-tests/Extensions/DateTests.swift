//
//  DateTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

class DateTests: XCTestCase {

    func testStringDate_OK() {
        XCTAssertNotNil(Date.date(from: "2020-01-01", withFormat: "yyyy-MM-dd"))
        XCTAssertNotNil(Date.date(from: "01-01-2020", withFormat: "dd-MM-yyyy"))
    }
    
    func testStringDate_Nil() {
        XCTAssertNil(Date.date(from: "", withFormat: "yyyy-MM-dd"))
        XCTAssertNil(Date.date(from: "not a date", withFormat: "yyyy-MM-dd"))
        XCTAssertNil(Date.date(from: "01-01-2020", withFormat: "yyyy-MM-dd"))
    }
    
    func testHoursMinutesSecondsDate() {
        XCTAssertNotNil(Date.hoursMinutesSeconds(from: Date().timeIntervalSinceNow))
    }
}
