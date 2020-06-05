//
//  MarketDetailViewModel.swift
//  crypto-book
//
//  Created by Nestor Garcia on 04/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

final class MarketDetailViewModel {

    @Published var marketPair: MarketPair
    
    private var cancelables = Set<AnyCancellable>()
    
    init(marketPair: MarketPair) {
        self.marketPair = marketPair
    }
}
