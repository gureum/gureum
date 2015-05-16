//
//  NumberPadLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class NumberPadView: KeyboardView {
    @IBOutlet var leftSpaceButton: GRInputButton!
}

class NumberPadLayout: KeyboardLayout {
    var padView: NumberPadView {
        get {
            return self.view as! NumberPadView
        }
    }

    override class func loadView() -> KeyboardView {
        let view = NumberPadView(frame: CGRectMake(0, 0, 320, 216))
        view.deleteButton = GRInputButton()
        view.deleteButton.captionLabel.text = "⌫"
        view.deleteButton.tag = 0x0e
        view.doneButton = GRInputButton()

        //view.toggleKeyboardButton = GRInputButton()
        //view.toggleKeyboardButton.captionLabel.text = "123"
        //view.shiftButton = GRInputButton()
        //view.shiftButton.captionLabel.text = "⬆︎"
        view.leftSpaceButton = GRInputButton()

        for subview in [view.deleteButton] {
            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodeForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> Int {
        let code: Int? = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [nil, 0]][position.row][position.column]
        if let code = code {
            return code + 48
        } else {
            return 0
        }
    }

    func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let charcode = self.keycodeForPosition(position, shift: false)
        let altkey = "key-\(charcode)" // fixme
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

        let map = [
            self.padView.deleteButton!: trait.tenkeyDeleteCaption,
        ]

        for (button, captionTheme) in map {
            captionTheme.appealButton(button)
        }

        let size = rect.size
        for button in [self.padView.deleteButton] {
            button.frame.size = CGSizeMake(size.width / 3, size.height / 4)
        }
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.themeForHelper(self.helper).traitForSize(rect.size)
        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait, position: position)
            captionTheme.arrangeButton(button)
        }

        let map = [
            self.padView.deleteButton!: trait.tenkeyDeleteCaption,
            //self.padView.toggleKeyboardButton!: trait.tenkeyShiftCaption,
            //self.padView.nextKeyboardButton!: trait.tenkeyGlobeCaption,
        ]
        
        for (button, captionTheme) in map {
            captionTheme.arrangeButton(button)
        }
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        if row == 3 {
            return 2
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
            return [self.padView.leftSpaceButton]
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
        let key = self.keycodeForPosition(position, shift: false)
        button.tag = key
        if button.tag != 0 {
            button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        }
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position, shift: false)
        let title = String(UnicodeScalar(keycode))
        return title
    }
}

class PhonePadLayout: NumberPadLayout {
    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(number_from_tenkey_handler(), number_from_tenkey_handler(), number_tenkey_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! NumberPadView
        return view
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position, shift: false)
        let titles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", ""]
        let titles2 = titles1
        let label = (self.view.shiftButton.selected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}
