//
//  KeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let MINIMAL_COUNT = 30

class KeyboardViewEventView: UIView {
    var touchingDate: NSDate = NSDate()
    var touchingCount: Int = 0
    var touchingTimer: Timer = Timer()
    var touchingButtons: NSArray = NSArray()

    var untouchingTimer: Timer = Timer()

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
        self.untouchingTimer.invalidate()
        self.touchingButtons = self.touchedButtons.copy() as! NSArray
        self.touchingTimer = Timer.scheduledTimer(timeInterval: 0.014, target: self, selector: #selector(KeyboardViewEventView.checkTouchingTimer(_:)), userInfo: nil, repeats: true)
    }

    func stopTouching() {
        self.touchingDate = NSDate()
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

    func checkUntouchingTimer(timer: Timer) {
        self.keyboardView.untouchButton.sendActions(for: .touchUpInside)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //println("touch began?")
        if touches.count == 1 {
            self.resetTouching()
        } else {
            self.stopTouching()
        }
        self.touchesMoved(touches , with: event)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        for rawTouch in (event?.allTouches!)! {
            let touch = rawTouch as UITouch
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
                    if self.touchingButtons.count != 1 || self.touchingCount < MINIMAL_COUNT {
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
        
        self.stopTouching()
        if self.touchedButtons.count == 0 {
            self.touchingTimer = Timer.scheduledTimer(timeInterval: 0.36, target: self, selector: Selector(("checkUntouchingTimer:")), userInfo: nil, repeats: false)
        }
        
        //        for spot in self.touchedSpots {
        //            spot.hidden = true
        //        }
    }

   
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for rawTouch in (event?.allTouches!)! {
            let touch = rawTouch as UITouch
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
    var layout: KeyboardLayout! = nil

    @IBOutlet var nextKeyboardButton: GRInputButton! = nil
    @IBOutlet var deleteButton: GRInputButton! = nil
    @IBOutlet var doneButton: GRInputButton! = nil

    @IBOutlet var toggleKeyboardButton: GRInputButton! = nil
    @IBOutlet var shiftButton: GRInputButton! = nil

    let errorButton = GRInputButton(frame: CGRect(x : -1000, y : -1000, width : 0, height : 0))
    let untouchButton = GRInputButton(frame: CGRect(x : -1000, y : -1000, width : 0, height : 0))


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
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

class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    var context: UnsafeMutableRawPointer? = nil
    lazy var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: self)

    lazy var view: KeyboardView = {
        let view = type(of: self).loadView()
        view.layout = self

        assert(view.nextKeyboardButton != nil)
        assert(view.deleteButton != nil)
        view.nextKeyboardButton.addTarget(nil, action: Selector(("mode:")), for: .touchUpInside)
        view.deleteButton.addTarget(nil, action: Selector(("inputDelete:")), for: .touchUpInside)

        view.insertSubview(view.errorButton, at: 0)
        view.insertSubview(view.untouchButton, at: 0)
        view.errorButton.addTarget(nil, action: Selector(("error:")), for: .touchUpInside)
        view.untouchButton.addTarget(nil, action: Selector(("untouch:")), for: .touchUpInside)

        self.context = type(of: self).loadContext()

        return view
    }()

    class func loadView() -> KeyboardView {
        assert(false)
        return KeyboardView()
    }

    class func loadContext() -> UnsafeMutableRawPointer? {
        assert(false)
        return nil
    }

    init() {
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
        if point.x > self.view.frame.size.width {
            newPoint.x = self.view.frame.size.width - 1
        }
        if point.y < 0 {
            newPoint.y = 0
        }
        if point.y > self.view.frame.size.height {
            newPoint.y = self.view.frame.size.height - 1
        }
        for button in self.view.subviews {
            if !(button is GRInputButton) {
                continue
            }
            if button.frame.contains(newPoint) {
                return button as! GRInputButton
            }
        }

        self.view.errorButton.tag = Int(newPoint.x) * 10000 + Int(newPoint.y)
        return self.view.errorButton
    }

    func layoutWillLoad(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutDidLoad(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
    }

    func layoutDidLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
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
        return globalInputViewController!.inputMethodView.theme
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func loadView() -> KeyboardView {
        let view = KeyboardView(frame: CGRect(x : 0, y : 0,width : 320,height : 216))

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

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat {
        return 216
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize: CGSize) -> CGFloat {
        return 320
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton(type: .system) as GRInputButton
        button.tag = Int(UnicodeScalar(" ").value)
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

    func switchLayout() {
        let oldLayout = self.selectedLayout
        self.selectedLayoutIndex += 1
        if self.selectedLayoutIndex >= self.layouts.count {
            self.selectedLayoutIndex = 0
        }
        let newLayout = self.selectedLayout

        newLayout.view.frame = oldLayout.view.frame
        oldLayout.view.superview!.addSubview(newLayout.view)
        oldLayout.view.removeFromSuperview()
    }
}
