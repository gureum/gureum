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
                self.startAnimating()
            } else {
                self.stopAnimating()
            }
        }
    }

    func pushAnimating() {
        self._animatingCount += 1
    }

    func popAnimation() {
        self._animatingCount -= 1
    }
}

var _UIWindowActivityIndicatorViews = Dictionary<UIWindow, UIActivityIndicatorView>()

extension UIWindow {
    var activityIndicatorView: UIActivityIndicatorView {
        get {
            let indicator_ = _UIWindowActivityIndicatorViews[self]
            if let indicator = indicator_ {
                return indicator
            } else {
                let newIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                newIndicator.center = self.center
                self.addSubview(newIndicator)
                _UIWindowActivityIndicatorViews[self] = newIndicator
                return newIndicator
            }
        }
    }
}
