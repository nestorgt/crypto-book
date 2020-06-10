//
//  BinanceAPIRouterTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceAPIRouterTests: XCTestCase {
    
    func testDepthSnapshot_BTCUSDT_500() {
        let sut = BinanceAPIRouter.depthSnapshot(marketPair: MarketPairMock.btcusdt, limit: 500)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut?.url)
        XCTAssertEqual(sut!.url!.absoluteString, "https://api.binance.com/api/v3/depth?symbol=BTCUSDT&limit=500")
    }
    
    func testDepthSnapshot_BNBUSDT_1000() {
        let sut = BinanceAPIRouter.depthSnapshot(marketPair: MarketPairMock.bnbusdt, limit: 1000)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut?.url)
        XCTAssertEqual(sut!.url!.absoluteString, "https://api.binance.com/api/v3/depth?symbol=BNBUSDT&limit=1000")
    }
    
    func testRecentTrades_BTCUSDT_500() {
        let sut = BinanceAPIRouter.depthSnapshot(marketPair: MarketPairMock.btcusdt, limit: 500)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut?.url)
        XCTAssertEqual(sut!.url!.absoluteString, "https://api.binance.com/api/v3/depth?symbol=BTCUSDT&limit=500")
    }
    
    func testRecentTrades_BNBUSDT_1000() {
        let sut = BinanceAPIRouter.depthSnapshot(marketPair: MarketPairMock.bnbusdt, limit: 1000)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut?.url)
        XCTAssertEqual(sut!.url!.absoluteString, "https://api.binance.com/api/v3/depth?symbol=BNBUSDT&limit=1000")
    }
}
