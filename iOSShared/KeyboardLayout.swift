//
//  KeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let MINIMAL_COUNT = 30

class KeyboardViewEventView: UIView {
    var touchingDate: Date = Date()
    var touchingCount: Int = 0
    var touchingTimer: Timer = Timer()
    var touchingButtons: NSArray = NSArray()

    // var untouchingTimer: NSTimer = NSTimer()

    var touchedButtons: NSMutableArray = NSMutableArray()
    func addButton(button: GRInputButton) {
        if !touchedButtons.contains(button) {
            touchedButtons.add(button)
        }
    }

//    var touchedSpots: [UIView] = {
//        var spots: [UIView] = []
//        for i in 0...10 {
//            let view = UIView(frame: CGRectMake(0, 0, 40, 40))
//            view.backgroundColor = UIColor.redColor()
//            view.layer.cornerRadius = 20
//            view.clipsToBounds = true
//            view.layer.borderWidth = 4
//            view.layer.borderColor = UIColor.blueColor().CGColor
//            view.hidden = true
//            spots.append(view)
//        }
//        return spots
//    }()

    var keyboardView: KeyboardView {
        return superview! as! KeyboardView
    }

    func resetTouching() {
        stopTouching()
        // self.untouchingTimer.invalidate()
        touchingButtons = touchedButtons.copy() as! NSArray
        touchingTimer = Timer.scheduledTimer(timeInterval: 0.014, target: self, selector: #selector(KeyboardViewEventView.checkTouchingTimer(_:)), userInfo: nil, repeats: true)
    }

    func stopTouching() {
        touchingDate = Date()
        touchingCount = 0
        touchingTimer.invalidate()
    }

    @objc func checkTouchingTimer(_: Timer) {
        if touchedButtons.count != 1 {
            stopTouching()
            return
        }

        if !touchedButtons.isEqual(touchedButtons) {
            resetTouching()
            return
        }

        touchingCount += 1

        if touchingCount >= MINIMAL_COUNT && touchingCount % 10 == 0 || touchingCount >= MINIMAL_COUNT * 4 && touchingCount % 5 == 0 {
            let button = touchedButtons[0] as! GRInputButton
            button.sendActions(for: .touchUpInside)
        }
        // println("touching \(self.touchingCount)")
    }

//    func checkUntouchingTimer(timer: NSTimer) {
//        self.keyboardView.untouchButton.sendActionsForControlEvents(.TouchUpInside)
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // println("touch began?")
        if touches.count == 1 {
            resetTouching()
        } else {
            stopTouching()
        }
        touchesMoved(touches, with: event)
    }

    override func touchesMoved(_: Set<UITouch>, with event: UIEvent?) {
        var buttons: [GRInputButton: Bool] = [:]
        var orphans: [GRInputButton] = []

        for rawTouch in (event?.allTouches!)! {
            let touch = rawTouch as UITouch
            let prevPoint = touch.previousLocation(in: self)
            let prevButton = keyboardView.layout.correspondingButtonForPoint(point: prevPoint, size: frame.size)
            let point = touch.location(in: self)
            let button = keyboardView.layout.correspondingButtonForPoint(point: point, size: frame.size)
            if prevButton != button {
                buttons[prevButton] = nil
                prevButton.hideEffect()
                resetTouching()
                // println("--touch moved point: \(point) \(button.captionLabel.text)")
            } else {
                // println("--touch point: \(point) \(button.captionLabel.text)")
            }
            button.showEffect()
            buttons[button] = true
        }

        for raw in touchedButtons {
            let button = raw as! GRInputButton
            if buttons[button] == nil {
                button.hideEffect()
                orphans.append(button)
            }
        }

        for button in orphans {
            touchedButtons.remove(button)
        }
        for button in buttons.keys {
            addButton(button: button)
        }
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
//        for (i, rawTouch) in enumerate(event.allTouches()!) {
//            let touch = rawTouch as UITouch
//            let point = touch.locationInView(self)
//            let spot = self.touchedSpots[i]
//            spot.center = point
//            spot.hidden = false
//            self.addSubview(spot)
//        }
    }

