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
    
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         orderBookService: OrderBookServiceProtocol = DI.orderBookService) {
        self.marketPair = marketPair
        self.orderBookService = orderBookService
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBook)
        orderBookService.orderBook()
            .sink(receiveCompletion: { status in
                Log.message("Fetch \(status)", level: .error, type: .orderBook)
            }, receiveValue: { [weak self] orderBook in
                Log.message("Received Order Book: \(orderBook)", level: .debug, type: .orderBook)
                self?.updateDataSnapshots(with: orderBook)
            })
            .store(in: &cancelables)
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .debug, type: .orderBook)
    }
}

private extension OrderBookViewModel {
    
    func updateDataSnapshots(with orderBook: OrderBook) {
        let bidModels = orderBook.bids.map { OrderBookCellViewModel(price: $0.price, pricePrecision: 2, amount: $0.amount) }
        var bidSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        bidSnapshot.appendSections([0])
        bidSnapshot.appendItems(bidModels)
        bidDataSnapshot = bidSnapshot
        Log.message("Bid Offer Models: \(bidModels)", level: .info, type: .orderBook)
        
        let askModels = orderBook.asks.map { OrderBookCellViewModel(price: $0.price, pricePrecision: 2, amount: $0.amount) }
        var askSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        askSnapshot.appendSections([0])
        askSnapshot.appendItems(askModels)
        askDataSnapshot = askSnapshot
        Log.message("Ask Offer Models: \(askModels)", level: .info, type: .orderBook)
    }
}
