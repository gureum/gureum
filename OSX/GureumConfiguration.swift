//
//  GureumConfiguration.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import AppKit

var CIMLastHangulInputMode = "CIMLastHangulInputMode"

var CIMLeftCommandKeyShortcutBehavior = "CIMLeftCommandKeyShortcutBehavior"
var CIMLeftOptionKeyShortcutBehavior = "CIMLeftOptionKeyShortcutBehavior"
var CIMLeftControlKeyShortcutBehavior = "CIMLeftControlKeyShortcutBehavior"
var CIMRightCommandKeyShortcutBehavior = "CIMRightCommandKeyShortcutBehavior"
var CIMRightOptionKeyShortcutBehavior = "CIMRightOptionKeyShortcutBehavior"
var CIMRightControlKeyShortcutBehavior = "CIMRightControlKeyShortcutBehavior"
var CIMInputModeExchangeKeyModifier = "CIMInputModeExchangeKeyModifier"
var CIMInputModeExchangeKeyCode = "CIMInputModeExchangeKeyCode"
var CIMInputModeHanjaKeyModifier = "CIMInputModeHanjaKeyModifier"
var CIMInputModeHanjaKeyCode = "CIMInputModeHanjaKeyCode"
var CIMInputModeEnglishKeyModifier = "CIMInputModeEnglishKeyModifier"
var CIMInputModeEnglishKeyCode = "CIMInputModeEnglishKeyCode"
var CIMInputModeKoreanKeyModifier = "CIMInputModeKoreanKeyModifier"
var CIMInputModeKoreanKeyCode = "CIMInputModeKoreanKeyCode"
var CIMOptionKeyBehavior = "CIMOptionKeyBehavior"

var CIMSharedInputManager = "CIMSharedInputManager"
var CIMAutosaveDefaultInputMode = "CIMAutosaveDefaultInputMode"
var CIMRomanModeByEscapeKey = "CIMRomanModeByEscapeKey"
var CIMShowsInputForHanjaCandidates = "CIMShowsInputForHanjaCandidates"


@objc class GureumConfiguration: UserDefaults {

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        self.register(defaults: [
            CIMInputModeExchangeKeyModifier: NSEvent.ModifierFlags.shift.rawValue,
            CIMInputModeExchangeKeyCode: 0x31,
            CIMInputModeHanjaKeyModifier: NSEvent.ModifierFlags.option.rawValue,
            CIMInputModeHanjaKeyCode: 0x24,
            CIMAutosaveDefaultInputMode: true,
        ])
    }

    @objc public var lastHangulInputMode: String? {
        get {
            return self.string(forKey: CIMLastHangulInputMode)
        }
        set {
            return self.set(newValue, forKey: CIMLastHangulInputMode)
        }
    }

    @objc public var optionKeyBehavior: Int {
        get {
            return self.integer(forKey: CIMOptionKeyBehavior)
        }
        set {
            return self.set(newValue, forKey: CIMOptionKeyBehavior)
        }
    }

    @objc public var showsInputForHanjaCandidates: Int {
        get {
            return self.integer(forKey: CIMShowsInputForHanjaCandidates)
        }
        set {
            return self.set(newValue, forKey: CIMShowsInputForHanjaCandidates)
        }
    }

    @objc public var inputModeExchangeKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: CIMInputModeExchangeKeyModifier)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
    }
    
    @objc public var inputModeExchangeKeyCode: Int {
        get {
            return self.integer(forKey: CIMInputModeExchangeKeyCode)
        }
    }
    
    public var inputModeExchangeKey: (NSEvent.ModifierFlags, Int) {
        get {
            return (self.inputModeExchangeKeyModifier, self.inputModeExchangeKeyCode)
        }
    }

    @objc public var inputModeHanjaKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: CIMInputModeHanjaKeyModifier)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
        set {
            return self.set(newValue, forKey: CIMInputModeHanjaKeyModifier)
        }
    }

    @objc public var inputModeHanjaKeyCode: Int {
        get {
            return self.integer(forKey: CIMInputModeHanjaKeyCode)
        }
        set {
            return self.set(newValue, forKey: CIMInputModeHanjaKeyCode)
        }
    }
    
    public var inputModeHanjaKey: (NSEvent.ModifierFlags, Int) {
        get{
            return (self.inputModeHanjaKeyModifier, self.inputModeHanjaKeyCode)
        }
    }

    @objc public var romanModeByEscapeKey: Int {
        get {
            return self.integer(forKey: CIMRomanModeByEscapeKey);
        }
        set {
            return self.set(newValue, forKey: CIMRomanModeByEscapeKey)
        }
    }

    @objc public var autosaveDefaultInputMode: Int {
        get {
            return self.integer(forKey: CIMAutosaveDefaultInputMode);
        }
        set {
            return self.set(newValue, forKey: CIMAutosaveDefaultInputMode)
        }
    }

    static let _shared = GureumConfiguration()

    @objc class func shared() -> GureumConfiguration {
        return _shared
    }
}
