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
    
    func restart()
    func start()
    func pause()
    func stop()
}

final class OrderBookService: OrderBookServiceProtocol {
    
    private var binanceWSService: BinanceWSServiceProtocol
    private let binanceAPIService: BinanceAPIServiceProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    
    private var marketPair: MarketPair
    private var updateSpeed: BinanceWSRouter.UpdateSpeed
    
    private let limit: Int
    private var buffer = [WSOrderBookDiff]()
    private var isRequestingAPIDepthSnapshot = false
    
    private var orderBookDiffPublisherCancelable: AnyCancellable?
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: Int,
         updateSpeed: BinanceWSRouter.UpdateSpeed,
         binanceWSService: BinanceWSServiceProtocol,
         binanceAPIService: BinanceAPIServiceProtocol = BinanceAPIService(),
         reachabilityService: ReachabilityServiceProtocol = ReachabilityService()) {
        self.marketPair = marketPair
        self.limit = limit
        self.updateSpeed = updateSpeed
        self.binanceAPIService = binanceAPIService
        self.binanceWSService = binanceWSService
        self.reachabilityService = reachabilityService
        setupWSPublisher()
        setupReachability()
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .orderBookService)
        binanceWSService.stop()
    }
    
    // MARK: - OrderBookServiceProtocol

    var isConnecting = CurrentValueSubject<Bool, Never>(true)
    var orderBookPublisher = CurrentValueSubject<OrderBook?, Never>(nil)
    
    func restart() {
        isConnecting.value = false
        binanceWSService.restart()
    }
    
    func start() {
        binanceWSService.start()
    }
    
    func pause() {
        binanceWSService.pause()
    }
    
    func stop() {
        binanceWSService.stop()
    }
}

// MARK: - Private

private extension OrderBookService {
    
    func setupWSPublisher() {
        isConnecting.value = true
        
        binanceWSService.publisher
            .compactMap { $0 }
            .sink(receiveCompletion: { completion in
                Log.message("publisher completion: \(completion)", level: .error, type: .orderBookService)
            }, receiveValue: { [weak self] result in
                switch result {
                case .success(let wsEvent):
                    guard let orderBookDiff = wsEvent as? WSOrderBookDiff else {
                        Log.message("Can't cast to WSOrderBookDiff", level: .error, type: .orderBookService)
                        return
                    }
                    self?.update(with: orderBookDiff)
                case .failure(let error):
                    Log.message("publisher error: \(error)", level: .error, type: .orderBookService)
                }
            })
            .store(in: &cancelables)
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
    
    func update(with orderBookDiff: WSOrderBookDiff) {
        // 1- Store on buffer until we get the depth snapshot from API
        if isConnecting.value {
            addToBuffer(orderBookDiff)
            if !isRequestingAPIDepthSnapshot {
                Log.message("Update diff, waiting for API request...", level: .debug, type: .orderBookService)
                isRequestingAPIDepthSnapshot = true
                fetchBookSnapshot()
            }
    
        } else {
            // 2- Then merge and publish
            if !buffer.isEmpty {
                consumeBuffer()
            }
            mergeOrderBook(with: [orderBookDiff])
        }
    }
    
    func fetchBookSnapshot() {
        fetchBookSnapshot { [weak self] didSuccess in
            if didSuccess {
                self?.isConnecting.value = false
            } else {
                self?.fetchBookSnapshot()
            }
        }
    }
    
    func fetchBookSnapshot(completion: @escaping (Bool) -> Void) {
        binanceAPIService.depthSnapshot(marketPair: marketPair) { [weak self] result in
            switch result {
            case .success(let orderBook):
                Log.message("Fetched Depth Snapshot: \(orderBook)", level: .info, type: .orderBookService)
                let filteredOrderBook = orderBook.filteringZeroAmounts
                self?.orderBookPublisher.value = filteredOrderBook
                completion(true)
            case .failure(let error):
                Log.message("Could not retrieve Depth Snapshot: \(error)", level: .error, type: .orderBookService)
                completion(false)
            }
        }
    }
    
    func addToBuffer(_ orderBookDiff: WSOrderBookDiff) {
        Log.message("BUFFER add \(orderBookDiff.lastUpdateId)", level: .debug, type: .orderBookService)
        buffer.append(orderBookDiff)
    }
    
    func consumeBuffer() {
        Log.message(
            "BUFFER consume: \(buffer.first?.firstUpdateId ?? 0)" +
            " -> \(buffer.last?.lastUpdateId ?? 0)",
            level: .debug, type: .orderBookService
        )
        mergeOrderBook(with: buffer)
        buffer = []
    }
    
    func mergeOrderBook(with orderBookDiffs: [WSOrderBookDiff]) {
        let orderBook = orderBookPublisher.value?
            .merging(diffs: orderBookDiffs)
            .prefixingOffers(Int(limit))
        orderBookPublisher.send(orderBook)
        isConnecting.value = false
    }
}
