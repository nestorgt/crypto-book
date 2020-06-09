//
//  WebSocketServiceProtocol.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Generic web socket service that allows openion and data flow to any given webSocket url.
/// - seeAlso: https://binance-docs.github.io/apidocs/spot/en/#webSocket-market-streams
protocol WebSocketServiceProtocol {

    /// The entity to receive delegate calls.
    var delegate: WebSocketServiceDelegate? { get set }
    
    /// Opens the WebSocket connection with the given URL. 
    func open(with url: URL)
    
    /// Closes the WebSocket connection. Also calls `cancel()`.
    func close()
    
    /// `close()` + `open()` with previous url used + `resume()`.
    func restart()
    
    /// Resumes the WebSocket connection.
    func resume()
    
    /// Suspends the WebSocket connection temporary.
    func suspend()
    
    /// Cancels the WebSocket connection.
    func cancel()
    
    /// Sends a WebSocket message, receiving the result in a completion handler.
    /// - Parameters:
    ///     - message: The WebSocket message to send to the other endpoint.
    ///     - completionHandler: A closure that receives an NSError that indicates an error encountered while sending, or nil if no error occurred.
    func send(message: URLSessionWebSocketTask.Message, completionHandler: ((Error?) -> Void)?)
}
