//
//  NumpadKeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class NumpadKeyboardView: KeyboardView {

    @IBOutlet var numberButton: UIButton!
    @IBOutlet var alphabetButton: UIButton!
    @IBOutlet var hangeulButton: UIButton!
    @IBOutlet var spaceButton: UIButton!

    override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class NumpadKeyboardLayout: KeyboardLayout {
    var numpadView: NumpadKeyboardView {
    get {
        return self.view as NumpadKeyboardView
    }
    }

    override class func loadView() -> KeyboardView {
        return KeyboardView()
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
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

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat {
        return 54
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize: CGSize) -> CGFloat {
        if row == 3 {
            return 176
        } else {
            return 34
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [self.numpadView.numberButton]
        case 2:
            return [self.numpadView.alphabetButton]
        case 3:
            return [self.numpadView.hangeulButton]
        case 4:
            return [self.numpadView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [self.numpadView.numberButton]
        case 2:
            return [self.numpadView.alphabetButton]
        case 3:
            return [self.numpadView.hangeulButton]
        case 4:
            return [self.numpadView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let keylines = ["123", "456", "789", "*0#"]
        let keyline = keylines[position.row].unicodeScalars
        let idx = advance(keyline.startIndex, position.column)
        let key = keyline[idx]

        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", forState: .Normal)
        } else {
            button.setTitle("\(Character(UnicodeScalar(key)))", forState: .Normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)

        return button
    }

}

class CheonjiinKeyboardLayout: NumpadKeyboardLayout {

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(ksx5002_from_qwerty_phase(), ksx5002_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let keylines = ["123", "456", "789", ">0."]
        let keyline = keylines[position.row].unicodeScalars
        let idx = advance(keyline.startIndex, position.column)
        let key = keyline[idx]

        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", forState: .Normal)
        } else {
            let label = key.value // ksx5002_label(Int8(key.value))
            button.setTitle("\(Character(UnicodeScalar(label)))", forState: .Normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
}
