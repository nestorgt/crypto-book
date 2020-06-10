//
//  WSTrade.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Trade history item model from WebSocket..
struct WSTrade: WSEventProtocol, Equatable {
    
    let event: WSEvent
    let trade: Trade
}

// MARK: - Decodable

extension WSTrade: Decodable {
    
    /*
     {
       "e": "aggTrade",  // Event type
       "E": 123456789,   // Event time
       "s": "BNBBTC",    // Symbol
       "a": 12345,       // Aggregate trade ID
       "p": "0.001",     // Price
       "q": "100",       // Quantity
       "f": 100,         // First trade ID
       "l": 105,         // Last trade ID
       "T": 123456785,   // Trade time
       "m": true,        // Is the buyer the market maker?
       "M": true         // Ignore
     }
    */
    
    public init(from decoder: Decoder) throws {
        event = try decoder.singleValueContainer().decode(WSEvent.self)
        trade = try decoder.singleValueContainer().decode(Trade.self)
    }
}
