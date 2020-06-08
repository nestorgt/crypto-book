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
    @Published var isLoading: Bool = false

    var screenTitle: String { NSLocalizedString("page-menu-order-book-title") }
    
    var pricePrecision: Int {
        4
    }
    
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair) {
        self.marketPair = marketPair
        self.orderBookService = OrderBookService(marketPair: marketPair)
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBookViewModel)
        orderBookService.resumeLiveUpdates()
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
        isLoading = true
        orderBookService.orderBookPublisher
            .sink(receiveCompletion: { orderBookError in
                Log.message("Commpleted, error?: \(orderBookError)",
                    level: .debug, type: .orderBookViewModel)
            }, receiveValue: { [weak self] orderBook in
                Log.message("OrderBook.lastUpdateId: \(orderBook?.lastUpdateId ?? 0)",
                    level: .debug, type: .orderBookViewModel)
                self?.updateDataSnapshots(with: orderBook)
            })
            .store(in: &cancelables)
    }
    
    func updateDataSnapshots(with orderBook: OrderBook?) {
        guard let orderBook = orderBook else { return }
        let numberOfElements = OrderBookTableView.numberOfCells
        let maxMinData = orderBook.maxMinData(prefixElements: numberOfElements)
        
        let bidModels = orderBook.bids.prefix(numberOfElements).map { bid -> OrderBookCellViewModel in
            let progress = OrderBook.bidWeight(for: bid.amount, with: maxMinData)
            return OrderBookCellViewModel(price: bid.price,
                                   pricePrecision: pricePrecision,
                                   amount: bid.amount,
                                   progress: progress)
        }
        var bidSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        bidSnapshot.appendSections([0])
        bidSnapshot.appendItems(bidModels)

        let askModels = orderBook.asks.prefix(numberOfElements).map { ask -> OrderBookCellViewModel in
            let progress = OrderBook.askWeight(for: ask.amount, with: maxMinData)
            return OrderBookCellViewModel(price: ask.price,
                                   pricePrecision: pricePrecision,
                                   amount: ask.amount,
                                   progress: progress)
        }
        var askSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        askSnapshot.appendSections([0])
        askSnapshot.appendItems(askModels)
        
        isLoading = false
        bidDataSnapshot = bidSnapshot
        askDataSnapshot = askSnapshot
    }
}
