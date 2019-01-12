//
//  GureumConfiguration.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import AppKit
import Foundation

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

class GureumConfiguration: UserDefaults {
    var enableCapslockToToggleInputMode: Bool = true

    typealias Shortcut = (UInt, NSEvent.ModifierFlags)

    class func convertShortcutToConfiguration(_ shortcut: Shortcut?) -> [String: Any] {
        guard let shortcut = shortcut else {
            return [:]
        }
        return ["modifier": shortcut.1.rawValue, "keyCode": shortcut.0]
    }

    class func convertConfigurationToShortcut(_ configuration: [String: Any]) -> Shortcut? {
        guard let modifier = configuration["modifier"] as? UInt, let keyCode = configuration["keyCode"] as? UInt else {
            return nil
        }
        return (keyCode, NSEvent.ModifierFlags(rawValue: modifier))
    }

    init() {
        super.init(suiteName: "org.youknowone.Gureum")!
        register(defaults: [
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
        enableCapslockToToggleInputMode = state > 0
    }

    func getShortcut(forKey key: String) -> Shortcut? {
        guard let value = self.dictionary(forKey: key) else {
            return nil
        }
        return GureumConfiguration.convertConfigurationToShortcut(value)
    }

    func setShortcut(_ newValue: Shortcut?, forKey key: String) {
        `set`(GureumConfiguration.convertShortcutToConfiguration(newValue), forKey: key)
    }

    var lastHangulInputMode: String {
        get {
            return string(forKey: GureumConfigurationName.lastHangulInputMode.rawValue)!
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.lastHangulInputMode.rawValue)
        }
    }

    var lastRomanInputMode: String {
        get {
            return string(forKey: GureumConfigurationName.lastRomanInputMode.rawValue)!
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.lastRomanInputMode.rawValue)
        }
    }

    var optionKeyBehavior: Int {
        get {
            return integer(forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.optionKeyBehavior.rawValue)
        }
    }

    var showsInputForHanjaCandidates: Bool {
        get {
            return bool(forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
    }

    var inputModeExchangeKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeExchangeKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeExchangeKey.rawValue)
        }
    }

    var inputModeEmoticonKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeEmoticonKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeEmoticonKey.rawValue)
        }
    }

    var inputModeHanjaKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeHanjaKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeHanjaKey.rawValue)
        }
    }

    var inputModeEnglishKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeEnglishKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeEnglishKey.rawValue)
        }
    }

    var inputModeKoreanKey: Shortcut? {
        get {
            return getShortcut(forKey: GureumConfigurationName.inputModeKoreanKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: GureumConfigurationName.inputModeKoreanKey.rawValue)
        }
    }

    var romanModeByEscapeKey: Bool {
        get {
            return bool(forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.romanModeByEscapeKey.rawValue)
        }
    }

    var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            return bool(forKey: GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
    }

    var hangulAutoReorder: Bool {
        get {
            return bool(forKey: GureumConfigurationName.hangulAutoReorder.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.hangulAutoReorder.rawValue)
        }
    }

    var hangulNonChoseongCombination: Bool {
        get {
            return bool(forKey: GureumConfigurationName.hangulNonChoseongCombination.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.hangulNonChoseongCombination.rawValue)
        }
    }

    var hangulForceStrictCombinationRule: Bool {
        get {
            return bool(forKey: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
        set {
            `set`(newValue, forKey: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
    }

    static let shared = GureumConfiguration()
}
