//
//  PageMenuView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class PageMenuView: UIView {

    static let height: CGFloat = 50
    static let titleFont: UIFont = .systemFont(ofSize: 18)
    static let selectedTitleFont: UIFont = .boldSystemFont(ofSize: 18)
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private let selectorView = UIView()
    
    private var centerSelectorConstriant: NSLayoutConstraint?
    
    /// Block delegate called when the user taps on an item.
    var didSelectIndex: ((Int) -> Void)?
    
    init(items: [String]) {
        self.buttons = items.map { Self.createButton(with: $0) }
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.height)
    }
    
    /// Adds a new item to the menu.
    /// - Parameter item: a string (the title of the button).
    func add(item: String) {
        let button = Self.createButton(with: item)
        buttons.append(button)
        setup(button: button)
    }
    
    /// Selects an index in the menu.
    /// - Parameter index: index to be selected.
    func select(index: Int) {
        let startOffset = selectorView.center.x
        let endOffset = buttons[index].center.x
        let constant = startOffset - endOffset
        
        centerSelectorConstriant?.isActive = false
        centerSelectorConstriant =
            selectorView.centerXAnchor.constraint(equalTo: buttons[index].centerXAnchor, constant: constant)
        centerSelectorConstriant?.isActive = true
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Animate the selection according to a given percentange left to finish.
    /// - Parameters:
    ///   - toIndex: index that will be selected.
    ///   - fromIndex: the current selected index.
    ///   - percentage: missing percentage to end the animation.
    func animate(toIndex: Int, fromIndex: Int, percentage: CGFloat) {
        let startOffset = buttons[fromIndex].center.x
        let endOffset = buttons[toIndex].center.x
        let constant = (startOffset - endOffset) * percentage
        
        centerSelectorConstriant?.constant = !constant.isNaN ? constant : 0
        setNeedsLayout()
        layoutIfNeeded()
        
        selectButton(buttons[toIndex], percentage: percentage)
        deselectButton(buttons[fromIndex], percentage: percentage)
    }
}

// MARK: - Private

private extension PageMenuView {
    
    func setupViews() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        selectorView.backgroundColor = .binanceYellow
        selectorView.layer.cornerRadius = 5

        addSubviews([stackView, selectorView])
        stackView.anchor(top: topAnchor,
                         left: leftAnchor,
                         right: rightAnchor)
        selectorView.anchor(top: stackView.bottomAnchor,
                            bottom: bottomAnchor,
                            widthConstant: 30,
                            heightConstant: 3)
        
        buttons.forEach { [weak self] in self?.setup(button: $0) }
        
        if let firstButton = buttons.first {
            centerSelectorConstriant = selectorView.centerXAnchor.constraint(equalTo: firstButton.centerXAnchor)
            centerSelectorConstriant?.isActive = true
            selectButton(firstButton, percentage: 0)
        }
    }
    
    func selectButton(_ button: UIButton, percentage: CGFloat) {
        if percentage < 0.2 {
            button.setTitleColor(.systemYellow, for: .normal)
            button.titleLabel?.font = Self.selectedTitleFont
        }
    }
    
    func deselectButton(_ button: UIButton, percentage: CGFloat) {
        if percentage < 0.8 {
            button.setTitleColor(.systemGray, for: .normal)
            button.titleLabel?.font = Self.titleFont
        }
    }
    
    func setup(button: UIButton) {
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    static func createButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.50
        button.titleLabel?.textAlignment = .center
        return button
    }
    
    // MARK: - User Input
    
    @objc func didPressButton(_ button: UIButton) {
        guard let index = buttons.firstIndex(of: button) else {
            Log.message("Index out of bounds", level: .error, type: .page)
            return
        }
        Log.message("Did press button: \(button.titleLabel?.text ?? "<nil>")", level: .debug, type: .page)
        didSelectIndex?(index)
    }
}
