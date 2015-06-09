//
//  QwertyKeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class QwertyKeyboardView: KeyboardView {
//    @IBOutlet var spaceButton: GRInputButton!
    @IBOutlet var leftSpaceButton: GRInputButton!
    @IBOutlet var rightSpaceButton: GRInputButton!

    @IBOutlet var URLDotButton: GRInputButton! = nil
    @IBOutlet var URLSlashButton: GRInputButton! = nil
    @IBOutlet var URLDotComButton: GRInputButton! = nil

    @IBOutlet var emailSpaceButton: GRInputButton! = nil
    @IBOutlet var emailSnailButton: GRInputButton! = nil
    @IBOutlet var emailDotButton: GRInputButton! = nil

    @IBOutlet var twitterSnailButton: GRInputButton! = nil
    @IBOutlet var twitterHashButton: GRInputButton! = nil

    override var URLButtons: [GRInputButton] {
        get {
            return [URLDotButton!, URLSlashButton!, URLDotComButton!]
        }
    }

    override var emailButtons: [GRInputButton] {
        get {
            return [emailSpaceButton!, emailSnailButton!, emailDotButton!]
        }
    }

    override var twitterButtons: [GRInputButton] {
        get {
            return [twitterSnailButton!, twitterHashButton!]
        }
    }

    override var visibleButtons: [GRInputButton] {
        get {
            return [self.toggleKeyboardButton, self.shiftButton, self.nextKeyboardButton, self.spaceButton, self.deleteButton, self.doneButton] + self.URLButtons + self.emailButtons + self.twitterButtons
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.URLDotButton = GRInputButton()
        self.URLDotButton.captionLabel.text = "."
        self.URLDotButton.keycode = UnicodeScalar(".").value
        self.URLSlashButton = GRInputButton()
        self.URLSlashButton.captionLabel.text = "/"
        self.URLSlashButton.keycode = UnicodeScalar("/").value
        self.URLDotComButton = GRInputButton()
        self.URLDotComButton.captionLabel.text = ".com"

        self.emailSpaceButton = GRInputButton()
        self.emailSpaceButton.captionLabel.text = self.spaceButton.captionLabel.text
        self.emailSpaceButton.keycode = self.spaceButton.keycode
        self.emailSnailButton = GRInputButton()
        self.emailSnailButton.captionLabel.text = "@"
        self.emailSnailButton.keycode = UnicodeScalar("@").value
        self.emailDotButton = GRInputButton()
        self.emailDotButton.captionLabel.text = "."
        self.emailDotButton.keycode = UnicodeScalar(".").value

        self.twitterSnailButton = GRInputButton()
        self.twitterSnailButton.captionLabel.text = "@"
        self.twitterSnailButton.keycode = UnicodeScalar("@").value
        self.twitterHashButton = GRInputButton()
        self.twitterHashButton.captionLabel.text = "#"
        self.twitterHashButton.keycode = UnicodeScalar("#").value

        self.leftSpaceButton = GRInputButton()
        self.rightSpaceButton = GRInputButton()

        for subview in self.URLButtons + self.emailButtons + self.twitterButtons {
            subview.alpha = 0
        }

        self.spaceButton.addTarget(nil, action: "space:", forControlEvents: .TouchUpInside)
        for button in [self.URLDotButton, self.URLSlashButton] + self.emailButtons + self.twitterButtons {
            button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        }
        self.URLDotComButton.addTarget(nil, action: "dotcom:", forControlEvents: .TouchUpInside)
    }
}

func getKey(keylines: [String], position: GRKeyboardLayoutHelper.Position) -> UnicodeScalar {
    let keyline = keylines[position.row].unicodeScalars
    let idx = advance(keyline.startIndex, position.column)
    let key = keyline[idx]
    return key
}

class QwertyBaseKeyboardLayout: KeyboardLayout {
    var qwertyView: QwertyKeyboardView {
        get {
            return self.view as! QwertyKeyboardView
        }
    }

