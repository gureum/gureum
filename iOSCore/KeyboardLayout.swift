//
//  KeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class KeyboardViewEventView: UIView {
    var keyboardView: KeyboardView {
        get {
            return self.superview! as KeyboardView
        }
    }
    var touching: Bool = false {
        didSet {
            println("touching changed: \(touching)")
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.touching = true
        self.touchesMoved(touches, withEvent: event)
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for rawTouch in event.allTouches()! {
            let touch = rawTouch as UITouch
            let point = touch.locationInView(self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            println("touch point: \(point) \(button)")
            button.showEffect()
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for rawTouch in event.allTouches()! {
            let touch = rawTouch as UITouch
            let point = touch.locationInView(self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            button.sendActionsForControlEvents(.TouchUpInside)
            button.hideEffect()
        }
        self.touching = false
    }

    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.touching = false
    }
}

class KeyboardView: UIView {
    var layout: KeyboardLayout! = nil

    @IBOutlet var nextKeyboardButton: GRInputButton! = nil
    @IBOutlet var deleteButton: GRInputButton! = nil
    @IBOutlet var doneButton: GRInputButton! = nil

    @IBOutlet var toggleKeyboardButton: GRInputButton! = nil
    @IBOutlet var shiftButton: GRInputButton! = nil

    override init() {
        super.init()
        self.backgroundColor = UIColor.clearColor()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.removeFromSuperview()
        self.insertSubview(self.backgroundImageView, atIndex: 0)
        self.foregroundImageView.removeFromSuperview()
        self.addSubview(self.foregroundImageView)
        self.foregroundEventView.removeFromSuperview()
        self.addSubview(self.foregroundEventView)
    }

    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return view
    }()

    lazy var foregroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return view
    }()

    lazy var foregroundEventView: KeyboardViewEventView = {
        let view = KeyboardViewEventView(frame: self.bounds)
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        view.userInteractionEnabled = true
        return view
    }()
}

class NoKeyboardView: KeyboardView {
}

class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    var context: UnsafeMutablePointer<()> = nil
    lazy var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: self)

    lazy var view: KeyboardView = {
        let view = self.dynamicType.loadView()
        view.layout = self

        assert(view.nextKeyboardButton != nil)
        assert(view.deleteButton != nil)
        view.nextKeyboardButton.addTarget(nil, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        view.deleteButton.addTarget(nil, action: "delete", forControlEvents: .TouchUpInside)

        self.context = self.dynamicType.loadContext()

        return view
    }()

    class func loadView() -> KeyboardView {
        assert(false)
        return KeyboardView()
    }

    class func loadContext() -> UnsafeMutablePointer<()> {
        assert(false)
        return nil
    }

    init() {
        let view = self.view
        self.helper.createButtonsInView(view)
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        var rect = self.view.bounds
        rect.size = size
        self.helper.layoutButtonsInRect(rect)
    }

    func correspondingButtonForPoint(point: CGPoint, size: CGSize) -> GRInputButton {
        var newPoint = point
        if point.x < 0 {
            newPoint.x = 0
        }
        if point.x > self.view.frame.size.width {
            newPoint.x = self.view.frame.size.width
        }
        if point.y < 0 {
            newPoint.y = 0
        }
        if point.y > self.view.frame.size.height {
            newPoint.x = self.view.frame.size.height
        }
        for button in self.view.subviews {
            if !(button is GRInputButton) {
                continue
            }
            if CGRectContainsPoint(button.frame, newPoint) {
                return button as GRInputButton
            }
        }
        assert(false)
        return GRInputButton()
    }

    func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
    }

    func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
    }

    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        assert(false)
        return UIEdgeInsetsZero
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

    func themeForHelper(helper: GRKeyboardLayoutHelper) -> Theme {
        return globalInputViewController!.inputMethodView.theme
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func loadView() -> KeyboardView {
        let view = KeyboardView(frame: CGRectMake(0, 0, 320, 216))

        view.nextKeyboardButton = GRInputButton()
        view.deleteButton = GRInputButton()
        view.doneButton = GRInputButton()
        view.toggleKeyboardButton = GRInputButton()
        view.shiftButton = GRInputButton()

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton] {
            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return nil
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
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
        let button = GRInputButton.buttonWithType(.System) as GRInputButton
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
