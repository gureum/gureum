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
        let view = NumberPadView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))

        view.leftButton = view.toggleKeyboardButton

        for subview in [view.deleteButton, view.leftButton] {
            view.addSubview(subview!)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodesForPosition(position: GRKeyboardLayoutHelper.Position) -> [UInt] {
        let code: UInt = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]][position.row][position.column]
        return [code + 48]
    }

    override func captionThemeForTrait(trait: ThemeTrait, position: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        let keycodes = self.keycodesForPosition(position: position)
        let title = self.helper(helper: self.helper, titleForPosition: position)
        let keycode = "\(keycodes[0])" // FIXME:

        let identifier = "\(type(of: self))-\(title)-\(keycode))"
        return trait.captionForIdentifier(identifier: identifier, needsMargin: type(of: self).needsMargin, classes: {
            trait.captionClassesForGetters(getters: [
                { $0.caption(key: title) },
                { $0.key(key: keycode) },
                { $0.row(row: position.row + 1) },
                { $0.key },
                { $0.base },
            ], inGroups: [trait.numpad, trait.common])
        })
    }

    override func themesForTrait(trait: ThemeTrait) -> [GRInputButton : ThemeCaption] {

        func functionCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier(identifier: "numpad-\(name)", needsMargin: false, classes: {
                trait.captionClassesForGetters(getters: [
                    { $0.classByName(key: name) },
                    { $0.row(row: row) },
                    { $0.function },
                    { $0.base },
                    ], inGroups: [trait.tenkey, trait.common])
            })
        }
        func specialCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier(identifier: "numpad-\(name)", needsMargin: false, classes: {
                trait.captionClassesForGetters(getters: [
                    { $0.classByName(key: name) },
                    { $0.row(row: row) },
                    { $0.special },
                    { $0.base },
                    ], inGroups: [trait.tenkey, trait.common])
            })
        }

        var map = [
            self.padView.deleteButton!: functionCaption(name: "delete", row: 4),
            self.padView.toggleKeyboardButton!: functionCaption(name: "toggle", row: 4),
            self.padView.shiftButton!: functionCaption(name: "shift", row: 4),
            //self.padView.doneButton!: functionCaption("done", 4),
            //self.padView.spaceButton!: specialCaption("space", 4),
        ]
        if !map.keys.contains(self.padView.leftButton) {
            map[self.padView.leftButton] = specialCaption(name: "left", row: 4)
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
        let button = GRInputButton(type: .system)
        button.keycodes = self.keycodesForPosition(position: position)
        if button.keycode != 0 {
            button.addTarget(nil, action: "input:", for: .touchUpInside)
        }
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycodes = self.keycodesForPosition(position: position)
        let title = String(UnicodeScalar(UInt32(keycodes[0]))!)
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

    override func layoutWillLoad(helper: GRKeyboardLayoutHelper) {
        super.layoutWillLoad(helper: self.helper)
        self.padView.leftButton.addTarget(nil, action: "input:", for: .touchUpInside)
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
        return [super.keycodesForPosition(position: position)[0], altcode]
    }
}
