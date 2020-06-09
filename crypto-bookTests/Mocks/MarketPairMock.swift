//
//  MarketPairMock.swift
//  crypto-bookTests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
@testable import crypto_book

struct MarketPairMock {
    
    static var btcusdt: MarketPair {
        MarketPair(from: "btc", to: "usdt")
    }
    
    static var bnbusdt: MarketPair {
        MarketPair(from: "bnb", to: "usdt")
    }
}
