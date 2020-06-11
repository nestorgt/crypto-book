//
//  OrderBookViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

final class OrderBookViewModel {
    
    static var numberOfCells: Int = 20
    
    @Published var marketPair: MarketPair
    @Published var bidCellViewModels: [OrderBookCellViewModel]?
    @Published var askCellViewModels: [OrderBookCellViewModel]?
    @Published var isLoading: Bool = false

    var screenTitle: String { NSLocalizedString("page-menu-order-book-title") }
    
    private var precision: Precision?
    private var originalPrecision: Int?
    @Published var precisionOptions: [Int]?
    @Published var precisionSelected: Int?
    
    private let updateSpeed: BinanceWSRouter.UpdateSpeed
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: Int,
         updateSpeed: BinanceWSRouter.UpdateSpeed) {
        self.marketPair = marketPair
        self.updateSpeed = updateSpeed
        let url = BinanceWSRouter.depth(for: marketPair, updateSpeed: updateSpeed)
        self.orderBookService = OrderBookService(marketPair: marketPair,
                                                 limit: limit,
                                                 updateSpeed: updateSpeed,
                                                 binanceWSService: BinanceWSService(url: url))
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBookViewModel)
        orderBookService.start()
    }
    
    func pauseLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBookViewModel)
        orderBookService.pause()
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .info, type: .orderBookViewModel)
        orderBookService.stop()
    }
}

// MARK: - Private

private extension OrderBookViewModel {
    
    func setupBindings() {
        orderBookService.orderBookPublisher
            .throttle(for: DevMenuViewController.uiThrottle,
                      scheduler: DispatchQueue(label: "\(Self.self)"),
                      latest: true)
            .sink(receiveCompletion: { error in
                Log.message("Commpleted, error?: \(error)", level: .debug, type: .orderBookViewModel)
            }, receiveValue: { [weak self] orderBook in
                Log.message("Received orderBook, lastUpdateId: \(String(describing: orderBook?.lastUpdateId))",
                    level: .debug, type: .orderBookViewModel)
                self?.updateDataSnapshots(with: orderBook)
            })
            .store(in: &cancelables)
        
        orderBookService.isConnecting
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveValue: { [weak self] isConnecting in
                self?.isLoading = isConnecting
            })
            .store(in: &cancelables)
    }
    
    func updateDataSnapshots(with orderBook: OrderBook?) {
        guard let book = orderBook else { return }
        
        getPrecisionIfNeeded(for: book)
        let filteredOrderBook = filterByPrecisionIfNeeded(orderBook: book)
        
        let numberOfElements = OrderBookViewModel.numberOfCells
        let maxMinData = filteredOrderBook.maxMinData(prefixElements: numberOfElements)
        
        let bids = filteredOrderBook.filteredBids.isEmpty ? filteredOrderBook.bids : filteredOrderBook.filteredBids
        let bidModels = bids.prefix(numberOfElements).map { bid -> OrderBookCellViewModel in
            let progress = OrderBook.bidWeight(for: bid.amount, with: maxMinData)
            return OrderBookCellViewModel(price: bid.price,
                                          pricePrecision: precision,
                                          amount: bid.amount,
                                          progress: progress)
        }

        let asks = filteredOrderBook.filteredAsks.isEmpty ? filteredOrderBook.asks : filteredOrderBook.filteredAsks
        let askModels = asks.prefix(numberOfElements).map { ask -> OrderBookCellViewModel in
            OrderBookCellViewModel(price: ask.price,
                                   pricePrecision: precision,
                                   amount: ask.amount,
                                   progress: OrderBook.askWeight(for: ask.amount, with: maxMinData))
        }
        
        bidCellViewModels = bidModels
        askCellViewModels = askModels
    }
    
    func getPrecisionIfNeeded(for orderBook: OrderBook) {
        guard precisionOptions == nil && precisionSelected == nil else { return }
        let length = OrderBookViewModel.numberOfCells
        let prices = Array(orderBook.bids.prefix(length) + orderBook.asks.prefix(length)).map { $0.price }
        let maxNumberOfDecimals = prices.map { $0.maxNumberOfDecimals }.max() ?? 8
        let zerosAfterDots = prices.map { $0.zerosAfterDot }.min() ?? 0
        let minPrecision = zerosAfterDots > 0 ? zerosAfterDots + 1 : zerosAfterDots
        precision = Precision(min: minPrecision, max: maxNumberOfDecimals)
        precisionOptions = (minPrecision...maxNumberOfDecimals).map { $0 }
        precisionSelected = maxNumberOfDecimals
        originalPrecision = maxNumberOfDecimals
    }
    
    func filterByPrecisionIfNeeded(orderBook: OrderBook) -> OrderBook {
        guard let precisionSelected = precisionSelected,
            let originalPrecision = originalPrecision,
            precisionSelected != originalPrecision
            else { return orderBook }
        
        return orderBook.filter(by: precisionSelected)
    }
}
