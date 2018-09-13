//
//  InputViewController.swift
//  inputmethod
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

var crashlyticsInitialized = false

var globalInputViewController: InputViewController? = nil
var sharedInputMethodView: InputMethodView? = nil
var launchedDate: NSDate = NSDate()

class BasicInputViewController: UIInputViewController {
    lazy var inputMethodView: InputMethodView = { return InputMethodView(frame: self.view.bounds) }()
    var willContextBeforeInput: String = ""
    var willContextAfterInput: String = ""
    var didContextBeforeInput: String = ""
    var didContextAfterInput: String = ""

    override func textWillChange(_ textInput: UITextInput?) {
        //self.log("text will change")
        super.textWillChange(textInput)
        let proxy = self.textDocumentProxy
        self.willContextBeforeInput = proxy.documentContextBeforeInput ?? ""
        self.willContextAfterInput = proxy.documentContextAfterInput ?? ""
    }

    override func textDidChange(_ textInput: UITextInput?) {
        //self.log("text did change")
        let proxy = self.textDocumentProxy
        self.didContextBeforeInput = proxy.documentContextBeforeInput ?? ""
        self.didContextAfterInput = proxy.documentContextAfterInput ?? ""
        super.textDidChange(textInput)
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
        #if DEBUG
        println(text)
        return;

        let diff = String(format: "%.3f", NSDate().timeIntervalSinceDate(launchedDate))
        self.logTextView.text = diff + "> " +  text + "\n" + self.logTextView.text
        self.view.bringSubviewToFront(self.logTextView)
        #endif
    }

    func input(_ sender: GRInputButton) {

    }

    func inputDelete(_ sender: GRInputButton) {

    }

    func reloadInputMethodView() {

    }
    
}

class DebugInputViewController: BasicInputViewController {
    var initialized = false
    var modeDate = NSDate()

    override func loadView() {
        self.view = self.inputMethodView
    }

