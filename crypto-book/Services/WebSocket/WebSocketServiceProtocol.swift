//
//  WebSocketServiceProtocol.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

/// Provides configuration parameters required to perform a connection with the WebSocketService.
struct WebSocketServiceConfiguration {
    
    /// The URL of the WebSocket
    let url: URL
    
    /// Specifies the quality of service for the delegate queue of the the URL Serssion
    let queueQualityOfService: QualityOfService
    
    /// When assigned, it wil send a ping to the server every amount of second specified
    var pingTimeInterval: TimeInterval?
}

/// Generic web socket service that allows openion and data flow to any given webSocket url.
/// - seeAlso: https://binance-docs.github.io/apidocs/spot/en/#webSocket-market-streams
protocol WebSocketServiceProtocol {

    /// Sets up everything needed to start receiving/sending information.
    /// - Note: **This method should be called first**.
    /// - Parameters:
    ///     - configuration: The configration for the WebSocket.
    ///     - delegate: The entity that will receive WebSocketService delegate methods.
    func setup(with configuration: WebSocketServiceConfiguration, delegate: WebSocketServiceDelegate?)
    
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
