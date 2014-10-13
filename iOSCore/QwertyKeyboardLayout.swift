//
//  QwertyKeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class QwertyKeyboardView: KeyboardView {
    @IBOutlet var spaceButton: GRInputButton!
    @IBOutlet var leftSpaceButton: GRInputButton!
    @IBOutlet var rightSpaceButton: GRInputButton!

    override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

func getKey(keylines: [String], position: GRKeyboardLayoutHelper.Position) -> UnicodeScalar {
    let keyline = keylines[position.row].unicodeScalars
    let idx = advance(keyline.startIndex, position.column)
    let key = keyline[idx]
    return key
}

class QwertyKeyboardLayout: KeyboardLayout {
    var qwertyView: QwertyKeyboardView {
        get {
            return self.view as QwertyKeyboardView
        }
    }

    func keyForPosition(position: GRKeyboardLayoutHelper.Position) -> UnicodeScalar {
        let keylines = ["qwertyuiop", "asdfghjkl", "zxcvbnm", " "]
        let key = getKey(keylines, position)
        return key
    }

    func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let layout = ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
        let row = layout[position.row]
        let chr = row[advance(row.startIndex, position.column)]
        let altkey = "qwerty-key-\(chr)"
        let theme1 = trait.captionForKey(altkey, fallback: trait.qwertyKeyCaption)
        let title = self.helper(self.helper, titleForPosition: position)
        let theme2 = trait.captionForKey("qwerty-key-" + title, fallback: theme1)
        return theme2
    }

    override class func loadView() -> QwertyKeyboardView {
        let view = QwertyKeyboardView(frame: CGRectMake(0, 0, 320, 216))

        view.nextKeyboardButton = GRInputButton()
        view.deleteButton = GRInputButton()
        view.doneButton = GRInputButton()
        view.toggleKeyboardButton = GRInputButton()
        view.shiftButton = GRInputButton()
        view.spaceButton = GRInputButton()
        view.leftSpaceButton = GRInputButton()
        view.rightSpaceButton = GRInputButton()

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton, view.spaceButton] {

            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_decoder())
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
        self.qwertyView.spaceButton.tag = 32
        self.qwertyView.spaceButton.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)

        self.qwertyView.shiftButton.addTarget(nil, action: "shift:", forControlEvents: .TouchUpInside)

        self.qwertyView.toggleKeyboardButton.addTarget(nil, action: "toggle:", forControlEvents: .TouchUpInside)
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {

    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let theme = preferences.theme.traitForSize(rect.size)

        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(theme, position: position)
            captionTheme.appealButton(button)
        }

        let map = [
            self.qwertyView.shiftButton!: theme.qwertyShiftCaption,
            self.qwertyView.deleteButton!: theme.qwertyDeleteCaption,
            self.qwertyView.toggleKeyboardButton!: theme.qwerty123Caption,
            self.qwertyView.nextKeyboardButton!: theme.qwertyGlobeCaption,
            self.qwertyView.spaceButton!: theme.qwertySpaceCaption,
            self.qwertyView.doneButton!: theme.qwertyDoneCaption,
        ]

        for (button, captionTheme) in map {
            captionTheme.appealButton(button)
        }

        let size = rect.size
        for button in [self.qwertyView.shiftButton!, self.qwertyView.deleteButton!] {
            button.frame.size = CGSizeMake(size.width * 3 / 20, size.height / 4)
        }
        for button in [self.qwertyView.toggleKeyboardButton!, self.qwertyView.nextKeyboardButton!] {
            button.frame.size = CGSizeMake(size.width / 8, size.height / 4)
        }
        for button in [self.qwertyView.spaceButton!] {
            button.frame.size = CGSizeMake(size.width / 2, size.height / 4)
        }
        for button in [self.qwertyView.doneButton!] {
            button.frame.size = CGSizeMake(size.width / 4, size.height / 4)
        }
        for button in [self.qwertyView.leftSpaceButton!, self.qwertyView.rightSpaceButton!] {
            button.frame.size = CGSizeMake(size.width / 20, size.height / 4)
        }
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let theme = preferences.theme.traitForSize(rect.size)
        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(theme, position: position)
            captionTheme.arrangeButton(button)
        }

        let map = [
            self.qwertyView.shiftButton!: theme.qwertyShiftCaption,
            self.qwertyView.deleteButton!: theme.qwertyDeleteCaption,
            self.qwertyView.toggleKeyboardButton!: theme.qwerty123Caption,
            self.qwertyView.nextKeyboardButton!: theme.qwertyGlobeCaption,
            self.qwertyView.spaceButton!: theme.qwertySpaceCaption,
            self.qwertyView.doneButton!: theme.qwertyDoneCaption,
        ]

        for (button, captionTheme) in map {
            captionTheme.arrangeButton(button)
        }
    }

    override func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
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
            return 0
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize size: CGSize) -> CGFloat {
        return size.height / 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 10
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [self.qwertyView.leftSpaceButton]
        case 2:
            assert(self.qwertyView.shiftButton != nil)
            return [self.qwertyView.shiftButton]
        case 3:
            assert(self.view.toggleKeyboardButton != nil)
            assert(self.view.nextKeyboardButton != nil)
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return [self.qwertyView.rightSpaceButton]
        case 2:
            assert(self.view.deleteButton != nil)
            return [self.view.deleteButton]
        case 3:
            assert(self.qwertyView.spaceButton != nil)
            assert(self.view.doneButton != nil)
            return [self.qwertyView.spaceButton, self.view.doneButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        let key =  self.keyForPosition(position)
        button.tag = Int(((key.value - 32) << 15) + key.value)
        button.sizeToFit()
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)

        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let key =  self.keyForPosition(position)
        return "\(Character(UnicodeScalar(key.value - 32)))"
    }

}

class QwertySymbolKeyboardLayout: QwertyKeyboardLayout {
    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let keylines1 = ["1234567890", "-/:;()$&@\"", ".,?!'", " "]
        let keylines2 = ["[]{}#%^*+=", "_\\|~<>XXXX", ".,?!'", " "]
        let key1 = getKey(keylines1, position)
        let key2 = getKey(keylines2, position)

        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        button.tag = Int(key2.value << 15) + Int(key1.value)
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        //println("button: \(button.tag)");
//        button.tag = 0
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keylines1 = ["1234567890", "-/:;()$&@\"", ".,?!'", " "]
        let keylines2 = ["[]{}#%^*+=", "_\\|~<>XXXX", ".,?!'", " "]

        let keycode = self.qwertyView.shiftButton.selected ? getKey(keylines2, position) : getKey(keylines1, position)
        let text = "\(Character(UnicodeScalar(keycode.value)))"
        return text
    }
}

class KSX5002KeyboardLayout: QwertyKeyboardLayout {

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(ksx5002_from_qwerty_phase(), ksx5002_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let key = self.keyForPosition(position)

        let button = GRInputButton.buttonWithType(.System) as GRInputButton
        button.tag = Int(((key.value - 32) << 15) + key.value)
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let key = self.keyForPosition(position)
        let keycode = self.qwertyView.shiftButton.selected ? key.value - 32 : key.value
        let label = ksx5002_label(Int8(keycode))
        let text = "\(Character(UnicodeScalar(label)))"
        return text
    }

}
