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
        setupViewModel()
    }
    
    // MARK: - ChildPageViewController
    
    @Published var isActive: Bool = false
}

// MARK: - UITableViewDataSource

extension MarketHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: MarketHistoryCell.identifier) as? MarketHistoryCell
            else { return UITableViewCell() }
        cell.setup(with: viewModel.cellViewModels?[safe: indexPath.row])
        return cell
    }
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
        tableView.dataSource = self
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
        
        viewModel.$cellViewModels
            .throttle(for: .milliseconds(viewModel.updateSpeed.milliseconds),
                      scheduler: DispatchQueue.global(qos: .background),
                      latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData() }
            .store(in: &cancelables)
    }
}
