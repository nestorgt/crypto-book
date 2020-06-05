//
//  ChildPageViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

/// Protocol to be conformed by each view controller inside the PageViewController
protocol ChildPageViewController: UIViewController {
    
    /// Return true if the current page selected is this child page view controller
    /// - Important: Default value should be `false`.
    var isActive: Bool { get set }
}
