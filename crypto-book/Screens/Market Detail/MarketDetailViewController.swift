//
//  MarketDetailViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 04/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

final class MarketDetailViewController: UIViewController {
    
    private enum Pages: Int {
        case orderBook
        case marketHistory
    }
    
    private let viewModel: MarketDetailViewModel
    
    private var pageViewController: PageViewController
    private let orderBookViewModel: OrderBookViewModel
    private let marketHistoryViewModel: MarketHistoryViewModel
    
    private var cancelables = Set<AnyCancellable>()
    
    init(viewModel: MarketDetailViewModel,
         orderBookViewModel: OrderBookViewModel,
         marketHistoryViewModel: MarketHistoryViewModel) {
        self.viewModel = viewModel
        self.orderBookViewModel = orderBookViewModel
        self.marketHistoryViewModel = marketHistoryViewModel
        let orderBookVC = OrderBookViewController(viewModel: orderBookViewModel)
        let marketHistoryVC = MarketHistoryViewController(viewModel: marketHistoryViewModel)
        pageViewController = PageViewController(childPages: [orderBookVC, marketHistoryVC])
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupPageViewController()
        setupPageViewModels()
    }
}

// MARK: - Private

private extension MarketDetailViewController {
    
    func setupNavigationBar() {
        viewModel
            .$marketPair
            .sink { [weak self] marketPair in
                self?.title = marketPair.description }
            .store(in: &cancelables)
    }
    
    func setupPageViewController() {
        addChild(pageViewController)
        view.addSafeFillingSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    func setupPageViewModels() {
        viewModel
            .$marketPair
            .assign(to: \.marketPair, on: orderBookViewModel)
            .store(in: &cancelables)
        
        viewModel
            .$marketPair
            .assign(to: \.marketPair, on: marketHistoryViewModel)
            .store(in: &cancelables)
    }
}
