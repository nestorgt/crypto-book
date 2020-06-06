//
//  WebSocketService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

final class WebSocketService: NSObject, URLSessionWebSocketDelegate, WebSocketServiceProtocol {
    
    weak var delegate: WebSocketServiceDelegate?
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let queue = OperationQueue()
    private var pingTimeInterval: TimeInterval?
    
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
    
    func setup(with configuration: WebSocketServiceConfiguration, delegate: WebSocketServiceDelegate?) {
        self.delegate = delegate
        pingTimeInterval = configuration.pingTimeInterval
        queue.qualityOfService = configuration.queueQualityOfService
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        webSocketTask = urlSession?.webSocketTask(with: configuration.url)
        readMessage()
    }
    
    func resume() {
        guard let webSocketTask = webSocketTask else {
            Log.message("WebSocket is not set up", level: .error, type: .websocket)
            return
        }
        Log.message("resume", level: .info, type: .websocket)
        webSocketTask.resume()
    }
    
    func suspend() {
        Log.message("suspend", level: .info, type: .websocket)
        webSocketTask?.suspend()
    }
    
    func cancel() {
        Log.message("cancel", level: .info, type: .websocket)
        webSocketTask?.cancel(with: .goingAway, reason: nil)
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
