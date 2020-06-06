//
//  BinanceWSError.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Errors returned by Binance WebSocket.
/// - seeAlso: https://github.com/binance-exchange/binance-official-api-docs/blob/master/web-socket-streams.md#error-messages
enum BinanceWSError: Decodable {

    case unknownProperty(message: String)
    case invalidValue(message: String)
    case invalidRequest(message: String)
    case invalidJSON(message: String)
    case other(message: String)
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let code = try keyedContainer.decode(Int.self, forKey: .code)
        let message = try keyedContainer.decode(String.self, forKey: .message)
        
        switch code {
        case 0:
            self = .unknownProperty(message: message)
        case 1:
            self = .invalidValue(message: message)
        case 2:
            self = .invalidRequest(message: message)
        case 3:
            self = .invalidJSON(message: message)
        default:
            self = .other(message: message)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message = "msg"
    }
}
