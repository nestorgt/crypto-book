//
//  MarketHistoryCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

class MarketHistoryCell: UITableViewCell {
    
    static let identifier = "market-history-cell-identifier"
    
    static let spacing: CGFloat = 30
    
    private let stackView = UIStackView()
    private let leftLabel = UILabel()
    private let midLabel = UILabel()
    private let rightLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: MarketHistoryCellViewModel?) {
        guard let viewModel = viewModel else { return }
        leftLabel.text = viewModel.timeString
        midLabel.textColor = viewModel.priceTextColor
        midLabel.text = viewModel.priceString
        rightLabel.text = viewModel.amountString
    }
    
    func setupViews() {
        let labels = [leftLabel, midLabel, rightLabel]
        labels.forEach {
            $0.font = .binanceTableCell
            stackView.addArrangedSubview($0)
        }
        rightLabel.textAlignment = .right
        
        stackView.distribution = .fillEqually
        stackView.spacing = Self.spacing

        contentView.addSubviewForAutoLayout(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.margin)
        ])
    }
}
