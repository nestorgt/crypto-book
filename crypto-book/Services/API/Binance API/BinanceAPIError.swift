//
//  BinanceAPIError.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Errors returned by Binance API.
/// - seeAlso: https://binance-docs.github.io/apidocs/spot/en/#error-codes-2
enum BinanceAPIError: Error, Decodable, Equatable {

    // Binance
    case general(message: String)
    case request(message: String)
    case sapi(message: String)
    case saving(message: String)
    case filter(message: String)
    case other(code: Int, message: String)
    
    // App
    case api(APIError)
    case generic(message: String?)
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let code = try keyedContainer.decode(Int.self, forKey: .code)
        let message = try keyedContainer.decode(String.self, forKey: .message)
        
        switch code {
        case -1099...(-1000):
            self = .general(message: message)
        case -2999...(-1100):
            self = .request(message: message)
        case -4999...(-3000):
            self = .sapi(message: message)
        case -6999...(-6000):
            self = .saving(message: message)
        case -9999...(-9000):
            self = .filter(message: message)
        default:
            self = .other(code: code, message: message)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message = "msg"
    }
}
