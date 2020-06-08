//
//  OrderBookTableView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class OrderBookTableView: UITableView {
    
    static var numberOfCells: Int = 20
    
    private var type: OrderBookTableType

    var cellDataSource: UITableViewDiffableDataSource<Double, OrderBookCellViewModel>?
    
    init(type: OrderBookTableType) {
        self.type = type
        super.init(frame: .zero, style: .plain)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource

extension OrderBookTableView {

    override var numberOfSections: Int {
        1
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        Self.numberOfCells
    }
}

// MARK: - Private

private extension OrderBookTableView {
    
    func setup() {
        separatorStyle = .none
        rowHeight = OrderBookCell.height
        register(type.cellClass, forCellReuseIdentifier: type.cellIdentifier)
        allowsSelection = false
        tableHeaderView = OrderBookHeaderView(type: type)
    }
}
