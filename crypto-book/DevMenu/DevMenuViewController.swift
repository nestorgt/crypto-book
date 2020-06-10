//
//  DevMenuViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuViewController: UITableViewController {
    
    static var uiThrottle: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
    
    @IBOutlet weak var fromMarketPairTextField: UITextField!
    @IBOutlet weak var toMarketPairTextField: UITextField!
    @IBOutlet weak var depthLimitTextField: UITextField!
    @IBOutlet weak var aggLimitTextField: UITextField!
    @IBOutlet weak var updateSpeedSegmented: UISegmentedControl!
    @IBOutlet weak var uiThrottleSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else { return  }
        switch section {
        case .start:
            guard let marketPair = marketPair,
                let updateSpeed = updateSpeed,
                let depthLimit = depthLimit,
                let aggLimit = aggLimit else { return }
            let vc = MarketDetailViewController(
                viewModel: MarketDetailViewModel(marketPair: marketPair),
                orderBookViewModel: OrderBookViewModel(marketPair: marketPair,
                                                       limit: depthLimit,
                                                       updateSpeed: updateSpeed),
                marketHistoryViewModel: MarketHistoryViewModel(marketPair: marketPair,
                                                               limit: aggLimit,
                                                               updateSpeed: updateSpeed)
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
    @IBAction func uiThrottleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: Self.uiThrottle = .zero
        case 1: Self.uiThrottle = .milliseconds(250)
        case 2: Self.uiThrottle = .milliseconds(500)
        case 3: Self.uiThrottle = .milliseconds(1000)
        default: Self.uiThrottle = .milliseconds(500)
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
