//
//  KeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class KeyboardView: UIView {
    @IBOutlet var nextKeyboardButton: GRInputButton! = nil
    @IBOutlet var toggleKeyboardButton: GRInputButton! = nil
    @IBOutlet var deleteButton: GRInputButton! = nil
    @IBOutlet var doneButton: GRInputButton! = nil
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
    }

    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int) -> CGFloat {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int) -> CGFloat {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        assert(false)
    }

    func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        assert(false)
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

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        button.tag = Int(UnicodeScalar(" ").value)
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        return "ERROR: This is a bug."
    }
}
