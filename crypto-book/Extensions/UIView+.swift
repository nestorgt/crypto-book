//
//  UIView+.swift
//  crypto-book
//
//  Created by Nestor Garcia on 03/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import UIKit

extension UIView {
    
    // MARK: - Add Subview
    
    /// Adds a array of subviews to self
    ///
    /// - Parameter subviews: the array of subviews to be added
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }

    /// Adds a subview to self and sets it's translatesAutoresizingMaskIntoConstraints property to false
    ///
    /// - Parameter subview: the subview to be added
    func addSubviewForAutoLayout(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    /// Adds a array of subviews to self and sets their translatesAutoresizingMaskIntoConstraints property to false
    ///
    /// - Parameter subviews: the array of subviews to be added
    func addSubviewsForAutoLayout(_ subviews: [UIView]) {
        subviews.forEach { addSubviewForAutoLayout($0) }
    }

    /// Adds a subview to receiver with constraints to fill it.
    ///
    /// - Parameters:
    ///   - subview: the view to be added.
    ///   - margin: an optional margin for all sides on the subview.
    func addFillingSubview(_ subview: UIView, margin: CGFloat = 0) {
        addSubview(subview)
        subview.fillToSuperview(margin: margin)
    }

    /// Adds a subview to receiver with constraints to fill it by using its safe margin.
    ///
    /// - Parameters:
    ///   - subview: the view to be added.
    ///   - margin: an optional margin for all sides on the subview.
    func addSafeFillingSubview(_ subview: UIView, margin: CGFloat = 0) {
        addSubview(subview)
        subview.fillToSuperviewSafeMargin(margin: margin)
    }

    /// Adds a subview to self with constraints to center it
    ///
    /// - Parameter subview: the view to be added
    func addCenteredSubview(_ subview: UIView) {
        addSubview(subview)
        subview.centerToSuperview()
    }

    // MARK: - Fill Subview
    
    /// Fills receiver to it's superview margin by adding anchors.
    ///
    /// - Parameter margin: an optional margin (in positive value).
    /// - Precondition: Receiver must have a superview.
    func fillToSuperview(margin: CGFloat = 0) {
        guard let superview = superview else { fatalError("\(self) does not have a superview") }
        anchor(top: superview.topAnchor, topMargin: margin,
               bottom: superview.bottomAnchor, bottomMargin: margin,
               leading: superview.leadingAnchor, leadingMargin: margin,
               trailing: superview.trailingAnchor, trailingMargin: margin)
    }

    /// Fills receiver to it's superview _safe_ margin by adding anchors.
    ///
    /// - Parameter margin: an optional margin (in positive value).
    /// - Precondition: Receiver must have a superview.
    func fillToSuperviewSafeMargin(margin: CGFloat = 0) {
        guard let superview = superview else { fatalError("\(self) does not have a superview") }
        anchor(top: superview.safeAreaLayoutGuide.topAnchor, topMargin: margin,
               bottom: superview.safeAreaLayoutGuide.bottomAnchor, bottomMargin: margin,
               leading: superview.safeAreaLayoutGuide.leadingAnchor, leadingMargin: margin,
               trailing: superview.safeAreaLayoutGuide.trailingAnchor, trailingMargin: margin)
    }
    
    // MARK: - Center

    /// Centers self to it's superview by adding anchors
    func centerToSuperview() {
        guard let superview = superview else { fatalError("\(self) does not have a superview") }
        anchor(centerX: superview.centerXAnchor, centerY: superview.centerYAnchor)
    }

    // MARK: - Anchor Helpers
    
    /// Method to add anchors easier
    /// - Note: anchors will be activated by default and the view will have it's translatesAutoresizingMaskIntoConstraints
    /// property set to false.
    /// - Returns: An array with all constraints already activated
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                topMargin: CGFloat = 0,
                bottom: NSLayoutYAxisAnchor? = nil,
                bottomMargin: CGFloat = 0,
                left: NSLayoutXAxisAnchor? = nil,
                leftMargin: CGFloat = 0,
                leading: NSLayoutXAxisAnchor? = nil,
                leadingMargin: CGFloat = 0,
                right: NSLayoutXAxisAnchor? = nil,
                rightMargin: CGFloat = 0,
                trailing: NSLayoutXAxisAnchor? = nil,
                trailingMargin: CGFloat = 0,
                centerX: NSLayoutXAxisAnchor? = nil,
                centerXMargin: CGFloat = 0,
                centerY: NSLayoutYAxisAnchor? = nil,
                centerYMargin: CGFloat = 0,
                width: NSLayoutAnchor<NSLayoutDimension>? = nil,
                widthConstant: CGFloat = 0,
                height: NSLayoutAnchor<NSLayoutDimension>? = nil,
                heightConstant: CGFloat = 0,
                priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {

        translatesAutoresizingMaskIntoConstraints = false
        var anchors = [NSLayoutConstraint]()
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topMargin))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomMargin))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftMargin))
        }
        if let leading = leading {
            anchors.append(leadingAnchor.constraint(equalTo: leading, constant: leadingMargin))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightMargin))
        }
        if let trailing = trailing {
            anchors.append(trailingAnchor.constraint(equalTo: trailing, constant: -trailingMargin))
        }
        if let centerX = centerX {
            anchors.append(centerXAnchor.constraint(equalTo: centerX, constant: centerXMargin))
        }
        if let centerY = centerY {
            anchors.append(centerYAnchor.constraint(equalTo: centerY, constant: centerYMargin))
        }
        if let width = width {
            anchors.append(widthAnchor.constraint(equalTo: width))
        }
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        if let height = height {
            anchors.append(heightAnchor.constraint(equalTo: height))
        }
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        if let priority = priority {
            anchors.forEach { $0.priority = priority }
        }
        NSLayoutConstraint.activate(anchors)
        return anchors
    }
}
