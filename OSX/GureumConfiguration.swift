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
    case inputModeEmoticonKey = "CIMInputModeEmoticonKey"
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
    case hangulAutoReorder = "HangulAutoReorder"
    case hangulNonChoseongCombination = "HangulNonChoseongCombination"
}


@objc public class GureumConfiguration: UserDefaults {

    public typealias Shortcut = (UInt, NSEvent.ModifierFlags)
    
    public class func convertShortcutToConfiguration(_ shortcut: Shortcut?) -> [String: Any] {
        guard let shortcut = shortcut else {
            return [:]
        }
        return ["modifier": shortcut.1.rawValue, "keyCode": shortcut.0]
    }
    
    public class func convertConfigurationToShortcut(_ configuration: [String: Any]) -> Shortcut? {
        guard let modifier = configuration["modifier"] as? UInt, let keyCode = configuration["keyCode"] as? UInt else {
            return nil
        }
        return (keyCode, NSEvent.ModifierFlags(rawValue: modifier))
    }

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        self.register(defaults: [
            GureumConfigurationName.inputModeExchangeKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x31, .shift)),
            GureumConfigurationName.inputModeEmoticonKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x24, [.shift, .option])),
            GureumConfigurationName.inputModeHanjaKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x24, .option)),
            GureumConfigurationName.optionKeyBehavior.rawValue: 0,
            GureumConfigurationName.autosaveDefaultInputMode.rawValue: true,
            GureumConfigurationName.romanModeByEscapeKey.rawValue: false,
            GureumConfigurationName.showsInputForHanjaCandidates.rawValue: true,
            GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue: true,
            GureumConfigurationName.enableCapslockToToggleInputMode.rawValue: true,
            GureumConfigurationName.lastHangulInputMode.rawValue: "org.youknowone.inputmethod.Gureum.han2",
        ])
    }
    
    func getShortcut(forKey key: String) -> Shortcut? {
        guard let value = self.dictionary(forKey: key) else {
            return nil
        }
        return GureumConfiguration.convertConfigurationToShortcut(value)
    }
    
    func setShortcut(_ newValue: Shortcut?, forKey key: String) {
        self.set(GureumConfiguration.convertShortcutToConfiguration(newValue) , forKey: key)
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
    
    public var inputModeExchangeKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeExchangeKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeExchangeKey.rawValue)
        }
    }

    public var inputModeEmoticonKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeEmoticonKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeEmoticonKey.rawValue)
        }
    }

    public var inputModeHanjaKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeHanjaKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeHanjaKey.rawValue)
        }
    }
    
    public var inputModeEnglishKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeEnglishKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeEnglishKey.rawValue)
        }
    }
    
    public var inputModeKoreanKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeKoreanKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeKoreanKey.rawValue)
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
    
    public var hangulAutoReorder: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.hangulAutoReorder.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.hangulAutoReorder.rawValue)
        }
    }
    
    public var hangulNonChoseongCombination: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.hangulNonChoseongCombination.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.hangulNonChoseongCombination.rawValue)
        }
    }

    static let _shared = GureumConfiguration()

    @objc class func shared() -> GureumConfiguration {
        return _shared
    }
}
