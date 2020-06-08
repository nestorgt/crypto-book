//
//  BinanceWebSocket.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct BinanceWSRouter {
    
    enum StreamName: String {
        case depth
    }
    
    static let base = "wss://stream.binance.com:9443/ws/"
    
    static func depth(for marketPair: MarketPair) -> URL {
        buildURL(for: marketPair, streamName: .depth)
    }
    
    static func buildURL(for marketPair: MarketPair, streamName: StreamName) -> URL {
        guard let url = URL(string: base + marketPair.webScoketSymbol + "@" + streamName.rawValue) else {
            fatalError("Can't build URL for \(marketPair) & \(streamName)")
        }
        return url
    }
}
