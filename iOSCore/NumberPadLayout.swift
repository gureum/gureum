//
//  NumberPadLayout.swift
//  iOS
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
        let view = NumberPadView(frame: CGRectMake(0, 0, 320, 216))

        view.leftButton = GRInputButton()

        for subview in [view.deleteButton, view.toggleKeyboardButton] {
            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodeForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> Int {
        let code: Int? = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]][position.row][position.column]
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
        self.padView.toggleKeyboardButton.addTarget(nil, action: "toggleLayout:", forControlEvents: .TouchUpInside)
        self.padView.leftButton.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
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
        ]
        if self.togglable {
            map[self.padView.toggleKeyboardButton!] = trait.tenkey123Caption
        }
        if self.padView.leftButton.tag != 0 {
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
        if self.togglable {
            map[self.padView.toggleKeyboardButton!] = trait.tenkey123Caption
        }
        if self.padView.leftButton.tag != 0 {
            map[self.padView.leftButton!] = trait.tenkeySpecialKeyCaption
        }
        
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
            if togglable {
                return [self.padView.toggleKeyboardButton]
            } else {
                return [self.padView.leftButton]
            }
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

class DecimalPadLayout: NumberPadLayout {
    override var togglable: Bool {
        get { return false }
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! NumberPadView
        view.leftButton.captionLabel.text = "."
        view.leftButton.tag = 46
        view.addSubview(view.leftButton)
        return view
    }

}

class PhonePadLayout: NumberPadLayout {

}
