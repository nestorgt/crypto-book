//
//  OrderBook.Diff.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension OrderBook {
 
    /// Order book depth diff from WebSocket
    struct Diff: CustomStringConvertible {
        let eventType: BinanceWSEventType
        let eventTimeInterval: TimeInterval
        let symbol: String
        let firstUpdateId: UInt64
        let lastUpdateId: UInt64
        let bids: [OrderBook.Offer]
        let asks: [OrderBook.Offer]
        
        var description: String {
            """
            \n- \(firstUpdateId) -> \(lastUpdateId)
            - bids: \(bids)
            - tasks: \(asks)
            """
        }
    }
}
    
extension OrderBook.Diff: Decodable {
        
    // MARK: - Decodable
    
    /*
    {
      "e": "depthUpdate", // Event type
      "E": 123456789,     // Event time
      "s": "BNBBTC",      // Symbol
      "U": 157,           // First update ID in event
      "u": 160,           // Final update ID in event
      "b": [              // Bids to be updated
        [
          "0.0024",       // Price level to be updated
          "10"            // Quantity
        ]
      ],
      "a": [              // Asks to be updated
        [
          "0.0026",       // Price level to be updated
          "100"           // Quantity
        ]
      ]
    }
    */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try keyedContainer.decode(BinanceWSEventType.self, forKey: .eventType)
        eventTimeInterval = try keyedContainer.decode(TimeInterval.self, forKey: .eventTimeInterval)
        symbol = try keyedContainer.decode(String.self, forKey: .symbol)
        firstUpdateId = try keyedContainer.decode(UInt64.self, forKey: .firstUpdateId)
        lastUpdateId = try keyedContainer.decode(UInt64.self, forKey: .lastUpdateId)
        let bidsArray = try keyedContainer.decode([[String]].self, forKey: .bids)
        bids = OrderBook.Offer.make(from: bidsArray)
        let asksArray = try keyedContainer.decode([[String]].self, forKey: .asks)
        asks = OrderBook.Offer.make(from: asksArray)
    }
    
    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTimeInterval = "E"
        case symbol = "s"
        case firstUpdateId = "U"
        case lastUpdateId = "u"
        case bids = "b"
        case asks = "a"
    }
}
