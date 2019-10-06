//
//  TenkeyKeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TenkeyKeyboardView: KeyboardView {
    @IBOutlet var numberButton: GRInputButton!
    @IBOutlet var alphabetButton: GRInputButton!
    @IBOutlet var hangeulButton: GRInputButton!

    override var visibleButtons: [GRInputButton] {
        return [self.numberButton, self.alphabetButton, self.hangeulButton, self.nextKeyboardButton, self.deleteButton, self.doneButton, self.shiftButton, self.spaceButton]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        deleteButton.keycode = 0x0E
        numberButton = GRInputButton()
        numberButton.captionLabel.text = "123"
        numberButton.tag = 2
        alphabetButton = GRInputButton()
        alphabetButton.captionLabel.text = "ABC"
        alphabetButton.tag = 1
        hangeulButton = GRInputButton()
        hangeulButton.captionLabel.text = "한글"
        hangeulButton.tag = 0

        spaceButton.keycode = 12
        spaceButton.addTarget(nil, action: "input:", for: .touchUpInside)
        doneButton.keycode = 13

        numberButton.addTarget(nil, action: "selectLayout:", for: .touchUpInside)
        alphabetButton.addTarget(nil, action: "selectLayout:", for: .touchUpInside)
        hangeulButton.addTarget(nil, action: "selectLayout:", for: .touchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TenkeyKeyboardLayout: KeyboardLayout {
    var tenkeyView: TenkeyKeyboardView {
        return self.view as! TenkeyKeyboardView
    }

    override func themesForTrait(trait: ThemeTrait) -> [GRInputButton: ThemeCaption] {
        func layoutCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier(identifier: "tenkey-\(name)", needsMargin: type(of: self).needsMargin, classes: {
                trait.captionClassesForGetters(getters: [
                    { $0.classByName(key: name) },
                    { $0.classByName(key: "toggle") },
                    { $0.row(row: row) },
                    { $0.function },
                    { $0.base },
                ], inGroups: [trait.tenkey, trait.common])
            })
        }
        func functionCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier(identifier: "tenkey-\(name)", needsMargin: type(of: self).needsMargin, classes: {
                trait.captionClassesForGetters(getters: [
                    { $0.classByName(key: name) },
                    { $0.row(row: row) },
                    { $0.function },
                    { $0.base },
                ], inGroups: [trait.tenkey, trait.common])
            })
        }
        func specialCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier(identifier: "tenkey-\(name)", needsMargin: type(of: self).needsMargin, classes: {
                trait.captionClassesForGetters(getters: [
                    { $0.classByName(key: name) },
                    { $0.row(row: row) },
                    { $0.special },
                    { $0.base },
                ], inGroups: [trait.tenkey, trait.common])
            })
        }

        return [
            self.tenkeyView.numberButton!: layoutCaption(name: "number", row: 1),
            self.tenkeyView.alphabetButton!: layoutCaption(name: "alphabet", row: 2),
            self.tenkeyView.hangeulButton!: layoutCaption(name: "hangeul", row: 3),
            self.tenkeyView.nextKeyboardButton!: functionCaption(name: "globe", row: 4),
            self.tenkeyView.deleteButton!: functionCaption(name: "delete", row: 1),
            self.tenkeyView.shiftButton!: functionCaption(name: "shift", row: 2),
            self.tenkeyView.doneButton!: functionCaption(name: "done", row: 3),
            self.tenkeyView.spaceButton!: specialCaption(name: "space", row: 4),
        ]
    }

    override class func loadView() -> KeyboardView {
        let view = TenkeyKeyboardView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        return view
    }

    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodeForPosition(position: GRKeyboardLayoutHelper.Position) -> Int {
        return position.row * 3 + position.column
    }

    override func captionThemeForTrait(trait: ThemeTrait, position: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        let keycode = "\(keycodeForPosition(position: position))"
        let title = helper(helper: helper, titleForPosition: position)

        let identifier = "\(type(of: self))-\(title)-\(keycode))"
        return trait.captionForIdentifier(identifier: identifier, needsMargin: type(of: self).needsMargin, classes: {
            trait.captionClassesForGetters(getters: [
                { $0.caption(key: title) },
                { $0.key(key: keycode) },
                { $0.row(row: position.row + 1) },
                { $0.key },
                { $0.base },
            ], inGroups: [trait.tenkey, trait.common])
        })
    }

    override func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        super.layoutWillLayout(helper: helper, forRect: rect)

        let size = rect.size
        for button in [self.tenkeyView.numberButton, self.tenkeyView.alphabetButton, self.tenkeyView.hangeulButton, self.tenkeyView.shiftButton, self.tenkeyView.deleteButton, self.tenkeyView.nextKeyboardButton, self.tenkeyView.doneButton, self.tenkeyView.spaceButton] {
            button?.frame.size = CGSize(width: size.width / 5, height: size.height / 4)
        }
    }

    override func numberOfRowsForHelper(helper _: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper _: GRKeyboardLayoutHelper, numberOfColumnsInRow _: Int) -> Int {
        return 3
    }

    override func helper(helper _: GRKeyboardLayoutHelper, heightOfRow _: Int, forSize size: CGSize) -> CGFloat {
        return size.height / 4
    }

    override func helper(helper _: GRKeyboardLayoutHelper, columnWidthInRow _: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 5
    }

    override func helper(helper _: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> [UIButton] {
        switch row {
        case 0:
            return [self.tenkeyView.numberButton]
        case 1:
            return [self.tenkeyView.alphabetButton]
        case 2:
            return [self.tenkeyView.hangeulButton]
        case 3:
            return [self.tenkeyView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper _: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> [UIButton] {
        switch row {
        case 0:
            return [self.tenkeyView.deleteButton]
        case 1:
            return [self.tenkeyView.shiftButton]
        case 2:
            return [self.tenkeyView.doneButton]
        case 3:
            return [self.tenkeyView.spaceButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper _: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton(type: .system)
        let keycode = keycodeForPosition(position: position)

        let shift = [3, 5, 6, 8, 11].contains(keycode) ? 2 : 1
        button.keycodes = [keycode, keycode + shift * 0x100]
        button.addTarget(nil, action: "input:", for: .touchUpInside)
        return button
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = keycodeForPosition(position: position)
        let titles = "123456789*0#"
        let idx = titles.index(titles.startIndex, offsetBy: keycode)
        return "\(titles[idx])"
    }
}

class TenKeyAlphabetKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(alphabet_from_tenkey_handler(), alphabet_from_tenkey_handler(), alphabet_tenkey_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.alphabetButton.isSelected = true
        return view
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = keycodeForPosition(position: position)
        let titles1 = ["@#/&_", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "⇨", ".,?!", ""]
        let titles2 = ["@#/&_", "ABC", "DEF", "GHI", "JKL", "MNO", "PQRS", "TUV", "WXYZ", "⇨", ".,?!", ""]
        let label = (view.shiftButton.isSelected ? titles2 : titles1)[keycode]

        return "\(label)"
    }
}

class TenKeyNumberKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(number_from_tenkey_handler(), number_from_tenkey_handler(), number_tenkey_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.numberButton.isSelected = true
        return view
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = keycodeForPosition(position: position)
        let titles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "0", "."]
        let titles2 = titles1
        let label = (view.shiftButton.isSelected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}

class CheonjiinKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(cheonjiin_from_tenkey_handler(), cheonjiin_from_tenkey_handler(), cheonjiin_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.hangeulButton.isSelected = true
        return view
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = keycodeForPosition(position: position)
        let titles1 = ["ㅣ", "·", "ㅡ", "ㄱㅋ", "ㄴㄹ", "ㄷㅌ", "ㅂㅍ", "ㅅㅎ", "ㅈㅊ", "⇨", "ㅇㅁ", ".,?!"]
        let titles2 = ["ㅣ", "· ·", "ㅡ", "ㄲ", "ㄹ", "ㄸ", "ㅃ", "ㅆ", "ㅉ", "⇨", "ㅁ", "?"]
        let label = (view.shiftButton.isSelected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}

class CheonjiinPlusKeyboardLayout: TenkeyKeyboardLayout {
    override func keycodeForPosition(position: GRKeyboardLayoutHelper.Position) -> Int {
        return position.row * 6 + position.column
    }

    override func helper(helper _: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0: return 4
        case 1, 2: return 6
        case 3: return 5
        default: return 0
        }
    }

    override func helper(helper _: GRKeyboardLayoutHelper, columnWidthInRow _: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 5
    }

    override class func loadContext() -> UnsafeMutableRawPointer {
        return context_create(cheonjiin_from_tenkey_handler(), cheonjiin_from_tenkey_handler(), cheonjiin_decoder())
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = keycodeForPosition(position: position)
        let titles1 = ["ㅣ", "·", "··", "ㅡ", "ㄱ", "ㅋ", "ㄴ", "ㄹ", "ㄷ", "ㅌ", "ㅂ", "ㅍ", "ㅅ", "ㅎ", "ㅈ", "ㅊ", "⇨", "ㅇ", "ㅁ", ".,", "?!"]
        let titles2 = titles1
        let label = (view.shiftButton.isSelected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}
