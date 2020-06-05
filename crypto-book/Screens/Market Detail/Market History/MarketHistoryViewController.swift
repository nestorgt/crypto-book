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

    private let viewModel: MarketHistoryViewModel
    
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
    }
    
    // MARK: - ChildPageViewController
    
    @Published var isActive: Bool = false
}
