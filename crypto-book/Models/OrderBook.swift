//
//  OrderBook.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Order book model from API.
struct OrderBook: CustomStringConvertible, Equatable {
    var lastUpdateId: UInt64
    var bids: [Offer]
    var asks: [Offer]
    
    var description: String {
        """
        \n- lastUpdateId: \(lastUpdateId)
        - bids: \(bids)
        - tasks: \(asks)
        """
    }
}

// MARK: - Decodable

extension OrderBook: Decodable {
    
    /*
    {
        "lastUpdateId": 4405135474,
        "bids": [
            [
                "9728.18000000",
                "0.12808100"
            ],
            [
                "9728.17000000",
                "0.04472000"
            ]
        ],
        "asks": [
            [
                "9728.99000000",
                "0.25704700"
            ],
            [
                "9729.07000000",
                "2.02563600"
            ]
        ]
    }
    */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdateId = try keyedContainer.decode(UInt64.self, forKey: .lastUpdateId)
        let bidsArray = try keyedContainer.decode([[String]].self, forKey: .bids)
        bids = Offer.make(from: bidsArray)
        let asksArray = try keyedContainer.decode([[String]].self, forKey: .asks)
        asks = Offer.make(from: asksArray)
    }
    
    enum CodingKeys: String, CodingKey {
        case lastUpdateId, bids, asks
    }
}