    override func themesForTrait(trait: ThemeTraitConfiguration) -> [GRInputButton: ThemeCaptionConfiguration] {
        return [
            self.qwertyView.shiftButton!: trait.qwertyShiftCaption,
            self.qwertyView.deleteButton!: trait.qwertyDeleteCaption,
            self.qwertyView.toggleKeyboardButton!: trait.qwertyToggleCaption,
            self.qwertyView.nextKeyboardButton!: trait.qwertyGlobeCaption,
            self.qwertyView.spaceButton!: trait.qwertySpaceCaption,
            self.qwertyView.doneButton!: trait.qwertyDoneCaption,

            self.qwertyView.URLDotButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.URLSlashButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.URLDotComButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.emailSpaceButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.emailSnailButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.emailDotButton!: trait.qwertySpecialKeyCaption,
            self.qwertyView.twitterSnailButton!: trait.qwertyFunctionCaption,
            self.qwertyView.twitterHashButton!: trait.qwertyFunctionCaption,
        ]
    }

    override class func loadView() -> QwertyKeyboardView {
        let view = QwertyKeyboardView(frame: CGRectMake(0, 0, 200, 100))

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton, view.spaceButton] + view.URLButtons + view.emailButtons + view.twitterButtons {
            view.addSubview(subview)
        }
        return view
    }

    func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        assert(false)
        return UnicodeScalar(0)
    }

    override func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let chr = self.keyForPosition(position, shift: false)
        let altkey = "key-\(chr)"
        let theme1 = trait.qwertyCaptionForKey(altkey, fallback: trait.qwertyCaptionForKeyInRow(position.row + 1))
        let title = self.helper(self.helper, titleForPosition: position)
        let theme2 = trait.qwertyCaptionForKey("key-" + title, fallback: theme1)
        return theme2
    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        super.layoutWillLayoutForHelper(helper, forRect: rect)

        let size = rect.size
        for button in [self.qwertyView.shiftButton!, self.qwertyView.deleteButton!] {
            let width = self.helper(self.helper, columnWidthInRow: 2, forSize: size)
            let count = self.helper(self.helper, numberOfColumnsInRow: 2)
            let height = self.helper(self.helper, heightOfRow: 2, forSize: size)
            button.frame.size = CGSizeMake((size.width - CGFloat(count) * width) / 2, height)
        }
        for button in [self.qwertyView.spaceButton!] {
            let height = self.helper(self.helper, heightOfRow: 3, forSize: size)
            button.frame.size = CGSizeMake(rect.size.width / 2, height)
        }

        for button in [self.qwertyView.doneButton!] {
            let height = self.helper(self.helper, heightOfRow: 3, forSize: size)
            button.frame.size = CGSizeMake((rect.size.width - self.qwertyView.spaceButton.frame.size.width) / 2, height)
        }

        for button in [self.qwertyView.toggleKeyboardButton!, self.qwertyView.nextKeyboardButton!] {
            let height = self.helper(self.helper, heightOfRow: 3, forSize: size)
            button.frame.size = CGSizeMake((rect.size.width - self.qwertyView.spaceButton.frame.size.width) / 4, height)
        }

        for button in [self.qwertyView.leftSpaceButton!, self.qwertyView.rightSpaceButton!] {
            let width = self.helper(self.helper, columnWidthInRow: 1, forSize: size)
            let count = self.helper(self.helper, numberOfColumnsInRow: 1)
            let height = self.helper(self.helper, heightOfRow: 1, forSize: size)
            button.frame.size = CGSizeMake((size.width - CGFloat(count) * width) / 2, height)
        }
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        func step(rect: CGRect) -> CGRect {
            var newRect = rect
            newRect.origin.x += rect.size.width
            return newRect
        }

        let spaceFrame = self.qwertyView.spaceButton.frame

        var URLRect = spaceFrame
        URLRect.size.width /= 3
        self.qwertyView.URLDotButton.frame = URLRect
        URLRect = step(URLRect)
        self.qwertyView.URLSlashButton.frame = URLRect
        URLRect = step(URLRect)
        self.qwertyView.URLDotComButton.frame = URLRect

        var emailRect = spaceFrame
        emailRect.size.width /= 2
        self.qwertyView.emailSpaceButton.frame = emailRect
        emailRect = step(emailRect)
        emailRect.size.width /= 2
        self.qwertyView.emailSnailButton.frame = emailRect
        emailRect = step(emailRect)
        self.qwertyView.emailDotButton.frame = emailRect

        var twitterRect = self.qwertyView.doneButton.frame
        twitterRect.size.width /= 2
        self.qwertyView.twitterSnailButton.frame = twitterRect
        twitterRect = step(twitterRect)
        self.qwertyView.twitterHashButton.frame = twitterRect


        super.layoutDidLayoutForHelper(helper, forRect: rect)
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize size: CGSize) -> CGFloat {
        return size.height / 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as! GRInputButton
        button.keycodes = [UInt(self.keyForPosition(position, shift: false).value), UInt(self.keyForPosition(position, shift: true).value)]
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        return button
    }

    override func adjustTraits(traits: UITextInputTraits) {
        let traitsKeyboardType = traits.keyboardType ?? .Default
        if traitsKeyboardType == .URL {
            if self.view.spaceButton.alpha > 0.0 {
                UIView.animateWithDefaultDurationAnimations({
                    for button in self.view.URLButtons {
                        button.alpha = 1.0
                    }
                })
            }
        } else {
            for button in self.view.URLButtons {
                button.alpha = 0.0
            }
        }
        if traitsKeyboardType == .EmailAddress {
            if self.view.spaceButton.alpha > 0.0 {
                UIView.animateWithDefaultDurationAnimations({
                    for button in self.view.emailButtons {
                        button.alpha = 1.0
                    }
                })
            }
        } else {
            for button in self.view.emailButtons {
                button.alpha = 0.0
            }
        }
        if traitsKeyboardType != .URL && traitsKeyboardType != .EmailAddress {
            self.view.spaceButton.alpha = 1.0
        } else {
            self.view.spaceButton.alpha = 0.0
        }

        if traitsKeyboardType == .Twitter {
            self.view.doneButton.alpha = 0.0
            for button in self.view.twitterButtons {
                button.alpha = 1.0
            }
        } else {
            self.view.doneButton.alpha = 1.0
            for button in self.view.twitterButtons {
                button.alpha = 0.0
            }
        }
    }
}

