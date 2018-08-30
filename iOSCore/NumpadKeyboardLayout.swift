//
//  NumpadKeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class NumpadKeyboardView: KeyboardView {

    @IBOutlet var numberButton: GRInputButton!
    @IBOutlet var alphabetButton: GRInputButton!
    @IBOutlet var hangeulButton: GRInputButton!
    @IBOutlet var spaceButton: GRInputButton!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class NumpadKeyboardLayout: KeyboardLayout {
    var numpadView: NumpadKeyboardView {
        get {
            return self.view as! NumpadKeyboardView
        }
    }

    override class func loadView() -> KeyboardView {
        let view = NumpadKeyboardView(frame: CGRect(x: 0, y: 0, width: 320, height: 216))

        view.numberButton = GRInputButton()
        view.numberButton.captionLabel.text = "123"
        view.alphabetButton = GRInputButton()
        view.alphabetButton.captionLabel.text = "ABC"
        view.hangeulButton = GRInputButton()
        view.hangeulButton.captionLabel.text = "한글"
        view.nextKeyboardButton = GRInputButton()
        view.nextKeyboardButton.captionLabel.text = "🌐"
        view.deleteButton = GRInputButton()
        view.deleteButton.captionLabel.text = "⌫"
        view.doneButton = GRInputButton()
        view.toggleKeyboardButton = GRInputButton()
        view.toggleKeyboardButton.captionLabel.text = "123"
        view.shiftButton = GRInputButton()
        view.shiftButton.captionLabel.text = "⬆︎"
//        view.spaceButton = GRInputButton()
//        view.spaceButton.captionLabel.text = "간격"

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton/*, view.spaceButton*/] {

            view.addSubview(subview!)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutableRawPointer {
        // FIXME: fix to bypass context
        return context_create(ksx5002_from_qwerty_handler(), ksx5002_combinator(), ksx5002_decoder())
        // return context_create(bypass_phase(), bypass_decoder())
    }

    func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        let keylines = ["123", "456", "789", " 0."]
        let key = getKey(keylines: keylines, position: position)
        if !shift {
            return key
        } else {
            return UnicodeScalar(key.value - 32)!
        }
    }

    func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let chr = self.keyForPosition(position: position, shift: false)
        let altkey = "numpad-key-\(chr)"
        let theme1 = trait.captionForKey(key: altkey, fallback: trait.numpadCaptionForRow(row: position.row + 1))
        let title = self.helper(helper: self.helper, titleForPosition: position)
        let theme2 = trait.captionForKey(key: "numpad-key-" + title, fallback: theme1)
        return theme2
    }

    override func layoutWillLoad(helper: GRKeyboardLayoutHelper) {
        //        self.qwertyView.spaceButton.tag = 32
        //        self.qwertyView.spaceButton.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)

        self.numpadView.doneButton.tag = 13
        self.numpadView.doneButton.addTarget(nil, action: Selector(("done:")), for: .touchUpInside)

        self.numpadView.shiftButton.addTarget(nil, action: Selector(("shift:")), for: .touchUpInside)

        self.numpadView.toggleKeyboardButton.addTarget(nil, action: Selector(("toggle:")), for: .touchUpInside)
    }

    override func layoutDidLoad(helper: GRKeyboardLayoutHelper) {

    }

    override func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.theme(helper: self.helper).traitForSize(size: rect.size)

        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait: trait, position: position)
            captionTheme.appealButton(button: button)
        }

        let map = [
            self.numpadView.shiftButton!: trait.qwertyShiftCaption,
            self.numpadView.deleteButton!: trait.qwertyDeleteCaption,
            self.numpadView.toggleKeyboardButton!: trait.qwerty123Caption,
            self.numpadView.nextKeyboardButton!: trait.qwertyGlobeCaption,
            //            self.qwertyView.spaceButton!: trait.qwertySpaceCaption,
            self.numpadView.doneButton!: trait.qwertyDoneCaption,
        ]

        for (button, captionTheme) in map {
            captionTheme.appealButton(button: button)
        }

        let size = rect.size
        for button in [self.numpadView.shiftButton!, self.numpadView.deleteButton!] {
            button.frame.size = CGSize(width: size.width * 3 / 20, height: size.height / 4)
        }
        for button in [self.numpadView.toggleKeyboardButton!, self.numpadView.nextKeyboardButton!] {
            button.frame.size = CGSize(width: size.width / 8, height: size.height / 4)
        }
        //        for button in [self.qwertyView.spaceButton!] {
        //            button.frame.size = CGSizeMake(size.width / 2, size.height / 4)
        //        }
        for button in [self.numpadView.doneButton!] {
            button.frame.size = CGSize(width: size.width / 4, height: size.height / 4)
        }
    }

    override func layoutDidLayout(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.theme(helper: self.helper).traitForSize(size: rect.size)
        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait: trait, position: position)
            captionTheme.arrangeButton(button: button)
        }

        let map = [
            self.numpadView.shiftButton!: trait.qwertyShiftCaption,
            self.numpadView.deleteButton!: trait.qwertyDeleteCaption,
            self.numpadView.toggleKeyboardButton!: trait.qwerty123Caption,
            self.numpadView.nextKeyboardButton!: trait.qwertyGlobeCaption,
            //            self.qwertyView.spaceButton!: trait.qwertySpaceCaption,
            self.numpadView.doneButton!: trait.qwertyDoneCaption,
        ]
        
        for (button, captionTheme) in map {
            captionTheme.arrangeButton(button: button)
        }
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
        case 0:
            return [self.numpadView.numberButton]
        case 1:
            return [self.numpadView.alphabetButton]
        case 2:
            return [self.numpadView.hangeulButton]
        case 3:
            return [self.numpadView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 0:
            return [self.numpadView.numberButton]
        case 1:
            return [self.numpadView.alphabetButton]
        case 2:
            return [self.numpadView.hangeulButton]
        case 3:
            return [self.numpadView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let keylines = ["123", "456", "789", "*0#"]
        let keyline = keylines[position.row].unicodeScalars
        let idx = keyline.index(keyline.startIndex, offsetBy: position.column)
        let key = keyline[idx]

        let button = GRInputButton(type: .system) as GRInputButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", for: .normal)
        } else {
            button.setTitle("\(Character(UnicodeScalar(key)))", for: .normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: Selector(("input:")), for: .touchUpInside)

        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        return "X"
    }
}

class CheonjiinKeyboardLayout: NumpadKeyboardLayout {

    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(ksx5002_from_qwerty_handler(), ksx5002_combinator(), ksx5002_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let keylines = ["123", "456", "789", ">0."]
        let keyline = keylines[position.row].unicodeScalars
        let idx = keyline.index(keyline.startIndex, offsetBy: position.column)
        let key = keyline[idx]

        let button = GRInputButton(type: .system) as GRInputButton
        button.tag = Int(key.value)
        if position.row == 3 {
            button.setTitle("간격", for: .normal)
        } else {
            let label = key.value // ksx5002_label(Int8(key.value))
            button.setTitle("\(Character(UnicodeScalar(label)!))", for: .normal)
        }
        button.sizeToFit()
        button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: Selector(("input:")), for: .touchUpInside)
        
        return button
    }
    
}
