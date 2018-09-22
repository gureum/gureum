//
//  GureumConfiguration.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import AppKit

enum GureumConfiguraionName: String {
    case lastHangulInputMode = "CIMLastHangulInputMode"
    
    case leftCommandKeyShortcutBehavior = "CIMLeftCommandKeyShortcutBehavior"
    case leftOptionKeyShortcutBehavior = "CIMLeftOptionKeyShortcutBehavior"
    case leftControlKeyShortcutBehavior = "CIMLeftControlKeyShortcutBehavior"
    case rightCommandKeyShortcutBehavior = "CIMRightCommandKeyShortcutBehavior"
    case rightOptionKeyShortcutBehavior = "CIMRightOptionKeyShortcutBehavior"
    case rightControlKeyShortcutBehavior = "CIMRightControlKeyShortcutBehavior"
    case inputModeExchangeKeyModifier = "CIMInputModeExchangeKeyModifier"
    case inputModeExchangeKeyCode = "CIMInputModeExchangeKeyCode"
    case inputModeHanjaKeyModifier = "CIMInputModeHanjaKeyModifier"
    case inputModeHanjaKeyCode = "CIMInputModeHanjaKeyCode"
    case inputModeEnglishKeyModifier = "CIMInputModeEnglishKeyModifier"
    case inputModeEnglishKeyCode = "CIMInputModeEnglishKeyCode"
    case inputModeKoreanKeyModifier = "CIMInputModeKoreanKeyModifier"
    case inputModeKoreanKeyCode = "CIMInputModeKoreanKeyCode"
    case optionKeyBehavior = "CIMOptionKeyBehavior"
    
    case sharedInputManager = "CIMSharedInputManager"
    case autosaveDefaultInputMode = "CIMAutosaveDefaultInputMode"
    case romanModeByEscapeKey = "CIMRomanModeByEscapeKey"
    case showsInputForHanjaCandidates = "CIMShowsInputForHanjaCandidates"
    case skippedVersion = "SkippedVersion"
}


@objc class GureumConfiguration: UserDefaults {

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        self.register(defaults: [
            GureumConfiguraionName.inputModeExchangeKeyModifier.rawValue: NSEvent.ModifierFlags.shift.rawValue,
            GureumConfiguraionName.inputModeExchangeKeyCode.rawValue: 0x31,
            GureumConfiguraionName.inputModeHanjaKeyModifier.rawValue: NSEvent.ModifierFlags.option.rawValue,
            GureumConfiguraionName.inputModeHanjaKeyCode.rawValue: 0x24,
            GureumConfiguraionName.autosaveDefaultInputMode.rawValue: true,
        ])
    }

    @objc public var lastHangulInputMode: String? {
        get {
            return self.string(forKey: GureumConfiguraionName.lastHangulInputMode.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.lastHangulInputMode.rawValue)
        }
    }

    @objc public var optionKeyBehavior: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.optionKeyBehavior.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.optionKeyBehavior.rawValue)
        }
    }

    @objc public var showsInputForHanjaCandidates: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.showsInputForHanjaCandidates.rawValue)
        }
    }

    @objc public var inputModeExchangeKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: GureumConfiguraionName.inputModeExchangeKeyModifier.rawValue)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
    }
    
    @objc public var inputModeExchangeKeyCode: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.inputModeExchangeKeyCode.rawValue)
        }
    }
    
    public var inputModeExchangeKey: (NSEvent.ModifierFlags, Int) {
        get {
            return (self.inputModeExchangeKeyModifier, self.inputModeExchangeKeyCode)
        }
    }

    @objc public var inputModeHanjaKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: GureumConfiguraionName.inputModeHanjaKeyModifier.rawValue)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.inputModeHanjaKeyModifier.rawValue)
        }
    }

    @objc public var inputModeHanjaKeyCode: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.inputModeHanjaKeyCode.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.inputModeHanjaKeyCode.rawValue)
        }
    }
    
    public var inputModeHanjaKey: (NSEvent.ModifierFlags, Int) {
        get{
            return (self.inputModeHanjaKeyModifier, self.inputModeHanjaKeyCode)
        }
    }

    @objc public var romanModeByEscapeKey: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.romanModeByEscapeKey.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.romanModeByEscapeKey.rawValue)
        }
    }

    @objc public var autosaveDefaultInputMode: Int {
        get {
            return self.integer(forKey: GureumConfiguraionName.autosaveDefaultInputMode.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.autosaveDefaultInputMode.rawValue)
        }
    }
    
    public var skippedVersion: String?{
        get {
            return self.string(forKey: GureumConfiguraionName.skippedVersion.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfiguraionName.skippedVersion.rawValue)
        }
    }

    static let _shared = GureumConfiguration()

    @objc class func shared() -> GureumConfiguration {
        return _shared
    }
}
