//
//  OrderBookTableType.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

enum OrderBookTableType {
    case bid
    case ask
    
    var title: String {
        NSLocalizedString("\(self)-title")
    }
    
    var amountLabelColor: UIColor {
        UIColor.label.withAlphaComponent(0.8)
    }
    
    var priceLabelColor: UIColor {
        switch self {
        case .bid:
            return .binanceBid
        case .ask:
            return .binanceAsk
        }
    }
    
    var backgroundProgressColor: UIColor {
        switch self {
        case .bid:
            return .binanceBidBackground
        case .ask:
            return .binanceAskBackground
        }
    }
    
    var cellClass: AnyClass {
        switch self {
        case .bid:
            return OrderBookBidCell.self
        case .ask:
            return OrderBookAskCell.self
        }
    }
    
    var cellIdentifier: String {
        switch self {
        case .bid:
            return OrderBookBidCell.identifier
        case .ask:
            return OrderBookAskCell.identifier
        }
    }
}
