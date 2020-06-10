//
//  OrderBookHeaderView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class OrderBookHeaderView: UIView {
    
    private let label = UILabel()
    private let type: OrderBookTableType
    
    init(type: OrderBookTableType) {
        self.type = type
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: Metrics.cellHeights))
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension OrderBookHeaderView {
    
    func setupViews() {
        backgroundColor = .binanceBackground
        
        label.textColor = UIColor.binanceGray2
        label.font = .binanceTableHeader
        label.text = type.title
        
        addSubviewForAutoLayout(label)
        label.anchor(top: topAnchor,
                     bottom: bottomAnchor,
                     right: rightAnchor,
                     priority: .defaultHigh)
        
        switch type {
        case .ask:
            label.anchor(left: leftAnchor,
                         leftMargin: Metrics.smallMargin,
                         priority: .defaultHigh)
        case .bid:
            label.anchor(left: leftAnchor,
                         leftMargin: Metrics.margin,
                         priority: .defaultHigh)
        }
    }
}
