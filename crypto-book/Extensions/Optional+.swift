//
//  Optional+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension Optional where Wrapped: CustomStringConvertible {

    /// A short and readable description of this optional's value, or "nil" if the optional has no value.
    var unwrappedDescription: String {
        guard case let .some(value) = self else { return "nil" }
        return value.description
    }
}
