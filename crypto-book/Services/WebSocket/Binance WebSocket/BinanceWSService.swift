//
//  BinanceWSService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

protocol BinanceWSServiceProtocol: class {
    
    /// Returns `true` while is trying to open the WebSocket connection.
    var isConnecting: CurrentValueSubject<Bool, Never> { get }
    
    /// Provides updates of the models received by the WebSocket.
    /// - Note:Intial value will be `nil`.
    /// - Important: Error from WebSocket are propagated upwards, the entity who uses this service should handle them.
    var publisher: CurrentValueSubject<(Result<WSEventProtocol, BinanceWSError>?), Never> { get }
    
    func restart()
    func start()
    func pause()
    func stop()
}

final class BinanceWSService: BinanceWSServiceProtocol {
    
    private let url: URL
    private var webSocketService: WebSocketServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(url: URL,
         webSocketService: WebSocketServiceProtocol = WebSocketService()) {
        self.url = url
        self.webSocketService = webSocketService
        setupWebSocket()
    }
    
    // MARK: - BinanceWSServiceProtocol
    
    var isConnecting = CurrentValueSubject<Bool, Never>(true)
    var publisher = CurrentValueSubject<(Result<WSEventProtocol, BinanceWSError>?), Never>(nil)
    
    func restart() {
        isConnecting.value = true
        webSocketService.restart()
    }
    
    func start() {
        webSocketService.resume()
    }
    
    func pause() {
        webSocketService.suspend()
    }
    
    func stop() {
        webSocketService.shutdown()
    }
}

// MARK: - Private

private extension BinanceWSService {
    
    func setupWebSocket() {
        isConnecting.value = true
        webSocketService.delegate = self
        webSocketService.setup(with: url)
    }
}

// MARK: - WebSocketServiceDelegate

extension BinanceWSService: WebSocketServiceDelegate {
    
    func didOpen(handshakeProtocol: String?) {
        Log.message("didOpen with protocol \(String(describing: handshakeProtocol))",
            level: .info, type: .wsBinance)
        isConnecting.value = false
    }
    
    func didClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reason = String(data: reason ?? Data(), encoding: .utf8) ?? "<nil>"
        Log.message("didClose with code: \(closeCode), reason: \(reason)", level: .info, type: .wsBinance)
    }
    
    func didReceive(message: URLSessionWebSocketTask.Message) {
        guard let string = message.string else {
            Log.message("didReceive un-handled data task message", level: .error, type: .wsBinance)
            return
        }
        guard let data = Parser.JSONData(from: string) else {
            Log.message("didReceive wrong data", level: .error, type: .wsBinance)
            return
        }
        if let wsEventType = (try? JSONDecoder.binance.decode(WSEvent.self, from: data))?.type {
//            Log.message("didReceive event \(wsEventType)", level: .debug, type: .wsBinance)
            do {
                switch wsEventType {
                case .depthUpdate:
                    let diff = try JSONDecoder.binance.decode(WSOrderBookDiff.self, from: data)
                    publisher.send(.success(diff))
                case .aggTrade:
                    let trade = try JSONDecoder.binance.decode(WSTrade.self, from: data)
                    publisher.send(.success(trade))
                }
            } catch {
                publisher.send(.failure(.generic(message: "Can't decode class for event) \(wsEventType)")))
            }
        } else if let error = try? JSONDecoder.binance.decode(BinanceWSError.self, from: data) {
            publisher.send(.failure(error))
        } else {
            publisher.send(.failure(.generic(message: "Can't decode message")))
        }
    }
    
    func didReceive(error: Error) {
        Log.message("didReceive error: \(error)", level: .error, type: .wsBinance)
    }
}
