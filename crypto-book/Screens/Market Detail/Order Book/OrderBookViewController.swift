//
//  OrderBookViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

final class OrderBookViewController: UIViewController, ChildPageViewController {

    static let marginBetweenTables: CGFloat = 1
    
    private let viewModel: OrderBookViewModel
    
    private let bidTableView = OrderBookTableView(type: .bid)
    private let askTableView = OrderBookTableView(type: .ask)
    private var bidDataSource: UITableViewDiffableDataSource<Int, OrderBookCellViewModel>?
    private var askDataSource: UITableViewDiffableDataSource<Int, OrderBookCellViewModel>?
    
    private var cancelables = Set<AnyCancellable>()
    
    init(viewModel: OrderBookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.screenTitle
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDataSources()
        setupViewModel()
    }
    
    // MARK: - ChildPageViewController
    
    @Published var isActive: Bool = false
}

// MARK: - Private

private extension OrderBookViewController {
    
    func setupViews() {
        let tables = [bidTableView, askTableView]
        tables.forEach {
            $0.isScrollEnabled = false
            $0.tableFooterView = UIView()
        }
        view.addSubviewsForAutoLayout(tables)
        bidTableView.anchor(top: view.topAnchor,
                            bottom: view.bottomAnchor,
                            left: view.leftAnchor)
        bidTableView.anchor(width: askTableView.widthAnchor)
        askTableView.anchor(top: view.topAnchor,
                            bottom: view.bottomAnchor,
                            right: view.rightAnchor)
        bidTableView.anchor(widthConstant: (view.frame.width / 2) - Self.marginBetweenTables)
    }
    
    func setupViewModel() {
        $isActive
            .dropFirst()
            .sink { [weak self] in
                $0 ? self?.viewModel.startLiveUpdates() : self?.viewModel.stopLiveUpdates() }
            .store(in: &cancelables)
    }
    
    func setupDataSources() {
        bidDataSource = UITableViewDiffableDataSource<Int, OrderBookCellViewModel>(tableView: bidTableView)
        { tableView, indexPath, cellViewModel in  
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: OrderBookBidCell.identifier) as? OrderBookBidCell
                else { return UITableViewCell() }
            cell.setup(with: cellViewModel)
            return cell
        }
        askDataSource = UITableViewDiffableDataSource<Int, OrderBookCellViewModel>(tableView: askTableView)
        { tableView, indexPath, cellViewModel in
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: OrderBookAskCell.identifier) as? OrderBookAskCell
                else { return UITableViewCell() }
            cell.setup(with: cellViewModel)
            return cell
        }
        
        bidTableView.dataSource = bidDataSource
        askTableView.dataSource = askDataSource
        
        viewModel
            .$bidDataSnapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                guard let snapshot = snapshot else { return }
                self?.bidDataSource?.apply(snapshot, animatingDifferences: false, completion: nil) }
            .store(in: &cancelables)
        
        viewModel
            .$askDataSnapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                guard let snapshot = snapshot else { return }
                self?.askDataSource?.apply(snapshot, animatingDifferences: false, completion: nil) }
            .store(in: &cancelables)
    }
}
