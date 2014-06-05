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

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.helper = GRKeyboardLayoutHelper(delegate: nil)
        self.keyboard = QwertyKeyboardLayout(nibName: "Container", bundle: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.keyboard.inputViewController = self
        self.helper.delegate = keyboard
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

    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.keyboard.view.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    func input(sender: UIButton) {
        let proxy = self.textDocumentProxy as UIKeyInput;
        proxy.insertText("\(Character(UnicodeScalar(sender.tag)))")
    }
}
