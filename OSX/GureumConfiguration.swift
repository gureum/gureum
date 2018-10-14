//
//  GureumConfiguration.swift
//  Gureum
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
    case inputModeExchangeKey = "CIMInputModeExchangeKey"
    case inputModeEmoticonKeyModifier = "CIMInputModeEmoticonKeyModifier"
    case inputModeEmoticonKeyCode = "CIMInputModeEmoticonKeyCode"
    case inputModeHanjaKey = "CIMInputModeHanjaKey"
    case inputModeEnglishKey = "CIMInputModeEnglishKey"
    case inputModeKoreanKey = "CIMInputModeKoreanKey"
    case optionKeyBehavior = "CIMOptionKeyBehavior"
    case enableCapslockToToggleInputMode = "EnableCapslockToToggleInputMode"
    
    case autosaveDefaultInputMode = "CIMAutosaveDefaultInputMode"
    case romanModeByEscapeKey = "CIMRomanModeByEscapeKey"
    case showsInputForHanjaCandidates = "CIMShowsInputForHanjaCandidates"
    case skippedVersion = "SkippedVersion"
    case hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
}


@objc public class GureumConfiguration: UserDefaults {

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        self.register(defaults: [
            GureumConfigurationName.inputModeExchangeKey.rawValue: ["modifier": NSEvent.ModifierFlags.shift.rawValue, "keyCode": 0x31],
            GureumConfigurationName.inputModeEmoticonKeyModifier.rawValue: NSEvent.ModifierFlags([.shift, .option]).rawValue,
            GureumConfigurationName.inputModeEmoticonKeyCode.rawValue: 0x24,
            GureumConfigurationName.inputModeHanjaKey.rawValue: ["modifier": NSEvent.ModifierFlags.option.rawValue, "keyCode": 0x24],
            GureumConfigurationName.optionKeyBehavior.rawValue: 0,
            GureumConfigurationName.autosaveDefaultInputMode.rawValue: true,
            GureumConfigurationName.romanModeByEscapeKey.rawValue: false,
            GureumConfigurationName.showsInputForHanjaCandidates.rawValue: true,
            GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue: true,
            GureumConfigurationName.enableCapslockToToggleInputMode.rawValue: true,
            GureumConfigurationName.lastHangulInputMode.rawValue: "org.youknowone.inputmethod.Gureum.han2",
        ])
    }
    
    func getShortcutKey(_ propertyString: String) -> (NSEvent.ModifierFlags, UInt)? {
        guard let value = self.dictionary(forKey: propertyString) else {
            return nil
        }
        guard !value.isEmpty else {
            return nil
        }
        return (NSEvent.ModifierFlags(rawValue: value["modifier"] as! UInt), value["keyCode"] as! UInt)
    }
    
    func setShortcutKey(_ propertyString: String, _ newValue: (NSEvent.ModifierFlags, UInt)?) {
        if let newValue = newValue {
            self.set(["modifier": newValue.0.rawValue, "keyCode": newValue.1], forKey: propertyString)
        } else {
            self.set([:], forKey: propertyString)
        }
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

    @objc public var showsInputForHanjaCandidates: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
    }
    
    @objc public var enableCapslockToToggleInputMode: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.enableCapslockToToggleInputMode.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.enableCapslockToToggleInputMode.rawValue)
        }
    }
    
    public var inputModeExchangeKeyCode: UInt? {
        get {
            return self.inputModeExchangeKey?.1
        }
    }
    
    public var inputModeExchangeKeyModifier: UInt? {
        get {
            return self.inputModeExchangeKey?.0.rawValue
        }
    }
    
    public var inputModeExchangeKey: (NSEvent.ModifierFlags, UInt)? {
        get {
            return getShortcutKey(GureumConfigurationName.inputModeExchangeKey.rawValue)
        }
        set {
            setShortcutKey(GureumConfigurationName.inputModeExchangeKey.rawValue, newValue)
        }
    }

    @objc public var inputModeEmoticonKeyModifier: NSEvent.ModifierFlags {
        get {
            let value = self.integer(forKey: GureumConfigurationName.inputModeEmoticonKeyModifier.rawValue)
            return NSEvent.ModifierFlags(rawValue: UInt(value))
        }
    }

    @objc public var inputModeEmoticonKeyCode: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.inputModeEmoticonKeyCode.rawValue)
        }
    }

    public var inputModeEmoticonKey: (NSEvent.ModifierFlags, Int) {
        get {
            return (self.inputModeEmoticonKeyModifier, self.inputModeEmoticonKeyCode)
        }
    }
    
    public var inputModeHanjaKeyCode: UInt? {
        get {
            return self.inputModeHanjaKey?.1
        }
    }
    
    public var inputModeHanjaKeyModifier: UInt? {
        get {
            return self.inputModeHanjaKey?.0.rawValue
        }
    }
    
    public var inputModeHanjaKey: (NSEvent.ModifierFlags, UInt)? {
        get {
            return getShortcutKey(GureumConfigurationName.inputModeHanjaKey.rawValue)
        }
        set {
            setShortcutKey(GureumConfigurationName.inputModeHanjaKey.rawValue, newValue)
        }
    }
    
    public var inputModeEnglishKeyCode: UInt? {
        get {
            return self.inputModeEnglishKey?.1
        }
    }
    
    public var inputModeEnglishKeyModifier: UInt? {
        get {
            return self.inputModeEnglishKey?.0.rawValue
        }
    }
    
    public var inputModeEnglishKey: (NSEvent.ModifierFlags, UInt)? {
        get {
            return getShortcutKey(GureumConfigurationName.inputModeEnglishKey.rawValue)
        }
        set {
            setShortcutKey(GureumConfigurationName.inputModeEnglishKey.rawValue, newValue)
        }
    }
    
    public var inputModeKoreanKeyCode: UInt? {
        get {
            return self.inputModeKoreanKey?.1
        }
    }
    
    public var inputModeKoreanKeyModifier: UInt? {
        get {
            return self.inputModeKoreanKey?.0.rawValue
        }
    }
    
    public var inputModeKoreanKey: (NSEvent.ModifierFlags, UInt)? {
        get {
            return getShortcutKey(GureumConfigurationName.inputModeKoreanKey.rawValue)
        }
        set {
            setShortcutKey(GureumConfigurationName.inputModeKoreanKey.rawValue, newValue)
        }
    }

    @objc public var romanModeByEscapeKey: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
        }
    }

    @objc public var autosaveDefaultInputMode: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.autosaveDefaultInputMode.rawValue);
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.autosaveDefaultInputMode.rawValue)
        }
    }
    
    public var skippedVersion: String? {
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
