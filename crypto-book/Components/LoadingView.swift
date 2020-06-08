//
//  LoadingView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 08/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class LoadingView: UIView {
    
    struct Config {
        let style: UIActivityIndicatorView.Style
        let outerMargin: CGFloat = 50
        let innerMargin: CGFloat = 20
    }
    
    private let contentView = UIView()
    private let spinner: UIActivityIndicatorView
    
    private let config: Config
    
    init(config: LoadingView.Config) {
        self.config = config
        spinner = UIActivityIndicatorView(style: config.style)
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present(in view: UIView?) {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        view?.addFillingSubview(self)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    static var standard: LoadingView {
        LoadingView(config: Config(style: .medium))
    }
}

// MARK: - Private


private extension LoadingView {
    
    func setupViews() {
        contentView.layer.cornerRadius = 5
        contentView.alpha = 0.8
        contentView.backgroundColor = UIColor.binanceGray4
        
        addSubviewForAutoLayout(contentView)
        contentView.addSubviewsForAutoLayout([spinner])
        
        contentView.centerToSuperview()
        spinner.fillToSuperview(margin: config.innerMargin)
        spinner.centerToSuperview()
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: config.outerMargin),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -config.outerMargin),
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: config.outerMargin),
            contentView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -config.outerMargin)
        ])

        spinner.startAnimating()
    }
}
