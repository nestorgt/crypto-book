//
//  DevMenuViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

class DevMenuViewController: UITableViewController {

    enum Sections: Int {
        case start
        case marketDetails
        case components
    }
    
    enum Components: Int {
        case pageViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else { return  }
        switch section {
        case .start:
            navigationController?.pushViewController(MarketDetailViewController(), animated: true)
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

