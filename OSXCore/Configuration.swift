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
    /// 한자 및 이모지 검색 단축키.
    static let inputModeSearchKey = "InputModeHanjaKey"
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
    /// 한글 입력기일 때 역따옴표(`)로 원화 기호(₩) 입력.
    static let hangulWonCurrencySymbolForBackQuote = "HangulWonCurrencySymbolForBackQuote"
    /// 완성되지 않은 낱자 자동 교정 (모아치기).
    static let hangulAutoReorder = "HangulAutoReorder"
    /// 두벌식 초성 조합 중에도 종성 결합 허용 (MS윈도 호환).
    static let hangulNonChoseongCombination = "HangulNonChoseongCombination"
    /// 모든 글자를 조합 중인 글자로 취급 (JDK 호환).
    static let hangulDeferredSymbolCommit = "HangulDeferredSymbolCommit"
    /// 세벌식 정석 강요.
    static let hangulForceStrictCombinationRule = "HangulForceStrictCombinationRule"
    /// 우측 키로 언어 전환
    static let rightToggleKey = "RightToggleKey"

    /// 업데이트 알림 받기
    static let updateNotification = "UpdateNotification"
    /// 실험버전 업데이트 알림 받기
    static let updateNotificationExperimental = "UpdateNotificationExperimental"
}

// MARK: - Configuration 클래스

public enum UpdateMode {
    case Stable
    case Experimental
}

/// 입력기의 환경 설정을 담당하는 오브젝트.
public class Configuration: UserDefaults {
    public static let sharedSuiteName = "org.youknowone.Gureum"
    public static var shared = Configuration()

    var enableCapslockToToggleInputMode: Bool = false

    public typealias Shortcut = (KeyCode, NSEvent.ModifierFlags)

    class func convertShortcutToConfiguration(_ shortcut: Shortcut?) -> [String: Any] {
        guard let shortcut = shortcut else {
            return [:]
        }
        return ["modifier": shortcut.1.rawValue, "keyCode": shortcut.0.rawValue]
    }

    class func convertConfigurationToShortcut(_ configuration: [String: Any]) -> Shortcut? {
        guard let modifier = configuration["modifier"] as? UInt,
              let keyCodeRawValue = configuration["keyCode"] as? Int,
              let keyCode = KeyCode(rawValue: keyCodeRawValue)
        else {
            return nil
        }
        return (keyCode, NSEvent.ModifierFlags(rawValue: modifier))
    }

    override init?(suiteName: String?) {
        super.init(suiteName: suiteName)

        register(defaults: [
            ConfigurationName.lastHangulInputMode: "org.youknowone.inputmethod.Gureum.han2",
            ConfigurationName.lastRomanInputMode: "org.youknowone.inputmethod.Gureum.qwerty",

            ConfigurationName.inputModeSearchKey: Configuration.convertShortcutToConfiguration((.return, .option)),
            ConfigurationName.optionKeyBehavior: 1,
            ConfigurationName.overridingKeyboardName: "com.apple.keylayout.ABC",

            ConfigurationName.romanModeByEscapeKey: false,
            ConfigurationName.hangulWonCurrencySymbolForBackQuote: true,
            ConfigurationName.hangulAutoReorder: false,
            ConfigurationName.hangulNonChoseongCombination: false,
            ConfigurationName.hangulDeferredSymbolCommit: false,
            ConfigurationName.hangulForceStrictCombinationRule: false,
            ConfigurationName.rightToggleKey: kHIDUsage_KeyboardRightAlt,

            ConfigurationName.updateNotification: true,
            ConfigurationName.updateNotificationExperimental: false,
        ])
    }

    convenience init() {
        self.init(suiteName: Configuration.sharedSuiteName)!
    }

    public func persistentDomain() -> [String: Any] {
        return persistentDomain(forName: Configuration.sharedSuiteName) ?? [:]
    }

    // TODO: code generation

    /// 마지막 한글 입력 모드.
    public var lastHangulInputMode: String {
        get {
            string(forKey: ConfigurationName.lastHangulInputMode)!
        }
        set {
            set(newValue, forKey: ConfigurationName.lastHangulInputMode)
        }
    }

    /// 마지막 로마자 입력 모드.
    public var lastRomanInputMode: String {
        get {
            string(forKey: ConfigurationName.lastRomanInputMode)!
        }
        set {
            set(newValue, forKey: ConfigurationName.lastRomanInputMode)
        }
    }

    /// 옵션 키 동작.
    public var optionKeyBehavior: Int {
        get {
            integer(forKey: ConfigurationName.optionKeyBehavior)
        }
        set {
            set(newValue, forKey: ConfigurationName.optionKeyBehavior)
        }
    }

