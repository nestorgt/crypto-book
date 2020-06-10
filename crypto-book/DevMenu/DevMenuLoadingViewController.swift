//
//  DevMenuLoadingViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 08/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuLoadingViewController: UIViewController {
    
    private var spinner: LoadingView?
    private let segmentedControl = UISegmentedControl()

    private lazy var sample =
    "Loading... Lorem ipsum dolor sit amet, consectetur adipiscing elit. In eu est sapien. In egestas placerat massa, sit amet accumsan purus viverra vel. Quisque sollicitudin aliquet tellus vel tincidunt. Mauris blandit est at elit rhoncus, sit amet varius lectus lacinia. Duis magna mi, molestie facilisis velit eu, aliquet hendrerit risus. Suspendisse non nunc sed lorem hendrerit vehicula. Duis tempor volutpat accumsan. Nulla nec lacus vehicula, varius magna eget, tempus risus. Fusce tempor quam commodo libero luctus, eget rhoncus magna laoreet."
    private var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
}

// MARK: - Private

private extension DevMenuLoadingViewController {

    func setupNavigationBar() {
        view.backgroundColor = .binanceBackground
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(addLoadingView)),
            UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(changeText)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeLoadingView))
        ], animated: false) 
        segmentedControl.insertSegment(withTitle: "medium", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "large", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(removeLoadingView), for: .valueChanged)
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
        spinner?.present(in: view, message: message)
    }
    
    @objc func removeLoadingView() {
        Log.message("Removing...", level: .debug, type: .devMenu)
        spinner?.dismiss()
    }
    
    @objc func changeText() {
        Log.message("Changing text...", level: .debug, type: .devMenu)
        message = String(sample.prefix(Int.random(in: 1..<sample.count)))
        if spinner?.superview == nil {
            addLoadingView()
        } else {
            spinner?.update(message: message)
        }
        view.backgroundColor = .random()
    }
}
