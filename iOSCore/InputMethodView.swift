//
//  InputMethodView.swift
//  iOS
//
//  Created by Jeong YunWon on 8/3/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

class InputMethodView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    var collections: [KeyboardLayoutCollection] = []
    var theme: Theme = CachedTheme(theme: preferences.theme)
    var traits: UITextInputTraits! = nil
    var lastSize = CGSizeZero
    var layouts: [KeyboardLayoutCollection] = []

    let layoutsView: UIScrollView! = UIScrollView()
    let pageControl: UIPageControl! = UIPageControl()
    let backgroundImageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth

        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: "leftForSwipeRecognizer:")
        leftRecognizer.direction = .Left
        self.addGestureRecognizer(leftRecognizer)
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: "rightForSwipeRecognizer:")
        rightRecognizer.direction = .Right
        self.addGestureRecognizer(rightRecognizer)

        layoutsView.scrollEnabled = false
        pageControl.userInteractionEnabled = false

        self.addSubview(self.backgroundImageView)
        self.addSubview(self.layoutsView)
        self.addSubview(self.pageControl)
        self.layoutsView.frame = frame

        self.preloadFromTheme()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

    func keyboardLayoutCollectionForLayoutName(name: String, frame: CGRect) -> KeyboardLayoutCollection {
        var layouts: [KeyboardLayout] = {
            switch name {
            case "qwerty":
                return [QwertyKeyboardLayout(), QwertySymbolKeyboardLayout()]
            case "qwerty123":
                return [QwertySymbolKeyboardLayout()]
            case "ksx5002":
                return [KSX5002KeyboardLayout(), QwertySymbolKeyboardLayout()]
            case "danmoum":
                return [DanmoumKeyboardLayout(), QwertySymbolKeyboardLayout()]
            default:
                return [NoKeyboardLayout()]
            }
        }()
        return KeyboardLayoutCollection(layouts: layouts)
    }

    func preloadFromTheme() {
        let trait = self.theme.traitForSize(self.frame.size)
        self.backgroundImageView.image = trait.backgroundImage
    }

    func loadFromTheme() {
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
            assert(self.bounds.height > 0)
            assert(self.bounds.width > 0)
            let collection = self.keyboardLayoutCollectionForLayoutName(name, frame: self.bounds)
            self.collections.append(collection)
            for layout in collection.layouts {
                layout.view.frame.origin.x = CGFloat(i) * self.frame.width
            }
            layoutsView.addSubview(collection.selectedLayout.view)
        }

        self.pageControl.numberOfPages = collections.count
        self.selectLayoutByIndex(preferences.defaultLayoutIndex, animated: false)

        self.backgroundImageView.image = nil
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        if self.lastSize == size {
            return
        } else {
            self.lastSize = size
        }
        globalInputViewController?.log("transitionViewToSize: \(size)")
        let layoutIndex = self.selectedLayoutIndex
        let theme = self.theme
        let trait = theme.traitForSize(size)

        let viewBounds = CGRect(origin: CGPointZero, size: size)
        layoutsView.frame = viewBounds
        backgroundImageView.frame = viewBounds
        pageControl.center = CGPointMake(size.width / 2, size.height - 20.0)

        for (i, collection) in enumerate(self.collections) {
            for layout in collection.layouts {
                layout.view.frame.origin.x = CGFloat(i) * size.width
                layout.view.frame.size.width = size.width
            }
        }
//        dispatch_async(dispatch_get_main_queue(), {
        for (i, collection) in enumerate(self.collections) {
            for layout in collection.layouts {
                layout.view.backgroundImageView.image = trait.backgroundImage
                layout.view.foregroundImageView.image = trait.foregroundImage
                layout.transitionViewToSize(size, withTransitionCoordinator: coordinator)
            }
        }
//        })
        self.selectLayoutByIndex(layoutIndex, animated: false)
    }

    var selectedLayoutIndex: Int {
        get {
            let layoutsView = self.layoutsView
            var page = Int(layoutsView.contentOffset.x / layoutsView.frame.size.width + 0.5)
            if page < 0 {
                page = 0
            }
            else if page >= self.pageControl.numberOfPages {
                page = self.collections.count - 1
            }
            return page
        }
    }

    func selectLayoutByIndex(index: Int, animated: Bool) {
        let newWidth = self.frame.width * CGFloat(self.collections.count)
        self.layoutsView.contentSize = CGSizeMake(newWidth, 0)
        globalInputViewController?.log("layoutview frame: \(self.layoutsView.frame)")

        self.pageControl.currentPage = index
        let offset = CGFloat(index) * self.frame.width
        self.layoutsView.setContentOffset(CGPointMake(offset, 0), animated: animated)

        for (i, collection) in enumerate(self.collections) {
            for (j, layout) in enumerate(collection.layouts) {
                if i == index && j == collection.selectedLayoutIndex {
                    break;
                }
                for button in layout.helper.buttons.values {
                    button.hideEffect()
                }
            }
        }

        self.pageControl.alpha = 1.0
        let animation = { self.pageControl.alpha = 0.0 }
        if animated {
            UIView.animateWithDuration(0.72, animations: animation )
        } else {
            animation()
        }
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
        self.pageControl.alpha = 1.0
    }

    func scrollViewDidScroll(scrollView: UIScrollView!) {
        self.pageControl.currentPage = self.selectedLayoutIndex
    }
}
