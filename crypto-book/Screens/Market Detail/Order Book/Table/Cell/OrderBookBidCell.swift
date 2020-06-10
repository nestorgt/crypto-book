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
    
    override func setup(with viewModel: OrderBookCellViewModel?) {
        guard let viewModel = viewModel else { return }
        
        leftLabel.text = viewModel.amountString
        rightLabel.text = viewModel.priceString
        
        progressView.progress = Float(viewModel.progress)
    }
    
    override func setupViews() {
        super.setupViews()
        
        let type = OrderBookTableType.bid
        leftLabel.textColor = type.amountLabelColor
        rightLabel.textColor = type.priceLabelColor
        progressView.progressTintColor = type.backgroundProgressColor
        progressView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        stackView.anchor(left: contentView.leftAnchor, leftMargin: Metrics.margin,
                         right: contentView.rightAnchor, rightMargin: Metrics.smallMargin)
    }
}
