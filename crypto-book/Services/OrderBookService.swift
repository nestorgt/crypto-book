//
//  OrderBookService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

protocol OrderBookServiceProtocol {

    /*
    How to manage a local order book correctly
    1- Open a stream to wss://stream.binance.com:9443/ws/bnbbtc@depth.
    2- Buffer the events you receive from the stream.
    3- Get a depth snapshot from https://www.binance.com/api/v3/depth?symbol=BNBBTC&limit=1000 .
    4- Drop any event where u is <= lastUpdateId in the snapshot.
    5- The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1.
    6- While listening to the stream, each new event's U should be equal to the previous event's u+1.
    7- The data in each event is the absolute quantity for a price level.
    8- If the quantity is 0, remove the price level.
    9- Receiving an event that removes a price level that is not in your local order book can happen and is normal.
    */
    
    /// Provides updates of the Order Book for the Market pair setup.
    /// - Note: Intial value will be `nil`.
    var orderBookPublisher: CurrentValueSubject<OrderBook?, Never> { get }
    
    /// Starts the service to
    func resumeLiveUpdates()
    func suspendLiveUpdates()
    func cancelLiveUpdates()
    
    /// Returns `true` while is trying to get the depth order book & connecting to the websocket.
    /// Will return `false` once it's sending order book updates.
    /// The initial state will be `nil`.
    var isConnecting: CurrentValueSubject<Bool?, Never> { get }
}

enum OrderBookServiceError: Error {
    case apiError(APIError)
    case wrongURLRequest
    case decoder
}

final class OrderBookService: OrderBookServiceProtocol {
    
    var isConnecting = CurrentValueSubject<Bool?, Never>(nil)
    
    private var webSocketService: WebSocketServiceProtocol
    private let apiService: APIServiceProtocol
    
    private var marketPair: MarketPair
    
    private var orderBookDiffPublisher = PassthroughSubject<OrderBook.Diff, OrderBookServiceError>()
    private var orderBookDiffBuffer = [OrderBook.Diff]()
    private var isRequestingOrderBook = false
    
    private var orderBookDiffPublisherCancelable: AnyCancellable?
    
    init(marketPair: MarketPair,
         webSocketService: WebSocketServiceProtocol = WebSocketService(),
         apiService: APIServiceProtocol = APIService()) {
        self.marketPair = marketPair
        self.apiService = apiService
        self.webSocketService = webSocketService
        self.webSocketService.setup(with: BinanceWSRouter.depth(for: marketPair))
        self.webSocketService.delegate = self
        start()
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .orderBookService)
        webSocketService.cancel()
    }
    
    // MARK: - OrderBookServiceProtocol

    var orderBookPublisher = CurrentValueSubject<OrderBook?, Never>(nil)
    
    func resumeLiveUpdates() {
        webSocketService.resume()
    }
    
    func suspendLiveUpdates() {
        webSocketService.suspend()
    }
    
    func cancelLiveUpdates() {
        webSocketService.cancel()
    }
}

// MARK: - Private

private extension OrderBookService {
    
    func start() {
        isConnecting.value = true
        orderBookDiffBuffer = []
        orderBookDiffPublisherCancelable?.cancel()
        isRequestingOrderBook = false
        
        orderBookDiffPublisherCancelable = orderBookDiffPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { orderBookError in
                Log.message("orderBookDiffPublisher error: \(orderBookError)", level: .error, type: .orderBookService)
            }, receiveValue: { [weak self] orderBookDiff in
                guard let strongSelf = self else { return }
                // First time -> get order book and save diffs on a buffer
                if !strongSelf.isRequestingOrderBook && strongSelf.orderBookPublisher.value == nil {
                    strongSelf.addToBuffer(orderBookDiff)
                    strongSelf.isRequestingOrderBook = true
                    strongSelf.orderBookSnapshot(completion: { result in
                        switch result {
                        case .failure(let error):
                            Log.message("SNAPSHOT error: \(error)", level: .error, type: .orderBookService)
                            strongSelf.start()
                        case .success(let orderBook):
                            Log.message("SNAPSHOT lastUpdateId: \(orderBook.lastUpdateId)",
                                level: .debug, type: .orderBookService)
                            strongSelf.orderBookPublisher.send(orderBook)
                            strongSelf.isRequestingOrderBook = false
                        }
                    })
                } else {
                    // Then keep storing on buffer until we get the order book
                    if strongSelf.orderBookPublisher.value == nil {
                        strongSelf.addToBuffer(orderBookDiff)
                    } else {
                        // Once we have the order book in place:
                        // 1- Consume Diffs on the buffer if there is any
                        if !strongSelf.orderBookDiffBuffer.isEmpty {
                            strongSelf.consumeBuffer()
                        }
                        // 2- Consume the incoming orderBookDiff
                        strongSelf.mergeOrderBook(with: [orderBookDiff])
                    }
                }
            })
    }
    
    func orderBookSnapshot(completion: @escaping (Result<OrderBook, OrderBookServiceError>) -> Void) {
        guard let request = BinanceAPIRouter.depthSnapshot(marketPair: marketPair) else {
            completion(.failure(.wrongURLRequest))
            return
        }
        apiService.perform(urlRequest: request, completion: { result in
            switch result {
            case .failure(let apiError):
                completion(.failure(.apiError(apiError)))
            case .success(let data):
                guard let orderBook = try? JSONDecoder.binance.decode(OrderBook.self, from: data) else {
                    completion(.failure(.decoder))
                    return
                }
                let filteredOrderBook = orderBook.filteringZeroAmounts
                completion(.success(filteredOrderBook))
            }
        })
    }
    
    func addToBuffer(_ orderBookDiff: OrderBook.Diff) {
        Log.message("BUFFER add \(orderBookDiff.finalUpdateId)",
            level: .debug, type: .orderBookService)
        orderBookDiffBuffer.append(orderBookDiff)
    }
    
    func consumeBuffer() {
        Log.message(
            "BUFFER consume: \(orderBookDiffBuffer.first?.firstUpdateId ?? 0)" +
            " -> \(orderBookDiffBuffer.last?.finalUpdateId ?? 0)",
            level: .debug, type: .orderBookService
        )
        mergeOrderBook(with: orderBookDiffBuffer)
        orderBookDiffBuffer = []
    }
    
    func mergeOrderBook(with orderBookDiffs: [OrderBook.Diff]) {
        let orderBook = orderBookPublisher.value?.merging(diffs: orderBookDiffs)
        orderBookPublisher.send(orderBook)
        isConnecting.value = false
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
            Log.message("didReceive un-handled data task message", level: .error, type: .orderBookService)
            return
        }
        guard let data = Parser.JSONData(from: string),
            let eventType = (try? JSONDecoder.binance.decode(BinanceWSEventTypeResponse.self, from: data))?.eventType else {
                Log.message("didReceive un-handled event type", level: .error, type: .orderBookService)
                return
        }
        switch eventType {
        case .depthUpdate:
            do {
                let depthUpdate = try JSONDecoder.binance.decode(OrderBook.Diff.self, from: data)
                Log.message("depthUpdate: \(depthUpdate.firstUpdateId) -> \(depthUpdate.finalUpdateId)",
                    level: .error, type: .orderBookService)
                orderBookDiffPublisher.send(depthUpdate)
            } catch {
                Log.message("bad depthUpdate, can't decode -> error: \(error)",
                    level: .error, type: .orderBookService)
                orderBookDiffPublisher.send(completion: .failure(.decoder))
            }
        }
    }
    
    func didReceive(error: Error) {
        Log.message("didReceive error: \(error)", level: .error, type: .orderBookService)
    }
}
