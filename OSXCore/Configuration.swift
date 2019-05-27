//
//  Configuration.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import AppKit
import Foundation

enum ConfigurationName: String {
    case lastHangulInputMode = "LastHangulInputMode"
    case lastRomanInputMode = "LastRomanInputMode"

    case inputModeExchangeKey = "InputModeExchangeKey"
    case inputModeEmoticonKey = "InputModeEmoticonKey"
    case inputModeHanjaKey = "InputModeHanjaKey"
    case inputModeEnglishKey = "InputModeEnglishKey"
    case inputModeKoreanKey = "InputModeKoreanKey"
    case optionKeyBehavior = "OptionKeyBehavior"
    case overridingKeyboardName = "OverridingKeyboardName"

    case romanModeByEscapeKey = "ExchangeToRomanModeByEscapeKey"
    case showsInputForHanjaCandidates = "ShowsInputForHanjaCandidates"
    case hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
    case hangulAutoReorder = "HangulAutoReorder"
    case hangulNonChoseongCombination = "HangulNonChoseongCombination"
    case hangulForceStrictCombinationRule = "HangulForceStrictCombinationRule"
}

public class Configuration: UserDefaults {
    public static let sharedSuiteName = "org.youknowone.Gureum"
    public static var shared = Configuration()

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

    override init?(suiteName: String?) {
        super.init(suiteName: suiteName)

        register(defaults: [
            ConfigurationName.lastHangulInputMode.rawValue: "org.youknowone.inputmethod.Gureum.han2",
            ConfigurationName.lastRomanInputMode.rawValue: "org.youknowone.inputmethod.Gureum.qwerty",

            ConfigurationName.inputModeEmoticonKey.rawValue: Configuration.convertShortcutToConfiguration((0x24, [.shift, .option])),
            ConfigurationName.inputModeHanjaKey.rawValue: Configuration.convertShortcutToConfiguration((0x24, .option)),
            ConfigurationName.optionKeyBehavior.rawValue: 0,
            ConfigurationName.overridingKeyboardName.rawValue: "com.apple.keylayout.ABC",

            ConfigurationName.romanModeByEscapeKey.rawValue: false,
            ConfigurationName.showsInputForHanjaCandidates.rawValue: false,
            ConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue: true,
            ConfigurationName.hangulAutoReorder.rawValue: false,
            ConfigurationName.hangulNonChoseongCombination.rawValue: false,
            ConfigurationName.hangulForceStrictCombinationRule.rawValue: false,
        ])

        // 시스템 설정 읽어와서 반영한다. 여기도 observer 설정 가능한지 확인 필요
        let libraryUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let globalPreferences = NSDictionary(contentsOf: URL(fileURLWithPath: "Preferences/.GlobalPreferences.plist", relativeTo: libraryUrl))!
        let state: Int = (globalPreferences["TISRomanSwitchState"] as? NSNumber)?.intValue ?? 1
        enableCapslockToToggleInputMode = state > 0
    }

    convenience init() {
        self.init(suiteName: Configuration.sharedSuiteName)!
    }

    func getShortcut(forKey key: String) -> Shortcut? {
        guard let value = self.dictionary(forKey: key) else {
            return nil
        }
        return Configuration.convertConfigurationToShortcut(value)
    }

    func setShortcut(_ newValue: Shortcut?, forKey key: String) {
        `set`(Configuration.convertShortcutToConfiguration(newValue), forKey: key)
    }

    var lastHangulInputMode: String {
        get {
            return string(forKey: ConfigurationName.lastHangulInputMode.rawValue)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastHangulInputMode.rawValue)
        }
    }

    var lastRomanInputMode: String {
        get {
            return string(forKey: ConfigurationName.lastRomanInputMode.rawValue)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastRomanInputMode.rawValue)
        }
    }

    var optionKeyBehavior: Int {
        get {
            return integer(forKey: ConfigurationName.optionKeyBehavior.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.optionKeyBehavior.rawValue)
        }
    }

    var overridingKeyboardName: String {
        get {
            return string(forKey: ConfigurationName.overridingKeyboardName.rawValue)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.overridingKeyboardName.rawValue)
        }
    }

    var showsInputForHanjaCandidates: Bool {
        get {
            return bool(forKey: ConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.showsInputForHanjaCandidates.rawValue)
        }
    }

    var inputModeExchangeKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeExchangeKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeExchangeKey.rawValue)
        }
    }

    var inputModeEmoticonKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeEmoticonKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEmoticonKey.rawValue)
        }
    }

    var inputModeHanjaKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeHanjaKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeHanjaKey.rawValue)
        }
    }

    var inputModeEnglishKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeEnglishKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEnglishKey.rawValue)
        }
    }

    var inputModeKoreanKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeKoreanKey.rawValue)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeKoreanKey.rawValue)
        }
    }

    var romanModeByEscapeKey: Bool {
        get {
            return bool(forKey: ConfigurationName.romanModeByEscapeKey.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.romanModeByEscapeKey.rawValue)
        }
    }

    var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote.rawValue)
        }
    }

    var hangulAutoReorder: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulAutoReorder.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulAutoReorder.rawValue)
        }
    }

    var hangulNonChoseongCombination: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulNonChoseongCombination.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulNonChoseongCombination.rawValue)
        }
    }

    var hangulForceStrictCombinationRule: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulForceStrictCombinationRule.rawValue)
        }
    }
}
