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

class BasicInputViewController: UIInputViewController {
    let inputMethodView = InputMethodView(frame: CGRectMake(0, 0, 320, 216))
    var willContextBeforeInput: String!
    var willContextAfterInput: String!
    var didContextBeforeInput: String!
    var didContextAfterInput: String!

    override func textWillChange(textInput: UITextInput) {
        super.textWillChange(textInput)
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        self.willContextBeforeInput = proxy.documentContextBeforeInput
        self.willContextAfterInput = proxy.documentContextAfterInput
    }

    override func textDidChange(textInput: UITextInput) {
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        self.didContextBeforeInput = proxy.documentContextBeforeInput
        self.didContextAfterInput = proxy.documentContextAfterInput
        super.textDidChange(textInput)
    }

    lazy var logTextView: UITextView = {
        let rect = CGRectMake(0, 0, 300, 200)
        let textView = UITextView(frame: rect)
        textView.backgroundColor = UIColor.clearColor()
        textView.userInteractionEnabled = false
        textView.textColor = UIColor.redColor()
        self.view.addSubview(textView)
        return textView
    }()

    func log(text: String) {
        println(text)
        return;

        let diff = String(format: "%.3f", NSDate().timeIntervalSinceDate(launchedDate))
        self.logTextView.text = diff + "> " +  text + "\n" + self.logTextView.text
        self.view.bringSubviewToFront(self.logTextView)
    }

    func input(sender: UIButton) {

    }

    func inputDelete(sender: UIButton) {

    }

    func reloadInputMethodView() {

    }
    
}

class DebugInputViewController: BasicInputViewController {
    var initialized = false
    var modeDate = NSDate()

    override func loadView() {
        //globalInputViewController = self
        self.view = self.inputMethodView
    }

    override func viewDidLoad() {
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        self.log("loaded: \(self.view.frame)")
        //globalInputViewController = self
        super.viewDidLoad()

        dispatch_async(dispatch_get_main_queue(), { // prevent timeout
            self.initialized = true
            let proxy = self.textDocumentProxy as! UITextInputTraits
            self.log("adding input method view")
            self.inputMethodView.loadFromTheme(proxy)
            self.log("added method view")
        })
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if initialized {
            //self.log("viewWillLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator())
        }
    }

    override func viewDidLayoutSubviews() {
        if initialized {
            //self.log("viewDidLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator())
        }
        super.viewDidLayoutSubviews()
    }
}

class InputViewController: BasicInputViewController {
    var initialized = false
    var modeDate = NSDate()
    var lastTraits: UITextInputTraits! = nil

