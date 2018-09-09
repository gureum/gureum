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

    //var untouchingTimer: NSTimer = NSTimer()

    var touchedButtons: NSMutableArray = NSMutableArray()
    func addButton(button: GRInputButton) {
        if !self.touchedButtons.contains(button) {
            self.touchedButtons.add(button)
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
        get {
            return self.superview! as! KeyboardView
        }
    }

    func resetTouching() {
        self.stopTouching()
        //self.untouchingTimer.invalidate()
        self.touchingButtons = self.touchedButtons.copy() as! NSArray
        self.touchingTimer = Timer.scheduledTimer(timeInterval: 0.014, target: self, selector: #selector(KeyboardViewEventView.checkTouchingTimer(_:)), userInfo: nil, repeats: true)
    }

    func stopTouching() {
        self.touchingDate = Date()
        self.touchingCount = 0
        self.touchingTimer.invalidate()
    }

    @objc func checkTouchingTimer(_ timer: Timer) {
        if self.touchedButtons.count != 1 {
            self.stopTouching()
            return
        }

        if !self.touchedButtons.isEqual(self.touchedButtons) {
            self.resetTouching()
            return
        }

        self.touchingCount += 1

        if self.touchingCount >= MINIMAL_COUNT && self.touchingCount % 10 == 0 || self.touchingCount >= MINIMAL_COUNT * 4 && self.touchingCount % 5 == 0 {
            let button = self.touchedButtons[0] as! GRInputButton
            button.sendActions(for: .touchUpInside)
        }
        //println("touching \(self.touchingCount)")
    }

//    func checkUntouchingTimer(timer: NSTimer) {
//        self.keyboardView.untouchButton.sendActionsForControlEvents(.TouchUpInside)
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //println("touch began?")
        if touches.count == 1 {
            self.resetTouching()
        } else {
            self.stopTouching()
        }
        self.touchesMoved(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var buttons: [GRInputButton: Bool] = [:]
        var orphans: [GRInputButton] = []

        for rawTouch in (event?.allTouches!)! {
            let touch = rawTouch as UITouch
            let prevPoint = touch.previousLocation(in: self)
            let prevButton = self.keyboardView.layout.correspondingButtonForPoint(point: prevPoint, size: self.frame.size)
            let point = touch.location(in: self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point: point, size: self.frame.size)
            if prevButton != button {
                buttons[prevButton] = nil
                prevButton.hideEffect()
                self.resetTouching()
                //println("--touch moved point: \(point) \(button.captionLabel.text)")
            } else {
                //println("--touch point: \(point) \(button.captionLabel.text)")
            }
            button.showEffect()
            buttons[button] = true
        }

        for raw in self.touchedButtons {
            let button = raw as! GRInputButton
            if buttons[button] == nil {
                button.hideEffect()
                orphans.append(button)
            }
        }
        
        for button in orphans {
            self.touchedButtons.remove(button)
        }
        for button in buttons.keys {
            self.addButton(button: button)
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in event!.allTouches! {
            if touch.phase != .ended {
                continue
            }
            let point = touch.location(in: self)
            var button = self.keyboardView.layout.correspondingButtonForPoint(point: point, size: self.frame.size)
            if !self.touchedButtons.contains(button) {
                let point = touch.previousLocation(in: self)
                button = self.keyboardView.layout.correspondingButtonForPoint(point: point, size: self.frame.size)
            }
            if self.touchedButtons.contains(button) {
                while self.touchedButtons.count > 0 {
                    let poppedButton = self.touchedButtons[0] as! GRInputButton
                    self.touchedButtons.removeObject(at: 0)
                    if (self.touchingButtons.count != 1 || self.touchingCount < MINIMAL_COUNT) && poppedButton.isEnabled {
                        poppedButton.sendActions(for: .touchUpInside)
                    }
                    poppedButton.hideEffect()
                    //println("--touch ended: \(poppedButton.captionLabel.text)")
                    if button == poppedButton {
                        break
                    }
                }
            } else {
                //println("already popped? \(button.captionLabel.text)")
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

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in event!.allTouches! {
            if touch.phase != .cancelled {
                continue
            }
            let point = touch.location(in: self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point: point, size: self.frame.size)
            button.hideEffect()
            //println("touch cancelled: \(button.captionLabel.text)")
        }

        self.stopTouching()
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
    }
}

class KeyboardView: UIView {
    weak var layout: KeyboardLayout! = nil

    @IBOutlet var nextKeyboardButton: GRInputButton! = nil
    @IBOutlet var deleteButton: GRInputButton! = nil
    @IBOutlet var spaceButton: GRInputButton! = nil
    @IBOutlet var doneButton: GRInputButton! = nil

    @IBOutlet var toggleKeyboardButton: GRInputButton! = nil
    @IBOutlet var shiftButton: GRInputButton! = nil

    var URLButtons: [GRInputButton] {
        get { return [] }
    }

    var emailButtons: [GRInputButton] {
        get { return [] }
    }

    var twitterButtons: [GRInputButton] {
        get { return [] }
    }

    var visibleButtons: [GRInputButton] {
        get { return [] }
    }

    let errorButton = GRInputButton(frame: CGRect(x : -1000, y : -1000, width : 0, height : 0))
    let untouchButton = GRInputButton(frame: CGRect(x : -1000, y : -1000, width : 0, height : 0))

    func needsMargin() -> Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.nextKeyboardButton = GRInputButton()
        self.deleteButton = GRInputButton()
        self.doneButton = GRInputButton()
        self.toggleKeyboardButton = GRInputButton()
        self.shiftButton = GRInputButton()
        self.spaceButton = GRInputButton()

        self.preset()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        func reset(button: GRInputButton?) -> GRInputButton {
            if let button = button {
                //button.setTitleColor(UIColor.clearColor(), forState: .Normal)
                return button
            } else {
                return GRInputButton()
            }
        }

        self.nextKeyboardButton = reset(button: self.nextKeyboardButton)
        self.deleteButton = reset(button: self.deleteButton)
        self.doneButton = reset(button: self.doneButton)
        self.toggleKeyboardButton = reset(button: self.toggleKeyboardButton)
        self.shiftButton = reset(button: self.shiftButton)
        self.spaceButton = reset(button: self.spaceButton)

        self.preset()
    }

    func preset() {
        self.nextKeyboardButton.captionLabel.text = "🌐"
        self.deleteButton.captionLabel.text = "⌫"
        self.deleteButton.keycode = 0x7f
        self.doneButton.captionLabel.text = "다음문장"
        self.doneButton.keycode = UnicodeScalar("\n").value
        self.spaceButton.captionLabel.text = "간격"
        self.spaceButton.keycode = UnicodeScalar(" ").value

        self.nextKeyboardButton.addTarget(nil, action: "mode:", for: .touchUpInside)
        self.deleteButton.addTarget(nil, action: "inputDelete:", for: .touchUpInside)
        self.shiftButton.addTarget(nil, action: "shift:", for: .touchUpInside)
        self.doneButton.addTarget(nil, action: "done:", for: .touchUpInside)
        self.toggleKeyboardButton.addTarget(nil, action: "toggleLayout:", for: .touchUpInside)

        self.insertSubview(self.errorButton, at: 0)
        self.insertSubview(self.untouchButton, at: 0)
        self.errorButton.addTarget(nil, action: "error:", for: .touchUpInside)
        self.untouchButton.addTarget(nil, action: "untouch:", for: .touchUpInside)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.removeFromSuperview()
        self.insertSubview(self.backgroundImageView, at: 0)
        self.foregroundImageView.removeFromSuperview()
        self.addSubview(self.foregroundImageView)
        self.foregroundEventView.removeFromSuperview()
        self.addSubview(self.foregroundEventView)
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

class NoKeyboardView: KeyboardView {
}

class KeyboardLayout: NSObject, GRKeyboardLayoutHelperDelegate {
    
    enum ShiftState {
        case Off
        case On
        case Auto
    }

    var context: UnsafeMutableRawPointer? = nil
    var togglable = true {
        didSet {
            self.view.toggleKeyboardButton.isEnabled = togglable
            self.view.toggleKeyboardButton.alpha = togglable ? 1.0 : 0.0
        }
    }
    class var capitalizable: Bool {
        get { return false }
    }
    class var autounshift: Bool {
        get { return false }
    }
    class var shiftCaption: String {
        get { return "⬆︎" }
    }
    class var toggleCaption: String {
        get { return "123" }
    }
    class var needsMargin: Bool {
        get { return false }
    }

    func themesForTrait(trait: ThemeTrait) -> [GRInputButton: ThemeCaption] {
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
            switch (self.view.shiftButton.isSelected, self.autocapitalized) {
            case (true, true): return .Auto
            case (true, false): return .On
            default: return .Off
            }
        }
        set {
            self.view.shiftButton.isSelected = newValue != .Off
            self.autocapitalized = newValue == .Auto
            self.helper.updateCaptionLabel()
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
        self.helper.createButtonsInView(view: view)
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        var rect = self.view.bounds
        rect.size = size
        self.helper.layoutButtonsInRect(rect: rect)
    }

    func correspondingButtonForPoint(point: CGPoint, size: CGSize) -> GRInputButton {
        var newPoint = point
        if point.x < 0 {
            newPoint.x = 0
        }
        if point.x >= self.view.frame.size.width {
            newPoint.x = self.view.frame.size.width - 1
        }
        if point.y < 0 {
            newPoint.y = 0
        }
        if point.y >= self.view.frame.size.height {
            newPoint.y = self.view.frame.size.height - 1
        }
        for view in self.view.subviews {
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

        self.view.errorButton.tag = Int(newPoint.x) * 10000 + Int(newPoint.y)
        return self.view.errorButton
    }

    func captionThemeForTrait(trait: ThemeTrait, position: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        assert(false)
        return trait._baseCaption
    }

    func layoutWillLoad(helper: GRKeyboardLayoutHelper) {
        for subview in self.view.visibleButtons {
            self.view.addSubview(subview)
        }
    }

    func layoutDidLoad(helper: GRKeyboardLayoutHelper) {
    }


    func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.theme(helper: self.helper).traitForSize(size: rect.size)

        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait: trait, position: position)
            captionTheme.appealButton(button: button)
        }

        let themeMap = self.themesForTrait(trait: trait)
        for button in self.view.visibleButtons {
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

    func layoutDidLayout(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        let trait = self.theme(helper: self.helper).traitForSize(size: rect.size)
        for (position, button) in self.helper.buttons {
            let captionTheme = self.captionThemeForTrait(trait: trait, position: position)
            captionTheme.arrangeButton(button: button)
        }

        let themeMap = self.themesForTrait(trait: trait)
        for button in self.view.visibleButtons {
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

    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int, forSize: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        assert(false)
        return GRInputButton()
    }

    func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        assert(false)
        return ""
    }

    func theme(helper: GRKeyboardLayoutHelper) -> Theme {
        if let inputViewController = globalInputViewController {
            return inputViewController.inputMethodView.theme
        } else {
            return PreferencedTheme(resources: preferences.themeResources)
        }
    }

    func adjustTraits(traits: UITextInputTraits) {
        //
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func loadView() -> KeyboardView {
        let view = KeyboardView(frame: CGRect(x:0, y:0, width:200, height:100))

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

    override func layoutWillLoad(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutDidLoad(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
    }

    override func layoutDidLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
    }

    override func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize size: CGSize) -> CGFloat {
        return size.height
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        return size.width
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton(type: .system)
        button.keycode = UnicodeScalar(" ").value
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        return "ERROR: This is a bug."
    }
}

class KeyboardLayoutCollection {
    let layouts: [KeyboardLayout]
    var selectedLayoutIndex = 0
    var selectedLayout: KeyboardLayout {
        get {
            return self.layouts[self.selectedLayoutIndex]
        }
    }

    init(layouts: [KeyboardLayout]) {
        self.layouts = layouts
    }

    func selectLayoutIndex(index: Int) {
        if self.selectedLayoutIndex == index {
            return
        }
        let oldLayout = self.selectedLayout
        self.selectedLayoutIndex = index
        let newLayout = self.selectedLayout
        newLayout.view.frame = oldLayout.view.frame
        oldLayout.view.superview!.addSubview(newLayout.view)
        oldLayout.view.removeFromSuperview()
    }

    func switchLayout() {
        var layoutIndex = self.selectedLayoutIndex + 1
        if layoutIndex >= self.layouts.count {
            layoutIndex = 0
        }
        self.selectLayoutIndex(index: layoutIndex)
    }
}
