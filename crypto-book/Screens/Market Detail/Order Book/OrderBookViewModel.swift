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
    
    var pricePrecision: Int {
        4
    }
    
    private let updateSpeed: BinanceWSRouter.UpdateSpeed
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
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
            .throttle(for: .milliseconds(updateSpeed.milliseconds),
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
        guard let orderBook = orderBook else { return }
        let numberOfElements = OrderBookViewModel.numberOfCells
        let maxMinData = orderBook.maxMinData(prefixElements: numberOfElements)
        
        let bidModels = orderBook.bids.prefix(numberOfElements).map { bid -> OrderBookCellViewModel in
            let progress = OrderBook.bidWeight(for: bid.amount, with: maxMinData)
            return OrderBookCellViewModel(price: bid.price,
                                   pricePrecision: pricePrecision,
                                   amount: bid.amount,
                                   progress: progress)
        }

        let askModels = orderBook.asks.prefix(numberOfElements).map { ask -> OrderBookCellViewModel in
            OrderBookCellViewModel(price: ask.price,
                                   pricePrecision: pricePrecision,
                                   amount: ask.amount,
                                   progress: OrderBook.askWeight(for: ask.amount, with: maxMinData))
        }
        
        bidCellViewModels = bidModels
        askCellViewModels = askModels
    }
}
