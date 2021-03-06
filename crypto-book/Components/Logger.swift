//
//  Logger.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import os.log

/// Class used to capture log messages in the app. Log messages are sent to Apple's unified logging system,
/// and can be viewed and filtered in the Console app.
final class Log {
    static var enabledLevels: [Log.Level] = Log.Level.allCases
    static var enabledTypes: [Log.Kind] = Log.Kind.allCases
    
    static func message(_ message: Any?, level: Log.Level, type: Log.Kind = .other) {
        guard enabledLevels.contains(level),
            enabledTypes.contains(type)
            else { return }
        os_log("%@",
               log: OSLog(subsystem: Bundle.main.bundleIdentifier ?? "",
                          category: "\(level.rawValue) \(type.rawValue)"),
               type: level.oslogType,
               "\(message ?? "")")
    }
}

// MARK: - Enums

extension Log {
    
    /// Log levels supported.
    enum Level: String, CaseIterable {
        case error = "🔴"
        case info = "🟢"
        case debug = "🔵"
        
        var oslogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .error: return .error
            }
        }
    }

    /// Kind refers to the different sections of the app that could potentially send logs.
    enum Kind: String, CaseIterable {
        case devMenu = "Dev Menu"
        case page = "Page"
        case orderBookViewModel = "Order Book ViewModel"
        case orderBookService = "Order Book Service"
        case orderBook = "Order Book"
        case marketHistoryViewModel = "Market History ViewModel"
        case marketHistoryService = "Market History Service"
        case parser = "Parser"
        case api = "API"
        case websocket = "Web Socket"
        case wsBinance = "WS Binance"
        case reachabilty = "Reachability"
        case other = "Other"
    }
}
