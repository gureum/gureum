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
    var lastSize = CGSize.zero
    var layouts: [KeyboardLayoutCollection] = []

    let layoutsView: UIScrollView! = UIScrollView()
    let pageControl: UIPageControl! = UIPageControl()
    let backgroundImageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin , .flexibleTopMargin , .flexibleBottomMargin , .flexibleHeight , .flexibleWidth]

        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("leftForSwipeRecognizer:"))
        leftRecognizer.direction = .left
        self.addGestureRecognizer(leftRecognizer)
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("rightForSwipeRecognizer:"))
        rightRecognizer.direction = .right
        self.addGestureRecognizer(rightRecognizer)

        layoutsView.isScrollEnabled = false
        pageControl.isUserInteractionEnabled = false

        self.addSubview(self.backgroundImageView)
        self.addSubview(self.layoutsView)
        self.addSubview(self.pageControl)
        self.layoutsView.frame = frame

        self.preloadFromTheme()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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
            for layout in collection.layouts {
                if layout.context != nil {
                context_truncate(collection.selectedLayout.context)
                }
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
            case "numpad":
                return [NumpadKeyboardLayout(), CheonjiinKeyboardLayout()]
            default:
                return [NoKeyboardLayout()]
            }
        }()
        return KeyboardLayoutCollection(layouts: layouts)
    }

    func preloadFromTheme() {
        let trait = self.theme.traitForSize(size: self.frame.size)
        self.backgroundImageView.image = trait.backgroundImage
    }

    func loadFromTheme(traits: UITextInputTraits) {
        for view in layoutsView.subviews {
            view.removeFromSuperview()
        }

//        원근 모드
//        let image = self.theme.backgroundImage
//        if image != nil {
//            self.inputMethodView.backgroundImageView.image = image
//        }

        assert(preferences.themeResources.count > 0)
        self.collections.removeAll(keepingCapacity: true)

        let returnKeyType = traits.returnKeyType
        let returnTitle: String = {
            if returnKeyType == nil {
                return "완료"
            }
            switch returnKeyType! {
            case .default:
                return "다음문장"
            case .go:
                return "이동"
            case .google:
                return "Google"
            case .join:
                return "가입"
            case .next:
                return "다음"
            case .route:
                return "이동"
            case .search:
                return "검색"
            case .send:
                return "보내기"
            case .yahoo:
                return "Yahoo!"
            case .done:
                return "완료"
            case .emergencyCall:
                return "응급"
            case .continue:
                return "계속"
            }
        }()

        let layoutNames = preferences.layouts
        for (i, name) in layoutNames.enumerated() {
            assert(self.bounds.height > 0)
            assert(self.bounds.width > 0)
            let collection = self.keyboardLayoutCollectionForLayoutName(name: name, frame: self.bounds)
            self.collections.append(collection)
            for layout in collection.layouts {
                layout.view.doneButton.captionLabel.text = returnTitle
                layout.view.frame.origin.x = CGFloat(i) * self.frame.width
            }
            layoutsView.addSubview(collection.selectedLayout.view)
        }

        self.pageControl.numberOfPages = collections.count
        self.selectLayoutByIndex(index: preferences.defaultLayoutIndex, animated: false)

        self.backgroundImageView.image = nil
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        if self.lastSize == size {
            return
        } else {
            self.lastSize = size
        }
        globalInputViewController?.log(text: "transitionViewToSize: \(size)")
        let layoutIndex = self.selectedLayoutIndex
        let theme = self.theme
        let trait = theme.traitForSize(size: size)

        let viewBounds = CGRect(origin: CGPoint.zero, size: size)
        layoutsView.frame = viewBounds
        backgroundImageView.frame = viewBounds
        pageControl.center = CGPoint(x : size.width / 2, y : size.height - 20.0)

        for (i, collection) in self.collections.enumerated() {
            for layout in collection.layouts {
                layout.view.frame.origin.x = CGFloat(i) * size.width
                layout.view.frame.size.width = size.width
            }
        }
//        dispatch_async(dispatch_get_main_queue(), {
        for (_, collection) in self.collections.enumerated() {
            for layout in collection.layouts {
                layout.view.backgroundImageView.image = trait.backgroundImage
                layout.view.foregroundImageView.image = trait.foregroundImage
                layout.transitionViewToSize(size: size, withTransitionCoordinator: coordinator)
            }
        }
//        })
        self.selectLayoutByIndex(index: layoutIndex, animated: false)
    }

    var selectedLayoutIndex: Int {
        get {
            let layoutsView = self.layoutsView
            var page = Int((layoutsView?.contentOffset.x)! / (layoutsView?.frame.size.width)! + 0.5)
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
        self.layoutsView.contentSize = CGSize(width : newWidth, height : 0)
        globalInputViewController?.log(text: "layoutview frame: \(self.layoutsView.frame)")

        self.pageControl.currentPage = index
        let offset = CGFloat(index) * self.frame.width
        self.layoutsView.setContentOffset(CGPoint(x : offset,y : 0), animated: animated)
        
        for (i, collection) in self.collections.enumerated() {
            for (j, layout) in collection.layouts.enumerated() {
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
            UIView.animate(withDuration: 0.36, animations: animation )
        } else {
            animation()
        }
    }

    @IBAction func leftForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.selectedLayoutIndex
        if index < self.collections.count - 1 {
            self.selectLayoutByIndex(index: index + 1, animated: true)
        }
    }

    @IBAction func rightForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.selectedLayoutIndex
        if index > 0 {
            self.selectLayoutByIndex(index: index - 1, animated: true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageControl.alpha = 1.0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = self.selectedLayoutIndex
    }
}
