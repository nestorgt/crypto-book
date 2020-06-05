//
//  DevMenuViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuViewController: UITableViewController {
    
    @IBOutlet var fromMarketPairTextField: UITextField!
    @IBOutlet var toMarketPairTextField: UITextField!
    @IBOutlet weak var depthLimitTextField: UITextField!
    @IBOutlet weak var aggLimitTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else { return  }
        switch section {
        case .start:
            guard let marketPair = MarketPair(from: fromMarketPairTextField.text,
                                              to: toMarketPairTextField.text)
                else { return }
            let vc = MarketDetailViewController(viewModel: MarketDetailViewModel(marketPair: marketPair),
                                                orderBookViewModel: OrderBookViewModel(marketPair: marketPair),
                                                marketHistoryViewModel: MarketHistoryViewModel(marketPair: marketPair))
            navigationController?.pushViewController(vc, animated: true)
        case .marketDetails:
            break
        case .components:
            guard let component = Components(rawValue: indexPath.row) else { return }
            switch component {
            case .pageViewController:
                navigationController?.pushViewController(DevMenuPageViewController(), animated: true)
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
    }
}
