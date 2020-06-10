//
//  WebSocketService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

/// Generic web socket service that allows openion and data flow to any given webSocket url.
/// - seeAlso: https://binance-docs.github.io/apidocs/spot/en/#webSocket-market-streams
protocol WebSocketServiceProtocol {

    /// The entity to receive delegate calls.
    var delegate: WebSocketServiceDelegate? { get set }
    
    /// Sets up the WebSocket connection with the given URL.
    func setup(with url: URL)
    
    /// Shuts down the WebSocket connection. Also calls `cancel()`.
    func shutdown()
    
    /// `shutdown()` + `setup()` with previous url used + `resume()`.
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

final class WebSocketService: NSObject, URLSessionWebSocketDelegate, WebSocketServiceProtocol {
    
    static let pingTimeInterval: TimeInterval = 60
    
    weak var delegate: WebSocketServiceDelegate?
    
    private var url: URL?
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var queue = OperationQueue()
    private var pingCancelable: AnyCancellable?
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        delegate?.didOpen(handshakeProtocol: `protocol`)
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        delegate?.didClose(closeCode: closeCode, reason: reason)
    }
    
    // MARK: - WebSocketServiceProtocol
    
    func setup(with url: URL) {
        Log.message("Opening with url: \(url.absoluteString)", level: .info, type: .websocket)
        self.url = url
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        webSocketTask = urlSession?.webSocketTask(with: url)
        readMessage()
    }
    
    func shutdown() {
        Log.message("closing...", level: .info, type: .websocket)
        pingCancelable?.cancel()
        cancel()
        urlSession?.finishTasksAndInvalidate()
        queue.cancelAllOperations()
    }
    
    func restart() {
        guard let url = url else { return }
        Log.message("restarting...", level: .info, type: .websocket)
        shutdown()
        setup(with: url)
        resume()
    }
    
    func resume() {
        Log.message("resuming...", level: .info, type: .websocket)
        webSocketTask?.resume()
        schedulePing()
    }
    
    func suspend() {
        Log.message("suspending...", level: .info, type: .websocket)
        webSocketTask?.suspend()
        queue.cancelAllOperations()
    }
    
    func cancel() {
        Log.message("cancelling...", level: .info, type: .websocket)
        webSocketTask?.cancel(with: .goingAway, reason: "Closing manually.".data(using: .utf8))
    }
    
    func send(message: URLSessionWebSocketTask.Message, completionHandler: ((Error?) -> Void)?) {
        webSocketTask?.send(message) { error in
            Log.message("Can't send message: \(message) due to error: \(String(describing: error))",
                level: .error, type: .websocket)
            completionHandler?(error)
        }
    }
}

// MARK: - Private

private extension WebSocketService {
    
    func schedulePing() {
        Log.message("Scheduled ping every \(Self.pingTimeInterval)s", level: .info, type: .websocket)
        pingCancelable?.cancel()
        pingCancelable = Timer.publish(every: Self.pingTimeInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sendPing()
        }
    }
    
    func sendPing() {
        Log.message("Sending ping...", level: .info, type: .websocket)
        webSocketTask?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                Log.message("Error sending Ping error: \(String(describing: error))",
                    level: .error, type: .websocket)
            } else {
                Log.message("Ping Success", level: .info, type: .websocket)
            }
        })
    }
    
    func readMessage()  {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                Log.message("receive error: \(String(describing: error))", level: .error, type: .websocket)
                self?.delegate?.didReceive(error: error)
            case .success(let message):
                self?.delegate?.didReceive(message: message)
                // Be aware that if you want to receive messages continuously you need
                // to call this again once you are done with receiving a message.
                self?.readMessage()
            }
        }
    }
}
