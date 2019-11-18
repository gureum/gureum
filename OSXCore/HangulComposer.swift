//
//  HangulComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 8. 13..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Foundation
import Hangul

let DEBUG_HANGULCOMPOSER = false

private let table: [HGUCSChar: HGUCSChar] = [
    // {'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'}
    0x1161: 0x314F, 0x1162: 0x3150, 0x1163: 0x3151, 0x1164: 0x3152, 0x1165: 0x3153, 0x1166: 0x3154, 0x1167: 0x3155, 0x1168: 0x3156, 0x1169: 0x3157, 0x116A: 0x3158, 0x116B: 0x3159, 0x116C: 0x315A, 0x116D: 0x315B, 0x116E: 0x315C, 0x116F: 0x315D, 0x1170: 0x315E, 0x1171: 0x315F, 0x1172: 0x3160, 0x1173: 0x3161, 0x1174: 0x3162, 0x1175: 0x3163,
    // {JONGSUNG ' ', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'}
    0x0000: 0x0000, 0x11A8: 0x3131, 0x11A9: 0x3132, 0x11AA: 0x3133, 0x11AB: 0x3134, 0x11AC: 0x3135, 0x11AD: 0x3136, 0x11AE: 0x3137, 0x11AF: 0x3139, 0x11B0: 0x313A, 0x11B1: 0x313B, 0x11B2: 0x313C, 0x11B3: 0x313D, 0x11B4: 0x313E, 0x11B5: 0x313F, 0x11B6: 0x3140, 0x11B7: 0x3141, 0x11B8: 0x3142, 0x11B9: 0x3144, 0x11BA: 0x3145, 0x11BB: 0x3146, 0x11BC: 0x3147, 0x11BD: 0x3148, 0x11BE: 0x314A, 0x11BF: 0x314B, 0x11C0: 0x314C, 0x11C1: 0x314D, 0x11C2: 0x314E,
]

/// 한글호환 자모 유니코드로 바꿔주는 함수.
func convertUnicode(_ ucsString: UnsafePointer<HGUCSChar>) -> UnsafeMutablePointer<HGUCSChar> {
    var index: Int = 0
    let newUcsString = UnsafeMutablePointer<HGUCSChar>.allocate(capacity: 4)
    while ucsString[index] != UInt32(0) {
        if let chr = table[ucsString[index]] {
            newUcsString[index] = chr
        } else {
            newUcsString[index] = ucsString[index]
        }
        index += 1
    }
    newUcsString[index] = UInt32(0)
    return newUcsString
}

func representableString(ucsString: UnsafePointer<HGUCSChar>) -> String {
    // 채움문자로 조합 중 판별
    if !HGCharacterIsChoseong(ucsString[0]) {
        return NSString(ucsString: convertUnicode(ucsString)) as String
    }
    if ucsString[0] == 0x115F {
        return NSString(ucsString: convertUnicode(ucsString) + 1) as String
    }
    if ucsString[1] == 0x1160 {
        let fill: NSMutableString = NSMutableString(ucsString: ucsString, length: 1)
        fill.append(NSString(ucsString: ucsString + 2, length: 1) as String)
        return fill as String
    }
    // 옛한글은 그대로
    return NSString(ucsString: ucsString) as String
}

// MARK: - HangulComposer 클래스

/// `libhangul`을 사용하는 한글 합성기.
///
/// `libhangul`의 input context를 사용하는 합성기다.
///
/// `HGInputContext` 클래스를 참고한다.
final class HangulComposer: NSObject, Composer {
    /// 한글 합성기의 종류를 정의한 열거형.
    ///
    /// 각 케이스의 원시 값은 그에 대응하는 키보드 식별자를 나타낸다.
    enum ComposerType: String {
        /// 두벌식 자판.
        case han2 = "2-full"
        /// 두벌식 옛글 자판.
        case han2Classic = "2y-full"
        /// 세벌식 최종 자판.
        case han3Final = "3f"
        /// 세벌식 390 자판.
        case han390 = "39"
        /// 세벌식 순아래 자판.
        case han3NoShift = "3s"
        /// 세벌식 옛글 자판.
        case han3Classic = "3y"
        /// 세벌식 두벌식 배치 자판.
        case han3Layout2 = "32"
        /// 세벌식 로마자 자판.
        case hanRoman = "ro"
        /// 안마태 자판.
        case hanAhnmatae = "ahn"
        /// 세벌식 최종 순아래 자판.
        case han3FinalNoShift = "3gs"
        /// 세벌식 2011 자판.
        case han3_2011 = "3-2011"
        /// 세벌식 2012 자판.
        case han3_2012 = "3-2012"
    }

    /// 합성을 완료한 문자열.
    private var _commitString: String

    let inputContext: HGInputContext
    let configuration = Configuration.shared

