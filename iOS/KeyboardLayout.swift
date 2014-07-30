//
//  QwertyKeyboard.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class KeyboardView: UIView {
    @IBOutlet var logTextView: UITextView!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var toggleKeyboardButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var shiftButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
}

class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    let view: KeyboardView
    var inputViewController: KeyboardViewController? = nil {
        didSet {
            self.view.nextKeyboardButton.addTarget(self.inputViewController, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
            self.view.deleteButton.addTarget(self.inputViewController, action: "delete", forControlEvents: .TouchUpInside)
        }
    }

    init(nibName: String, bundle: NSBundle?) {
        let vc = UIViewController(nibName: nibName, bundle: nil)
        self.view = vc.view as KeyboardView
    }

    // --

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

class QwertyKeyboardLayout: KeyboardLayout {
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
        return 40
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int) -> CGFloat {
        if row == 3 {
            return 176
        } else {
            return 28
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [UIButton(frame: CGRectMake(0, 0, 10, 10))]
        case 2:
            return [self.view.shiftButton]
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
            button.setTitle("\(Character(key))", forState: .Normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(self.inputViewController, action: "input:", forControlEvents: .TouchUpInside)
        button.alpha = 0.5


        let defaults = NSUserDefaults(suiteName: "group.org.youknowone.Gureum")
        let data: String? = defaults.objectForKey("test") as String!
        var title: String
        if data {
            title = data!
        } else {
            title = "X"
        }
        button.setTitle(title, forState: .Normal)
        return button
    }

}