    override func viewDidLoad() {
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        self.log(text: "loaded: \(self.view.frame)")
        //globalInputViewController = self
        super.viewDidLoad()

        self.initialized = true
        let proxy = self.textDocumentProxy as UITextInputTraits
        self.log(text: "adding input method view")
        self.inputMethodView.loadCollections(traits: proxy)
        self.log(text: "added method view")
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
        let proxy = self.textDocumentProxy as UITextInputTraits
        self.inputMethodView.loadCollections(traits: proxy)
        //self.inputMethodView.adjustTraits(proxy)
        self.inputMethodView.adjustedSize = CGSize.zero
        //println("bounds: \(self.view.bounds)")
        self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: nil)
    }

    override func viewDidLoad() {
        if !crashlyticsInitialized {
            //Crashlytics().debugMode = true
//            Crashlytics.startWithAPIKey("1b5d8443c3eabba778b0d97bff234647af846181")
            Fabric.with([Crashlytics()])
            crashlyticsInitialized = true
        }
        //assert(globalInputViewController == nil, "input view controller is set?? \(globalInputViewController)")
        //self.log("loaded: \(self.view.frame)")
        super.viewDidLoad()

        globalInputViewController = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialized && self.view.bounds != CGRect.zero {
            self.view = self.inputMethodView
            let traits = self.textDocumentProxy as UITextInputTraits
            self.lastTraits = traits
            self.inputMethodView.loadCollections(traits: traits)

            if preferences.swipe {
                let leftRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("leftForSwipeRecognizer:"))
                leftRecognizer.direction = .left
                let rightRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("rightForSwipeRecognizer:"))
                rightRecognizer.direction = .right
                self.view.addGestureRecognizer(leftRecognizer)
                self.view.addGestureRecognizer(rightRecognizer)
            }

            initialized = true
        }
    }

    override func viewDidLayoutSubviews() {
        if initialized {
            self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: self.transitionCoordinator)
        }
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
//        self.keyboard.view.logTextView.text = ""
        super.textDidChange(textInput)
        if !initialized {
            return
        }

        if self.willContextBeforeInput != self.didContextBeforeInput || self.willContextAfterInput != self.didContextAfterInput {
            self.inputMethodView.resetContext()
            self.inputMethodView.selectedCollection.selectLayoutIndex(index: 0)
            self.inputMethodView.selectedLayout.view.shiftButton?.isSelected = false
            self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        }
        if let traits = textInput as UITextInput? {
            self.lastTraits = traits // for app
        } else {
            self.lastTraits = self.textDocumentProxy as UITextInputTraits // for keyboard
        }
        self.adjustTraits(traits: self.lastTraits)
    }

    func adjustTraits(traits: UITextInputTraits) {
        var textColor: UIColor
        if traits.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }

        self.inputMethodView.adjustTraits(traits: traits)
        self.inputMethodView.transitionViewToSize(size: self.view.bounds.size, withTransitionCoordinator: nil)

        let selectedLayout = self.inputMethodView.selectedLayout
        let proxy = self.textDocumentProxy

        if traits.enablesReturnKeyAutomatically ?? false && (self.didContextBeforeInput.count + self.didContextAfterInput.count) == 0 {
            selectedLayout.view.doneButton.isEnabled = false
        } else {
            selectedLayout.view.doneButton.isEnabled = true
        }

        if type(of: selectedLayout).capitalizable {
            if selectedLayout.shift == .Auto {
                selectedLayout.shift = .Off
            }
            if type(of: selectedLayout).capitalizable && selectedLayout.shift != .Auto {
                var needsShift = false
                switch traits.autocapitalizationType! {
                case .allCharacters:
                    needsShift = true
                case .words:
                    if self.didContextBeforeInput.count == 0 {
                        needsShift = true
                    } else {
                        let whitespaces = NSCharacterSet.whitespacesAndNewlines
                        let lastCharacter =  self.didContextBeforeInput.unicodeScalars.last!
                        needsShift = whitespaces.contains(lastCharacter)
                    }
                case .sentences:
                    let whitespaces = NSCharacterSet.whitespaces
                    
                    // FIXME: porting
                    /*
                    let punctuations = NSCharacterSet(charactersIn: ".!?")
                    let utf16 = self.didContextBeforeInput.utf16 
                    var index = utf16.endIndex
                    needsShift = true
                    while index != utf16.startIndex {
                        index = index.predecessor()
                        let code = utf16[index]
                        if punctuations.characterIsMember(code) || code == 10 {
                            let nextIndex = index.successor()
                            if utf16.endIndex != nextIndex && utf16[nextIndex] == 32 {
                                break
                            }
                        }
                        if !whitespaces.characterIsMember(code) {
                            needsShift = false
                            break
                        }
                    }
                    */
                default: break
                }
                if needsShift {
                    selectedLayout.shift = .Auto
                }
            }
        }
        //self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    @objc override func input(_ sender: GRInputButton) {
        //Crashlytics().crash()
        let proxy = self.textDocumentProxy
        self.log(text: "before: \(proxy.documentContextBeforeInput)")

        let selectedLayout = self.inputMethodView.selectedLayout
        for collection in self.inputMethodView.collections {
            for layout in collection.layouts {
                if selectedLayout.context != layout.context && layout.context != nil {
                    context_truncate(layout.context)
                }
            }
        }

        if sender.sequence != nil {
            (self.textDocumentProxy as UIKeyInput).insertText(sender.sequence)
            return
        }

        let context = selectedLayout.context
        let shiftButton = selectedLayout.view.shiftButton

        let keycode: UInt32
        if sender.keycodes.count > 1 && shiftButton?.isSelected ?? false {
            keycode = UInt32(sender.keycodes[1] as! UInt)
        } else {
            keycode = sender.keycode
        }

        if type(of: selectedLayout).autounshift && shiftButton?.isSelected ?? false {
            shiftButton?.isSelected = false
            selectedLayout.helper.updateCaptionLabel()
        }

        selectedLayout.view.doneButton.isEnabled = true

        //assert(selectedLayout.view.spaceButton != nil)
        //assert(selectedLayout.view.doneButton != nil)
        if sender == selectedLayout.view.spaceButton ?? nil || sender == selectedLayout.view.doneButton ?? nil {
            self.inputMethodView.selectedCollection.selectLayoutIndex(index: 0)
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

        let precomposed = context_get_composed_unicodes(context: context!)
        let processed = context_put(context, UInt32(keycode))
        //self.log("processed: \(processed) / precomposed: \(precomposed)")

        if processed == 0 {
            self.inputMethodView.resetContext()
            
            if let opForced = UnicodeScalar(keycode) {
                proxy.insertText("\(UnicodeScalar(keycode)!)")
            } else {
                print("Optional clear fail!")
            }
            //self.log("truncate and insert: \(UnicodeScalar(keycode))")
            
        } else {
            let commited = context_get_commited_unicodes(context: context!)
            let composed = context_get_composed_unicodes(context: context!)
            let combined = commited + composed
            //self.log("combined: \(combined)")
            var sharedLength = 0
            for (i, char) in precomposed.enumerated() {
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
                let string = unicodes_to_string(unicodes: unsharedCombined)
                proxy.insertText(string)
            }
            //self.log("-- inserted")
            self.log(text: "commited: \(commited) / composed: \(composed)")

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
        self.log(text: "input done")
        //self.log("after: \(proxy.documentContextAfterInput)")
    }

    @objc override func inputDelete(_ sender: GRInputButton) {
        let proxy = self.textDocumentProxy
        let context = self.inputMethodView.selectedLayout.context
        let precomposed = context_get_composed_unicodes(context: context!)
        if precomposed.count > 0 {
            let processed = context_put(context, InputSource(sender.keycode))
            let proxy = self.textDocumentProxy as UIKeyInput
            if processed > 0 {
                //self.log("start deleting")
                let commited = context_get_commited_unicodes(context: context!)
                let composed = context_get_composed_unicodes(context: context!)
                let combined = commited + composed
                //self.log("combined: \(combined)")
                var sharedLength = 0
                for (i, char) in combined.enumerated() {
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
                    let composed = unicodes_to_string(unicodes: unsharedCombined)
                    proxy.insertText("\(composed)")
                }
                //self.log("end deleting")
            } else {
                proxy.deleteBackward()
            }
            //self.log("deleted and add \(UnicodeScalar(composed))")
        } else {
            (self.textDocumentProxy as UIKeyInput).deleteBackward()
            //self.log("deleted")
        }
    }

    @objc func space(_ sender: GRInputButton) {
        let proxy = self.textDocumentProxy
        self.input(sender)
    }

    @objc func shift(_ sender: GRInputButton) {
        self.inputMethodView.selectedLayout.shift = sender.isSelected ? .Off : .On
    }

    @objc func toggleLayout(_ sender: GRInputButton) {
        self.inputMethodView.selectedLayout.shift = .Off
        let collection = self.inputMethodView.selectedCollection
        collection.switchLayout()
        collection.selectedLayout.view.toggleKeyboardButton.isSelected = collection.selectedLayoutIndex != 0
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        self.adjustTraits(traits: self.lastTraits)
    }

    @objc func selectLayout(_ sender: GRInputButton) {
        let collection = self.inputMethodView.selectedCollection
        collection.selectLayoutIndex(index: sender.tag)
        self.inputMethodView.selectedLayout.helper.updateCaptionLabel()
        self.adjustTraits(traits: self.lastTraits)
    }

    @objc func done(_ sender: GRInputButton) {
        self.inputMethodView.resetContext()
        sender.keycode = 13
        self.input(sender)
    }

    @objc func mode(_ sender: GRInputButton) {
        let now = NSDate()
        var needsNextInputMode = false
        if preferences.inglobe {
            if now.timeIntervalSince(self.modeDate as Date) < 0.5 {
                needsNextInputMode = true
            }
        } else {
            needsNextInputMode = true
        }
        if needsNextInputMode {
            self.advanceToNextInputMode()
        } else {
            let newIndex = self.inputMethodView.selectedCollectionIndex == 0 ? 1 : 0;
            self.inputMethodView.selectCollectionByIndex(index: newIndex, animated: true)
            self.modeDate = now
            self.adjustTraits(traits: self.lastTraits)
        }
    }

    @objc func leftForSwipeRecognizer(_ recognizer: UISwipeGestureRecognizer!) {
        let index = self.inputMethodView.selectedCollectionIndex
        if index < self.inputMethodView.collections.count - 1 {
            self.inputMethodView.selectCollectionByIndex(index: index + 1, animated: true)
            self.adjustTraits(traits: self.lastTraits)
        } else {
            self.inputMethodView.selectCollectionByIndex(index: 0, animated: true)
        }
    }

    @objc func rightForSwipeRecognizer(_ recognizer: UISwipeGestureRecognizer!) {
        let index = self.inputMethodView.selectedCollectionIndex
        if index > 0 {
            self.inputMethodView.selectCollectionByIndex(index: index - 1, animated: true)
            self.adjustTraits(traits: self.lastTraits)
        } else {
            self.inputMethodView.selectCollectionByIndex(index: self.inputMethodView.collections.count - 1, animated: true)
        }
    }

//    func untouch(sender: UIButton) {
//        context_put(self.inputMethodView.selectedLayout.context, InputSource(0))
//    }

    @objc func error(_ sender: UIButton) {
        self.inputMethodView.resetContext()
        let proxy = self.textDocumentProxy
        #if DEBUG
        proxy.insertText("<error: \(sender.tag)>")
        #endif
    }

}
