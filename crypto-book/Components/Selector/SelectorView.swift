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
        let numberOfOptions: Int
        let selectedIndex: Int
        let button: SelectorButton
    }
    
    private let stackView = UIStackView()
    private weak var button: SelectorButton?
    
    static let width = CGFloat(60)
    private var height: CGFloat?
    private let scale = CGFloat(0.3)
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func present(in view: UIView?, config: Config) -> SelectorView? {
        guard let view = view else { return nil }
        view.addFillingSubview(self)
        setup(config: config)
        return self
    }
}

// MARK: - Private

private extension SelectorView {
    
    func setupViews() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        addSubview(stackView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOutside)))
    }
    
    func setup(config: Config) {
        Log.message("Setup selector with config: \(config)", level: .info)
        button = config.button
        for i in 0...config.numberOfOptions {
            let button = makeButton()
            button.setTitle(String(i), for: .normal)
            button.setTitleColor(.binanceYellow, for: .highlighted)
            if i == config.selectedIndex {
                button.setTitleColor(.binanceYellow, for: .normal)
            }
            stackView.addArrangedSubview(button)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        height = CGFloat(config.numberOfOptions * 26)
        guard let height = height else { return }
        
        self.stackView.frame = CGRect(x: config.button.center.x + config.button.frame.width/2 - Self.width,
                                      y: config.button.center.y + config.button.frame.height/2 + 2,
                                      width: Self.width,
                                      height: height)

        self.stackView.transform = CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: 0, y: (-height/2 + config.button.frame.height/2) * 1 / scale)
        UIView.animate(withDuration: 0.1, animations: {
            self.stackView.transform = .identity
        })
    }
    
    func makeButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .binanceTitle
        button.backgroundColor = .binanceGray6
        button.addTarget(self, action: #selector(didPress(_:)), for: .touchUpInside)
        return button
    }
    
    @objc func didPress(_ sender: UIButton) {
        Log.message("Did select \(sender.titleLabel?.text ?? "<nil>")", level: .info)
        button?.text = sender.titleLabel?.text
        dismiss()
    }
    
    @objc func didTapOutside() {
        Log.message("Did tap outside", level: .info)
        dismiss()
    }
    
    func dismiss() {
        guard let height = height else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.stackView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                .translatedBy(x: 0, y: (-height/2 + SelectorButton.height/2) * 1 / self.scale)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
