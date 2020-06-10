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
    
    @Published var marketPair: MarketPair
    @Published var tradesSnapshot: NSDiffableDataSourceSnapshot<Int, MarketHistoryCellViewModel>?
    @Published var isLoading: Bool = false
    
    var screenTitle: String { NSLocalizedString("page-menu-market-history-title") }
    var timeText: String { NSLocalizedString("time-title") }
    var priceText: String { NSLocalizedString("price-title") }
    var quantityText: String { NSLocalizedString("quantity-title") }

    private let marketHistoryService: MarketHistoryServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
         updateSpeed: BinanceWSRouter.UpdateSpeed) {
        self.marketPair = marketPair
        let wsRouter = BinanceWSRouter.compressedTrades(for: marketPair)
        self.marketHistoryService = MarketHistoryService(marketPair: marketPair,
                                                         limit: limit,
                                                         updateSpeed: updateSpeed,
                                                         binanceWSService: BinanceWSService(url: wsRouter))
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .marketHistoryViewModel)
        marketHistoryService.start()
    }
    
    func pauseLiveUpdates() {
        marketHistoryService.pause()
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .debug, type: .marketHistoryViewModel)
        marketHistoryService.stop()
    }
}

// MARK: - Private

private extension MarketHistoryViewModel {
    
    func setupBindings() {
        marketHistoryService.marketHistoryPublisher
            .compactMap { $0 }
            .sink(receiveCompletion: { error in
                Log.message("Commpleted, error?: \(error)", level: .debug, type: .marketHistoryViewModel)
            }, receiveValue: { [weak self] trades in
                self?.updateDataSnapshot(with: trades)
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
    
    func updateDataSnapshot(with trades: [Trade]?) {
        guard let trades = trades else { return }
        let numberOfElements = Self.numberOfCells
        // TODO: get precision checking the first 10-20 items and see the 0's at the end
        let precision = 4
        
        let models = trades.prefix(numberOfElements).map { trade -> MarketHistoryCellViewModel in
            MarketHistoryCellViewModel(timestamp: trade.timestamp,
                                       price: trade.price,
                                       amount: trade.amount,
                                       isBuyerMaker: trade.isBuyerMaker,
                                       precision: precision)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Int, MarketHistoryCellViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(models)
        tradesSnapshot = snapshot
    }
    
}
