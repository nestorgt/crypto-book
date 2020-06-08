//
//  BinanceAPIRouter.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct BinanceAPIRouter {
    
    enum PathName: String {
        case depth
    }
    
    private static let scheme = "https"
    private static let host = "api.binance.com"
    private static let apiVersion = "v3"
    private static let timeoutInterval = 60.0
    
    static func depthSnapshot(marketPair: MarketPair, limit: UInt = 500) -> URLRequest? {
        var components = commonComponents
        components.path = path(for: .depth)
        components.queryItems = [URLQueryItem(name: "symbol", value: marketPair.apiSymbol),
                                 URLQueryItem(name: "limit", value: String(limit))]
        guard let url = components.url else { return nil }
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: Self.timeoutInterval)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
    
    private static var commonComponents: URLComponents {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        return components
    }
    
    private static func path(for pathName: PathName) -> String {
        "/api" + "/\(apiVersion)" + "/\(pathName.rawValue)"
    }
}