class QwertyKeyboardLayout: QwertyBaseKeyboardLayout {
    override class var toggleCaption: String {
        get { return "ABC" }
    }
    override class var capitalizable: Bool {
        get { return true }
    }
    override class var autounshift: Bool {
        get { return true }
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    override func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        let keylines = ["qwertyuiop", "asdfghjkl", "zxcvbnm", " "]
        let key = getKey(keylines, position)
        if !shift || position.row == 3 {
            return key
        } else {
            return UnicodeScalar(key.value - 32)
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0:
            return 10
        case 1:
            return 9
        case 2:
            return 7
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        if row == 3 {
            return size.width / 2
        } else {
            return size.width / 10
        }
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
            assert(self.view.spaceButton != nil)
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton, self.view.spaceButton]
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
//            assert(self.qwertyView.spaceButton != nil)
            assert(self.view.doneButton != nil)
            return [/*self.qwertyView.spaceButton, */self.view.doneButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let key =  self.keyForPosition(position, shift: true)
        return "\(Character(key))"
    }

    override func correspondingButtonForPoint(point: CGPoint, size: CGSize) -> GRInputButton {
        var newPoint = point
        if point.x < size.width / 2 {
            newPoint.x += 2
        } else {
            newPoint.x -= 2
        }
        var button = super.correspondingButtonForPoint(point, size: size)
        if button == self.qwertyView.leftSpaceButton {
            button = self.helper.buttons[GRKeyboardLayoutHelper.Position(row: 1, column: 0)]!
        }
        else if button == self.qwertyView.rightSpaceButton {
            button = self.helper.buttons[GRKeyboardLayoutHelper.Position(row: 1, column: 8)]!
        }
        return button
    }

}

class QwertySymbolKeyboardLayout: QwertyBaseKeyboardLayout {
    override class var toggleCaption: String {
        get { return "123" }
    }
    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    override func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        let keylines = !shift ? ["1234567890", "-/:;()₩&@\"", ".,?!'\"₩", " "] : ["[]{}#%^*+=", "_\\|~<>$€¥·", ".,?!'\"₩", " "]
        let key = getKey(keylines, position)
        return key
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0:
            return 10
        case 1:
            return 10
        case 2:
            return 5
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return []
        case 2:
            assert(self.qwertyView.shiftButton != nil)
            return [self.qwertyView.shiftButton]
        case 3:
            assert(self.view.toggleKeyboardButton != nil)
            assert(self.view.nextKeyboardButton != nil)
            assert(self.view.spaceButton != nil)
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton, self.view.spaceButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 1:
            return []
        case 2:
            assert(self.view.deleteButton != nil)
            return [self.view.deleteButton]
        case 3:
//            assert(self.qwertyView.spaceButton != nil)
            assert(self.view.doneButton != nil)
            return [/*self.qwertyView.spaceButton, */self.view.doneButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        if row == 3 {
            return size.width / 2
        } else if row == 2 {
            return size.width * 7 / 5 / 10
        } else {
            return size.width / 10
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let key = self.keyForPosition(position, shift: self.qwertyView.shiftButton.selected)
        let text = "\(Character(UnicodeScalar(key.value)))"
        return text
    }
}

class KSX5002KeyboardLayout: QwertyBaseKeyboardLayout {
    override class var toggleCaption: String {
        get { return "한글" }
    }
    override class var autounshift: Bool {
        get { return true }
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(ksx5002_from_qwerty_handler(), ksx5002_combinator(), ksx5002_decoder())
    }

