//
//  SelectorButton.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class SelectorButton: UIView {
    
    static let width = CGFloat(30)
    static let height = CGFloat(20)

    private let triangleView = UIView()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Self.width, height: Self.height))
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didPressHandler: (() -> Void)?
    var text: String? {
        didSet {
            label.text = text
        }
    }
}

// MARK: - Private

private extension SelectorButton {
    
    func setupViews() {
        backgroundColor = .binanceGray6
        label.font = .binanceTableHeader
        layer.cornerRadius = 3
        addSubviewsForAutoLayout([label, triangleView])
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 6),
            label.rightAnchor.constraint(equalTo: triangleView.leftAnchor, constant: -1),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            triangleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            triangleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -2),
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
        setDownTriangle()
    }

    func setDownTriangle(){
        let width = 10
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width/2, y: width/2))
        path.addLine(to: CGPoint(x: width, y:0))
        path.addLine(to: CGPoint(x:0, y:0))
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.binanceYellow.cgColor
        
        triangleView.layer.insertSublayer(shape, at: 0)
      }
    
    @objc func didTap() {
        didPressHandler?()
    }
}
