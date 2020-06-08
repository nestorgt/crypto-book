//
//  DevMenuLoadingView.swift
//  crypto-book
//
//  Created by Nestor Garcia on 08/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuLoadingView: UIViewController {
    
    private var spinner: LoadingView?
    private let segmentedControl = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
}

// MARK: - Private

private extension DevMenuLoadingView {

    func setupNavigationBar() {
        view.backgroundColor = .binanceBackground
        title = "PageViewController"
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(addLoadingView)),
            UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(removeLoadingView))
        ], animated: false) 
        segmentedControl.insertSegment(withTitle: "medium", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "large", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
    }
    
    @objc func addLoadingView() {
        guard spinner?.superview == nil else { return }
        Log.message("Adding...", level: .debug, type: .devMenu)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            spinner = LoadingView.init(config: LoadingView.Config(style: .medium))
        default:
            spinner = LoadingView.init(config: LoadingView.Config(style: .large))
        }
        spinner?.present(in: view)
    }
    
    @objc func removeLoadingView() {
        Log.message("Removing...", level: .debug, type: .devMenu)
        spinner?.dismiss()
    }
}