    // overriding `init` causes crash
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }

    override func reloadInputMethodView() {
        let proxy = self.textDocumentProxy as! UITextInputTraits
        self.inputMethodView.loadFromTheme(proxy)
        //self.inputMethodView.adjustTraits(proxy)
        self.inputMethodView.lastSize = CGSizeZero
        //println("bounds: \(self.view.bounds)")
        self.inputMethodView.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: nil)
    }

    override func loadView() {
        globalInputViewController = self
        self.view = self.inputMethodView
        if preferences.swipe {
            let leftRecognizer = UISwipeGestureRecognizer(target: self, action: "leftForSwipeRecognizer:")
            leftRecognizer.direction = .Left
            self.view.addGestureRecognizer(leftRecognizer)
            let rightRecognizer = UISwipeGestureRecognizer(target: self, action: "rightForSwipeRecognizer:")
            rightRecognizer.direction = .Right
            self.view.addGestureRecognizer(rightRecognizer)
        }
    }

    override func viewDidLoad() {
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        //self.log("loaded: \(self.view.frame)")
        super.viewDidLoad()

        dispatch_async(dispatch_get_main_queue(), { // prevent timeout
            self.initialized = true
            let proxy = self.textDocumentProxy as! UITextInputTraits
            //self.log("adding input method view")
            self.inputMethodView.loadFromTheme(proxy)
            //self.inputMethodView.adjustTraits(proxy)
            //self.log("added method view")
        })
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if initialized {
            //self.log("viewWillLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator())
        }
    }

    override func viewDidLayoutSubviews() {
        if initialized {
            //self.log("viewDidLayoutSubviews \(self.view.bounds)")
            self.inputMethodView.transitionViewToSize(self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator())
        }
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
//        self.keyboard.view.logTextView.text = ""
        self.log("text did change")

        super.textDidChange(textInput)

        if self.willContextBeforeInput != self.didContextBeforeInput || self.willContextAfterInput != self.didContextAfterInput {
            self.inputMethodView.resetContext()
            self.inputMethodView.selectedCollection.selectLayoutIndex(0)
            self.inputMethodView.selectedLayout.view.shiftButton.selected = false
            self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        }
        self.lastTraits = textInput as UITextInputTraits
        self.adjustTraits(textInput as UITextInputTraits)
    }

    func adjustTraits(traits: UITextInputTraits) {
        var textColor: UIColor
        if traits.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.inputMethodView.adjustTraits(traits)

        if self.inputMethodView.selectedLayout.capitalizable {
            if self.inputMethodView.selectedLayout.shift == .Auto {
                self.inputMethodView.selectedLayout.shift = .Off
            }
            if self.inputMethodView.selectedLayout.capitalizable && self.inputMethodView.selectedLayout.shift != .Auto {
                var needsShift = false
                switch traits.autocapitalizationType! {
                case .AllCharacters:
                    needsShift = true
                case .Words:
                    if self.didContextBeforeInput == nil || count(self.didContextBeforeInput) == 0 {
                        needsShift = true
                    } else {
                        let whitespaces = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                        let punctuations = NSCharacterSet.punctuationCharacterSet()
                        let utf16 = self.didContextBeforeInput.utf16
                        let lastCharacter = utf16[utf16.endIndex.predecessor()]
                        needsShift = whitespaces.characterIsMember(lastCharacter) || punctuations.characterIsMember(lastCharacter)
                    }
                case .Sentences:
                    if self.didContextBeforeInput == nil {
                        needsShift = true
                    } else {
                        let whitespaces = NSCharacterSet.whitespaceCharacterSet()
                        let punctuations = NSCharacterSet.punctuationCharacterSet()
                        let utf16 = self.didContextBeforeInput.utf16
                        var index = utf16.endIndex
                        needsShift = true
                        while index != utf16.startIndex {
                            index = index.predecessor()
                            let code = utf16[index]
                            if punctuations.characterIsMember(code) || code == 10 {
                                break
                            }
                            if !whitespaces.characterIsMember(code) {
                                needsShift = false
                                break
                            }
                        }
                    }
                default: break
                }
                if needsShift {
                    self.inputMethodView.selectedLayout.shift = .Auto
                }
            }
        }
        //self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    override func selectionDidChange(textInput: UITextInput)  {
        self.log("selection did change:")
        self.inputMethodView.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.redColor()
    }

    override func selectionWillChange(textInput: UITextInput)  {
        self.log("selection will change:")
        self.inputMethodView.resetContext()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.blueColor()
    }

    override func input(sender: UIButton) {
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        self.log("before: \(proxy.documentContextBeforeInput)");
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
        var keycode = shiftButton.selected ? sender.tag >> 15 : sender.tag & 0x7fff
        if shiftButton.selected {
            shiftButton.selected = false
            self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        }

        assert(selectedLayout.view.spaceButton != nil)
        assert(selectedLayout.view.doneButton != nil)
        if sender == selectedLayout.view.spaceButton || sender == selectedLayout.view.doneButton {
            self.inputMethodView.selectedCollection.selectLayoutIndex(0)
            self.inputMethodView.resetContext()
            // FIXME: dirty solution
            if sender == selectedLayout.view.spaceButton {
                proxy.insertText(" ")
            }
            else if sender == selectedLayout.view.doneButton {
                proxy.insertText("\n")
            }
            return
        }

        let precomposed = context_get_composed_unicodes(context)
        let processed = context_put(context, UInt32(keycode))
        //self.log("processed: \(processed) / precomposed: \(precomposed)")

        if !processed {
            self.inputMethodView.resetContext()
            proxy.insertText("\(UnicodeScalar(keycode))")
            //self.log("truncate and insert: \(UnicodeScalar(keycode))")
        } else {
            let commited = context_get_commited_unicodes(context)
            let composed = context_get_composed_unicodes(context)
            let combined = commited + composed
            //self.log("combined: \(combined)")
            var sharedLength = 0
            for (i, char) in enumerate(precomposed) {
                if char == combined[i] {
                    sharedLength = i + 1
                } else {
                    break
                }
            }

            let unsharedPrecomposed = Array(precomposed[sharedLength..<precomposed.count])
            let unsharedCombined = Array(combined[sharedLength..<combined.count])

            //self.log("-- deleting")
            for _ in unsharedPrecomposed {
                proxy.deleteBackward()
            }
            //self.log("-- deleted")

            //self.log("-- inserting")
            //self.log("shared length: \(sharedLength) unshared text: \(unsharedCombined)")
            if unsharedCombined.count > 0 {
                let string = unicodes_to_string(unsharedCombined)
                proxy.insertText(string)
            }
            //self.log("-- inserted")
            self.log("commited: \(commited) / composed: \(composed)")

            /*
            let NFDPrecomposed = unicodes_nfc_to_nfd(unsharedPrecomposed)
            let NFDCombined = unicodes_nfc_to_nfd(unsharedCombined)

            var NFDSharedLength = 0
            for (i, char) in enumerate(NFDPrecomposed) {
                if char == NFDCombined[i] {
                    NFDSharedLength = i + 1
                } else {
                    break
                }
            }

            let NFDUnsharedPrecomposed = Array(NFDPrecomposed[NFDSharedLength..<NFDPrecomposed.count])
            let NFDUnsharedCombined = Array(NFDCombined[NFDSharedLength..<NFDCombined.count])

            if NFDUnsharedPrecomposed.count == 0 {
                if NFDUnsharedCombined.count > 0 {
                    let string = unicodes_to_string(NFDUnsharedCombined)
                    proxy.insertText(string)
                }
            } else {
                //self.log("-- deleting")
                for _ in unsharedPrecomposed {
                    proxy.deleteBackward()
                }
                self.needsProtection = !proxy.hasText()
                //self.log("-- deleted")

                //self.log("-- inserting")
                //self.log("shared length: \(sharedLength) unshared text: \(unsharedCombined)")
                if unsharedCombined.count > 0 {
                    let string = unicodes_to_string(NFDCombined)
                    proxy.insertText(string)
                }
                //self.log("-- inserted")
                self.log("commited: \(commited) / composed: \(composed)")
            }
            */

        }
        self.log("input done")
        //self.log("after: \(proxy.documentContextAfterInput)")
    }

    override func inputDelete(sender: UIButton) {
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        let context = self.inputMethodView.selectedLayout.context
        let precomposed = context_get_composed_unicodes(context)
        if precomposed.count > 0 {
            let processed = context_put(context, InputSource(sender.tag))
            let proxy = self.textDocumentProxy as! UIKeyInput
            if processed {
                //self.log("start deleting")
                let commited = context_get_commited_unicodes(context)
                let composed = context_get_composed_unicodes(context)
                let combined = commited + composed
                //self.log("combined: \(combined)")
                var sharedLength = 0
                for (i, char) in enumerate(combined) {
                    if char == precomposed[i] {
                        sharedLength = i + 1
                    } else {
                        break
                    }
                }
                let unsharedPrecomposed = Array(precomposed[sharedLength..<precomposed.count])
                let unsharedCombined = Array(combined[sharedLength..<combined.count])

                for _ in unsharedPrecomposed {
                    proxy.deleteBackward()
                }

                if unsharedCombined.count > 0 {
                    let composed = unicodes_to_string(unsharedCombined)
                    proxy.insertText("\(composed)")
                }
                //self.log("end deleting")
            } else {
                proxy.deleteBackward()
            }
            //self.log("deleted and add \(UnicodeScalar(composed))")
        } else {
            (self.textDocumentProxy as! UIKeyInput).deleteBackward()
            //self.log("deleted")
        }
    }

    func space(sender: UIButton) {
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        self.input(sender)
    }

    func shift(sender: UIButton) {
        self.inputMethodView.selectedLayout.shift = sender.selected ? .Off : .On
    }

    func toggleLayout(sender: UIButton) {
        let collection = self.inputMethodView.selectedCollection
        collection.switchLayout()
        collection.selectedLayout.view.toggleKeyboardButton.selected = collection.selectedLayoutIndex != 0
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        self.adjustTraits(self.lastTraits)
    }

    func selectLayout(sender: UIButton) {
        let collection = self.inputMethodView.selectedCollection
        collection.selectLayoutIndex(sender.tag)
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        self.adjustTraits(self.lastTraits)
    }

    func done(sender: UIButton) {
        self.inputMethodView.resetContext()
        sender.tag = (13 << 15) + 13
        self.input(sender)
    }

    func mode(sender: UIButton) {
        let now = NSDate()
        var needsNextInputMode = false
        if preferences.inglobe {
            if now.timeIntervalSinceDate(self.modeDate) < 0.5 {
                needsNextInputMode = true
            }
        } else {
            needsNextInputMode = true
        }
        if needsNextInputMode {
            self.advanceToNextInputMode()
        } else {
            let newIndex = self.inputMethodView.selectedCollectionIndex == 0 ? 1 : 0;
            self.inputMethodView.selectCollectionByIndex(newIndex, animated: true)
            self.modeDate = now
            self.adjustTraits(self.lastTraits)
        }
    }

    func leftForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.inputMethodView.selectedCollectionIndex
        if index < self.inputMethodView.collections.count - 1 {
            self.inputMethodView.selectCollectionByIndex(index + 1, animated: true)
            self.adjustTraits(self.lastTraits)
        }
    }

    func rightForSwipeRecognizer(recognizer: UISwipeGestureRecognizer!) {
        let index = self.inputMethodView.selectedCollectionIndex
        if index > 0 {
            self.inputMethodView.selectCollectionByIndex(index - 1, animated: true)
            self.adjustTraits(self.lastTraits)
        }
    }

//    func untouch(sender: UIButton) {
//        context_put(self.inputMethodView.selectedLayout.context, InputSource(0))
//    }

    func error(sender: UIButton) {
        self.inputMethodView.resetContext()
        let proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText("<error: \(sender.tag)>");
    }

}
