//
//  UIColor+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static let binanceYellow = UIColor(red: 207/255, green: 176/255, blue: 80/255, alpha: 1)
    static let binanceGray = UIColor.systemGray
    static let binanceGray2 = UIColor.systemGray2
    static let binanceGray4 = UIColor.systemGray4
    static let binanceGray6 = UIColor.systemGray6
    static let binanceBackground = UIColor.systemBackground
    
    static let binanceBid = UIColor(red: 82/255, green: 170/255, blue: 131/255, alpha: 1)
    static let binanceBidBackground = UIColor.binanceBid.withAlphaComponent(0.3)
    static let binanceAsk = UIColor(red: 176/255, green: 69/255, blue: 99/255, alpha: 1)
    static let binanceAskBackground = UIColor.binanceAsk.withAlphaComponent(0.3)
}
