//
//  ChildPageViewControllerMock.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class ChildPageViewControllerMock: UIViewController, ChildPageViewController {
    
    var isActive: Bool = false {
        didSet { Log.message("\(title ?? "") isActive: \(isActive)", level: .debug, type: .devMenu) }
    }
    
    func willBecomeActive() {
        Log.message("\(title ?? "") willBecomeActive", level: .debug, type: .devMenu)
    }
    
    func willResignActive() {
        Log.message("\(title ?? "") willResignActive", level: .debug, type: .devMenu)
    }
}
