//
//  OrderBook+UtilsTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class OrderBookUtilsTests: XCTestCase {
    
    var sut: OrderBook!
    
    override func setUp() {
        super.setUp()
        sut = OrderBookMock.sample
    }
    
    func testPrefixingOffers() {
        let prefixed = sut.prefixingOffers(1)
        
        XCTAssertEqual(prefixed.asks.count, 1)
        XCTAssertEqual(prefixed.bids.count, 1)
    }
    
    func testPrefixingOffers_OutOfBounds() {
        let prefixed = sut.prefixingOffers(100)
        
        XCTAssertEqual(prefixed.asks.count, 3)
        XCTAssertEqual(prefixed.bids.count, 3)
    }
    
    func testMaxMin_Prefix3() {
        let maxMinData = sut.maxMinData(prefixElements: 3)
        
        XCTAssertEqual(maxMinData, OrderBook.MaxMinData(minBidAmount: 10,
                                                        maxBidAmmount: 50,
                                                        minAskAmount: 60,
                                                        maxAskAmmount: 100))
    }
    
    func testMaxMin_Prefix2() {
        let maxMinData = sut.maxMinData(prefixElements: 2)
        
        XCTAssertEqual(maxMinData, OrderBook.MaxMinData(minBidAmount: 10,
                                                        maxBidAmmount: 30,
                                                        minAskAmount: 60,
                                                        maxAskAmmount: 80))
    }
    
    func testMaxMin_Prefix1() {
        let maxMinData = sut.maxMinData(prefixElements: 1)
        
        XCTAssertEqual(maxMinData, OrderBook.MaxMinData(minBidAmount: 10,
                                                        maxBidAmmount: 10,
                                                        minAskAmount: 60,
                                                        maxAskAmmount: 60))
    }
    
    func testBidWeidht_ValidAmounts() {
        let maxMinData = sut.maxMinData(prefixElements: 3)

        XCTAssertEqual(OrderBook.bidWeight(for: 50, with: maxMinData), 1.0)
        XCTAssertEqual(OrderBook.bidWeight(for: 30, with: maxMinData), 0.5)
        XCTAssertEqual(OrderBook.bidWeight(for: 10, with: maxMinData), 0.0)
    }
    
    func testBidWeidht_OutOfRangeAmounts() {
        let maxMinData = sut.maxMinData(prefixElements: 3)
        
        XCTAssertEqual(OrderBook.bidWeight(for: 0, with: maxMinData), 0.0)
        XCTAssertEqual(OrderBook.bidWeight(for: 1000, with: maxMinData), 1.0)
    }
}