    init(type: HangulComposer.ComposerType) {
        _commitString = ""
        let keyboardIdentifier = type.rawValue
        let inputContext = HGInputContext(keyboardIdentifier: keyboardIdentifier)!
        self.inputContext = inputContext
        self.inputContext.setOption(HANGUL_IC_OPTION_AUTO_REORDER, value: configuration.hangulAutoReorder)
        self.inputContext.setOption(HANGUL_IC_OPTION_NON_CHOSEONG_COMBI, value: configuration.hangulNonChoseongCombination)
        super.init()
        configuration.addObserver(self, forKeyPath: ConfigurationName.hangulAutoReorder, options: .new, context: nil)
        configuration.addObserver(self, forKeyPath: ConfigurationName.hangulNonChoseongCombination, options: .new, context: nil)
        configuration.addObserver(self, forKeyPath: ConfigurationName.hangulForceStrictCombinationRule, options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == ConfigurationName.hangulForceStrictCombinationRule {
            let lastHangulInputMode = configuration.lastHangulInputMode
            let inputSource = GureumInputSource(rawValue: lastHangulInputMode) ?? .han2
            let keyboard = inputSource.keyboardIdentifier
            setKeyboard(identifier: keyboard)
        } else {
            inputContext.setOption(HANGUL_IC_OPTION_AUTO_REORDER, value: configuration.hangulAutoReorder)
            inputContext.setOption(HANGUL_IC_OPTION_NON_CHOSEONG_COMBI, value: configuration.hangulNonChoseongCombination)
        }
    }

    deinit {
        configuration.removeObserver(self, forKeyPath: ConfigurationName.hangulAutoReorder)
        configuration.removeObserver(self, forKeyPath: ConfigurationName.hangulNonChoseongCombination)
        configuration.removeObserver(self, forKeyPath: ConfigurationName.hangulForceStrictCombinationRule)
    }

    // MARK: Composer 프로토콜 구현

    var composedString: String {
        let preedit = inputContext.preeditUCSString
        return representableString(ucsString: preedit)
    }

    var originalString: String {
        let preedit = inputContext.preeditUCSString
        return representableString(ucsString: preedit)
    }

    var commitString: String {
        return _commitString
    }

    var candidates: [NSAttributedString]? {
        return nil
    }

    var hasCandidates: Bool {
        return false
    }

    func clear() {
        clearCompositionContext()
    }

    @discardableResult
    func dequeueCommitString() -> String {
        let queuedCommitString = _commitString
        _commitString = ""
        return queuedCommitString
    }

    func cancelComposition() {
        let flushedString: String! = representableString(ucsString: inputContext.flushUCSString())
        _commitString.append(flushedString)
    }

    func clearCompositionContext() {
        inputContext.reset()
        _commitString = ""
    }

    func composerSelected() {
        clear()
    }

    func candidateSelected(_: NSAttributedString) {
        dassert(false)
    }

    func candidateSelectionChanged(_: NSAttributedString) {
        dassert(false)
    }

    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client _: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        // libhangul은 backspace를 키로 받지 않고 별도로 처리한다.
        if keyCode == .delete {
            return inputContext.backspace() ? .processed : .notProcessed
        }

        if !keyCode.isKeyMappable || [.delete, .return, .tab, .space].contains(keyCode) {
            dlog(DEBUG_HANGULCOMPOSER, " ** ESCAPE from outbound keyCode: %lu", keyCode.rawValue)
            return InputResult(processed: false, action: .commit)
        }

        var string = string!
        // 한글 입력에서 캡스락 무시
        if flags.contains(.shift) {
            string = KeyMapUpper[keyCode.rawValue] ?? string
        } else {
            string = KeyMapLower[keyCode.rawValue] ?? string
        }
        let handled = inputContext.process(string.unicodeScalars.first!.value)
        let ucsString = inputContext.commitUCSString
        let recentCommitString = representableString(ucsString: ucsString)
        if configuration.hangulWonCurrencySymbolForBackQuote, keyCode == .ansiGrave, flags.isSubset(of: .capsLock) {
            if !handled {
                _commitString.append(recentCommitString + "₩")
                return .processed
            } else if recentCommitString.last! == "`" {
                _commitString.append(recentCommitString.dropLast() + "₩")
                return .processed
            }
        }

        _commitString.append(recentCommitString)
        // dlog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->_commitString, recentCommitString)
        return handled ? .processed : InputResult(processed: false, action: .cancel)
    }
}

extension HangulComposer {
    /// 현재 context의 배열을 바꾼다.
    ///
    /// - Parameter identifier: `libhangul`의 `hangul_ic_select_keyboard`를 참고한다.
    func setKeyboard(identifier: String) {
        if configuration.hangulForceStrictCombinationRule, identifier == "39" || identifier == "3f" {
            let strictCombinationIdentifier = "\(identifier)s"
            inputContext.setKeyboardWithIdentifier(strictCombinationIdentifier)
        } else {
            inputContext.setKeyboardWithIdentifier(identifier)
        }
    }

    private func input(controller _: InputController, command _: String?, key _: Int, modifiers _: NSEvent.ModifierFlags, client _: Any) -> InputResult {
        assert(false)
        return .notProcessed
    }
}
