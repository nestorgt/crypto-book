//
//  MarketHistoryViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

final class MarketHistoryViewController: UIViewController, ChildPageViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: MarketHistoryViewModel
    
    private var tradeDataSource: UITableViewDiffableDataSource<Int, MarketHistoryCellViewModel>?
    private let loadingView = LoadingView.standard
    
    private var cancelables = Set<AnyCancellable>()
    
    init(viewModel: MarketHistoryViewModel) {
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

private extension MarketHistoryViewController {
    
    func setupViews() {
        tableView.separatorStyle = .none
        tableView.rowHeight = Metrics.cellHeights
        tableView.register(MarketHistoryCell.self, forCellReuseIdentifier: MarketHistoryCell.identifier)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = MarketHistoryHeaderView(
            leftTitle: viewModel.timeText,
            midTitle: viewModel.priceText,
            rightTitle: viewModel.quantityText
        )
        tableView.tableFooterView = UIView()
        view.addFillingSubview(tableView)
    }
    
    func setupViewModel() {
        $isActive
            .dropFirst()
            .sink { [weak self] in
                $0 ? self?.viewModel.startLiveUpdates()
                    : self?.viewModel.pauseLiveUpdates() }
            .store(in: &cancelables)
        
        viewModel.$isLoading
            .combineLatest($isActive)
            .drop(while: { $0.1 == false })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                $0.0 ? _ = self?.loadingView.present(in: self?.view)
                    : self?.loadingView.dismiss() }
            .store(in: &cancelables)
    }
    
    func setupDataSources() {
        tradeDataSource = UITableViewDiffableDataSource<Int, MarketHistoryCellViewModel>(tableView: tableView)
        { tableView, indexPath, cellViewModel in
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: MarketHistoryCell.identifier) as? MarketHistoryCell
                else { return UITableViewCell() }
            cell.setup(with: cellViewModel)
            return cell
        }
        
        tableView.dataSource = tradeDataSource
        
        viewModel.$tradesSnapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                guard let snapshot = snapshot else { return }
                self?.tradeDataSource?.apply(snapshot, animatingDifferences: false, completion: nil) }
            .store(in: &cancelables)
    }
}
