//
//  MarketHistoryViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

final class MarketHistoryViewModel {
    
    static var numberOfCells: Int = 20
    
    private var precision: Precision?
    @Published var marketPair: MarketPair
    @Published var cellViewModels: [MarketHistoryCellViewModel]?
    @Published var isLoading: Bool = false
    
    var screenTitle: String { NSLocalizedString("page-menu-market-history-title") }
    var timeText: String { NSLocalizedString("time-title") }
    var priceText: String { NSLocalizedString("price-title") }
    var quantityText: String { NSLocalizedString("quantity-title") }
    
    private let updateSpeed: BinanceWSRouter.UpdateSpeed
    private let marketHistoryService: MarketHistoryServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: Int,
         updateSpeed: BinanceWSRouter.UpdateSpeed) {
        self.marketPair = marketPair
        self.updateSpeed = updateSpeed
        let url = BinanceWSRouter.aggTrades(for: marketPair)
        self.marketHistoryService = MarketHistoryService(marketPair: marketPair,
                                                         limit: limit,
                                                         updateSpeed: updateSpeed,
                                                         binanceWSService: BinanceWSService(url: url))
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .marketHistoryViewModel)
        marketHistoryService.start()
    }
    
    func pauseLiveUpdates() {
        Log.message("PAUSE Live Updates", level: .info, type: .marketHistoryViewModel)
        marketHistoryService.pause()
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .info, type: .marketHistoryViewModel)
        marketHistoryService.stop()
    }
}

// MARK: - Private

private extension MarketHistoryViewModel {
    
    func setupBindings() {
        marketHistoryService.marketHistoryPublisher
            .throttle(for: DevMenuViewController.uiThrottle,
                      scheduler: DispatchQueue(label: "\(Self.self)"),
                      latest: true)
            .compactMap { $0 }
            .sink(receiveCompletion: { error in
                Log.message("Commpleted, error?: \(error)", level: .debug, type: .marketHistoryViewModel)
            }, receiveValue: { [weak self] trades in
                let newCount = trades.firstIndex(where: { $0.id == self?.cellViewModels?.first?.id })
                let firstId = trades.first?.id ?? 0
                let lastId = trades.last?.id ?? 0
                Log.message("Received \(newCount ?? Self.numberOfCells) new trades: (\(firstId) -> \(lastId))",
                    level: .debug, type: .marketHistoryViewModel)
                self?.updateCellViewModels(with: trades)
            })
            .store(in: &cancelables)
        
        marketHistoryService.isConnecting
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
                }, receiveValue: { [weak self] isConnecting in
                    self?.isLoading = isConnecting
            })
            .store(in: &cancelables)
    }
    
    func updateCellViewModels(with trades: [Trade]?) {
        guard let trades = trades else { return }
        let numberOfElements = Self.numberOfCells
        if precision == nil {
            precision = getPrecision(for: trades)
        }
        
        let models = trades.prefix(numberOfElements).map { trade -> MarketHistoryCellViewModel in
            MarketHistoryCellViewModel(id: trade.id,
                                       timestamp: trade.timestamp,
                                       price: trade.price,
                                       amount: trade.amount,
                                       isBuyerMaker: trade.isBuyerMaker,
                                       precision: precision)
        }
        cellViewModels = models
    }
    
    func getPrecision(for trades: [Trade]) -> Precision {
        let length = Self.numberOfCells
        let prices = Array(trades.prefix(length)).map { $0.price }
        
        let maxNumberOfDecimals = prices.map { $0.maxNumberOfDecimals }.max() ?? 8
        let zerosAfterDots = prices.map { $0.zerosAfterDot }.min() ?? 0
        let minPrecision = zerosAfterDots > 0 ? zerosAfterDots + 1 : zerosAfterDots
        
        return Precision(min: minPrecision,
                         max: maxNumberOfDecimals)
    }
}
