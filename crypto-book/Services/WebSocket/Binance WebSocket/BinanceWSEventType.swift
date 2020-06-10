//
//  BinanceWSEventType.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

enum BinanceWSEventType: String, Decodable {
    case depthUpdate
    case aggTrade
    
    var decodableType: Decodable.Type {
        switch self {
        case .depthUpdate:
            return WSOrderBookDiff.self
        case .aggTrade:
            return WSTrade.self
        }
    }
}
