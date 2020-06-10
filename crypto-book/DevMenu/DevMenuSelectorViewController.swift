//
//  DevMenuSelectorViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 10/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuSelectorViewController: UIViewController {
    
    private var button: SelectorButton?
    private var selectorView: SelectorView?
    private var numberOfOptions: Int?
    private var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
}

// MARK: - Private

private extension DevMenuSelectorViewController {

    func setupNavigationBar() {
        view.backgroundColor = .binanceBackground
        title = "SelectorView"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addSelectorButton))
    }
    
    @objc func addSelectorButton() {
        numberOfOptions = Int.random(in: 2...9)
        guard let numberOfOptions = numberOfOptions else { return }
        selectedIndex = Int.random(in: 0..<numberOfOptions)
        guard let selectedIndex = selectedIndex else { return }
        
        selectorView?.removeFromSuperview()
        button?.removeFromSuperview()
        button = SelectorButton.make()
        guard let button = button else { return }
        button.didPressHandler = { [weak self] in
            Log.message("Did press selector button", level: .info, type: .devMenu)
            self?.presentSelectorView()
        }
        button.text = String(selectedIndex)
        view.addSubview(button)
        let margin = CGFloat(SelectorView.width)
        let width = view.frame.width - margin
        let height = view.frame.height - margin*4
        button.center = CGPoint(x: .random(in: margin...width), y: .random(in: margin...height))
        Log.message("Adding button to \(button.center)", level: .info, type: .devMenu)
    }
    
    func presentSelectorView() {
        guard let button = button,
            let numberOfOptions = numberOfOptions,
            let selectedIndex = selectedIndex
            else { return }
        selectorView = SelectorView()
        let config = SelectorView.Config(numberOfOptions: numberOfOptions,
                                         selectedIndex: selectedIndex,
                                         button: button)
        selectorView?.present(in: view, config: config)
    }
}
