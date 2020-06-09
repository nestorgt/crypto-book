//
//  BinanceWSRouterTests.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceWSRouterTests: XCTestCase {
    
    func testDepth_BTCUSDT_Thousand() {
        let sut = BinanceWSRouter.url(for: MarketPairMock.btcusdt, streamName: .depth, updateSpeed: .thousand)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/btcusdt@depth@1000ms")
    }
    
    func testDepth_BNBUSDT_Hundred() {
        let sut = BinanceWSRouter.url(for: MarketPairMock.bnbusdt, streamName: .depth, updateSpeed: .hundred)
        
        XCTAssertEqual(sut.absoluteString, "wss://stream.binance.com:9443/ws/bnbusdt@depth@100ms")
    }
}
