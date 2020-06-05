//
//  MarketPair.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct MarketPair {
    
    let from: String
    let to: String
    
    var description: String {
        "\(from) / \(to)"
    }
}

extension MarketPair {
    
    init?(from: String?, to: String?)  {
        guard let from = from, let to = to else { return nil }
        self.from = from
        self.to = to
    }
}
