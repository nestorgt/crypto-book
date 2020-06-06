//
//  OrderBookCell.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

class OrderBookCell: UITableViewCell {
    
    static let height: CGFloat = 26
    static let standardMargin: CGFloat = 2
    static let bigMargin: CGFloat = 8
    
    let stackView = UIStackView()
    let progressView = UIView()
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    
    var progressViewConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: OrderBookCellViewModel) {
        setNeedsLayout()
        layoutIfNeeded()
        
        progressViewConstraint?.isActive = false
        progressViewConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                     multiplier: CGFloat(viewModel.progress))
        progressViewConstraint?.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    func setupViews() {
        leftLabel.font = .binanceTableCell
        rightLabel.textAlignment = .right
        rightLabel.font = .binanceTableCell
        
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        contentView.addSubviewsForAutoLayout([progressView, stackView])
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
        stackView.anchor(top: contentView.topAnchor,
                         bottom: contentView.bottomAnchor)
        
        progressView.anchor(top: contentView.topAnchor,
                            bottom: contentView.bottomAnchor)
    }
}