    override func touchesEnded(_: Set<UITouch>, with event: UIEvent?) {
        for touch in event!.allTouches! {
            if touch.phase != .ended {
                continue
            }
            let point = touch.location(in: self)
            var button = keyboardView.layout.correspondingButtonForPoint(point: point, size: frame.size)
            if !touchedButtons.contains(button) {
                let point = touch.previousLocation(in: self)
                button = keyboardView.layout.correspondingButtonForPoint(point: point, size: frame.size)
            }
            if touchedButtons.contains(button) {
                while touchedButtons.count > 0 {
                    let poppedButton = touchedButtons[0] as! GRInputButton
                    touchedButtons.removeObject(at: 0)
                    if touchingButtons.count != 1 || touchingCount < MINIMAL_COUNT, poppedButton.isEnabled {
                        poppedButton.sendActions(for: .touchUpInside)
                    }
                    poppedButton.hideEffect()
                    // println("--touch ended: \(poppedButton.captionLabel.text)")
                    if button == poppedButton {
                        break
                    }
                }
            } else {
                // println("already popped? \(button.captionLabel.text)")
            }
        }

//        self.stopTouching()
//        if self.touchedButtons.count == 0 {
//            self.touchingTimer = NSTimer.scheduledTimerWithTimeInterval(0.36, target: self, selector: "checkUntouchingTimer:", userInfo: nil, repeats: false)
//        }
//
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
    }

    override func touchesCancelled(_: Set<UITouch>, with event: UIEvent?) {
        for touch in event!.allTouches! {
            if touch.phase != .cancelled {
                continue
            }
            let point = touch.location(in: self)
            let button = keyboardView.layout.correspondingButtonForPoint(point: point, size: frame.size)
            button.hideEffect()
            // println("touch cancelled: \(button.captionLabel.text)")
        }

        stopTouching()
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
    }
}

class KeyboardView: UIView {
    weak var layout: KeyboardLayout!

    @IBOutlet var nextKeyboardButton: GRInputButton!
    @IBOutlet var deleteButton: GRInputButton!
    @IBOutlet var spaceButton: GRInputButton!
    @IBOutlet var doneButton: GRInputButton!

    @IBOutlet var toggleKeyboardButton: GRInputButton!
    @IBOutlet var shiftButton: GRInputButton!

    var URLButtons: [GRInputButton] { return [] }

    var emailButtons: [GRInputButton] { return [] }

    var twitterButtons: [GRInputButton] { return [] }

    var visibleButtons: [GRInputButton] { return [] }

    let errorButton = GRInputButton(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))
    let untouchButton = GRInputButton(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))

    func needsMargin() -> Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        nextKeyboardButton = GRInputButton()
        deleteButton = GRInputButton()
        doneButton = GRInputButton()
        toggleKeyboardButton = GRInputButton()
        shiftButton = GRInputButton()
        spaceButton = GRInputButton()

        preset()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        func reset(button: GRInputButton?) -> GRInputButton {
            if let button = button {
                // button.setTitleColor(UIColor.clearColor(), forState: .Normal)
                return button
            } else {
                return GRInputButton()
            }
        }

        nextKeyboardButton = reset(button: nextKeyboardButton)
        deleteButton = reset(button: deleteButton)
        doneButton = reset(button: doneButton)
        toggleKeyboardButton = reset(button: toggleKeyboardButton)
        shiftButton = reset(button: shiftButton)
        spaceButton = reset(button: spaceButton)

        preset()
    }

    func preset() {
        nextKeyboardButton.captionLabel.text = "🌐"
        deleteButton.captionLabel.text = "⌫"
        deleteButton.keycode = 0x7F
        doneButton.captionLabel.text = "다음문장"
        doneButton.keycode = UnicodeScalar("\n").value
        spaceButton.captionLabel.text = "간격"
        spaceButton.keycode = UnicodeScalar(" ").value

        nextKeyboardButton.addTarget(nil, action: Selector("mode:"), for: .touchUpInside)
        deleteButton.addTarget(nil, action: Selector("inputDelete:"), for: .touchUpInside)
        shiftButton.addTarget(nil, action: Selector("shift:"), for: .touchUpInside)
        doneButton.addTarget(nil, action: Selector("done:"), for: .touchUpInside)
        toggleKeyboardButton.addTarget(nil, action: Selector("toggleLayout:"), for: .touchUpInside)

        insertSubview(errorButton, at: 0)
        insertSubview(untouchButton, at: 0)
        errorButton.addTarget(nil, action: Selector("error:"), for: .touchUpInside)
        untouchButton.addTarget(nil, action: Selector("untouch:"), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.removeFromSuperview()
        insertSubview(backgroundImageView, at: 0)
        foregroundImageView.removeFromSuperview()
        addSubview(foregroundImageView)
        foregroundEventView.removeFromSuperview()
        addSubview(foregroundEventView)
    }

    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.contentMode = .scaleToFill
        return view
    }()

    lazy var foregroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    lazy var foregroundEventView: KeyboardViewEventView = {
        let view = KeyboardViewEventView(frame: self.bounds)
        view.isMultipleTouchEnabled = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
        return view
    }()
}