    /// 기본 키보드 레이아웃.
    public var overridingKeyboardName: String {
        get {
            string(forKey: ConfigurationName.overridingKeyboardName)!
        }
        set {
            set(newValue, forKey: ConfigurationName.overridingKeyboardName)
        }
    }

    /// 입력기 바꾸기 단축키.
    public var inputModeExchangeKey: Shortcut? {
        get {
            shortcut(forKey: ConfigurationName.inputModeExchangeKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeExchangeKey)
        }
    }

    /// 한자 및 이모지 검색 단축키.
    public var inputModeSearchKey: Shortcut? {
        get {
            shortcut(forKey: ConfigurationName.inputModeSearchKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeSearchKey)
        }
    }

    /// 로마자로 바꾸기 단축키.
    public var inputModeEnglishKey: Shortcut? {
        get {
            shortcut(forKey: ConfigurationName.inputModeEnglishKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeEnglishKey)
        }
    }

    /// 한글로 바꾸기 단축키.
    public var inputModeKoreanKey: Shortcut? {
        get {
            shortcut(forKey: ConfigurationName.inputModeKoreanKey)
        }
        set {
            setShortcut(newValue, forKey: ConfigurationName.inputModeKoreanKey)
        }
    }

    /// Esc 키로 로마자 자판으로 전환 (vi 모드).
    public var romanModeByEscapeKey: Bool {
        get {
            bool(forKey: ConfigurationName.romanModeByEscapeKey)
        }
        set {
            set(newValue, forKey: ConfigurationName.romanModeByEscapeKey)
        }
    }

    /// 한글 입력기일 때 역따옴표(`)로 원화 기호(₩) 입력.
    public var hangulWonCurrencySymbolForBackQuote: Bool {
        get {
            bool(forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
        set {
            set(newValue, forKey: ConfigurationName.hangulWonCurrencySymbolForBackQuote)
        }
    }

    /// 완성되지 않은 낱자 자동 교정 (모아치기).
    public var hangulAutoReorder: Bool {
        get {
            bool(forKey: ConfigurationName.hangulAutoReorder)
        }
        set {
            set(newValue, forKey: ConfigurationName.hangulAutoReorder)
        }
    }

    /// 두벌식 초성 조합 중에도 종성 결합 허용 (MS윈도 호환).
    public var hangulNonChoseongCombination: Bool {
        get {
            bool(forKey: ConfigurationName.hangulNonChoseongCombination)
        }
        set {
            set(newValue, forKey: ConfigurationName.hangulNonChoseongCombination)
        }
    }

    /// 모든 글자를 조합중인 글자로 취급 (JDK 호환).
    public var hangulDeferredSymbolCommit: Bool {
        get {
            bool(forKey: ConfigurationName.hangulDeferredSymbolCommit)
        }
        set {
            set(newValue, forKey: ConfigurationName.hangulDeferredSymbolCommit)
        }
    }

    /// 세벌식 정석 강요.
    public var hangulForceStrictCombinationRule: Bool {
        get {
            bool(forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
        set {
            set(newValue, forKey: ConfigurationName.hangulForceStrictCombinationRule)
        }
    }

    /// 우측 키로 언어 전환
    public var rightToggleKey: Int {
        get {
            integer(forKey: ConfigurationName.rightToggleKey)
        }
        set {
            set(newValue, forKey: ConfigurationName.rightToggleKey)
        }
    }

    /// 업데이트 알림 받기
    public var updateNotification: Bool {
        get {
            bool(forKey: ConfigurationName.updateNotification)
        }
        set {
            set(newValue, forKey: ConfigurationName.updateNotification)
        }
    }

    /// 실험버전 업데이트 알림 받기
    public var updateNotificationExperimental: Bool {
        get {
            if Bundle.main.isExperimental {
                return true
            } else {
                return bool(forKey: ConfigurationName.updateNotificationExperimental)
            }
        }
        set {
            assert(!Bundle.main.isExperimental)
            set(newValue, forKey: ConfigurationName.updateNotificationExperimental)
        }
    }

    public var updateMode: UpdateMode? {
        switch (updateNotification, updateNotificationExperimental) {
        case (false, _):
            return nil
        case (true, false):
            return .Stable
        case (true, true):
            return .Experimental
        }
    }
}

private extension Configuration {
    func shortcut(forKey key: String) -> Shortcut? {
        guard let value = dictionary(forKey: key) else { return nil }
        return Configuration.convertConfigurationToShortcut(value)
    }

    func setShortcut(_ newValue: Shortcut?, forKey key: String) {
        set(Configuration.convertShortcutToConfiguration(newValue), forKey: key)
    }
}
