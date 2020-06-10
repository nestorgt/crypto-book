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
    
    /// Returns `true` while is trying to get the depth order book & connecting to the websocket.
    /// Will return `false` once it's sending order book updates.
    var isConnecting: CurrentValueSubject<Bool, Never> { get }
    
    /// Provides updates of the Order Book.
    /// - Note: Intial value will be `nil`.
    var orderBookPublisher: CurrentValueSubject<OrderBook?, Never> { get }
    
    func resume()
    func suspend()
    func cancel()
}

enum OrderBookServiceError: Error {
    case apiError(APIError)
    case wsError(BinanceWSError)
    case wrongURLRequest
    case decoder
}

final class OrderBookService: OrderBookServiceProtocol {
    
    private var webSocketService: WebSocketServiceProtocol
    private let apiService: APIServiceProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    
    private var marketPair: MarketPair
    private var updateSpeed: BinanceWSRouter.UpdateSpeed
    
    @Published private var orderBookDiffPublisher: Result<WSOrderBookDiff, OrderBookServiceError>?
    private var orderBookDiffBuffer = [WSOrderBookDiff]()
    private var isRequestingOrderBook = false
    
    private var orderBookDiffPublisherCancelable: AnyCancellable?
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
         updateSpeed: BinanceWSRouter.UpdateSpeed,
         webSocketService: WebSocketServiceProtocol = WebSocketService(),
         apiService: APIServiceProtocol = APIService(),
         reachabilityService: ReachabilityServiceProtocol = ReachabilityService()) {
        self.marketPair = marketPair
        self.updateSpeed = updateSpeed
        self.apiService = apiService
        self.webSocketService = webSocketService
        self.reachabilityService = reachabilityService
        setupWebSocket()
        setupReachability()
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .orderBookService)
        webSocketService.cancel()
    }
    
    // MARK: - OrderBookServiceProtocol

    var isConnecting = CurrentValueSubject<Bool, Never>(true)
    var orderBookPublisher = CurrentValueSubject<OrderBook?, Never>(nil)
    
    func restart() {
        isConnecting.value = true
        webSocketService.restart()
    }
    
    func resume() {
        webSocketService.resume()
    }
    
    func suspend() {
        webSocketService.suspend()
    }
    
    func cancel() {
        webSocketService.cancel()
    }
}

// MARK: - Private

private extension OrderBookService {
    
    
    func setupWebSocket() {
        webSocketService.delegate = self
        webSocketService.setup(with: BinanceWSRouter.depth(for: marketPair, updateSpeed: updateSpeed))
    }
    
    func setupReachability() {
        reachabilityService.isReachablePublisher
            .removeDuplicates()
            .dropFirst()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] isReachable in
                    if isReachable {
                        self?.restart()
                    } else {
                        self?.isConnecting.value = true
                    }
            })
            .store(in: &cancelables)
    }
    
    func startListening() {
        isConnecting.value = true
        orderBookDiffBuffer = []
        orderBookDiffPublisherCancelable?.cancel()
        orderBookDiffPublisher = nil
        isRequestingOrderBook = false
        
        orderBookDiffPublisherCancelable = $orderBookDiffPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink(receiveCompletion: { completion in
                Log.message("orderBookDiffPublisher completion: \(completion)",
                    level: .error, type: .orderBookService)
            }, receiveValue: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let orderBookDiff):
                    // First time -> get order book and save diffs on a buffer
                    if !strongSelf.isRequestingOrderBook && strongSelf.orderBookPublisher.value == nil {
                        strongSelf.addToBuffer(orderBookDiff)
                        strongSelf.isRequestingOrderBook = true
                        strongSelf.orderBookSnapshot(completion: { result in
                            switch result {
                            case .failure(let error):
                                Log.message("SNAPSHOT error: \(error)", level: .error, type: .orderBookService)
                                self?.startListening()
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
                case .failure(let error):
                    Log.message("$orderBookDiffPublisher error: \(error)",
                        level: .error, type: .orderBookService)
                    self?.restart()
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
    
    func addToBuffer(_ orderBookDiff: WSOrderBookDiff) {
        Log.message("BUFFER add \(orderBookDiff.lastUpdateId)",
            level: .debug, type: .orderBookService)
        orderBookDiffBuffer.append(orderBookDiff)
    }
    
    func consumeBuffer() {
        Log.message(
            "BUFFER consume: \(orderBookDiffBuffer.first?.firstUpdateId ?? 0)" +
            " -> \(orderBookDiffBuffer.last?.lastUpdateId ?? 0)",
            level: .debug, type: .orderBookService
        )
        mergeOrderBook(with: orderBookDiffBuffer)
        orderBookDiffBuffer = []
    }
    
    func mergeOrderBook(with orderBookDiffs: [WSOrderBookDiff]) {
        let orderBook = orderBookPublisher.value?.merging(diffs: orderBookDiffs)
        orderBookPublisher.send(orderBook)
        isConnecting.value = false
    }
}

// MARK: - WebSocketServiceDelegate

extension OrderBookService: WebSocketServiceDelegate {
    
    func didOpen(handshakeProtocol: String?) {
        Log.message("didOpen with protocol \(String(describing: handshakeProtocol))",
            level: .info, type: .orderBookService)
        startListening()
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
        guard let data = Parser.JSONData(from: string) else {
            Log.message("didReceive wrong data", level: .error, type: .orderBookService)
            return
        }
        if let wsEventType = (try? JSONDecoder.binance.decode(WSEvent.self, from: data))?.type {
            switch wsEventType {
            case .aggTrade:
                break
            case .depthUpdate:
                do {
                    let depthUpdate = try JSONDecoder.binance.decode(WSOrderBookDiff.self, from: data)
                    Log.message("depthUpdate: \(depthUpdate.firstUpdateId) -> \(depthUpdate.lastUpdateId)",
                        level: .debug, type: .orderBookService)
                    orderBookDiffPublisher = .success(depthUpdate)
                } catch {
                    Log.message("bad depthUpdate, can't decode -> error: \(error)",
                        level: .error, type: .orderBookService)
                    orderBookDiffPublisher = .failure(.decoder)
                }
            }
        } else if let error = try? JSONDecoder.binance.decode(BinanceWSError.self, from: data) {
            Log.message("didReceive message: \(error)", level: .error, type: .orderBookService)
            orderBookDiffPublisher = .failure(.wsError(error))
        } else {
            Log.message("didReceive un-handled event type", level: .error, type: .orderBookService)
        }
    }
    
    func didReceive(error: Error) {
        Log.message("didReceive error: \(error)", level: .error, type: .orderBookService)
    }
}
