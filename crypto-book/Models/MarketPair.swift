//
//  MarketPair.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Model representing a pair of currencies such as `BNB` & `BTC`.
struct MarketPair {
    
    let from: String
    let to: String
    
    var apiSymbol: String {
        "\(from)\(to)".uppercased()
    }
    
    var webScoketSymbol: String {
        "\(from)\(to)".lowercased()
    }
    
    var description: String {
        "\(from.uppercased()) / \(to.uppercased())"
    }
}

extension MarketPair {
    
    init?(from: String?, to: String?)  {
        guard let from = from, let to = to else { return nil }
        self.from = from
        self.to = to
    }
}
