//
//  Trade.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Trade history item model from API.
struct Trade: CustomStringConvertible, Equatable {
    let id: UInt64
    let price: Double
    let amount: Double
    let firstTradeId: UInt64
    let lastTradeId: UInt64
    let timestamp: TimeInterval
    let isBuyerMaker: Bool
    let isBestPriceMatch: Bool
    
    var description: String {
        "id: \(id), price: \(price), amount: \(amount). (\(firstTradeId) -> \(lastTradeId))"
    }
}

// MARK: - Decodable

extension Trade: Decodable {
    
    /*
     {
         "a": 26129,         // Aggregate tradeId
         "p": "0.01633102",  // Price
         "q": "4.70443515",  // Quantity
         "f": 27781,         // First tradeId
         "l": 27781,         // Last tradeId
         "T": 1498793709153, // Timestamp
         "m": true,          // Was the buyer the maker?
         "M": true           // Was the trade the best price match?
     }
    */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        guard let priceString = try? keyedContainer.decode(String.self, forKey: .price),
            let amountString = try? keyedContainer.decode(String.self, forKey: .amount),
            let price = Double(priceString),
            let amount = Double(amountString)
            else { throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [CodingKeys.price, CodingKeys.amount],
                debugDescription: "Can't decode Amount and/or Price."))
        }
        id = try keyedContainer.decode(UInt64.self, forKey: .id)
        self.price = price
        self.amount = amount
        firstTradeId = try keyedContainer.decode(UInt64.self, forKey: .firstTradeId)
        lastTradeId = try keyedContainer.decode(UInt64.self, forKey: .lastTradeId)
        timestamp = try keyedContainer.decode(TimeInterval.self, forKey: .timestamp)
        isBuyerMaker = try keyedContainer.decode(Bool.self, forKey: .maker)
        isBestPriceMatch = try keyedContainer.decode(Bool.self, forKey: .taker)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "a"
        case price = "p"
        case amount = "q"
        case firstTradeId = "f"
        case lastTradeId = "l"
        case timestamp = "T"
        case maker = "m"
        case taker = "M"
    }
}
