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

    private let selectorButton = SelectorButton()
    private var selectorView: SelectorView?
    private let loadingView = LoadingView.standard
    
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
        setupViewModel()
    }
    
    // MARK: - ChildPageViewController
    
    @Published var isActive: Bool = false
}

// MARK: - UITableViewDataSource

extension OrderBookViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == bidTableView {
            return viewModel.bidCellViewModels?.count ?? 0
        } else if tableView == askTableView {
            return viewModel.askCellViewModels?.count ?? 0
        } else {
             return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bidTableView {
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: OrderBookBidCell.identifier) as? OrderBookBidCell
                else { return UITableViewCell() }
            cell.setup(with: viewModel.bidCellViewModels?[safe: indexPath.row])
            return cell
        } else if tableView == askTableView {
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: OrderBookAskCell.identifier) as? OrderBookAskCell
                else { return UITableViewCell() }
            cell.setup(with: viewModel.askCellViewModels?[safe: indexPath.row])
            return cell
        } else {
             return UITableViewCell()
        }
    }
}

// MARK: - Private

private extension OrderBookViewController {
    
    func setupViews() {
        let tables = [bidTableView, askTableView]
        tables.forEach {
            $0.dataSource = self
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
        
        selectorButton.isHidden = true
        selectorButton.didPressHandler = { [weak self] in
            Log.message("Did press selector button", level: .info)
            self?.presentSelectorView()
        }
        view.addSubviewForAutoLayout(selectorButton)
        NSLayoutConstraint.activate([
            selectorButton.rightAnchor.constraint(equalTo: askTableView.rightAnchor, constant: -Metrics.margin),
            selectorButton.topAnchor.constraint(equalTo: askTableView.topAnchor, constant: Metrics.smallMargin),
            selectorButton.widthAnchor.constraint(equalToConstant: SelectorButton.width),
            selectorButton.heightAnchor.constraint(equalToConstant: SelectorButton.height)
        ])
    }
    
    func presentSelectorView() {
        guard let options = viewModel.precisionOptions,
            let selected = viewModel.precisionSelected
            else { return }
        selectorView = SelectorView()
        let config = SelectorView.Config(options: options,
                                         selectedIndex: selected,
                                         button: selectorButton)
        selectorView?.present(in: view, config: config)
        selectorView?.didSelect = { [weak self] text in
            guard let text = text, let index = Int(text) else { return }
            self?.viewModel.precisionSelected = index
            self?.selectorButton.text = text
        }
    }
    
    func setupViewModel() {
        $isActive
            .dropFirst()
            .sink { [weak self] in
                $0 ? self?.viewModel.startLiveUpdates()
                    : self?.viewModel.pauseLiveUpdates() }
            .store(in: &cancelables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                $0 ? _ = self?.loadingView.present(in: self?.view)
                    : self?.loadingView.dismiss() }
            .store(in: &cancelables)
        
        viewModel.$askCellViewModels
            .zip(viewModel.$bidCellViewModels)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Prevent rendering when scrolling
                guard self?.isActive == true else { return }
                self?.askTableView.reloadData()
                self?.bidTableView.reloadData() }
            .store(in: &cancelables)
        
        viewModel.$precisionSelected
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedIndex in
                self?.selectorButton.text = "\(selectedIndex)"
                self?.selectorButton.isHidden = false }
            .store(in: &cancelables)
    }
}
