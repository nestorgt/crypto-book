//
//  BinanceWebSocket.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct BinanceWSRouter {
    
    static let base = "wss://stream.binance.com:9443/ws/"
    
    static func depth(for marketPair: MarketPair, updateSpeed: UpdateSpeed) -> URL {
        url(for: marketPair, streamName: .depth, updateSpeed: updateSpeed)
    }
    
    static func url(for marketPair: MarketPair, streamName: StreamName, updateSpeed: UpdateSpeed) -> URL {
        let urlString = base
            + marketPairComponent(for: marketPair)
            + streamNameComponent(for: streamName)
            + updateSpeedComponent(for: updateSpeed)
        guard let url = URL(string: urlString) else {
            fatalError("Can't build URL for \(marketPair) & \(streamName)")
        }
        return url
    }
}

// MARK: - Enums

extension BinanceWSRouter {
    
    enum StreamName: String {
        case depth
    }
    
    enum UpdateSpeed: String {
        case hundred = "100ms"
        case thousand = "1000ms"
    }
}

// MARK: - Private

private extension BinanceWSRouter {
    
    static func marketPairComponent(for marketPair: MarketPair) -> String {
        marketPair.webScoketSymbol
    }
    
    static func streamNameComponent(for streamName: StreamName) -> String {
        adatp(component: streamName.rawValue)
    }
    
    static func updateSpeedComponent(for updateSpeed: UpdateSpeed) -> String {
        adatp(component: updateSpeed.rawValue)
    }
    
    static func adatp(component: String) -> String {
        "@" + component
    }
}
