//
//  InputMethodView.swift
//  Gureum
//
//  Created by Jeong YunWon on 8/3/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

class InputMethodView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    var collections: [KeyboardLayoutCollection] = []
    var layoutNames: [String] = []
    var theme: Theme = {
        var theme: Theme = preferences.theme
        if theme.dataForFilename(name: "config.json") == nil {
            assert(false)
            theme = BuiltInTheme()
        }
        return CachedTheme(theme: theme)
    }()

    var adjustedSize = CGSize.zero
    var selectedCollectionIndex = preferences.defaultLayoutIndex

    let layoutsView: UIScrollView! = UIScrollView()
    let pageControl: UIPageControl! = UIPageControl()
    let backgroundImageView: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]

        layoutsView.isScrollEnabled = false
        pageControl.isUserInteractionEnabled = false

        addSubview(backgroundImageView)
        addSubview(layoutsView)
        addSubview(pageControl)
        backgroundImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        layoutsView.frame = frame

        preloadTheme()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    var selectedCollection: KeyboardLayoutCollection {
        assert(selectedCollectionIndex < collections.count)
        let collection = collections[self.selectedCollectionIndex]
        return collection
    }

    var selectedLayout: KeyboardLayout {
        return selectedCollection.selectedLayout
    }

    func resetContext() {
        for collection in collections {
            for layout in collection.layouts {
                if layout.context != nil {
                    context_truncate(collection.selectedLayout.context)
                }
            }
        }
    }

    func keyboardLayoutCollectionForLayoutName(name: String, frame _: CGRect) -> KeyboardLayoutCollection {
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
            case "emoticon":
                return [EmoticonKeyboardLayout()]
            case "number":
                return [NumberPadLayout()]
            case "ascii":
                return [QwertyKeyboardLayout(), QwertySymbolKeyboardLayout()]
            case "numberpunc":
                return [QwertySymbolKeyboardLayout(), QwertyKeyboardLayout()]
            case "phone":
                return [PhonePadLayout()]
            case "decimal":
                return [DecimalPadLayout()]
            default:
                return [NoKeyboardLayout()]
            }
        }()
        assert(layouts.count > 0)
        if layouts.count == 1 {
            layouts[0].togglable = false
        } else {
            for (i, layout) in layouts.enumerated() {
                if i == 0 {
                    layout.view.toggleKeyboardButton.captionLabel.text = type(of: layouts[1]).toggleCaption
                } else {
                    layout.view.toggleKeyboardButton.captionLabel.text = type(of: layouts[0]).toggleCaption
                }
            }
        }
        return KeyboardLayoutCollection(layouts: layouts)
    }

    func preloadTheme() {
        let trait = theme.traitForSize(size: frame.size)
        backgroundImageView.image = trait.backgroundImage
    }

    func adjustTraits(traits: UITextInputTraits) {
        if layoutNames != layoutNamesForKeyboardType(type: traits.keyboardType) {
            loadCollections(traits: traits)
        }

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

        for collection in collections {
            for layout in collection.layouts {
                layout.view.doneButton.captionLabel.text = returnTitle
                layout.adjustTraits(traits: traits)
            }
        }
    }

    func layoutNamesForKeyboardType(type: UIKeyboardType?) -> [String] {
        if let type = type {
            switch type {
            case .asciiCapable:
                return ["ascii"]
            case .numberPad:
                return ["number"]
            case .numbersAndPunctuation:
                return ["numberpunc"]
            case .phonePad:
                return ["phone"]
            case .namePhonePad:
                return preferences.layouts // temp
            case .decimalPad:
                return ["decimal"]
            default:
                return preferences.layouts
            }
        } else {
            return preferences.layouts
        }
    }

    func loadCollections(traits: UITextInputTraits) {
        var layoutNames = layoutNamesForKeyboardType(type: traits.keyboardType)
        self.layoutNames = layoutNames

        for view in layoutsView.subviews {
            view.removeFromSuperview()
        }

//        원근 모드
//        let image = self.theme.backgroundImage
//        if image != nil {
//            self.inputMethodView.backgroundImageView.image = image
//        }

        // assert(preferences.themeResources.count > 0)
        collections.removeAll(keepingCapacity: true)

        let firstLayout = preferences.layouts.first
        let lastLayout = preferences.layouts.last
        if let fisrt = firstLayout, let last = lastLayout {
            layoutNames.insert(last, at: 0)
            layoutNames.insert(fisrt, at: layoutNames.count)
        }

        for (i, name) in layoutNames.enumerated() {
            assert(bounds.height > 0)
            assert(bounds.width > 0)
            let collection = keyboardLayoutCollectionForLayoutName(name: name, frame: bounds)
            collections.append(collection)
            for layout in collection.layouts {
                layout.view.frame.origin.x = CGFloat(i) * frame.width
            }
            layoutsView.addSubview(collection.selectedLayout.view)
        }

        pageControl.numberOfPages = collections.count
        selectCollectionByIndex(index: preferences.defaultLayoutIndex, animated: false)

        // self.backgroundImageView.image = nil

        selectedCollectionIndex = preferences.defaultLayoutIndex < collections.count ? preferences.defaultLayoutIndex : 0
        adjustedSize = CGSize.zero
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        if adjustedSize == size {
            return
        }

        adjustedSize = size

//        globalInputViewController?.log("transitionViewToSize: \(size)")
        let theme = self.theme
        let trait = theme.traitForSize(size: size)

        let viewBounds = CGRect(origin: CGPoint.zero, size: size)
        layoutsView.frame = viewBounds
        // self.backgroundImageView.frame = viewBounds
        pageControl.center = CGPoint(x: size.width / 2, y: size.height - 20.0)

        for (i, collection) in collections.enumerated() {
            for layout in collection.layouts {
                layout.view.frame.origin.x = CGFloat(i) * size.width
                layout.view.frame.size = size
            }
        }

//        dispatch_async(dispatch_get_main_queue(), {
        for collection in collections {
            for layout in collection.layouts {
                layout.view.backgroundImageView.image = trait.backgroundImage
                layout.view.foregroundImageView.image = trait.foregroundImage
                layout.transitionViewToSize(size: size, withTransitionCoordinator: coordinator)
            }
        }
//        })
        selectCollectionByIndex(index: selectedCollectionIndex, animated: false)
    }

    func selectCollectionByIndex(index: Int, animated: Bool) {
        selectedCollectionIndex = index
        let newWidth = frame.width * CGFloat(collections.count)
        layoutsView.frame = frame
        layoutsView.contentSize = CGSize(width: newWidth, height: 0)
        // globalInputViewController?.log("layoutview frame: \(self.layoutsView.frame)")

        // 스크롤 하기 전의 offset으로 설정한다
        if index == layoutNames.count + 1 {
            let tempOffset = CGFloat(0) * frame.width
            layoutsView.contentOffset = CGPoint(x: tempOffset, y: 0)
            selectedCollectionIndex = 1
        } else if index == 0 {
            let tempOffset = CGFloat(layoutNames.count + 1) * frame.width
            layoutsView.contentOffset = CGPoint(x: tempOffset, y: 0)
            selectedCollectionIndex = layoutNames.count
        }

        pageControl.currentPage = selectedCollectionIndex
        let offset = CGFloat(selectedCollectionIndex) * frame.width
        layoutsView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)

        for (i, collection) in collections.enumerated() {
            collection.selectLayoutIndex(index: 0)
            for (j, layout) in collection.layouts.enumerated() {
                if i == index, j == collection.selectedLayoutIndex {
                    break
                }
                layout.view.shiftButton?.isSelected = false
                for button in layout.helper.buttons.values + layout.view.visibleButtons {
                    button.hideEffect()
                }
            }
        }

        pageControl.alpha = 1.0
        let animation = { self.pageControl.alpha = 0.0 }
        if animated {
            UIView.animate(withDuration: 0.36, animations: animation)
        } else {
            animation()
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        pageControl.alpha = 1.0
    }

    func scrollViewDidScroll(_: UIScrollView) {
        pageControl.currentPage = selectedCollectionIndex
    }
}
