//
//  WebSocketModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

protocol WSEventProtocol {
    var event: WSEvent { get }
}

struct WSEvent: Equatable {
    let type: BinanceWSEventType
    let timeInterval: TimeInterval
    let symbol: String
}

// MARK: - Decodable

extension WSEvent: Decodable {
    
    /*
     {
       "e": "aggTrade",  // Event type
       "E": 123456789,   // Event time
       "s": "BNBBTC",    // Symbol
     }
    */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        type = try keyedContainer.decode(BinanceWSEventType.self, forKey: .type)
        timeInterval = try keyedContainer.decode(TimeInterval.self, forKey: .timeInterval)
        symbol = try keyedContainer.decode(String.self, forKey: .symbol)
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "e"
        case timeInterval = "E"
        case symbol = "s"
    }
}
