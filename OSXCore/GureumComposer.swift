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
    /// 한글 두벌식 옛글 자판.
    case han2Classic = "org.youknowone.inputmethod.Gureum.han2classic"
    /// 한글 세벌식 최종 자판.
    case han3Final = "org.youknowone.inputmethod.Gureum.han3final"
    /// 한글 세벌식 390 자판.
    case han390 = "org.youknowone.inputmethod.Gureum.han390"
    /// 한글 세벌식 순아래 자판.
    case han3NoShift = "org.youknowone.inputmethod.Gureum.han3noshift"
    /// 한글 세벌식 옛글 자판.
    case han3Classic = "org.youknowone.inputmethod.Gureum.han3classic"
    /// 한글 세벌식 두벌식 배치 자판.
    case han3Layout2 = "org.youknowone.inputmethod.Gureum.han3layout2"
    /// 한글 안마태 자판.
    case hanAhnmatae = "org.youknowone.inputmethod.Gureum.hanahnmatae"
    /// 한글 로마자 자판.
    case hanRoman = "org.youknowone.inputmethod.Gureum.hanroman"
    /// 한글 세벌식 최종 순아래 자판.
    case han3FinalNoShift = "org.youknowone.inputmethod.Gureum.han3finalnoshift"
    /// 한글 세벌식 2011 자판.
    case han3_2011 = "org.youknowone.inputmethod.Gureum.han3-2011"
    /// 한글 세벌식 2012 자판.
    case han3_2012 = "org.youknowone.inputmethod.Gureum.han3-2012"
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
    /// 한자 및 이모지는 해당 합성기를 사용하여 입력이 이루어진다.
    let hangulDependentSearchingComposer = SearchingComposer(dependentComposerType: .hangul)
    /// 로마자 합성기에 의존하여 문자를 검색하고 입력하는 합성기.
    ///
    /// 이모지는 해당 합성기를 사용하여 입력이 이루어진다.
    let romanDependentSearchingComposer = SearchingComposer(dependentComposerType: .roman)
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
        hangulDependentSearchingComposer.delegate = hangulComposer
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var commitString: String {
        return _commitStrings.joined() + delegate.commitString
    }

    func clear() {
        hangulComposer.clear()
        romanComposer.clear()
        hangulDependentSearchingComposer.clear()
        romanDependentSearchingComposer.clear()
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
                hangulDependentSearchingComposer.showsCandidateWindow = !isComposing
                delegate = hangulDependentSearchingComposer
                delegate.composerSelected()
                hangulDependentSearchingComposer.update(client: sender as! IMKTextInput)
            } else if delegate is RomanComposer {
                romanDependentSearchingComposer.delegate = delegate
                delegate = romanDependentSearchingComposer
                romanDependentSearchingComposer.update(client: sender as! IMKTextInput)
            } else {
                return .notProcessed
            }
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

        if let searchingComposer = delegate as? SearchingComposer {
            if searchingComposer.dependentComposerType == .hangul, !searchingComposer.showsCandidateWindow, searchingComposer.composedString.isEmpty, searchingComposer.commitString.isEmpty {
                // 한자 입력이 완료되었고 한자 모드도 아님
                delegate = hangulComposer
            } else if searchingComposer.dependentComposerType == .roman {
                if !searchingComposer.showsCandidateWindow {
                    searchingComposer.showsCandidateWindow = true
                    delegate = romanComposer
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
            return "2-full"
        case .han2Classic:
            return "2y-full"
        case .han3Final:
            return "3f"
        case .han390:
            return "39"
        case .han3NoShift:
            return "3s"
        case .han3Classic:
            return "3y"
        case .han3Layout2:
            return "32"
        case .hanAhnmatae:
            return "ahn"
        case .hanRoman:
            return "ro"
        case .han3FinalNoShift:
            return "3gs"
        case .han3_2011:
            return "3-2011"
        case .han3_2012:
            return "3-2012"
        }
    }
}
