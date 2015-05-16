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
    var layoutNames: Array<String> = []
    var theme: Theme = {
        var theme: Theme = preferences.theme
        if theme.dataForFilename("config.json") == nil {
            theme = BuiltInTheme()
        }
        return CachedTheme(theme: theme)
    }()
    var adjustedSize = CGSizeZero
    var selectedCollectionIndex = preferences.defaultLayoutIndex

    let layoutsView: UIScrollView! = UIScrollView()
    let pageControl: UIPageControl! = UIPageControl()
    let backgroundImageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth


        layoutsView.scrollEnabled = false
        pageControl.userInteractionEnabled = false

        self.addSubview(self.backgroundImageView)
        self.addSubview(self.layoutsView)
        self.addSubview(self.pageControl)
        self.layoutsView.frame = frame


        self.preloadTheme()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    var selectedCollection: KeyboardLayoutCollection {
        get {
            assert(self.selectedCollectionIndex < self.collections.count)
            let collection = self.collections[self.selectedCollectionIndex]
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
            case "symbol":
                return [QwertySymbolKeyboardLayout()]
            case "ksx5002":
                return [KSX5002KeyboardLayout(), QwertySymbolKeyboardLayout()]
            case "danmoum":
                return [DanmoumKeyboardLayout(), QwertySymbolKeyboardLayout()]
            case "cheonjiin":
                return [CheonjiinKeyboardLayout(), TenKeyAlphabetKeyboardLayout(), TenKeyNumberKeyboardLayout()]
            case "numberpad":
                return [NumberPadLayout()]
            default:
                return [NoKeyboardLayout()]
            }
        }()
        return KeyboardLayoutCollection(layouts: layouts)
    }

    func preloadTheme() {
        let trait = self.theme.traitForSize(self.frame.size)
        self.backgroundImageView.image = trait.backgroundImage
    }

    func adjustTraits(traits: UITextInputTraits) {
        if self.layoutNames != self.layoutNamesForKeyboardType(traits.keyboardType) {
            self.loadCollections(traits)
        }
        switch traits.keyboardType! {
        default:
            break
        }

        let returnKeyType = traits.returnKeyType
        let returnTitle: String = {
            if returnKeyType == nil {
                return "완료"
            }
            switch returnKeyType! {
            case .Default:
                return "다음문장"
            case .Go:
                return "이동"
            case .Google:
                return "Google"
            case .Join:
                return "가입"
            case .Next:
                return "다음"
            case .Route:
                return "이동"
            case .Search:
                return "검색"
            case .Send:
                return "보내기"
            case .Yahoo:
                return "Yahoo!"
            case .Done:
                return "완료"
            case .EmergencyCall:
                return "응급"
            }
        }()

        for (i, collection) in enumerate(self.collections) {
            for layout in collection.layouts {
                layout.view.doneButton.captionLabel.text = returnTitle
            }
        }
    }

    func layoutNamesForKeyboardType(type: UIKeyboardType?) -> Array<String> {
        if let type = type {
            switch type {
            case .NumberPad:
                return ["numberpad"]
            default:
                return preferences.layouts
            }
        } else {
            return preferences.layouts
        }
    }

    func loadCollections(traits: UITextInputTraits) {
        let layoutNames = self.layoutNamesForKeyboardType(traits.keyboardType)
        self.layoutNames = layoutNames

        for view in layoutsView.subviews {
            view.removeFromSuperview()
        }

//        원근 모드
//        let image = self.theme.backgroundImage
//        if image != nil {
//            self.inputMethodView.backgroundImageView.image = image
//        }

        //assert(preferences.themeResources.count > 0)
        self.collections.removeAll(keepCapacity: true)

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
        self.selectCollectionByIndex(preferences.defaultLayoutIndex, animated: false)

        self.backgroundImageView.image = nil

        self.selectedCollectionIndex = preferences.defaultLayoutIndex < self.collections.count ? preferences.defaultLayoutIndex : 0
        self.adjustedSize = CGSizeZero
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        if self.adjustedSize == size {
            return
        }

        self.adjustedSize = size

//        globalInputViewController?.log("transitionViewToSize: \(size)")
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
        self.selectCollectionByIndex(self.selectedCollectionIndex, animated: false)
    }

    func selectCollectionByIndex(index: Int, animated: Bool) {
        self.selectedCollectionIndex = index
        let newWidth = self.frame.width * CGFloat(self.collections.count)
        self.layoutsView.frame = self.frame
        self.layoutsView.contentSize = CGSizeMake(newWidth, 0)
        //globalInputViewController?.log("layoutview frame: \(self.layoutsView.frame)")

        self.pageControl.currentPage = index
        let offset = CGFloat(index) * self.frame.width
        self.layoutsView.setContentOffset(CGPointMake(offset, 0), animated: animated)

        for (i, collection) in enumerate(self.collections) {
            collection.selectLayoutIndex(0)
            for (j, layout) in enumerate(collection.layouts) {
                if i == index && j == collection.selectedLayoutIndex {
                    break;
                }
                layout.view.shiftButton?.selected = false
                for button in layout.helper.buttons.values {
                    button.hideEffect()
                }
            }
        }

        self.pageControl.alpha = 1.0
        let animation = { self.pageControl.alpha = 0.0 }
        if animated {
            UIView.animateWithDuration(0.36, animations: animation )
        } else {
            animation()
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.pageControl.alpha = 1.0
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.pageControl.currentPage = self.selectedCollectionIndex
    }
}
