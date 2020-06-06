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
    case decoder
}

protocol OrderBookServiceProtocol {
    
    /// Returns the current order book snapshoot
    func orderBookSnapshot() -> AnyPublisher<OrderBook, OrderBookError>
    
    /// Stream of `<OrderBookDiff, OrderBookError>`. Will start emitting after calling `startLiveUpdates`
    var liveUpdates: PassthroughSubject<OrderBookDiff, OrderBookError> { get }
    
    func resumeLiveUpdates()
    func suspendLiveUpdates()
    func cancelLiveUpdates()
}

final class OrderBookService: OrderBookServiceProtocol {
    
    private let webSocketService: WebSocketServiceProtocol
    
    var liveUpdates = PassthroughSubject<OrderBookDiff, OrderBookError>()
    
    init(webSocketService: WebSocketServiceProtocol) {
        self.webSocketService = webSocketService
        let config = WebSocketServiceConfiguration(url: BinanceWSRouter.url,
                                                   queueQualityOfService: .default,
                                                   pingTimeInterval: 30)
        webSocketService.setup(with: config, delegate: self)
        
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .orderBookService)
        webSocketService.cancel()
    }
    
    // MARK: - OrderBookServiceProtocol
    
    func resumeLiveUpdates() {
        webSocketService.resume()
    }
    
    func suspendLiveUpdates() {
        webSocketService.suspend()
    }
    
    func cancelLiveUpdates() {
        webSocketService.cancel()
    }
    
    func orderBookSnapshot() -> AnyPublisher<OrderBook, OrderBookError> {
        let order = OrderBook(lastUpdateId: 1,
                              bids: [OrderBook.Offer(price: 10.1234, amount: 1.1234)],
                              asks: [OrderBook.Offer(price: 9.1234, amount: 0.1234)])
        
        return Future<OrderBook, OrderBookError> { promise in
            promise(.success(order))
        }.eraseToAnyPublisher()
    }
}

// MARK: - WebSocketServiceDelegate

extension OrderBookService: WebSocketServiceDelegate {
    
    func didOpen(handshakeProtocol: String?) {
        Log.message("didOpen with protocol \(handshakeProtocol ?? "<nil>")", level: .info, type: .orderBookService)
    }
    
    func didClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reason = String(data: reason ?? Data(), encoding: .utf8) ?? "<nil>"
        Log.message("didClose with code: \(closeCode), reason: \(reason)", level: .info, type: .orderBookService)
    }
    
    func didReceive(message: URLSessionWebSocketTask.Message) {
        guard let string = message.string else {
            Log.message("Un-handled data task message", level: .error, type: .orderBookService)
            return
        }
        guard let data = Parser.JSONData(from: string),
            let eventType = (try? JSONDecoder.binance.decode(BinanceWSEventTypeResponse.self, from: data))?.eventType else {
                Log.message("Un-handled event type", level: .error, type: .orderBookService)
                return
        }
        switch eventType {
        case .depthUpdate:
            do {
                let depthUpdate = try JSONDecoder.binance.decode(OrderBookDiff.self, from: data)
                liveUpdates.send(depthUpdate)
            } catch {
                Log.message("didReceive can't decode, error: \(error)", level: .error, type: .orderBookService)
                liveUpdates.send(completion: .failure(.decoder))
            }
        }
    }
    
    func didReceive(error: Error) {
        Log.message("didReceive error: \(error)", level: .error, type: .orderBookService)
    }
}
