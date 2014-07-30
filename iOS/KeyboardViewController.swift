//
//  KeyboardViewController.swift
//  inputmethod
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    var helper: GRKeyboardLayoutHelper
    var keyboard: KeyboardLayout
    var context: UnsafePointer<()>

    func _postinit() {
        self.keyboard.inputViewController = self
        self.helper.delegate = keyboard
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.helper = GRKeyboardLayoutHelper(delegate: nil)
        self.keyboard = QwertyKeyboardLayout(nibName: "Container", bundle: nil)
        self.context = _context()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _postinit()
    }

    init(coder: NSCoder) {
        self.helper = GRKeyboardLayoutHelper(delegate: nil)
        self.keyboard = QwertyKeyboardLayout(nibName: "Container", bundle: nil)
        self.context = _context()
        super.init(coder: coder)
        _postinit()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bounds = self.keyboard.view.bounds
        self.view.addSubview(self.keyboard.view)

        if let logView = self.keyboard.view.subviews[0] as? UITextView {
            logView.text = "\(self.keyboard.view)"
        }
        // Perform custom UI setup here

//    
//        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
//        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
//        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])

        self.helper.layoutIn(self.keyboard.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput!) {
//        self.keyboard.view.logTextView.backgroundColor = UIColor.yellowColor()
//        self.keyboard.view.logTextView.text = ""
//        self.log("text will change:")
        // The app is about to change the document's contents. Perform any preparation here.
        self.context = _context()
    }

    override func textDidChange(textInput: UITextInput!) {
        // The app has just changed the document's contents, the document context has been updated.
//        self.keyboard.view.logTextView.text = ""
//        self.log("text did change:")
        self.context = _context()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.greenColor()

        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    override func selectionDidChange(textInput: UITextInput!)  {
        self.context = _context()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.redColor()
    }

    override func selectionWillChange(textInput: UITextInput!)  {
        self.context = _context()
//        self.keyboard.view.logTextView.backgroundColor = UIColor.blueColor()
    }

    func log(text: String?) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        if text == nil {
            self.keyboard.view.logTextView.text = self.keyboard.view.logTextView.text + proxy.documentContextBeforeInput + "\n"
        } else {
            self.keyboard.view.logTextView.text = self.keyboard.view.logTextView.text + "(null)\n"
        }
    }

    func input(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
//        self.keyboard.view.logTextView.text = ""
//        log(proxy.documentContextBeforeInput);
//        log(proxy.documentContextAfterInput);
//        println("\(self.context) \(sender.tag)")

        let had_state = _state(self.context)
        if had_state > 0 {
            proxy.deleteBackward()
        }
        let r = _put(self.context, UInt32(sender.tag))
        if r > 0 {
            proxy.insertText("\(UnicodeScalar(r))")
        }
        let s = _state(self.context)
        if s > 0 {
            proxy.insertText("\(UnicodeScalar(s))")
        }

        log(proxy.documentContextBeforeInput);
        log(proxy.documentContextAfterInput);
    }

    func delete() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        self.keyboard.view.logTextView.text = ""
        log(proxy.documentContextBeforeInput);
        log(proxy.documentContextAfterInput);
        let s = _state(self.context)
        (self.textDocumentProxy as UIKeyInput).deleteBackward()
        if s > 0 {
            self.context = _context()
        }
        log(proxy.documentContextBeforeInput);
        log(proxy.documentContextAfterInput);
    }
}
