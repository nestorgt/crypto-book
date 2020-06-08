//
//  OrderBook+MergeTests.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class OrderBookMergeTests: XCTestCase {

    var sut: OrderBook!
    
    override func setUp() {
        super.setUp()
        sut = OrderBookMock.sample
    }
    
    func testIgnore_LowerId() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 990,
                                          finalUpdateId: 999,
                                          bids: [OrderBook.Offer(price: 5, amount: 0.1)],
                                          asks: [OrderBook.Offer(price: 6, amount: 0.1)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertEqual(orderBook, sut)
    }
    
    func testInsert_Bid_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 5.1, amount: 1)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5.1, amount: 1),
                                                   OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testInsert_Bid_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 3.5, amount: 2)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3.5, amount: 2),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testInsert_Bid_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 0.9, amount: 3)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50),
                                                   OrderBook.Offer(price: 0.9, amount: 3)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testRemove_Bid_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 5, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testRemove_Bid_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 3, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testRemove_Bid_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 1, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testReplace_Bid_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 5, amount: 0.1)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 0.1),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testReplace_Bid_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 3, amount: 0.2)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 0.2),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testReplace_Bid_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          bids: [OrderBook.Offer(price: 1, amount: 0.3)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 0.3)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }

    func testInsert_Ask_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 5.9, amount: 1)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 5.9, amount: 1),
                                                   OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testInsert_Ask_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 8.5, amount: 2)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 8.5, amount: 2),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testInsert_Ask_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 10.1, amount: 3)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100),
                                                   OrderBook.Offer(price: 10.1, amount: 3)]))
    }
    
    func testRemove_Ask_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 6, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testRemove_Ask_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 8, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testRemove_Ask_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 10, amount: 0)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80)]))
    }
    
    func testReplace_Ask_First() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 6, amount: 0.1)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 0.1),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testReplace_Ask_Mid() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 8, amount: 0.2)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 0.2),
                                                   OrderBook.Offer(price: 10, amount: 100)]))
    }
    
    func testReplace_Ask_Last() {
        let diff = OrderBookDiffMock.make(firstUpdateId: 1001,
                                          finalUpdateId: 1002,
                                          asks: [OrderBook.Offer(price: 10, amount: 0.3)])
        let orderBook = sut.merging(diffs: [diff])
        
        XCTAssertNotEqual(orderBook, sut)
        XCTAssertEqual(orderBook, OrderBook(lastUpdateId: 1002,
                                            bids: [OrderBook.Offer(price: 5, amount: 10),
                                                   OrderBook.Offer(price: 3, amount: 30),
                                                   OrderBook.Offer(price: 1, amount: 50)],
                                            asks: [OrderBook.Offer(price: 6, amount: 60),
                                                   OrderBook.Offer(price: 8, amount: 80),
                                                   OrderBook.Offer(price: 10, amount: 0.3)]))
    }
}
