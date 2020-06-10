//
//  PageViewController.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit
import Combine

/// Component that displays several pages (view controllers) horizontally.
/// Contains a top menu to allow selecion of a controller.
final class PageViewController: UIViewController {
    
    private let pageMenuView: PageMenuView
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var trailingContentViewConstraint: NSLayoutConstraint?
    private var withContentViewConstraint: NSLayoutConstraint?
    
    private var viewControllers: [ChildPageViewController] = []
    
    private var width: CGFloat { view.frame.size.width }
    private var offset: CGFloat { scrollView.contentOffset.x }
    private var pages: Int { viewControllers.count }
    
    private var previousIndex: Int = 0
    
    private var index: Int = 0
    
    /// Returns the current selected view controller
    var currentViewController: ChildPageViewController? {
        viewControllers[safe: index]
    }
    
    /// Custom init. You can pass the pages from the beginning or use later `add(childPage:)`.
    /// - Parameter childPages: The starting view controllers (child pages)
    init(childPages: [ChildPageViewController]) {
        pageMenuView = PageMenuView(items: childPages.map { $0.title ?? "No Title" })
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = childPages
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    /// Adds a new child (view controller)
    func add(childPage: ChildPageViewController) {
        let lastViewController = viewControllers.last
        viewControllers.append(childPage)
        addViewController(childPage, previousViewController: lastViewController)
        pageMenuView.add(item: childPage.title ?? "No Title")
    }
}

// MARK: - Private

private extension PageViewController {
    
    func setupViews() {
        view.backgroundColor = .binanceBackground
        
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeft.direction = .left
        contentView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        contentView.addGestureRecognizer(swipeRight)
        contentView.isUserInteractionEnabled = true
        
        view.addSubviews([pageMenuView, scrollView])
        pageMenuView.anchor(top: view.topAnchor,
                            left: view.leftAnchor,
                            right: view.rightAnchor)
        scrollView.anchor(top: pageMenuView.bottomAnchor,
                          bottom: view.bottomAnchor,
                          left: view.leftAnchor,
                          right: view.rightAnchor)
        
        scrollView.addFillingSubview(contentView)
        scrollView.anchor(height: contentView.heightAnchor)
        
        pageMenuView.didSelectIndex = { [weak self] index in
            self?.scroll(to: index)
        }
    }
    
    func setupViewControllers() {
        var previousViewController: UIViewController?
        viewControllers.forEach { [weak self] vc in
            self?.addViewController(vc, previousViewController: previousViewController)
            previousViewController = vc
        }
        viewControllers[index].isActive = true
    }
    
    func addViewController(_ viewController: UIViewController, previousViewController: UIViewController?) {
        withContentViewConstraint?.isActive = false
        defer { withContentViewConstraint?.isActive = true }
        
        addChild(viewController)
        addView(viewController.view, previousViewController: previousViewController)
        viewController.didMove(toParent: self)
        
        withContentViewConstraint = contentView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                                       multiplier: CGFloat(pages))
    }
    
    func addView(_ view: UIView, previousViewController: UIViewController?) {
        trailingContentViewConstraint?.isActive = false
        defer { trailingContentViewConstraint?.isActive = true }
        
        scrollView.contentSize = contentView.frame.size
        contentView.addSubviewForAutoLayout(view)
        view.anchor(top: contentView.topAnchor,
                    bottom: contentView.bottomAnchor,
                    leading: previousViewController?.view.trailingAnchor ?? contentView.leadingAnchor,
                    width: self.view.widthAnchor)
        
        trailingContentViewConstraint = view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    }
    
    func goToNext() {
        guard index + 1 < pages  else {
            Log.message("Can't go to next - index: \(index), offset: \(offset), pages: \(pages)",
                level: .error, type: .page)
            return
        }
        scroll(to: index + 1)
    }
    
    func goToPrevious() {
        guard index > 0 else {
            Log.message("Can't go to previous - index: \(index), offset: \(offset), pages: \(pages)",
                level: .error, type: .page)
            return
        }
        scroll(to: index - 1)
    }
    
    func scroll(to index: Int) {
        Log.message("Scrolling to: \(index)", level: .info, type: .page)
        
        previousIndex = self.index
        self.index = index
        pageMenuView.select(index: index)
        
        viewControllers[previousIndex].isActive = false
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: true)
    }
    
    // MARK: - User Input
    
    @objc func didSwipeLeft() {
        Log.message("Did swipe Left", level: .debug, type: .page)
        goToNext()
    }
    
    @objc func didSwipeRight() {
        Log.message("Did swipe Right", level: .debug, type: .page)
        goToPrevious()
    }
}

// MARK: - UIScrollViewDelegate

extension PageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let startOffset = CGFloat(previousIndex) * width
        let endOffset = CGFloat(index) * width
        let currentOffset = scrollView.contentOffset.x
        let range = abs(endOffset - startOffset)
        let correctedStartValue = abs(currentOffset - endOffset)
        let percentage = correctedStartValue / range
        pageMenuView.animate(toIndex: index, fromIndex: previousIndex, percentage: percentage)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        viewControllers[index].isActive = true
    }
}
