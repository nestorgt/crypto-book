//
//  MarketHistoryService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

protocol MarketHistoryServiceProtocol {

    /// Returns `true` while is trying to get the depth order book & connecting to the websocket.
    /// Will return `false` once it's sending order book updates.
    var isConnecting: CurrentValueSubject<Bool, Never> { get }
    
    /// Provides updates of the Market History for the Market pair setup.
    /// - Note: Intial value will be `nil`.
    var marketHistoryPublisher: CurrentValueSubject<[Trade]?, Never> { get }
    
    func restart()
    func start()
    func pause()
    func stop()
}

final class MarketHistoryService: MarketHistoryServiceProtocol {
    
    static let maxTradesCapacity = 100
    
    private let marketPair: MarketPair
    private let limit: UInt
    private let updateSpeed: BinanceWSRouter.UpdateSpeed
    
    private var binanceWSService: BinanceWSServiceProtocol
    private let binanceAPIService: BinanceAPIServiceProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    
    private var buffer = [Trade]()
    private var isRequestingAPIMarketHistory = false
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
         updateSpeed: BinanceWSRouter.UpdateSpeed,
         binanceWSService: BinanceWSServiceProtocol,
         binanceAPIService: BinanceAPIServiceProtocol = BinanceAPIService(),
         reachabilityService: ReachabilityServiceProtocol = ReachabilityService()) {
        self.marketPair = marketPair
        self.updateSpeed = updateSpeed
        self.limit = limit
        self.binanceAPIService = binanceAPIService
        self.binanceWSService = binanceWSService
        self.reachabilityService = reachabilityService
        setupReachability()
        setupWSPublisher()
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .marketHistoryService)
        binanceWSService.stop()
    }
    
    // MARK: - MarketHistoryServiceProtocol

    var isConnecting = CurrentValueSubject<Bool, Never>(true)
    var marketHistoryPublisher = CurrentValueSubject<[Trade]?, Never>(nil)
    
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

private extension MarketHistoryService {
    
    func setupWSPublisher() {
        isConnecting.value = true
        
        binanceWSService.publisher
            .compactMap { $0 }
            .sink(receiveCompletion: { completion in
                Log.message("publisher \(completion)", level: .error, type: .marketHistoryService)
            }, receiveValue: { [weak self] result in
                switch result {
                case .success(let wsEvent):
                    guard let wsTrade = wsEvent as? WSTrade else {
                        Log.message("Can't cast to WSTrade", level: .error, type: .marketHistoryService)
                        return
                    }
                    self?.update(with: wsTrade.trade)
                case .failure(let error):
                    Log.message("publisher error \(error)", level: .error, type: .marketHistoryService)
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
    
    func update(with trade: Trade) {
        // 1- Store on buffer until we get the market history from API
        if isConnecting.value {
            buffer.append(trade)
            if !isRequestingAPIMarketHistory {
                Log.message("Update trade, waiting for API request...", level: .debug, type: .marketHistoryService)
                isRequestingAPIMarketHistory = true
                fetchMarketHistory()
            }
        } else {
            // 2- Then merge and publish
            if !buffer.isEmpty {
                Log.message("Update trade, consuming buffer...", level: .debug, type: .marketHistoryService)
                let bufferTrades = buffer
                buffer = []
                merge(trades: [trade] + bufferTrades)
            } else {
                merge(trades: [trade])
            }
        }
    }
    
    func merge(trades: [Trade]) {
        let validTrades = trades.filter { $0.firstTradeId > marketHistoryPublisher.value?.first?.lastTradeId ?? 0 }
        let trades = validTrades + (marketHistoryPublisher.value ?? [])
        let tradesIgnoringOldest = Array(trades.prefix(Self.maxTradesCapacity))
        marketHistoryPublisher.send(tradesIgnoringOldest)
    }
    
    func fetchMarketHistory() {
        fetchMarketHistory { [weak self] didSuccess in
            if didSuccess {
                self?.isConnecting.value = false
            } else {
                self?.fetchMarketHistory()
            }
        }
    }
    
    func fetchMarketHistory(completion: @escaping (Bool) -> Void) {
        binanceAPIService.aggTrades(marketPair: marketPair, limit: limit) { [weak self] result in
            switch result {
            case .success(let trades):
                Log.message("Fetched \(trades.count) trades, most recent: (\(trades.first?.timestamp ?? 0))",
                    level: .info, type: .marketHistoryService)
                self?.marketHistoryPublisher.value = trades
                completion(true)
            case .failure(let error):
                Log.message("Could not retrieved trades: \(error)", level: .error, type: .marketHistoryService)
                completion(false)
            }
        }
    }
}
