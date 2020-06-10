//
//  BinanceAPIRouter.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct BinanceAPIRouter {
    
    private static let scheme = "https"
    private static let host = "api.binance.com"
    private static let apiVersion = "v3"
    private static let timeoutInterval = 60.0
    
    static func depthSnapshot(marketPair: MarketPair, limit: UInt = 500) -> URLRequest? {
        var components = commonComponents
        components.path = path(for: .depth)
        components.queryItems = [symbolComponent(for: marketPair),
                                 limitComponent(for: limit)]
        guard let url = components.url else { return nil }
        var urlRequest = request(for: url)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }

    static func compressedTrades(marketPair: MarketPair, limit: UInt = 80) -> URLRequest? {
        var components = commonComponents
        components.path = path(for: .compressedTrades)
        components.queryItems = [symbolComponent(for: marketPair),
                                 limitComponent(for: limit)]
        guard let url = components.url else { return nil }
        var urlRequest = request(for: url)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}

// MARK: - Enums

extension BinanceAPIRouter {
    
    enum PathName: String {
        case depth
        case compressedTrades = "aggTrades"
    }
}

// MARK: - Private

private extension BinanceAPIRouter {
    
    static func path(for pathName: PathName) -> String {
        "/api" + "/\(apiVersion)" + "/\(pathName.rawValue)"
    }
    
    static var commonComponents: URLComponents {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        return components
    }
    
    static func symbolComponent(for marketPair: MarketPair) -> URLQueryItem {
        URLQueryItem(name: "symbol", value: marketPair.apiSymbol)
    }
    
    static func limitComponent(for limit: UInt) -> URLQueryItem {
        URLQueryItem(name: "limit", value: String(limit))
    }
    
    static func request(for url: URL,
                        cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                        timeoutInterval: TimeInterval = Self.timeoutInterval) -> URLRequest {
        URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }
}
