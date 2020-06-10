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
    
    override func setup(with viewModel: OrderBookCellViewModel?) {
        guard let viewModel = viewModel else { return }
        
        leftLabel.text = viewModel.priceString
        rightLabel.text = viewModel.amountString
        
        progressView.progress = Float(viewModel.progress)
    }
    
    override func setupViews() {
        super.setupViews()
        
        let type = OrderBookTableType.ask
        leftLabel.textColor = type.priceLabelColor
        rightLabel.textColor = type.amountLabelColor
        progressView.progressTintColor = type.backgroundProgressColor
        
        stackView.anchor(left: contentView.leftAnchor, leftMargin: Metrics.smallMargin,
                         right: contentView.rightAnchor, rightMargin: Metrics.margin)
    }
}
