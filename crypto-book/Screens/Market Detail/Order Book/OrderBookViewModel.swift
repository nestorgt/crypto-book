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
    @Published var bidDataSnapshot: NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>?
    @Published var askDataSnapshot: NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>?
    @Published var isLoading: Bool = false

    var screenTitle: String { NSLocalizedString("page-menu-order-book-title") }
    
    var pricePrecision: Int {
        4
    }
    
    private let orderBookService: OrderBookServiceProtocol
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair,
         limit: UInt,
         updateSpeed: BinanceWSRouter.UpdateSpeed) {
        self.marketPair = marketPair
        self.orderBookService = OrderBookService(marketPair: marketPair, limit: limit, updateSpeed: updateSpeed)
        setupBindings()
    }
    
    func startLiveUpdates() {
        Log.message("START Live Updates", level: .info, type: .orderBookViewModel)
        // TODO: remove
//        orderBookService.resume()
    }
    
    func pauseLiveUpdates() {
        orderBookService.suspend()
    }
    
    func stopLiveUpdates() {
        Log.message("STOP Live Updates", level: .debug, type: .orderBookViewModel)
        orderBookService.cancel()
    }
}

// MARK: - Private

private extension OrderBookViewModel {
    
    func setupBindings() {
        orderBookService.orderBookPublisher
            .sink(receiveCompletion: { error in
                Log.message("Commpleted, error?: \(error)", level: .debug, type: .orderBookViewModel)
            }, receiveValue: { [weak self] orderBook in
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
        var bidSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        bidSnapshot.appendSections([0])
        bidSnapshot.appendItems(bidModels)

        let askModels = orderBook.asks.prefix(numberOfElements).map { ask -> OrderBookCellViewModel in
            OrderBookCellViewModel(price: ask.price,
                                   pricePrecision: pricePrecision,
                                   amount: ask.amount,
                                   progress: OrderBook.askWeight(for: ask.amount, with: maxMinData))
        }
        var askSnapshot = NSDiffableDataSourceSnapshot<Int, OrderBookCellViewModel>()
        askSnapshot.appendSections([0])
        askSnapshot.appendItems(askModels)
        
        bidDataSnapshot = bidSnapshot
        askDataSnapshot = askSnapshot
    }
}
