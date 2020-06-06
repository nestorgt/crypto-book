//
//  BinanceWSEventType.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct BinanceWSEventTypeResponse: Decodable {
    
    let eventType: BinanceWSEventType
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try keyedContainer.decode(BinanceWSEventType.self, forKey: .eventType)
    }
    
    enum CodingKeys: String, CodingKey {
        case eventType = "e"
    }
}

enum BinanceWSEventType: String, Decodable {
    case depthUpdate
}