class NoKeyboardView: KeyboardView {}

class KeyboardLayout: NSObject, GRKeyboardLayoutHelperDelegate {
    enum ShiftState {
        case Off
        case On
        case Auto
    }

    var context: UnsafeMutableRawPointer?
    var togglable = true {
        didSet {
            view.toggleKeyboardButton.isEnabled = togglable
            view.toggleKeyboardButton.alpha = togglable ? 1.0 : 0.0
        }
    }

    class var capitalizable: Bool { return false }

    class var autounshift: Bool { return false }

    class var shiftCaption: String { return "⬆︎" }

    class var toggleCaption: String { return "123" }

    class var needsMargin: Bool { return false }

    func themesForTrait(trait _: ThemeTrait) -> [GRInputButton: ThemeCaption] {
        return [:]
    }

    var autocapitalized = false

    lazy var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: self)

    lazy var view: KeyboardView = {
        let view = type(of: self).loadView()
        view.layout = self

        view.shiftButton.captionLabel.text = type(of: self).shiftCaption
        self.context = type(of: self).loadContext()

        return view
    }()

    var shift: ShiftState {
        get {
            switch (view.shiftButton.isSelected, autocapitalized) {
            case (true, true): return .Auto
            case (true, false): return .On
            default: return .Off
            }
        }
        set {
            view.shiftButton.isSelected = newValue != .Off
            autocapitalized = newValue == .Auto
            helper.updateCaptionLabel()
        }
    }

    class func loadView() -> KeyboardView {
        assert(false)
        return KeyboardView()
    }

    class func loadContext() -> UnsafeMutableRawPointer? {
        assert(false)
        return nil
    }

    override init() {
        super.init()
        let view = self.view
        helper.createButtonsInView(view: view)
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator _: UIViewControllerTransitionCoordinator!) {
        var rect = view.bounds
        rect.size = size
        helper.layoutButtonsInRect(rect: rect)
    }

    func correspondingButtonForPoint(point: CGPoint, size _: CGSize) -> GRInputButton {
        var newPoint = point
        if point.x < 0 {
            newPoint.x = 0
        }
        if point.x >= view.frame.size.width {
            newPoint.x = view.frame.size.width - 1
        }
        if point.y < 0 {
            newPoint.y = 0
        }
        if point.y >= view.frame.size.height {
            newPoint.y = view.frame.size.height - 1
        }
        for view in view.subviews {
            if !(view is GRInputButton) {
                continue
            }
            let button = view as! GRInputButton
            if button.alpha == 0.0 {
                continue
            }
            if button.frame.contains(newPoint) {
                return button
            }
        }

        view.errorButton.tag = Int(newPoint.x) * 10000 + Int(newPoint.y)
        return view.errorButton
    }

    func captionThemeForTrait(trait: ThemeTrait, position _: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        assert(false)
        return trait._baseCaption
    }

    func layoutWillLoad(helper _: GRKeyboardLayoutHelper) {
        for subview in view.visibleButtons {
            view.addSubview(subview)
        }
    }

    func layoutDidLoad(helper _: GRKeyboardLayoutHelper) {}

    func layoutWillLayout(helper _: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = theme(helper: helper).traitForSize(size: rect.size)

        for (position, button) in helper.buttons {
            let captionTheme = captionThemeForTrait(trait: trait, position: position)
            captionTheme.appealButton(button: button)
        }

        let themeMap = themesForTrait(trait: trait)
        for button in view.visibleButtons {
            if let theme = themeMap[button] {
                theme.appealButton(button: button)
            } else {
                #if DEBUG
                    assert(false)
                #endif
                trait._baseCaption.appealButton(button: button)
            }
        }
    }

    func layoutDidLayout(helper _: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = theme(helper: helper).traitForSize(size: rect.size)
        for (position, button) in helper.buttons {
            let captionTheme = captionThemeForTrait(trait: trait, position: position)
            captionTheme.arrangeButton(button: button)
        }

        let themeMap = themesForTrait(trait: trait)
        for button in view.visibleButtons {
            if let theme = themeMap[button] {
                theme.arrangeButton(button: button)
            } else {
                #if DEBUG
                    assert(false)
                #endif
                trait._baseCaption.arrangeButton(button: button)
            }
        }
    }

    func insetsForHelper(helper _: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func numberOfRowsForHelper(helper _: GRKeyboardLayoutHelper) -> Int {
        assert(false)
        return 0
    }

    func helper(helper _: GRKeyboardLayoutHelper, numberOfColumnsInRow _: Int) -> Int {
        assert(false)
        return 0
    }

    func helper(helper _: GRKeyboardLayoutHelper, heightOfRow _: Int, forSize _: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper _: GRKeyboardLayoutHelper, columnWidthInRow _: Int, forSize _: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper _: GRKeyboardLayoutHelper, leftButtonsForRow _: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper _: GRKeyboardLayoutHelper, rightButtonsForRow _: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper _: GRKeyboardLayoutHelper, buttonForPosition _: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        assert(false)
        return GRInputButton()
    }

    func helper(helper _: GRKeyboardLayoutHelper, titleForPosition _: GRKeyboardLayoutHelper.Position) -> String {
        assert(false)
        return ""
    }

    func theme(helper _: GRKeyboardLayoutHelper) -> Theme {
        if let inputViewController = globalInputViewController {
            return inputViewController.inputMethodView.theme
        } else {
            return PreferencedTheme(resources: preferences.themeResources)
        }
    }

    func adjustTraits(traits _: UITextInputTraits) {
        //
    }
}

