//
//  MarketHistoryHeaderView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class MarketHistoryHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let leftLabel = UILabel()
    private let midLabel = UILabel()
    private let rightLabel = UILabel()
    
    init(leftTitle: String, midTitle: String, rightTitle: String) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: Metrics.cellHeights))
        setupViews(leftTitle: leftTitle, midTitle: midTitle, rightTitle: rightTitle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension MarketHistoryHeaderView {

    func setupViews(leftTitle: String, midTitle: String, rightTitle: String) {
        backgroundColor = .binanceBackground
        leftLabel.text = leftTitle
        midLabel.text = midTitle
        rightLabel.text = rightTitle
        let labels = [leftLabel, midLabel, rightLabel]
        labels.forEach {
            $0.font = .binanceTableHeader
            $0.textColor = UIColor.binanceGray2
            stackView.addArrangedSubview($0)
        }
        rightLabel.textAlignment = .right
        
        stackView.distribution = .fillEqually
        stackView.spacing = MarketHistoryCell.spacing
        
        addSubviewForAutoLayout(stackView)
        let left = stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin)
        left.priority = .defaultLow
        let right = stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.margin)
        right.priority = .defaultLow
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            left, right
        ])
    }
}
