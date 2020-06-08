//
//  Result+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension Result {
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
    
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
