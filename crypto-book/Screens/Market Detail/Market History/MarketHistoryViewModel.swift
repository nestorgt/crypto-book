//
//  MarketHistoryViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

final class MarketHistoryViewModel {
    
    @Published var marketPair: MarketPair
    
    var screenTitle: String { NSLocalizedString("page-menu-market-history-title") }
    
    init(marketPair: MarketPair) {
        self.marketPair = marketPair
    }
}
