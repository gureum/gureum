//
//  Configuration.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 4. 19..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import AppKit
import Foundation

/// 환경 설정 이름을 정의한 열거형.
enum ConfigurationName {
    static let lastHangulInputMode = "LastHangulInputMode"
    static let lastRomanInputMode = "LastRomanInputMode"

    static let inputModeExchangeKey = "InputModeExchangeKey"
    static let inputModeEmoticonKey = "InputModeEmoticonKey"
    static let inputModeHanjaKey = "InputModeHanjaKey"
    static let inputModeEnglishKey = "InputModeEnglishKey"
    static let inputModeKoreanKey = "InputModeKoreanKey"
    static let optionKeyBehavior = "OptionKeyBehavior"
    static let overridingKeyboardName = "OverridingKeyboardName"

    static let romanModeByEscapeKey = "ExchangeToRomanModeByEscapeKey"
    static let showsInputForHanjaCandidates = "ShowsInputForHanjaCandidates"
    static let hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
    static let hangulAutoReorder = "HangulAutoReorder"
    static let hangulNonChoseongCombination = "HangulNonChoseongCombination"
    static let hangulForceStrictCombinationRule = "HangulForceStrictCombinationRule"
}

/// 입력기의 환경 설정을 담당하는 오브젝트.
public class Configuration: UserDefaults {
    public static let sharedSuiteName = "org.youknowone.Gureum"
    public static var shared = Configuration()

    var enableCapslockToToggleInputMode: Bool = false

    typealias Shortcut = (KeyCode, NSEvent.ModifierFlags)

    class func convertShortcutToConfiguration(_ shortcut: Shortcut?) -> [String: Any] {
        guard let shortcut = shortcut else {
            return [:]
        }
        return ["modifier": shortcut.1.rawValue, "keyCode": shortcut.0.rawValue]
    }

    class func convertConfigurationToShortcut(_ configuration: [String: Any]) -> Shortcut? {
        guard let modifier = configuration["modifier"] as? UInt,
            let keyCodeRawValue = configuration["keyCode"] as? Int,
            let keyCode = KeyCode(rawValue: keyCodeRawValue) else {
            return nil
        }
        return (keyCode, NSEvent.ModifierFlags(rawValue: modifier))
    }

    override init?(suiteName: String?) {
        super.init(suiteName: suiteName)

        register(defaults: [
            ConfigurationName.lastHangulInputMode: "org.youknowone.inputmethod.Gureum.han2",
            ConfigurationName.lastRomanInputMode: "org.youknowone.inputmethod.Gureum.qwerty",

            ConfigurationName.inputModeEmoticonKey: Configuration.convertShortcutToConfiguration((.return, [.shift, .option])),
            ConfigurationName.inputModeHanjaKey: Configuration.convertShortcutToConfiguration((.return, .option)),
            ConfigurationName.optionKeyBehavior: 0,
            ConfigurationName.overridingKeyboardName: "com.apple.keylayout.ABC",

            ConfigurationName.romanModeByEscapeKey: false,
            ConfigurationName.showsInputForHanjaCandidates: false,
            ConfigurationName.hangulWonCurrencySymbolForBackQuote: true,
            ConfigurationName.hangulAutoReorder: false,
            ConfigurationName.hangulNonChoseongCombination: false,
            ConfigurationName.hangulForceStrictCombinationRule: false,
        ])
    }

    convenience init() {
        self.init(suiteName: Configuration.sharedSuiteName)!
    }

    public func persistentDomain() -> [String: Any] {
        return persistentDomain(forName: Configuration.sharedSuiteName) ?? [:]
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
            return string(forKey: ConfigurationName.lastHangulInputMode)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastHangulInputMode)
        }
    }

    var lastRomanInputMode: String {
        get {
            return string(forKey: ConfigurationName.lastRomanInputMode)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastRomanInputMode)
        }
    }

    var optionKeyBehavior: Int {
        get {
            return integer(forKey: ConfigurationName.optionKeyBehavior)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.optionKeyBehavior)
        }
    }

    var overridingKeyboardName: String {
        get {
            return string(forKey: ConfigurationName.overridingKeyboardName)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.overridingKeyboardName)
        }
    }

    var showsInputForHanjaCandidates: Bool {
        get {
            return bool(forKey: ConfigurationName.showsInputForHanjaCandidates)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.showsInputForHanjaCandidates)
        }
    }

    var inputModeExchangeKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeExchangeKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeExchangeKey)
        }
    }

    var inputModeEmoticonKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeEmoticonKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEmoticonKey)
        }
    }

    var inputModeHanjaKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeHanjaKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeHanjaKey)
        }
    }

    var inputModeEnglishKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeEnglishKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEnglishKey)
        }
    }

    var inputModeKoreanKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeKoreanKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeKoreanKey)
        }
    }

    var romanModeByEscapeKey: Bool {
        get {
            return bool(forKey: ConfigurationName.romanModeByEscapeKey)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.romanModeByEscapeKey)
        }
    }

    var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
    }

    var hangulAutoReorder: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulAutoReorder)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulAutoReorder)
        }
    }

    var hangulNonChoseongCombination: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulNonChoseongCombination)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulNonChoseongCombination)
        }
    }

    var hangulForceStrictCombinationRule: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
    }
}
