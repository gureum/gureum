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
    /// 마지막 한글 입력 모드.
    static let lastHangulInputMode = "LastHangulInputMode"
    /// 마지막 로마자 입력 모드.
    static let lastRomanInputMode = "LastRomanInputMode"

    /// 입력기 바꾸기 단축키.
    static let inputModeExchangeKey = "InputModeExchangeKey"
    /// 이모티콘 단축키.
    static let inputModeEmoticonKey = "InputModeEmoticonKey"
    /// 한자 단축키.
    static let inputModeHanjaKey = "InputModeHanjaKey"
    /// 로마자로 바꾸기 단축키.
    static let inputModeEnglishKey = "InputModeEnglishKey"
    /// 한글로 바꾸기 단축키.
    static let inputModeKoreanKey = "InputModeKoreanKey"
    /// 옵션 키 동작.
    static let optionKeyBehavior = "OptionKeyBehavior"
    /// 기본 키보드 레이아웃.
    static let overridingKeyboardName = "OverridingKeyboardName"

    /// Esc 키로 로마자 자판으로 전환 (vi 모드).
    static let romanModeByEscapeKey = "ExchangeToRomanModeByEscapeKey"
    /// 한자 선택 후보 창에서 입력 문자 표시.
    static let showsInputForHanjaCandidates = "ShowsInputForHanjaCandidates"
    /// 한글 입력기일 때 역따옴표(`)로 원화 기호(₩) 입력.
    static let hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
    /// 완성되지 않은 낱자 자동 교정 (모아치기).
    static let hangulAutoReorder = "HangulAutoReorder"
    /// 두벌식 초성 조합 중에도 종성 결합 허용 (MS윈도 호환).
    static let hangulNonChoseongCombination = "HangulNonChoseongCombination"
    /// 세벌식 정석 강요.
    static let hangulForceStrictCombinationRule = "HangulForceStrictCombinationRule"
}

// MARK: - Configuration 클래스

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

            ConfigurationName.inputModeEmoticonKey: ":",
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

    /// 마지막 한글 입력 모드.
    var lastHangulInputMode: String {
        get {
            return string(forKey: ConfigurationName.lastHangulInputMode)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastHangulInputMode)
        }
    }

    /// 마지막 로마자 입력 모드.
    var lastRomanInputMode: String {
        get {
            return string(forKey: ConfigurationName.lastRomanInputMode)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.lastRomanInputMode)
        }
    }

    /// 옵션 키 동작.
    var optionKeyBehavior: Int {
        get {
            return integer(forKey: ConfigurationName.optionKeyBehavior)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.optionKeyBehavior)
        }
    }

    /// 기본 키보드 레이아웃.
    var overridingKeyboardName: String {
        get {
            return string(forKey: ConfigurationName.overridingKeyboardName)!
        }
        set {
            `set`(newValue, forKey: ConfigurationName.overridingKeyboardName)
        }
    }

    /// 한자 선택 후보 창에서 입력 문자 표시.
    var showsInputForHanjaCandidates: Bool {
        get {
            return bool(forKey: ConfigurationName.showsInputForHanjaCandidates)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.showsInputForHanjaCandidates)
        }
    }

    /// 입력기 바꾸기 단축키.
    var inputModeExchangeKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeExchangeKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeExchangeKey)
        }
    }

    /// 이모티콘 단축키.
    var inputModeEmoticonKey: String {
        get {
            return ":"
        }
        set {
            `set`(newValue, forKey: ConfigurationName.inputModeEmoticonKey)
        }
    }

    /// 한자 단축키.
    var inputModeHanjaKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeHanjaKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeHanjaKey)
        }
    }

    /// 로마자로 바꾸기 단축키.
    var inputModeEnglishKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeEnglishKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEnglishKey)
        }
    }

    /// 한글로 바꾸기 단축키.
    var inputModeKoreanKey: Shortcut? {
        get {
            return getShortcut(forKey: ConfigurationName.inputModeKoreanKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeKoreanKey)
        }
    }

    /// Esc 키로 로마자 자판으로 전환 (vi 모드).
    var romanModeByEscapeKey: Bool {
        get {
            return bool(forKey: ConfigurationName.romanModeByEscapeKey)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.romanModeByEscapeKey)
        }
    }

    /// 한글 입력기일 때 역따옴표(`)로 원화 기호(₩) 입력.
    var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
    }

    /// 완성되지 않은 낱자 자동 교정 (모아치기).
    var hangulAutoReorder: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulAutoReorder)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulAutoReorder)
        }
    }

    /// 두벌식 초성 조합 중에도 종성 결합 허용 (MS윈도 호환).
    var hangulNonChoseongCombination: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulNonChoseongCombination)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulNonChoseongCombination)
        }
    }

    /// 세벌식 정석 강요.
    var hangulForceStrictCombinationRule: Bool {
        get {
            return bool(forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
        set {
            `set`(newValue, forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
    }
}

private extension Configuration {
    func getShortcut(forKey key: String) -> Shortcut? {
        guard let value = dictionary(forKey: key) else { return nil }
        return Configuration.convertConfigurationToShortcut(value)
    }

    func setShortcut(_ newValue: Shortcut?, forKey key: String) {
        `set`(Configuration.convertShortcutToConfiguration(newValue), forKey: key)
    }
}
