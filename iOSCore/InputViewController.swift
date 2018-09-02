//
//  InputViewController.swift
//  inputmethod
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

var globalInputViewController: InputViewController? = nil
var launchedDate: NSDate = NSDate()

class InputViewController: UIInputViewController {
    let inputMethodView = InputMethodView(frame: CGRect(x: 0, y: 0, width: 320, height: 216))
    var initialized = false
    var needsProtection = false
    var deleting = false
    var modeDate = NSDate()

    lazy var logTextView: UITextView = {
        let rect = CGRect(x: 0, y: 0, width: 300, height: 200)
        let textView = UITextView(frame: rect)
        textView.backgroundColor = UIColor.clear
        textView.isUserInteractionEnabled = false
        textView.textColor = UIColor.red
        self.view.addSubview(textView)
        return textView
    }()

    func log(text: String) {
        print(text)
        return;
        let diff = String(format: "%.3f", NSDate().timeIntervalSince(launchedDate as Date))
        self.logTextView.text = diff + "> " +  text + "\n" + self.logTextView.text
        self.view.bringSubview(toFront: self.logTextView)
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
        let proxy = self.textDocumentProxy as UITextInputTraits
        self.inputMethodView.loadFromTheme(traits: proxy)
        self.inputMethodView.lastSize = CGSize.zero
        //println("bounds: \(self.view.bounds)")
        self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: nil)

    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func loadView() {
        globalInputViewController = self
        self.view = self.inputMethodView
    }

    override func viewDidLoad() {
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        self.log(text: "loaded: \(self.view.frame)")
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
//        self.view.frame = CGRectMake(0.0, 0.0, 320.0, 216.0)
//        self.view.addSubview(self.inputMethodViewController.view)
//        self.log("subview: \(self.inputMethodViewController.view.bounds)")
        DispatchQueue.main.async(execute: { // prevent timeout
            self.initialized = true
            let proxy = self.textDocumentProxy as UITextInputTraits
            self.log(text: "adding input method view")
            self.inputMethodView.loadFromTheme(traits: proxy)
            self.log(text: "added method view")
        })
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if initialized {
            //self.log("viewWillLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator)
        }
    }

    override func viewDidLayoutSubviews() {
        if initialized {
            //self.log("viewDidLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator)
        }
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        //self.log("text will change: \(self.needsProtection)")
        if !self.needsProtection {
            self.inputMethodView.resetContext()
        }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
//        self.keyboard.view.logTextView.text = ""
        //self.log("text did change: \(self.needsProtection)")
        if !self.needsProtection || self.deleting {
            self.inputMethodView.resetContext()
            self.needsProtection = false
        }
//        self.keyboard.view.logTextView.backgroundColor = UIColor.greenColor()

        var textColor: UIColor
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        //self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    override func selectionDidChange(_ textInput: UITextInput?)  {
        //self.log("selection did change:")
        self.inputMethodView.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.redColor()
    }

    override func selectionWillChange(_ textInput: UITextInput?)  {
        //self.log("selection will change:")
        self.inputMethodView.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.blueColor()
    }

    func input(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        self.log(text: "before: \(String(describing: proxy.documentContextBeforeInput))");
        //println("\(self.context) \(sender.tag)")

        let selectedLayout = self.inputMethodView.selectedLayout
        for collection in self.inputMethodView.collections {
            for layout in collection.layouts {
                if selectedLayout.context != layout.context && layout.context != nil {
                    context_truncate(layout.context)
                }
            }
        }

        let context = selectedLayout.context
        let shiftButton = self.inputMethodView.selectedLayout.view.shiftButton
        let keycode = (shiftButton?.isSelected)! ? sender.tag >> 15 : sender.tag & 0x7fff
        if (shiftButton?.isSelected)! {
            shiftButton?.isSelected = false
            self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        }
        if keycode == 32 && self.inputMethodView.selectedCollection.selectedLayoutIndex != 0 {
            self.inputMethodView.selectedCollection.switchLayout()
        }

        let precomposed = context_get_composed_unicode(context: context!)
        let processed = context_put(context, UInt32(keycode))
        //self.log("processed: \(processed) / precomposed: \(precomposed)")

        if processed == 0 {
            self.inputMethodView.resetContext()
            proxy.insertText("\(String(describing: UnicodeScalar(keycode)))")
            //self.log("truncate and insert: \(UnicodeScalar(keycode))")
        } else {
            if precomposed > 0 {
                //self.log("-- deleting")
                proxy.deleteBackward()
                //self.log("-- deleted")
            }
            self.needsProtection = !proxy.hasText

            //self.log("-- inserting")
            let commited = context_get_commited_unicode(context: context!)
            if commited > 0 {
                proxy.insertText("\(String(describing: UnicodeScalar(commited)))")
            }
            let composed = context_get_composed_unicode(context: context!)
            if composed > 0 {
                proxy.insertText("\(String(describing: UnicodeScalar(composed)))")
            }
            //self.log("-- inserted")
            //self.log("commited: \(UnicodeScalar(commited)) / composed: \(UnicodeScalar(composed))")

        }
        //self.log("after: \(proxy.documentContextAfterInput)")
    }

    func shift(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
    }

    func toggle(sender: UIButton) {
        let collection = self.inputMethodView.selectedCollection
        collection.switchLayout()
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
    }

    func done(sender: UIButton) {
        self.inputMethodView.resetContext()
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText("\n")
    }

    func mode(sender: UIButton) {
        let now = NSDate()
        if now.timeIntervalSince(self.modeDate as Date) < 0.5 {
            self.advanceToNextInputMode()
        } else {
            let newIndex = self.inputMethodView.selectedLayoutIndex == 0 ? 1 : 0;
            self.inputMethodView.selectLayoutByIndex(index: newIndex, animated: true)
            self.modeDate = now
        }
    }

    func untouch(sender: UIButton) {
        self.inputMethodView.resetContext()
    }

    func error(sender: UIButton) {
        self.inputMethodView.resetContext()
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText("<error: \(sender.tag)>");
    }

    func inputDelete(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        let context = self.inputMethodView.selectedLayout.context
        let precomposed = context_get_composed_unicode(context: context!)
        self.deleting = true
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
        self.deleting = false
        if precomposed > 0 {
            let processed = context_put(context, 0x7f)
            assert(processed != 0)
            let composed = context_get_composed_unicode(context: context!)
            if composed > 0 {
                proxy.insertText("\(String(describing: UnicodeScalar(composed)))")
                //self.log("deleted and add \(UnicodeScalar(composed))")
            } else {
                //self.log("deleted")
            }
        } else {
            //self.log("deleted")
        }
    }
}