    override func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        let keylines = ["qwertyuiop", "asdfghjkl", "zxcvbnm", " "]
        let key = getKey(keylines, position)
        if !shift || position.row == 3 {
            return key
        } else {
            return UnicodeScalar(key.value - 32)
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let key = self.keyForPosition(position, shift: self.qwertyView.shiftButton.selected)
        let keycode = key.value
        let label = ksx5002_label(Int8(keycode))
        let text = "\(Character(UnicodeScalar(label)))"
        return text
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0:
            return 10
        case 1:
            return 9
        case 2:
            return 7
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        if row == 3 {
            return size.width / 2
        } else {
            return size.width / 10
        }
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
            assert(self.view.spaceButton != nil)
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton, self.view.spaceButton]
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
            //            assert(self.qwertyView.spaceButton != nil)
            assert(self.view.doneButton != nil)
            return [/*self.qwertyView.spaceButton, */self.view.doneButton]
        default:
            return []
        }
    }

}

class DanmoumKeyboardLayout: KSX5002KeyboardLayout {
    override func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        let keylines = !shift ? ["qwerthop", "asdfgjkl", "zxcvnm", " "] : ["QWERTyOP", "asdfguil", "zxcvbm", " "]
        let key = getKey(keylines, position)
        return key
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(danmoum_from_qwerty_handler(), danmoum_combinator(), danmoum_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
        case 0:
            return 8
        case 1:
            return 8
        case 2:
            return 6
        default:
            return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        if row == 3 {
            return size.width / 2
        } else {
            return size.width / 8
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 2:
            assert(self.qwertyView.shiftButton != nil)
            return [self.qwertyView.shiftButton]
        case 3:
            assert(self.view.toggleKeyboardButton != nil)
            assert(self.view.nextKeyboardButton != nil)
            assert(self.view.spaceButton != nil)
            return [self.view.toggleKeyboardButton, self.view.nextKeyboardButton, self.view.spaceButton]
        default:
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 2:
            assert(self.view.deleteButton != nil)
            return [self.view.deleteButton]
        case 3:
//            assert(self.qwertyView.spaceButton != nil)
            assert(self.view.doneButton != nil)
            return [/*self.qwertyView.spaceButton, */self.view.doneButton]
        default:
            return []
        }
    }
}
