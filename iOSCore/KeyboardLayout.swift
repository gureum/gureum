//
//  QwertyKeyboard.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit
import GureumCore

class KeyboardView: UIView {
    @IBOutlet var nextKeyboardButton: UIButton! = nil
    @IBOutlet var toggleKeyboardButton: UIButton! = nil
    @IBOutlet var deleteButton: UIButton! = nil
    @IBOutlet var doneButton: UIButton! = nil
}

class NoKeyboardView: KeyboardView {
}

class QwertyKeyboardView: KeyboardView {

    @IBOutlet var shiftButton: UIButton!

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}


class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    var view: KeyboardView!
    var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: nil)
    var context: UnsafePointer<()> = nil

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

    class func loadContext() -> UnsafePointer<()> {
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
        return nil!
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func containerName() -> String {
        return "NoLayout"
    }

    override class func loadContext() -> UnsafePointer<()> {
        return nil
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
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }    
}


class QwertyKeyboardLayout: KeyboardLayout {
    var qwertyView: QwertyKeyboardView {
    get {
        return self.view as QwertyKeyboardView
    }
    }

    override class func containerName() -> String {
        return "QwertyLayout"
    }

    override class func loadContext() -> UnsafePointer<()> {
        return context_create(bypass_phase(), bypass_decoder())
    }

    override func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(12, 4, 4, 4)
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0:
            return 10
        case 1:
            return 9
        case 2:
            return 7
        case 3:
            return 1
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int) -> CGFloat {
        return 52
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int) -> CGFloat {
        if row == 3 {
            return 176
        } else {
            return 34
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [UIButton(frame: CGRectMake(0, 0, 10, 10))]
        case 2:
            return [self.qwertyView.shiftButton]
        case 3:
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [UIButton(frame: CGRectMake(0, 0, 10, 10))]
        case 2:
            return [self.view.deleteButton]
        case 3:
            return [self.view.doneButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, generatedButtonForPosition position: GRKeyboardLayoutHelper.Position) -> UIButton {
        let keylines = ["qwertyuiop", "asdfghjkl", "zxcvbnm", " "]
        let keyline = keylines[position.row].unicodeScalars
        var idx = keyline.startIndex
        for _ in 0..<position.column {
            idx = idx.successor()
        }
        let key = keyline[idx]

        let button = GRInputButton.buttonWithType(.System) as UIButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", forState: .Normal)
        } else {
            button.setTitle("\(Character(UnicodeScalar(key)))", forState: .Normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(self.inputViewController, action: "input:", forControlEvents: .TouchUpInside)

        return button
    }

}

class KSX5002KeyboardLayout: QwertyKeyboardLayout {

    override class func loadContext() -> UnsafePointer<()> {
        return context_create(ksx5002_from_qwerty_phase(), ksx5002_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, generatedButtonForPosition position: GRKeyboardLayoutHelper.Position) -> UIButton {
        let keylines = ["qwertyuiop", "asdfghjkl", "zxcvbnm", " "]
        let keyline = keylines[position.row].unicodeScalars
        var idx = keyline.startIndex
        for _ in 0..<position.column {
            idx = idx.successor()
        }
        let key = keyline[idx]

        let button = GRInputButton.buttonWithType(.System) as UIButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", forState: .Normal)
        } else {
            let label = ksx5002_label(Int8(key.value))
            button.setTitle("\(Character(UnicodeScalar(label)))", forState: .Normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(self.inputViewController, action: "input:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
}
