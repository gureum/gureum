//
//  InputMethodView.swift
//  iOS
//
//  Created by Jeong YunWon on 8/3/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

class InputMethodViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    var collections: [KeyboardLayoutCollection] = []
    var theme: Theme = preferences.theme
    var traits: UITextInputTraits! = nil

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(traits: UITextInputTraits) {
        super.init()
        self.traits = traits
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false)
    }

    var inputMethodView: InputMethodView {
        get {
            return self.view as InputMethodView
        }
    }

    var selectedCollection: KeyboardLayoutCollection {
        get {
            let collection = self.collections[self.selectedLayoutIndex]
            return collection
        }
    }

    var selectedLayout: KeyboardLayout {
        get {
            return self.selectedCollection.selectedLayout
        }
    }

    func resetContext() {
        for collection in self.collections {
            if collection.selectedLayout.context != nil {
                context_truncate(collection.selectedLayout.context)
            }
        }
    }

    func keyboardLayoutForLayoutName(name: String, frame: CGRect) -> [KeyboardLayout] {
        switch name {
        case "qwerty":
            return [QwertyKeyboardLayout(), QwertySymbolKeyboardLayout()]
        case "qwerty123":
            return [QwertySymbolKeyboardLayout()]
        case "ksx5002":
            return [KSX5002KeyboardLayout(), QwertySymbolKeyboardLayout()]
        default:
            return [NoKeyboardLayout()]
        }
    }

    override func loadView() {
        self.view = InputMethodView(frame: CGRectMake(0.0, 0.0, 320.0, 218.0))
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: "leftForSwipeRecognizer:")
        leftRecognizer.direction = .Left
        self.view.addGestureRecognizer(leftRecognizer)
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: "rightForSwipeRecognizer:")
        rightRecognizer.direction = .Right
        self.view.addGestureRecognizer(rightRecognizer)

        self.preloadFromTheme()
    }

    func preloadFromTheme() {
        let trait = self.theme.traitForSize(self.view.frame.size)
        self.inputMethodView.backgroundImageView.image = trait.backgroundImage
    }

    func loadFromTheme() {
        let layoutsView = self.inputMethodView.layoutsView
        for view in layoutsView.subviews {
            view.removeFromSuperview()
        }

//        원근 모드
//        let image = self.theme.backgroundImage
//        if image != nil {
//            self.inputMethodView.backgroundImageView.image = image
//        }

        assert(preferences.themeResources.count > 0)
        self.collections.removeAll(keepCapacity: true)

        let layoutNames = preferences.layouts
        for (i, name) in enumerate(layoutNames) {
            assert(self.view.bounds.height > 0)
            assert(self.view.bounds.width > 0)
            let layouts = self.keyboardLayoutForLayoutName(name, frame: self.view.bounds)
            self.collections.append(KeyboardLayoutCollection(layouts: layouts))
            for layout in layouts {
                layout.view.frame.origin.x = CGFloat(i) * self.view.frame.width
            }
            layoutsView.addSubview(layouts[0].view)
        }

        self.inputMethodView.pageControl.numberOfPages = collections.count
        self.selectLayoutByIndex(preferences.defaultLayoutIndex, animated: false)

        //self.inputMethodView.backgroundImageView.image = nil
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        let theme = self.theme
        let trait = theme.traitForSize(size)
        let layoutIndex = self.selectedLayoutIndex
        self.view.frame.size = size
        self.inputMethodView.layoutsView.contentSize = CGSizeMake(size.width * CGFloat(self.collections.count), 0)
        for (i, collection) in enumerate(self.collections) {
            for layout in collection.layouts {
                layout.view.backgroundImageView.image = trait.backgroundImage
                layout.view.foregroundImageView.image = trait.foregroundImage
                layout.view.frame.origin.x = CGFloat(i) * size.width
                layout.view.frame.size.width = size.width
                layout.transitionViewToSize(size, withTransitionCoordinator: coordinator)
            }
        }
        self.selectLayoutByIndex(layoutIndex, animated: false)
    }

    var selectedLayoutIndex: Int {
        get {
            let layoutsView = self.inputMethodView.layoutsView
            var page = Int(layoutsView.contentOffset.x / layoutsView.frame.size.width + 0.5)
            if page < 0 {
                page = 0
            }
            else if page >= self.inputMethodView.pageControl.numberOfPages {
                page = self.collections.count - 1
            }
            return page
        }
    }

    func selectLayoutByIndex(index: Int, animated: Bool) {
        self.inputMethodView.layoutsView.contentSize = CGSizeMake(self.inputMethodView.frame.width * CGFloat(self.collections.count), 0)

        self.inputMethodView.pageControl.currentPage = index
        let offset = CGPointMake(CGFloat(index) * self.inputMethodView.layoutsView.frame.width, 0)
        self.inputMethodView.layoutsView.setContentOffset(offset, animated: animated)

        self.inputMethodView.pageControl.alpha = 1.0
        UIView.animateWithDuration(0.72, animations: { self.inputMethodView.pageControl.alpha = 0.0 })
    }

    @IBAction func leftForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.selectedLayoutIndex
        if index < self.collections.count - 1 {
            self.selectLayoutByIndex(index + 1, animated: true)
        }
    }

    @IBAction func rightForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.selectedLayoutIndex
        if index > 0 {
            self.selectLayoutByIndex(index - 1, animated: true)
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView!) {
        self.inputMethodView.pageControl.alpha = 1.0
    }

    func scrollViewDidScroll(scrollView: UIScrollView!) {
        self.inputMethodView.pageControl.currentPage = self.selectedLayoutIndex
    }
}

class InputMethodView: UIView {
    let layoutsView: UIScrollView! = UIScrollView()
    let pageControl: UIPageControl! = UIPageControl()
    let backgroundImageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth

        layoutsView.frame = self.bounds
        layoutsView.scrollEnabled = false
        layoutsView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth

        pageControl.userInteractionEnabled = false
        pageControl.center = CGPointMake(self.frame.width / 2, self.frame.height - 20.0)

        backgroundImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth
        backgroundImageView.frame = self.bounds


        self.addSubview(self.backgroundImageView)
        self.addSubview(self.layoutsView)
        self.addSubview(self.pageControl)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
