//
//  OrderBookBidCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class OrderBookBidCell: UITableViewCell {

    static let identifier = "order-book-bid-cell-identifier"
    
    private let progressView = UIView()
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    
    private var progressViewConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(with viewModel: OrderBookCellViewModel) {
        leftLabel.text = viewModel.amount
            .rounding(decimals: 1)
            .toString()
//        rightLabel.text = viewModel.am
        
        progressViewConstraint?.constant = CGFloat(viewModel.progress) * contentView.frame.size.width
        UIView.animate(withDuration: 0.2) {
            self.contentView.layoutIfNeeded()
        }
    }
}

// MARK: - Private

private extension OrderBookBidCell {
    
    func setupViews() {
        let bid = OrderBookTableType.bid
        leftLabel.textColor = bid.amountLabelColor
        rightLabel.textColor = bid.priceLabelColor
        progressView.backgroundColor = bid.backgroundProgressColor
        leftLabel.font = .boldSystemFont(ofSize: 14)
        rightLabel.font = .boldSystemFont(ofSize: 14)
        
        contentView.addSubviewsForAutoLayout([progressView, leftLabel, rightLabel])
        
        progressViewConstraint = progressView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        progressViewConstraint?.isActive = true
//        progressView.anchor(top: contentView.topAnchor,
//                            bottom: contentView.bottomAnchor,
//                            right: contentView.rightAnchor)
//        leftLabel.anchor(top: contentView.topAnchor,
//                         bottom: contentView.topAnchor,
//                         left: contentView.leftAnchor,
//                         right: rightLabel.leftAnchor,
//                         width: rightLabel.widthAnchor)
//        rightLabel.anchor(top: contentView.topAnchor,
//                          bottom: contentView.topAnchor,
//                          right: contentView.rightAnchor)
    }
}
