//
//  DependencyInjector.swift
//  crypto-book
//
//  Created by Nestor Garcia on 05/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Quick accessor to DependencyInjector
let DI = DependencyInjector.shared

/// Dependency injector to share common components across the App.
protocol DependencyInjectorProtocol {
    
    var orderBookService: OrderBookServiceProtocol { get }
}

final class DependencyInjector: DependencyInjectorProtocol {
    
    static let shared = DependencyInjector() // singleton

    lazy var orderBookService: OrderBookServiceProtocol = OrderBookService()
        
    private init() { }
}
