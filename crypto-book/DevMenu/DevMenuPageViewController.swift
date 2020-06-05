//
//  DevMenuPageViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

final class DevMenuPageViewController: UIViewController {
    
    private var pageViewController: PageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupNavigationBar()
    }
}

// MARK: - Private

private extension DevMenuPageViewController {
    
    func setupNavigationBar() {
        title = "PageViewController"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChildPage))
    }
    
    func setupPageViewController() {
        pageViewController = PageViewController(pages: [randomViewController(color: .red, title: "First"),
                                                        randomViewController(color: .blue, title: "Second")])
        guard let pageViewController = pageViewController else { return }
        addChild(pageViewController)
        view.addSafeFillingSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    @objc func addChildPage() {
        Log.message("Adding new page", level: .debug, type: .devMenu)
        pageViewController?.add(page: randomViewController())
    }
    
    func randomViewController(color: UIColor = .random(), title: String = String.random(length: 5)) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        vc.title = title
        return vc
    }
}
