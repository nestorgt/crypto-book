//
//  OrderBookCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

class OrderBookCell: UITableViewCell {
    
    let stackView = UIStackView()
    let progressView = UIProgressView()
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: OrderBookCellViewModel) {
        
    }
    
    func setupViews() {
        leftLabel.font = .binanceTableCell
        rightLabel.textAlignment = .right
        rightLabel.font = .binanceTableCell
        progressView.trackTintColor = .clear
        
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        contentView.addSubviewsForAutoLayout([progressView, stackView])
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
        stackView.anchor(top: contentView.topAnchor,
                         bottom: contentView.bottomAnchor)
        
        progressView.anchor(top: contentView.topAnchor,
                            bottom: contentView.bottomAnchor,
                            left: contentView.leftAnchor,
                            right: contentView.rightAnchor)
    }
}
