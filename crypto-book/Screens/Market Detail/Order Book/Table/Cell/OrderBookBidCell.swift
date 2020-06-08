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
        super.setup(with: viewModel)
        
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
        
        stackView.anchor(left: contentView.leftAnchor, leftMargin: OrderBookCell.bigMargin,
                         right: contentView.rightAnchor, rightMargin: OrderBookCell.standardMargin)
    }
}