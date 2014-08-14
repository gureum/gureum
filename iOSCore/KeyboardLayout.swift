//
//  KeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class KeyboardView: UIView {
    @IBOutlet var nextKeyboardButton: UIButton! = nil
    @IBOutlet var toggleKeyboardButton: UIButton! = nil
    @IBOutlet var deleteButton: UIButton! = nil
    @IBOutlet var doneButton: UIButton! = nil
}

class NoKeyboardView: KeyboardView {
}

class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    var view: KeyboardView!
    var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: nil)
    var context: UnsafeMutablePointer<()> = nil
    var foregroundImageView: UIImageView! = nil

    var inputViewController: InputViewController? = nil {
    didSet {
        self.view.nextKeyboardButton.addTarget(self.inputViewController, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        self.view.deleteButton.addTarget(self.inputViewController, action: "delete", forControlEvents: .TouchUpInside)
    }
    }

    class func containerName() -> String {
        assert(false)
        return ""
    }

    class func loadContext() -> UnsafeMutablePointer<()> {
        assert(false)
        return nil
    }

    func _postinit() {
        self.helper.delegate = self
        self.helper.layoutIn(self.view)

        self.view.nextKeyboardButton.addTarget(self.inputViewController, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        self.view.deleteButton.addTarget(self.inputViewController, action: "delete", forControlEvents: .TouchUpInside)
        self.context = self.dynamicType.loadContext()
    }

    init(nibName: String, bundle: NSBundle?) {
        let vc = UIViewController(nibName: nibName, bundle: bundle)
        self.view = vc.view as KeyboardView
        _postinit()
    }

    init() {
        self.view = nil // mad limitation
        let name = self.dynamicType.containerName()
        let vc = UIViewController(nibName: name, bundle: nil)
        self.view = vc.view as KeyboardView
        _postinit()

    }

    func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        assert(false)
        return UIEdgeInsetsZero
    }

    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        assert(false)
        return 0;
    }

    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, generatedButtonForPosition position: GRKeyboardLayoutHelper.Position) -> UIButton {
        assert(false)
        UIButton()
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func containerName() -> String {
        return "NoLayout"
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return nil
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int) -> CGFloat {
        return 208
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int) -> CGFloat {
        return 320
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, generatedButtonForPosition position: GRKeyboardLayoutHelper.Position) -> UIButton {
        let button = GRInputButton.buttonWithType(.System) as UIButton
        button.tag = Int(UnicodeScalar(" ").value)
        button.setTitle("ERROR: This is a bug.", forState: .Normal)
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }    
}
