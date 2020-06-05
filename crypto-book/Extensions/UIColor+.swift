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
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static let binanceYellow = UIColor.systemYellow
    static let binanceBlue = UIColor.systemBlue
    static let binanceBackground = UIColor.systemBackground
}
