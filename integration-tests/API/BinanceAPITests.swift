//
//  BinanceAPITests.swift
//  integration-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceAPITests: XCTestCase {

    var binanceAPIService: BinanceAPIServiceProtocol!
    
    override func setUp() {
        super.setUp()
        binanceAPIService = BinanceAPIService(apiService: APIService())
    }
    
    // MARK: - Tests

    func testAggTradesSuccess_USDNZD_10() {
        let marketPair = MarketPairMock.btcusdt
        var result: Result<[Trade], BinanceAPIError>!
        let expectation = XCTestExpectation(description: "Performs a request")
        binanceAPIService
            .aggTrades(marketPair: marketPair, limit: 10, completion: { r in
                result = r
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertEqual(result.value?.count, 10)
    }
    
    func testConvertSuccess_USDNZD_10() {
        let marketPair = MarketPairMock.btcusdt
        var result: Result<OrderBook, BinanceAPIError>!
        let expectation = XCTestExpectation(description: "Performs a request")
        binanceAPIService
            .depthSnapshot(marketPair: marketPair, completion: { r in
                result = r
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
    }
}
