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
        .systemGray6
    }
    
    var priceLabelColor: UIColor {
        switch self {
        case .bid:
            return .systemGreen
        case .ask:
            return .systemRed
        }
    }
    
    var backgroundProgressColor: UIColor {
        priceLabelColor.withAlphaComponent(0.5)
    }
    
    var cellClass: AnyClass {
        switch self {
        case .bid:
            return OrderBookBidCell.self
        case .ask:
            return OrderBookBidCell.self // CHANGE
        }
    }
    
    var cellIdentifier: String {
        switch self {
        case .bid:
            return OrderBookBidCell.identifier
        case .ask:
            return OrderBookBidCell.identifier // CHANGE
        }
    }
}
