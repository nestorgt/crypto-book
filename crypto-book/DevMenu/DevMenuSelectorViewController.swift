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
    private var options: [Int]?
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
        let n = Int.random(in: 2...9)
        options = (0...n).map { $0 }
        guard let options = options else { return }
        selectedIndex = Int.random(in: 0..<options.count)
        guard let selectedIndex = selectedIndex else { return }
        
        selectorView?.removeFromSuperview()
        button?.removeFromSuperview()
        button = SelectorButton()
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
            let options = options,
            let selectedIndex = selectedIndex
            else { return }
        selectorView = SelectorView()
        let config = SelectorView.Config(options: options,
                                         selectedIndex: selectedIndex,
                                         button: button)
        selectorView?.present(in: view, config: config)
    }
}
