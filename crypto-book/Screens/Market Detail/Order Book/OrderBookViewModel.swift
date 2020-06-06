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
    
    @Published var marketPair: MarketPair
    @Published var bidDataSnapshot: NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>?
    @Published var askDataSnapshot: NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>?

    var screenTitle: String { NSLocalizedString("page-menu-order-book-title") }
    
    var pricePrecision: Int {
        4
    }
    
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         orderBookService: OrderBookServiceProtocol = DI.orderBookService) {
        self.marketPair = marketPair
        self.orderBookService = orderBookService
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBookViewModel)
        orderBookService.resumeLiveUpdates()
//        orderBookService.orderBookSnapshot()
//            .sink(receiveCompletion: { orderBookError in
//                Log.message("Error Order Book \(orderBookError)", level: .error, type: .orderBookViewModel)
//            }, receiveValue: { [weak self] orderBook in
//                Log.message("Received Order Book: \(orderBook)", level: .debug, type: .orderBookViewModel)
//                self?.updateDataSnapshots(with: orderBook)
//            })
//            .store(in: &cancelables)
    }
    
    func pauseLiveUpdates() {
        orderBookService.suspendLiveUpdates()
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .debug, type: .orderBookViewModel)
        orderBookService.cancelLiveUpdates()
    }
}

private extension OrderBookViewModel {
    
    func setupBindings() {
        orderBookService.liveUpdates
            .sink(receiveCompletion: { orderBookError in
                Log.message("Error Order Book Diff: \(orderBookError)", level: .debug, type: .orderBookViewModel)
            }, receiveValue: { [weak self] orderBookDiff in
                Log.message("Received Order Book Diff: \(orderBookDiff)", level: .debug, type: .orderBookViewModel)
                self?.updateDataSnapshots(with: orderBookDiff)
            })
            .store(in: &cancelables)
    }
    
    func updateDataSnapshots(with orderBook: OrderBook) {
        let bidModels = orderBook.bids.map {
            OrderBookCellViewModel(price: $0.price, pricePrecision: pricePrecision, amount: $0.amount)
        }
        var bidSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        bidSnapshot.appendSections([0])
        bidSnapshot.appendItems(bidModels)
        bidDataSnapshot = bidSnapshot
//        Log.message("Bid Offer Models: \(bidModels)", level: .info, type: .orderBookViewModel)
        
        let askModels = orderBook.asks.map {
            OrderBookCellViewModel(price: $0.price, pricePrecision: pricePrecision, amount: $0.amount)
        }
        var askSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        askSnapshot.appendSections([0])
        askSnapshot.appendItems(askModels)
        askDataSnapshot = askSnapshot
//        Log.message("Ask Offer Models: \(askModels)", level: .info, type: .orderBookViewModel)
    }
    
    func updateDataSnapshots(with orderBookDiff: OrderBookDiff) {
        let bidModels = orderBookDiff.bids.map {
            OrderBookCellViewModel(price: $0.price, pricePrecision: pricePrecision, amount: $0.amount)
        }
        var bidSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        bidSnapshot.appendSections([0])
        bidSnapshot.appendItems(bidModels)
        bidDataSnapshot = bidSnapshot
        
        let askModels = orderBookDiff.asks.map {
            OrderBookCellViewModel(price: $0.price, pricePrecision: pricePrecision, amount: $0.amount)
        }
        var askSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        askSnapshot.appendSections([0])
        askSnapshot.appendItems(askModels)
        askDataSnapshot = askSnapshot
    }
}
