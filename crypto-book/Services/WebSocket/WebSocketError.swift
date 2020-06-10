//
//  WebSocketError.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Possible WebSocket errors returned by the WebSocket Service.
enum WebSocketError: Error, Equatable {
    case generic(message: String)
}
