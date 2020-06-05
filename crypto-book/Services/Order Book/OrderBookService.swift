//
//  OrderBookService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

enum OrderBookError: Error {
    case generic
}

protocol OrderBookServiceProtocol {
    
    func orderBook() -> AnyPublisher<OrderBook, OrderBookError>
}

final class OrderBookService: OrderBookServiceProtocol {
    
    func orderBook() -> AnyPublisher<OrderBook, OrderBookError> {
        let order = OrderBook(lastUpdateId: 1,
                              bids: [OrderBook.Offer(price: 10.1234, amount: 1.1234)],
                              asks: [OrderBook.Offer(price: 9.1234, amount: 0.1234)])
        
        return Future<OrderBook, OrderBookError> { promise in
            promise(.success(order))
        }.eraseToAnyPublisher()
    }
}
