//
//  GureumComposer.swift
//  Gureum
//
//  Created by Hyewon on 2018. 9. 7..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Foundation

// MARK: - GureumInputSource 열거형

/// 구름 입력기에서 사용하는 인풋 소스를 정의한 열거형.
///
/// 각 케이스의 원시 값은 그에 대응하는 input method의 번들 식별자를 나타낸다.
enum GureumInputSource: String {
    /// 로마자 시스템 자판.
    case system = "org.youknowone.inputmethod.Gureum.system"
    /// 로마자 쿼티 자판.
    case qwerty = "org.youknowone.inputmethod.Gureum.qwerty"
    /// 로마자 드보락 자판.
    case dvorak = "org.youknowone.inputmethod.Gureum.dvorak"
    /// 로마자 콜맥 자판.
    case colemak = "org.youknowone.inputmethod.Gureum.colemak"
    /// 한글 두벌식 자판.
    case han2 = "org.youknowone.inputmethod.Gureum.han2"
    case han2noshift = "org.youknowone.inputmethod.Gureum.han2noshift"
    case han2n9256 = "org.youknowone.inputmethod.Gureum.han2n9256"
    case han390 = "org.youknowone.inputmethod.Gureum.han390"
    case han3Final = "org.youknowone.inputmethod.Gureum.han3final"
    case han3_p3 = "org.youknowone.inputmethod.Gureum.han3-p3"
    case han3moa_semoe_2018i = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2018i"
    case han3sun_2014 = "org.youknowone.inputmethod.Gureum.han3sun-2014"
    case han3shin_p2 = "org.youknowone.inputmethod.Gureum.han3shin-p2"
    case han2Classic = "org.youknowone.inputmethod.Gureum.han2classic"
    case han3Layout2 = "org.youknowone.inputmethod.Gureum.han3layout2"
    case hanRoman = "org.youknowone.inputmethod.Gureum.hanroman"
    case hanAhnmatae = "org.youknowone.inputmethod.Gureum.hanahnmatae"
    case han3sun_1990 = "org.youknowone.inputmethod.Gureum.han3sun-1990"
    case han3_89 = "org.youknowone.inputmethod.Gureum.han3-89"
    case han3NoShift = "org.youknowone.inputmethod.Gureum.han3noshift"
    case han3_93_yet = "org.youknowone.inputmethod.Gureum.han3-93-yet"
    case han3_95 = "org.youknowone.inputmethod.Gureum.han3-95"
    case han3ahnmatae = "org.youknowone.inputmethod.Gureum.han3ahnmatae"
    case han3_2011 = "org.youknowone.inputmethod.Gureum.han3-2011"
    case han3_2011_yet = "org.youknowone.inputmethod.Gureum.han3-2011-yet"
    case han3_2012 = "org.youknowone.inputmethod.Gureum.han3-2012"
    case han3_2012_yet = "org.youknowone.inputmethod.Gureum.han3-2012-yet"
    case han3_2014 = "org.youknowone.inputmethod.Gureum.han3-2014"
    case han3_2014_yet = "org.youknowone.inputmethod.Gureum.han3-2014-yet"
    case han3_2015 = "org.youknowone.inputmethod.Gureum.han3-2015"
    case han3_2015_yet = "org.youknowone.inputmethod.Gureum.han3-2015-yet"
    case han3_2015_metal = "org.youknowone.inputmethod.Gureum.han3-2015-metal"
    case han3_2015_patal = "org.youknowone.inputmethod.Gureum.han3-2015-patal"
    case han3_2015_patal_yet = "org.youknowone.inputmethod.Gureum.han3-2015-patal-yet"
    case han3_p2 = "org.youknowone.inputmethod.Gureum.han3-p2"
    case han3_14_proposal = "org.youknowone.inputmethod.Gureum.han3-14-proposal"
    case han3moa_semoe_2014 = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2014"
    case han3moa_semoe_2015 = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2015"
    case han3moa_semoe_2016 = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2016"
    case han3moa_semoe_2017 = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2017"
    case han3gimguk_38a_yet = "org.youknowone.inputmethod.Gureum.han3gimguk-38a-yet"
    case han3shin_1995 = "org.youknowone.inputmethod.Gureum.han3shin-1995"
    case han3shin_2003 = "org.youknowone.inputmethod.Gureum.han3shin-2003"
    case han3shin_2012 = "org.youknowone.inputmethod.Gureum.han3shin-2012"
    case han3shin_2015 = "org.youknowone.inputmethod.Gureum.han3shin-2015"
    case han3shin_m = "org.youknowone.inputmethod.Gureum.han3shin-m"
    case han3shin_p = "org.youknowone.inputmethod.Gureum.han3shin-p"
    case han3shin_p_yet = "org.youknowone.inputmethod.Gureum.han3shin-p-yet"
    case han3shin_p2_yet = "org.youknowone.inputmethod.Gureum.han3shin-p2-yet"
}

