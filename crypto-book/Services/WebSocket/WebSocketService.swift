//
//  WebSocketService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import Combine

final class WebSocketService: NSObject, URLSessionWebSocketDelegate, WebSocketServiceProtocol {
    
    static let pingTimeInterval: TimeInterval = 60
    
    weak var delegate: WebSocketServiceDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
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
        Log.message("setup with url: \(url.absoluteString)", level: .info, type: .websocket)
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        webSocketTask = urlSession.webSocketTask(with: url)
        readMessage()
    }
    
    func resume() {
        guard let webSocketTask = webSocketTask else {
            Log.message("webSocketTask is not set up", level: .error, type: .websocket)
            return
        }
        Log.message("resuming...", level: .info, type: .websocket)
        webSocketTask.resume()
        schedulePing()
    }
    
    func suspend() {
        Log.message("suspending...", level: .info, type: .websocket)
        pingCancelable?.cancel()
        webSocketTask?.suspend()
        queue.cancelAllOperations()
    }
    
    func cancel() {
        Log.message("cancelling...", level: .info, type: .websocket)
        pingCancelable?.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        queue.cancelAllOperations()
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
                self?.delegate?.didReceive(error: error)
            case .success(let message):
                self?.delegate?.didReceive(message: message)
            }
            // Be aware that if you want to receive messages continuously you need
            // to call this again once you are done with receiving a message.
            self?.readMessage()
        }
    }
}
