//
//  InputViewController.swift
//  inputmethod
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

var globalInputViewController: InputViewController? = nil;

class InputViewController: UIInputViewController {
    var inputMethodViewController: InputMethodViewController = InputMethodViewController()
    var initialized = false

    lazy var logTextView: UITextView = {
        let rect = CGRectMake(0, 0, 300, 200)
        let textView = UITextView(frame: rect)
        textView.backgroundColor = UIColor.clearColor()
        textView.alpha = 0.5
        textView.userInteractionEnabled = false
        textView.textColor = UIColor.lightGrayColor()
        self.view.addSubview(textView)
        return textView
    }()

    func log(text: String) {
        return;
        self.logTextView.text = text + "\n" + self.logTextView.text
        self.view.bringSubviewToFront(self.logTextView)
    }


    // overriding `init` causes crash
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }

    func reloadInputMethodView() {
        self.inputMethodViewController.loadFromPreferences()
        //println("bounds: \(self.view.bounds)")
        self.inputMethodViewController.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: nil)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        globalInputViewController = self
        super.viewDidLoad()
//        var view = self.view
//        while true {
//            view.clipsToBounds = false
//            if let superview = view.superview {
//                view = superview
//            } else {
//                break
//            }
//        }
        
//        dispatch_async(dispatch_get_main_queue(), {
            self.view.addSubview(self.inputMethodViewController.view)
//        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.view.bounds.width > 0 && self.inputMethodViewController.view.superview == self.view {
            self.log("viewDidLayoutSubviews \(self.view.bounds)")
            self.inputMethodViewController.view.frame = self.view.bounds
            self.inputMethodViewController.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator())
            self.log("pref keys: \(preferences.themeResources.allKeys)")
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.log("viewWillTransitionToSize \(self.view.bounds)")
        //println("coordinator: \(coordinator)")

        self.inputMethodViewController.view.frame = self.view.bounds
        self.inputMethodViewController.transitionViewToSize(size, withTransitionCoordinator: coordinator)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput) {
//        self.keyboard.view.logTextView.backgroundColor = UIColor.yellowColor()
//        self.keyboard.view.logTextView.text = ""
//        self.log("text will change:")
        // The app is about to change the document's contents. Perform any preparation here.
        self.inputMethodViewController.resetContext()
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
//        self.keyboard.view.logTextView.text = ""
//        self.log("text did change:")
        self.inputMethodViewController.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.greenColor()

        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        //self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    override func selectionDidChange(textInput: UITextInput)  {
        self.inputMethodViewController.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.redColor()
    }

    override func selectionWillChange(textInput: UITextInput)  {
        self.inputMethodViewController.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.blueColor()
    }

    func input(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        //log(proxy.documentContextBeforeInput);
        //log(proxy.documentContextAfterInput);
        //println("\(self.context) \(sender.tag)")

        let selectedLayout = self.inputMethodViewController.selectedLayout
        for collection in self.inputMethodViewController.collections {
            if selectedLayout.context != collection.selectedLayout.context && collection.selectedLayout.context != nil {
                context_truncate(collection.selectedLayout.context)
            }
        }

        let context = selectedLayout.context
        let shiftButton = self.inputMethodViewController.selectedLayout.view.shiftButton
        var keycode = shiftButton.selected ? sender.tag >> 15 : sender.tag & 0x7fff
        if shiftButton.selected {
            shiftButton.selected = false
            self.inputMethodViewController.selectedLayout.helper.updateCaptionLabel()
        }

        let precomposed = context_get_composed_unicode(context)
        let processed = context_put(context, UInt32(keycode))
        //println("processed: \(processed) / precomposed: \(precomposed)")

        if !processed {
            context_truncate(context)
            proxy.insertText("\(UnicodeScalar(keycode))")
        } else {
            if precomposed > 0 {
                proxy.deleteBackward()
            }

            let commited = context_get_commited_unicode(context)
            if commited > 0 {
                proxy.insertText("\(UnicodeScalar(commited))")
            }
            let composed = context_get_composed_unicode(context)
            if composed > 0 {
                proxy.insertText("\(UnicodeScalar(composed))")
            }
            self.log("commited: \(UnicodeScalar(commited)) / composed: \(UnicodeScalar(composed))")
            //self.log(proxy.documentContextBeforeInput)
            //self.log(proxy.documentContextAfterInput)
        }
    }

    func shift(sender: UIButton) {
        sender.selected = !sender.selected
        self.inputMethodViewController.selectedLayout.helper.updateCaptionLabel()
    }

    func toggle(sender: UIButton) {
        let collection = self.inputMethodViewController.selectedCollection
        collection.switchLayout()
        self.inputMethodViewController.selectedLayout.helper.updateCaptionLabel()
    }

    func delete() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        //self.keyboard.view.logTextView.text = ""
//        log(proxy.documentContextBeforeInput);
//        log(proxy.documentContextAfterInput);
        let context = self.inputMethodViewController.selectedLayout.context
        let precomposed = context_get_composed_unicode(context)
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
        if precomposed > 0 {
            let processed = context_put(context, 0x7f)
            assert(processed)
            let composed = context_get_composed_unicode(context)
            if composed > 0 {
                proxy.insertText("\(UnicodeScalar(composed))")
            }
        }
//        log(proxy.documentContextBeforeInput);
//        log(proxy.documentContextAfterInput);
    }
}
