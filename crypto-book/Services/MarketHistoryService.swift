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
    
    func start()
    func pause()
    func stop()
}

final class MarketHistoryService: MarketHistoryServiceProtocol {
    
    private let marketPair: MarketPair
    private let limit: UInt
    private let updateSpeed: BinanceWSRouter.UpdateSpeed
    
    private var binanceWSService: BinanceWSServiceProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    private let apiService: BinanceAPIServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
         updateSpeed: BinanceWSRouter.UpdateSpeed,
         apiService: BinanceAPIServiceProtocol = BinanceAPIService(),
         binanceWSService: BinanceWSServiceProtocol,
         reachabilityService: ReachabilityServiceProtocol = ReachabilityService()) {
        self.marketPair = marketPair
        self.updateSpeed = updateSpeed
        self.limit = limit
        self.apiService = apiService
        self.binanceWSService = binanceWSService
        self.reachabilityService = reachabilityService
        setupWSPublisher()
    }
    
    deinit {
        Log.message("deinit... ", level: .info, type: .marketHistoryService)
        binanceWSService.stop()
    }
    
    // MARK: - MarketHistoryServiceProtocol

    var isConnecting = CurrentValueSubject<Bool, Never>(true)
    var marketHistoryPublisher = CurrentValueSubject<[Trade]?, Never>(nil)
    
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
        binanceWSService.publisher
            .compactMap { $0 }
            .sink(receiveCompletion: { completion in
                Log.message("receiveCompletion \(completion)", level: .error, type: .marketHistoryService)
            }, receiveValue: { [weak self] result in
                switch result {
                case .success(let trade):
                    guard let wsTrade = trade as? WSTrade else {
                        Log.message("Can't cast to WSTrade", level: .error, type: .marketHistoryService)
                        return
                    }
                    self?.update(with: wsTrade.trade)
//                    self?.fetchMarketHistory()
                case .failure(let error):
                    Log.message("receiveValue error \(error)", level: .error, type: .marketHistoryService)
                }
            })
            .store(in: &cancelables)
    }
    
    func update(with trade: Trade) {
        let currentTrades = marketHistoryPublisher.value ?? []
        marketHistoryPublisher.value = [trade] + currentTrades
    }
    
    func fetchMarketHistory() {
        fetchMarketHistory { [weak self] didSuccess in
            if didSuccess {
                // start merging
            } else {
                self?.fetchMarketHistory()
            }
        }
    }
    
    func fetchMarketHistory(completion: @escaping (Bool) -> Void) {
        apiService.compressedTrades(marketPair: marketPair, limit: limit) { [weak self] result in
            switch result {
            case .success(let trades):
                Log.message("Fetched \(trades.count) trades, most recent: (\(trades.first?.timestamp ?? 0))",
                    level: .info, type: .marketHistoryService)
                self?.marketHistoryPublisher.value = result.value
                completion(true)
            case .failure(let error):
                Log.message("Could not retrieved trades: \(error)",
                level: .error, type: .marketHistoryService)
                completion(false)
            }
        }
    }
}
