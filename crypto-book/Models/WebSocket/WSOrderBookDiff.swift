//
//  OrderBook.Diff.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Trade history item model from WebSocket..
struct WSOrderBookDiff: WSEventProtocol, Equatable, CustomStringConvertible {
    
    let event: WSEvent
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
    
extension WSOrderBookDiff: Decodable {
        
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
        event = try decoder.singleValueContainer().decode(WSEvent.self)
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        firstUpdateId = try keyedContainer.decode(UInt64.self, forKey: .firstUpdateId)
        lastUpdateId = try keyedContainer.decode(UInt64.self, forKey: .lastUpdateId)
        let bidsArray = try keyedContainer.decode([[String]].self, forKey: .bids)
        bids = OrderBook.Offer.make(from: bidsArray)
        let asksArray = try keyedContainer.decode([[String]].self, forKey: .asks)
        asks = OrderBook.Offer.make(from: asksArray)
    }
    
    enum CodingKeys: String, CodingKey {
        case firstUpdateId = "U"
        case lastUpdateId = "u"
        case bids = "b"
        case asks = "a"
    }
}
