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
    static let binanceBlue = UIColor.systemBlue
    static let binanceGray = UIColor.systemGray
    static let binanceGray2 = UIColor.systemGray2
    static let binanceGray3 = UIColor.systemGray3
    static let binanceBackground = UIColor.systemBackground
    
    static let binanceBidBackground = UIColor(red: 19/255, green: 32/255, blue: 32/255, alpha: 1)
    static let binanceBid = UIColor(red: 82/255, green: 170/255, blue: 131/255, alpha: 1)
    static let binanceAskBackground = UIColor(red: 39/255, green: 23/255, blue: 33/255, alpha: 1)
    static let binanceAsk = UIColor(red: 176/255, green: 69/255, blue: 99/255, alpha: 1)
}
