//
//  APIError.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Possible API errors returned by the API Service.
/// A generic one was added for any unhandled error.
enum APIError: Error, Equatable {
    case badRequest
    case notFound
    case generic(message: String?)
    
    static func error(from httpCode: Int) -> APIError? {
        guard httpCode != 200 else { return nil }
        switch httpCode {
        case 400:
            return .badRequest
        case 404:
            return .notFound
        default:
            return .generic(message: "\(httpCode)")
        }
    }
    
    var errorMessage: String {
        return NSLocalizedString("api-error-generic")
    }
}