class NoKeyboardLayout: KeyboardLayout {
    override class func loadView() -> KeyboardView {
        let view = KeyboardView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))

        view.nextKeyboardButton = GRInputButton()
        view.deleteButton = GRInputButton()
        view.doneButton = GRInputButton()
        view.toggleKeyboardButton = GRInputButton()
        view.shiftButton = GRInputButton()

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton] {
            view.addSubview(subview!)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutableRawPointer? {
        return nil
    }

    override func layoutWillLoad(helper _: GRKeyboardLayoutHelper) {}

    override func layoutDidLoad(helper _: GRKeyboardLayoutHelper) {}

    override func layoutWillLayout(helper _: GRKeyboardLayoutHelper, forRect _: CGRect) {}

    override func layoutDidLayout(helper _: GRKeyboardLayoutHelper, forRect _: CGRect) {}

    override func insetsForHelper(helper _: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func numberOfRowsForHelper(helper _: GRKeyboardLayoutHelper) -> Int {
        return 1
    }

    override func helper(helper _: GRKeyboardLayoutHelper, numberOfColumnsInRow _: Int) -> Int {
        return 1
    }

    override func helper(helper _: GRKeyboardLayoutHelper, heightOfRow _: Int, forSize size: CGSize) -> CGFloat {
        return size.height
    }

    override func helper(helper _: GRKeyboardLayoutHelper, columnWidthInRow _: Int, forSize size: CGSize) -> CGFloat {
        return size.width
    }

    override func helper(helper _: GRKeyboardLayoutHelper, leftButtonsForRow _: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper _: GRKeyboardLayoutHelper, rightButtonsForRow _: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper _: GRKeyboardLayoutHelper, buttonForPosition _: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton(type: .system)
        button.keycode = UnicodeScalar(" ").value
        button.sizeToFit()
        // button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }

    override func helper(helper _: GRKeyboardLayoutHelper, titleForPosition _: GRKeyboardLayoutHelper.Position) -> String {
        return "ERROR: This is a bug."
    }
}

class KeyboardLayoutCollection {
    let layouts: [KeyboardLayout]
    var selectedLayoutIndex = 0
    var selectedLayout: KeyboardLayout {
        return layouts[self.selectedLayoutIndex]
    }

    init(layouts: [KeyboardLayout]) {
        self.layouts = layouts
    }

    func selectLayoutIndex(index: Int) {
        if selectedLayoutIndex == index {
            return
        }
        let oldLayout = selectedLayout
        selectedLayoutIndex = index
        let newLayout = selectedLayout
        newLayout.view.frame = oldLayout.view.frame
        oldLayout.view.superview!.addSubview(newLayout.view)
        oldLayout.view.removeFromSuperview()
    }

    func switchLayout() {
        var layoutIndex = selectedLayoutIndex + 1
        if layoutIndex >= layouts.count {
            layoutIndex = 0
        }
        selectLayoutIndex(index: layoutIndex)
    }
}
