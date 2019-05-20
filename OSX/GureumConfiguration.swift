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
    case lastHangulInputMode = "LastHangulInputMode"
    case lastRomanInputMode = "LastRomanInputMode"
    
    case inputModeExchangeKey = "InputModeExchangeKey"
    case inputModeEmoticonKey = "InputModeEmoticonKey"
    case inputModeHanjaKey = "InputModeHanjaKey"
    case inputModeEnglishKey = "InputModeEnglishKey"
    case inputModeKoreanKey = "InputModeKoreanKey"
    case optionKeyBehavior = "OptionKeyBehavior"
    
    case romanModeByEscapeKey = "ExchangeToRomanModeByEscapeKey"
    case showsInputForHanjaCandidates = "ShowsInputForHanjaCandidates"
    case hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
    case hangulAutoReorder = "HangulAutoReorder"
    case hangulNonChoseongCombination = "HangulNonChoseongCombination"
    case hangulForceStrictCombinationRule = "HangulForceStrictCombinationRule"
}


public class GureumConfiguration: UserDefaults {

    public var enableCapslockToToggleInputMode: Bool = true

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
            GureumConfigurationName.lastHangulInputMode.rawValue: "org.youknowone.inputmethod.Gureum.han2",
            GureumConfigurationName.lastRomanInputMode.rawValue: "org.youknowone.inputmethod.Gureum.qwerty",

            GureumConfigurationName.inputModeExchangeKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x31, .shift)),
            GureumConfigurationName.inputModeEmoticonKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x24, [.shift, .option])),
            GureumConfigurationName.inputModeHanjaKey.rawValue: GureumConfiguration.convertShortcutToConfiguration((0x24, .option)),
            GureumConfigurationName.optionKeyBehavior.rawValue: 0,

            GureumConfigurationName.romanModeByEscapeKey.rawValue: false,
            GureumConfigurationName.showsInputForHanjaCandidates.rawValue: false,
            GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue: true,
            GureumConfigurationName.hangulAutoReorder.rawValue: false,
            GureumConfigurationName.hangulNonChoseongCombination.rawValue: false,
            GureumConfigurationName.hangulForceStrictCombinationRule.rawValue: false,
        ])

        // 시스템 설정 읽어와서 반영한다. 여기도 observer 설정 가능한지 확인 필요
        let libraryUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let globalPreferences = NSDictionary(contentsOf: URL(fileURLWithPath: "Preferences/.GlobalPreferences.plist", relativeTo: libraryUrl))!
        let state: Int = (globalPreferences["TISRomanSwitchState"] as? NSNumber)?.intValue ?? 1
        self.enableCapslockToToggleInputMode = state > 0
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

    public var lastHangulInputMode: String {
        get {
            return self.string(forKey: GureumConfigurationName.lastHangulInputMode.rawValue)!
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.lastHangulInputMode.rawValue)
        }
    }

    public var lastRomanInputMode: String {
        get {
            return self.string(forKey: GureumConfigurationName.lastRomanInputMode.rawValue)!
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.lastRomanInputMode.rawValue)
        }
    }

    public var optionKeyBehavior: Int {
        get {
            return self.integer(forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
    }

    public var showsInputForHanjaCandidates: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
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

    public var romanModeByEscapeKey: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
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
    
    public var hangulForceStrictCombinationRule: Bool {
        get {
            return self.bool(forKey: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
        set {
            return self.set(newValue, forKey: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
    }
    
    static let shared = GureumConfiguration()
}
