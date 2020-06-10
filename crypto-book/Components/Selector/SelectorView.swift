//
//  SelectorView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class SelectorView: UIView {

    struct Config {
        let options: [String]
        let selectedIndex: Int
        let button: SelectorButton
    }
    
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let labels = [UILabel]()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func present(in view: UIView?, config: Config) -> SelectorView {
        setup(config: config)
        view?.addFillingSubview(self)
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        setNeedsLayout()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        return self
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - Private

private extension SelectorView {
    
    func setupViews() {
        backgroundColor = UIColor.binanceGray4
        stackView.axis = .vertical
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    func setup(config: Config) {
        for title in config.options.reversed() {
            let label = makeLabel()
            label.text = title
            stackView.addArrangedSubview(label)
        }
    }
    
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .binanceTitle
        label.isHidden = true
        return label
    }
    
    @objc func didTap() {
        dismiss()
    }
}
