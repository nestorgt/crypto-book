//
//  WebSocketServiceDelegate.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

protocol WebSocketServiceDelegate: class {
    
    /// Tells the delegate that the WebSocket task successfully negotiated the handshake with the endpoint, indicating the negotiated protocol.
    /// - Parameter handshakeProtocol: The protocol picked during the handshake phase. This parameter is nil if the server did not pick a protocol,
    ///                                or if the client did not advertise protocols when creating the task.
    func didOpen(handshakeProtocol: String?)
    
    /// Tells the delegate that the WebSocket task received a close frame from the server endpoint, optionally including a close code and reason from the server.
    /// - Parameters:
    ///   - closeCode: The close code provided by the server. If the close frame didn’t include a close code, this value is nil.
    ///   - reason: The close reason provided by the server. If the close frame didn’t include a reason, this value is nil.
    func didClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    
    /// Returns a WebSocket message once all the frames of the message are available.
    /// - Parameter message: The WebSocket message received.
    func didReceive(message: URLSessionWebSocketTask.Message)
    
    /// Returns an error that indicates an error encountered while receiving the message
    /// - Parameter error: The WebSocket error received.
    func didReceive(error: Error)
}
