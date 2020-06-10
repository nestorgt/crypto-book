//
//  BinanceAPIService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

protocol BinanceAPIServiceProtocol {
    
    func compressedTrades(marketPair: MarketPair,
                          limit: UInt,
                          completion: @escaping (Result<[Trade], BinanceAPIError>) -> Void)
}

final class BinanceAPIService: BinanceAPIServiceProtocol {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func compressedTrades(marketPair: MarketPair,
                          limit: UInt,
                          completion: @escaping (Result<[Trade], BinanceAPIError>) -> Void) {
        guard let request = BinanceAPIRouter.compressedTrades(marketPair: marketPair, limit: limit) else {
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
