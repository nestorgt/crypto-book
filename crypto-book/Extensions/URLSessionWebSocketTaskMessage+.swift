//
//  URLSessionWebSocketTaskMessage+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension URLSessionWebSocketTask.Message {
    
    var string: String? {
        if case .string(let string) = self {
            return string
        }
        return nil
    }
    
    var data: Data? {
        if case .data(let data) = self {
            return data
        }
        return nil
    }
}