// MARK: - GureumComposer 클래스

/// 구름 입력기의 합성기 오브젝트.
///
/// 입력 모드에 따라 `libhangul`을 이용하여 문자를 합성해 준다.
final class GureumComposer: Composer {
    // MARK: 합성기 테이블

    /// 한글 합성기.
    let hangulComposer = HangulComposer(type: .han2)
    /// 한글 합성기에 의존하여 문자를 검색하고 입력하는 합성기.
    ///
    /// 한자 및 이모지  합성기
    let searchComposer = SearchComposer()

    /// 로마자 시스템 합성기.
    let systemRomanComposer = RomanComposer(type: .system)
    /// 로마자 쿼티 합성기.
    let qwertyComposer = RomanComposer(type: .qwerty)
    /// 로마자 드보락 합성기.
    let dvorakComposer = RomanComposer(type: .dvorak)
    /// 로마자 콜맥 합성기.
    let colemakComposer = RomanComposer(type: .colemak)

    private var _inputMode: String = ""
    private var _commitStrings: [String] = []

    /// 실제 사용되는 로마자 합성기.
    var romanComposer: RomanComposer

    init() {
        romanComposer = qwertyComposer
        delegate = romanComposer
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var commitString: String {
        return _commitStrings.joined() + delegate.commitString
    }

    func clear() {
        hangulComposer.clear()
        romanComposer.clear()
        searchComposer.clear()
    }

    func dequeueCommitString() -> String {
        let r = commitString
        delegate.dequeueCommitString()
        _commitStrings.removeAll()
        return r
    }
}

extension GureumComposer {
    var inputMode: String {
        get {
            return _inputMode
        }
        set {
            guard inputMode != newValue else { return }

            guard let keyboardIdentifier = GureumInputSource(rawValue: newValue)?.keyboardIdentifier else {
                #if DEBUG
                    assert(false)
                #endif
                return
            }

            if let romanComposerType = RomanComposer.ComposerType(rawValue: keyboardIdentifier) {
                changeRomanComposer(by: romanComposerType)
                delegate = romanComposer
                Configuration.shared.lastRomanInputMode = newValue
            } else {
                delegate = hangulComposer
                // 단축키 지원을 위해 마지막 자판을 기억
                hangulComposer.setKeyboard(identifier: keyboardIdentifier)
                Configuration.shared.lastHangulInputMode = newValue
            }

            _inputMode = newValue
        }
    }

    func changeLayout(_ layout: ChangeLayout, client sender: Any) -> InputResult {
        var layout = layout
        if layout == .toggle {
            if delegate is RomanComposer {
                layout = .hangul
            } else if delegate is HangulComposer {
                layout = .roman
            } else {
                return .notProcessed
            }
        }

        switch layout {
        case .hangul, .roman:
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            let config = Configuration.shared
            delegate.cancelComposition()
            enqueueCommitString(delegate.dequeueCommitString())
            inputMode = layout == .hangul ? config.lastHangulInputMode : config.lastRomanInputMode
            return InputResult(processed: true, action: .layout(inputMode))
        case .search:
            // 한글 입력 상태에서 한자 및 이모티콘 입력기로 전환
            if delegate is HangulComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = !hangulComposer.composedString.isEmpty
                searchComposer.showsCandidateWindow = !isComposing
                searchComposer.delegate = delegate
            } else if delegate is RomanComposer {
                searchComposer.delegate = delegate
            } else {
                return .notProcessed
            }
            delegate = searchComposer
            delegate.composerSelected()
            searchComposer.update(client: sender as! IMKTextInput)
            return .processed
        default:
            assert(false)
            return .notProcessed
        }
    }

