//
//  OrderBookBidCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class OrderBookBidCell: OrderBookCell {

    static let identifier = "bid-cell-identifier"
    
    override func setup(with viewModel: OrderBookCellViewModel) {
        leftLabel.text = viewModel.amountString
        rightLabel.text = viewModel.priceString
        
        super.setup(with: viewModel)
    }
    
    override func setupViews() {
        super.setupViews()
        
        let type = OrderBookTableType.bid
        leftLabel.textColor = type.amountLabelColor
        rightLabel.textColor = type.priceLabelColor
        progressView.backgroundColor = type.backgroundProgressColor
        
        stackView.anchor(left: contentView.leftAnchor, leftMargin: OrderBookCell.bigMargin,
                         right: contentView.rightAnchor, rightMargin: OrderBookCell.standardMargin)
        
        progressViewConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0)
        progressViewConstraint?.isActive = true
        progressView.anchor(right: contentView.rightAnchor)
    }
}
