//
//  GlobalActivicyIndicatorView.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

var _UIActivityIndicatorViewAnimatedCounters = Dictionary<UIActivityIndicatorView, Int>()

extension UIActivityIndicatorView {
    var _animatingCount: Int {
        get {
            return _UIActivityIndicatorViewAnimatedCounters[self] ?? 0
        }
        set {
            _UIActivityIndicatorViewAnimatedCounters[self] = newValue
            if newValue > 0 {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }

    func pushAnimating() {
        if let superview = self.superview {
            superview.bringSubview(toFront: self)
        }
        _animatingCount += 1
    }

    func popAnimating() {
        _animatingCount -= 1
    }
}

var _UIWindowActivityIndicatorViews = Dictionary<UIWindow, UIActivityIndicatorView>()

func UIActivityIndicatorViewForWindow(window: UIWindow) -> UIActivityIndicatorView {
    let indicator_ = _UIWindowActivityIndicatorViews[window]
    if let indicator = indicator_ {
        return indicator
    } else {
        let newIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        newIndicator.center = window.center
        window.addSubview(newIndicator)
        _UIWindowActivityIndicatorViews[window] = newIndicator
        return newIndicator
    }
}

extension UIWindow {
    var activityIndicatorView: UIActivityIndicatorView {
        return UIActivityIndicatorViewForWindow(window: self)
    }
}
