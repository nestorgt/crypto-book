//
//  ReachabilityService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 08/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

protocol ReachabilityServiceProtocol {

    /// Returns bool event with the current reachability state
    var isReachablePublisher: CurrentValueSubject<Bool, Never> { get }
}

final class ReachabilityService: ReachabilityServiceProtocol {

    private let reachability = Reachability()

    let isReachablePublisher = CurrentValueSubject<Bool, Never>(true)

    init() {
        reachability?.whenReachable = { [weak self] reachability in
            Log.message("Internet is reachable", level: .info, type: .reachabilty)
            self?.isReachablePublisher.value = true
        }

        reachability?.whenUnreachable = { [weak self] reachability in
            Log.message("Internet is NOT reachable", level: .info, type: .reachabilty)
            self?.isReachablePublisher.value = false
        }

        do {
            try reachability?.startNotifier()
        } catch let error {
            Log.message("Can't start notifier: \(error)", level: .error, type: .reachabilty)
        }
    }
}
