//
//  BinanceWSRouterTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceWSRouterTests: XCTestCase {
    
    func testDepth_BTCUSDT_Thousand() {
        let sut = BinanceWSRouter.depth(for: MarketPairMock.btcusdt, updateSpeed: .thousand)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/btcusdt@depth@1000ms")
    }
    
    func testDepth_BNBUSDT_Hundred() {
        let sut = BinanceWSRouter.depth(for: MarketPairMock.bnbusdt, updateSpeed: .hundred)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/bnbusdt@depth@100ms")
    }
    
    func testCompressedTrade_BTCUSDT() {
        let sut = BinanceWSRouter.compressedTrades(for: MarketPairMock.btcusdt)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/btcusdt@aggTrade")
    }
    
    func testCompressedTrade_BNBUSDT() {
        let sut = BinanceWSRouter.compressedTrades(for: MarketPairMock.bnbusdt)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/bnbusdt@aggTrade")
    }
}
