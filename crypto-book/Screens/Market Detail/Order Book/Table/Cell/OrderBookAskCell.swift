//
//  OrderBookAskCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class OrderBookAskCell: OrderBookCell {

    static let identifier = "ask-cell-identifier"
    
    override func setup(with viewModel: OrderBookCellViewModel) {
        leftLabel.text = viewModel.priceString
        rightLabel.text = viewModel.amountString
        
        super.setup(with: viewModel)
    }
    
    override func setupViews() {
        super.setupViews()
        
        let type = OrderBookTableType.ask
        leftLabel.textColor = type.priceLabelColor
        rightLabel.textColor = type.amountLabelColor
        progressView.backgroundColor = type.backgroundProgressColor
        
        stackView.anchor(left: contentView.leftAnchor, leftMargin: OrderBookCell.standardMargin,
                         right: contentView.rightAnchor, rightMargin: OrderBookCell.bigMargin)
        
        progressViewConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0)
        progressViewConstraint?.isActive = true
        progressView.anchor(left: contentView.leftAnchor)
    }
}
