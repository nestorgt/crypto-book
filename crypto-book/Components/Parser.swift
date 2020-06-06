//
//  Parser.swift
//  crypto-book
//
//  Created by Nestor Garcia on 06/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

struct Parser {
    
    static func JSON(from string: String?) -> [String: Any]? {
        guard let data = string?.data(using: .utf8) else { return nil }
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dict
        } catch let error as NSError {
            Log.message("Can't create dict with string: \(string ?? "<nil>. Error: \(error)")",
                level: .error, type: .parser)
            return nil
        }
    }
    
    static func JSONData(from string: String) -> Data? {
        return string.data(using: .utf8)
    }
}
