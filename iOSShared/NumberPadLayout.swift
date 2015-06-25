//
//  NumberPadLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class NumberPadView: KeyboardView {
    @IBOutlet var leftButton: GRInputButton!
}

class NumberPadLayout: KeyboardLayout {
    var padView: NumberPadView {
        get {
            return self.view as! NumberPadView
        }
    }

    override class func loadView() -> KeyboardView {
        let view = NumberPadView(frame: CGRectMake(0, 0, 200, 100))

        view.leftButton = view.toggleKeyboardButton

        for subview in [view.deleteButton, view.leftButton] {
            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodesForPosition(position: GRKeyboardLayoutHelper.Position) -> [UInt] {
        let code: UInt = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]][position.row][position.column]
        return [code + 48]
    }

    override func captionThemeForTrait(trait: ThemeTrait, position: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        let keycodes = self.keycodesForPosition(position)
        let title = self.helper(self.helper, titleForPosition: position)
        let keycode = "\(keycodes[0])" // FIXME:

        let identifier = "\(self.dynamicType)-\(title)-\(keycode))"
        return trait.captionForIdentifier(identifier, needsMargin: self.dynamicType.needsMargin, classes: {
            trait.captionClassesForGetters([
                { $0.caption(title) },
                { $0.key(keycode) },
                { $0.row(position.row + 1) },
                { $0.key },
                { $0.base },
            ], inGroups: [trait.numpad, trait.common])
        })
    }

    override func themesForTrait(trait: ThemeTrait) -> [GRInputButton : ThemeCaption] {

        func functionCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier("numpad-\(name)", needsMargin: false, classes: {
                trait.captionClassesForGetters([
                    { $0.classByName(name) },
                    { $0.row(row) },
                    { $0.function },
                    { $0.base },
                    ], inGroups: [trait.tenkey, trait.common])
            })
        }
        func specialCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier("numpad-\(name)", needsMargin: false, classes: {
                trait.captionClassesForGetters([
                    { $0.classByName(name) },
                    { $0.row(row) },
                    { $0.special },
                    { $0.base },
                    ], inGroups: [trait.tenkey, trait.common])
            })
        }

        var map = [
            self.padView.deleteButton!: functionCaption("delete", 4),
            self.padView.toggleKeyboardButton!: functionCaption("toggle", 4),
            self.padView.shiftButton!: functionCaption("shift", 4),
            //self.padView.doneButton!: functionCaption("done", 4),
            //self.padView.spaceButton!: specialCaption("space", 4),
        ]
        if !contains(map.keys, self.padView.leftButton) {
            map[self.padView.leftButton] = specialCaption("left", 4)
        }
        return map
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        if row == 3 {
            return 1
        }
        return 3
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize size: CGSize) -> CGFloat {
        return size.height / 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 3
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 0, 1, 2:
            return []
        case 3:
            return [self.padView.leftButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 0, 1, 2:
            return []
        case 3:
            return [self.padView.deleteButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as! GRInputButton
        button.keycodes = self.keycodesForPosition(position)
        if button.keycode != 0 {
            button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        }
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycodes = self.keycodesForPosition(position)
        let title = String(UnicodeScalar(UInt32(keycodes[0])))
        return title
    }
}

class DecimalPadLayout: NumberPadLayout {
    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! NumberPadView
        view.leftButton = GRInputButton()
        view.leftButton.captionLabel.text = "."
        view.leftButton.keycode = UnicodeScalar(".").value
        view.addSubview(view.leftButton)
        return view
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
        super.layoutWillLoadForHelper(self.helper)
        self.padView.leftButton.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
    }
}

class PhonePadLayout: NumberPadLayout {
    override class var shiftCaption: String {
        get { return "+*#" }
    }
    override class var autounshift: Bool {
        get { return true }
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! NumberPadView
        view.leftButton = view.shiftButton
        view.addSubview(view.shiftButton)
        return view
    }

    override func keycodesForPosition(position: GRKeyboardLayoutHelper.Position) -> [UInt] {
        let altcode: UInt = [[49, 50, 51], [44, 53, 59], [42, 56, 35], [43]][position.row][position.column]
        return [super.keycodesForPosition(position)[0], altcode]
    }
}
