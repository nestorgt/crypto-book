//
//  DevMenuViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuViewController: UITableViewController {
    
    @IBOutlet weak var fromMarketPairTextField: UITextField!
    @IBOutlet weak var toMarketPairTextField: UITextField!
    @IBOutlet weak var depthLimitTextField: UITextField!
    @IBOutlet weak var aggLimitTextField: UITextField!
    @IBOutlet weak var updateSpeedSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else { return  }
        switch section {
        case .start:
            guard let marketPair = marketPair, let updateSpeed = updateSpeed, let limit = depthLimit else { return }
            let vc = MarketDetailViewController(
                viewModel: MarketDetailViewModel(marketPair: marketPair),
                orderBookViewModel: OrderBookViewModel(marketPair: marketPair,
                                                       limit: limit,
                                                       updateSpeed: updateSpeed),
                marketHistoryViewModel: MarketHistoryViewModel(marketPair: marketPair)
            )
            navigationController?.pushViewController(vc, animated: true)
        case .marketDetails:
            break
        case .components:
            guard let component = Components(rawValue: indexPath.row) else { return }
            switch component {
            case .pageViewController:
                navigationController?.pushViewController(DevMenuPageViewController(), animated: true)
            case .loadingView:
                navigationController?.pushViewController(DevMenuLoadingView(), animated: true)
            }
        }
    }
}

// MARK: - Enums

extension DevMenuViewController {
    
    enum Sections: Int {
        case start
        case marketDetails
        case components
    }
    
    enum Components: Int {
        case pageViewController
        case loadingView
    }
}

// MARK: - Private

private extension DevMenuViewController {
    
    var marketPair: MarketPair? {
        MarketPair(from: fromMarketPairTextField.text, to: toMarketPairTextField.text)
    }
    
    var updateSpeed: BinanceWSRouter.UpdateSpeed? {
        updateSpeedSegmented.selectedSegmentIndex == 0 ? .hundred : .thousand
    }
    
    var depthLimit: UInt? {
        guard let text = depthLimitTextField.text else { return nil }
        return UInt(text)
    }
    
    var aggLimit: UInt? {
        guard let text = aggLimitTextField.text else { return nil }
        return UInt(text)
    }
}
