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

    override func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let keycodes = self.keycodesForPosition(position)
        let altkey = "key-\(keycodes[0])" // FIXME:
        let theme1 = trait.tenkeyCaptionForKey(altkey, fallback: trait.tenkeyCaptionForKeyInRow(position.row + 1))
        let title = self.helper(self.helper, titleForPosition: position)
        let theme2 = trait.tenkeyCaptionForKey("key-" + title, fallback: theme1)
        return theme2
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.themeForHelper(self.helper).traitForSize(rect.size)

        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait, position: position)
            captionTheme.appealButton(button)
        }

        var map = [
            self.padView.deleteButton!: trait.tenkeyDeleteCaption,
            self.padView.toggleKeyboardButton!: trait.tenkeyToggleCaption,
            self.padView.shiftButton!: trait.tenkeyShiftCaption,
        ]
        if !contains(map.keys, self.padView.leftButton) {
            map[self.padView.leftButton!] = trait.tenkeySpecialKeyCaption
        }

        for (button, captionTheme) in map {
            captionTheme.appealButton(button)
        }

        let size = rect.size
        for button in [self.padView.deleteButton, self.padView.toggleKeyboardButton, self.padView.leftButton] {
            let width = self.helper(self.helper, columnWidthInRow: 3, forSize: size)
            let height = self.helper(self.helper, columnWidthInRow: 3, forSize: size)
            button.frame.size = CGSizeMake(width, height)
        }
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.themeForHelper(self.helper).traitForSize(rect.size)
        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait, position: position)
            captionTheme.arrangeButton(button)
        }

        var map = [
            self.padView.deleteButton!: trait.tenkeyDeleteCaption,
            //self.padView.nextKeyboardButton!: trait.tenkeyGlobeCaption,
        ]
        map[self.padView.leftButton!] = trait.tenkeySpecialKeyCaption

        for (button, captionTheme) in map {
            captionTheme.arrangeButton(button)
        }
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