    func filterCommand(keyCode: KeyCode,
                       modifiers flags: NSEvent.ModifierFlags,
                       client _: Any) -> InputEvent? {
        let configuration = Configuration.shared
        let inputModifier = flags
            .intersection(.deviceIndependentFlagsMask)
            .intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))

        // Handle SpecialKeyCode first
        let inputKey = (keyCode, inputModifier)
        if let shortcutKey = configuration.inputModeExchangeKey, shortcutKey == inputKey {
            return .changeLayout(.toggle, true)
        }
        if delegate is HangulComposer, let shortcutKey = configuration.inputModeEnglishKey, shortcutKey == inputKey {
            return .changeLayout(.roman, true)
        }
        if delegate is RomanComposer, let shortcutKey = configuration.inputModeKoreanKey, shortcutKey == inputKey {
            return .changeLayout(.hangul, true)
        }
        if let shortcutKey = configuration.inputModeSearchKey, shortcutKey == inputKey {
            return .changeLayout(.search, true)
        }

        if let searchComposer = delegate as? SearchComposer {
            if searchComposer.delegate is HangulComposer, !searchComposer.showsCandidateWindow, searchComposer.composedString.isEmpty, searchComposer.commitString.isEmpty {
                // 한자 입력이 완료되었고 한자 모드도 아님
                delegate = hangulComposer
                searchComposer.delegate = nil
            } else if searchComposer.delegate is RomanComposer {
                if !searchComposer.showsCandidateWindow {
                    searchComposer.showsCandidateWindow = true
                    delegate = romanComposer
                    searchComposer.delegate = nil
                }
            }
        }

        if delegate is HangulComposer {
            // Vi-mode: esc로 로마자 키보드로 전환
            if Configuration.shared.romanModeByEscapeKey {
                if keyCode == .escape || inputKey == (.ansiLeftBracket, .control) {
                    return .changeLayout(.roman, false)
                }
            }
        }

        return nil
    }

    private func enqueueCommitString(_ string: String) {
        _commitStrings.append(string)
    }

    private func changeRomanComposer(by romanComposerType: RomanComposer.ComposerType) {
        switch romanComposerType {
        case .system:
            romanComposer = systemRomanComposer
        case .qwerty:
            romanComposer = qwertyComposer
        case .dvorak:
            romanComposer = dvorakComposer
        case .colemak:
            romanComposer = colemakComposer
        }
    }
}

// MARK: - GureumInputSource 열거형 확장

extension GureumInputSource {
    /// 키보드 식별자.
    var keyboardIdentifier: String {
        switch self {
        case .system:
            return "system"
        case .qwerty:
            return "qwerty"
        case .dvorak:
            return "dvorak"
        case .colemak:
            return "colemak"
        case .han2:
            return "2"
        case .han2noshift:
            return "2noshift"
        case .han2n9256:
            return "2n9256"
        case .han390:
            return "3-90"
        case .han3Final:
            return "3-91"
        case .han3_p3:
            return "3-p3"
        case .han3moa_semoe_2018i:
            return "3moa-semoe-2018i"
        case .han3sun_2014:
            return "3sun-2014"
        case .han3shin_p2:
            return "3shin-p2"
        case .han2Classic:
            return "2y"
        case .han3Layout2:
            return "32"
        case .hanRoman:
            return "ro"
        case .hanAhnmatae:
            return "ahn"
        case .han3sun_1990:
            return "3sun-1990"
        case .han3_89:
            return "3-89"
        case .han3NoShift:
            return "3-91-noshift"
        case .han3_93_yet:
            return "3-93-yet"
        case .han3_95:
            return "3-95"
        case .han3ahnmatae:
            return "3-ahn"
        case .han3_2011:
            return "3-2011"
        case .han3_2011_yet:
            return "3-2011-yet"
        case .han3_2012:
            return "3-2012"
        case .han3_2012_yet:
            return "3-2012-yet"
        case .han3_2014:
            return "3-2014"
        case .han3_2014_yet:
            return "3-2014-yet"
        case .han3_2015:
            return "3-2015"
        case .han3_2015_yet:
            return "3-2015-yet"
        case .han3_2015_metal:
            return "3-2015-metal"
        case .han3_2015_patal:
            return "3-2015-patal"
        case .han3_2015_patal_yet:
            return "3-2015-patal-yet"
        case .han3_p2:
            return "3-p2"
        case .han3_14_proposal:
            return "3-14-proposal"
        case .han3moa_semoe_2014:
            return "3moa-semoe-2014"
        case .han3moa_semoe_2015:
            return "3moa-semoe-2015"
        case .han3moa_semoe_2016:
            return "3moa-semoe-2016"
        case .han3moa_semoe_2017:
            return "3moa-semoe-2017"
        case .han3gimguk_38a_yet:
            return "3gimguk-38a-yet"
        case .han3shin_1995:
            return "3shin-1995"
        case .han3shin_2003:
            return "3shin-2003"
        case .han3shin_2012:
            return "3shin-2012"
        case .han3shin_2015:
            return "3shin-2015"
        case .han3shin_m:
            return "3shin-m"
        case .han3shin_p:
            return "3shin-p"
        case .han3shin_p_yet:
            return "3shin-p-yet"
        case .han3shin_p2_yet:
            return "3shin-p2-yet"
        }
    }
}
