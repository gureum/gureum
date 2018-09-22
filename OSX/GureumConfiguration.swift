//
//  GureumConfiguration.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import AppKit

enum GureumConfigurationName: String {
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
    case hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
}


@objc class GureumConfiguration: UserDefaults {

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        self.register(defaults: [
            GureumConfigurationName.inputModeExchangeKeyModifier.rawValue: NSEvent.ModifierFlags.shift.rawValue,
            GureumConfigurationName.inputModeExchangeKeyCode.rawValue: 0x31,
            GureumConfigurationName.inputModeHanjaKeyModifier.rawValue: NSEvent.ModifierFlags.option.rawValue,
            GureumConfigurationName.inputModeHanjaKeyCode.rawValue: 0x24,
            GureumConfigurationName.autosaveDefaultInputMode.rawValue: true,
            GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue: true,
        ])
    }

    @objc public var lastHangulInputMode: String? {
        get {
            return self.string(forKey: GureumConfigurationName.lastHangulInputMode.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.lastHangulInputMode.rawValue)
        }
    }

    @objc public var optionKeyBehavior: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
    }

    @objc public var showsInputForHanjaCandidates: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
    }

    @objc public var inputModeExchangeKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: GureumConfigurationName.inputModeExchangeKeyModifier.rawValue)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
    }
    
    @objc public var inputModeExchangeKeyCode: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.inputModeExchangeKeyCode.rawValue)
        }
    }
    
    public var inputModeExchangeKey: (NSEvent.ModifierFlags, Int) {
        get {
            return (self.inputModeExchangeKeyModifier, self.inputModeExchangeKeyCode)
        }
    }

    @objc public var inputModeHanjaKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: GureumConfigurationName.inputModeHanjaKeyModifier.rawValue)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.inputModeHanjaKeyModifier.rawValue)
        }
    }

    @objc public var inputModeHanjaKeyCode: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.inputModeHanjaKeyCode.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.inputModeHanjaKeyCode.rawValue)
        }
    }
    
    public var inputModeHanjaKey: (NSEvent.ModifierFlags, Int) {
        get{
            return (self.inputModeHanjaKeyModifier, self.inputModeHanjaKeyCode)
        }
    }

    @objc public var romanModeByEscapeKey: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
        }
    }

    @objc public var autosaveDefaultInputMode: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.autosaveDefaultInputMode.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.autosaveDefaultInputMode.rawValue)
        }
    }
    
    public var skippedVersion: String?{
        get {
            return self.string(forKey: GureumConfigurationName.skippedVersion.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.skippedVersion.rawValue)
        }
    }
    
    public var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
    }

    static let _shared = GureumConfiguration()

    @objc class func shared() -> GureumConfiguration {
        return _shared
    }
}
