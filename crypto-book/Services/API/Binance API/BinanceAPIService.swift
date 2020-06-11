//
//  BinanceAPIService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

protocol BinanceAPIServiceProtocol {
    
    func depthSnapshot(marketPair: MarketPair,
                       completion: @escaping (Result<OrderBook, BinanceAPIError>) -> Void)
    
    func aggTrades(marketPair: MarketPair,
                   limit: Int,
                   completion: @escaping (Result<[Trade], BinanceAPIError>) -> Void)
}

final class BinanceAPIService: BinanceAPIServiceProtocol {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func depthSnapshot(marketPair: MarketPair,
                       completion: @escaping (Result<OrderBook, BinanceAPIError>) -> Void) {
        guard let request = BinanceAPIRouter.depthSnapshot(marketPair: marketPair) else {
            completion(.failure(.generic(message: "Can't build request")))
            return
        }
        apiService.perform(urlRequest: request, completion: { result in
            switch result {
            case .failure(let apiError):
                completion(.failure(.api(apiError)))
            case .success(let data):
                guard let orderBook = try? JSONDecoder.binance.decode(OrderBook.self, from: data) else {
                    completion(.failure(.generic(message: "Can't decode")))
                    return
                }
                completion(.success(orderBook))
            }
        })
    }
    
    func aggTrades(marketPair: MarketPair,
                          limit: Int,
                          completion: @escaping (Result<[Trade], BinanceAPIError>) -> Void) {
        guard let request = BinanceAPIRouter.aggTrades(marketPair: marketPair, limit: limit) else {
            completion(.failure(.generic(message: "Can't build request")))
            return
        }
        apiService.perform(urlRequest: request, completion: { result in
            switch result {
            case .failure(let apiError):
                completion(.failure(.api(apiError)))
            case .success(let data):
                guard let trades = try? JSONDecoder.binance.decode([Trade].self, from: data) else {
                    completion(.failure(.generic(message: "Can't decode")))
                    return
                }
                completion(.success(trades))
            }
        })
    }
}
