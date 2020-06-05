//
//  Int+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation

extension Int {
    
    static func random(max: Int = .max) -> Int {
        return Int(arc4random()) / Int.max
    }
}
