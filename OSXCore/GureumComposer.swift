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
        romanComposer = systemRomanComposer
        inputMode = Configuration.shared.lastRomanInputMode
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

    func input(text string: String?, key keyCode: KeyCode, modifiers flags: NSEvent.ModifierFlags, client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        if flags.contains(.option) {
            if delegate is HangulComposer {
                // 옵션 키 변환 처리
                let configuration = Configuration.shared
                dlog(DEBUG_INPUT_RECEIVER, "option key: %ld", configuration.optionKeyBehavior)
                switch configuration.optionKeyBehavior {
                case 0:
                    // default
                    dlog(DEBUG_INPUT_RECEIVER, " ** ESCAPE from option-key default behavior")
                    return InputResult(processed: false, action: .commit)
                case 1:
                    // roman
                    let character = romanComposer.map(text: string, key: keyCode, modifiers: flags)
                    dlog(DEBUG_INPUT_RECEIVER, " ** ESCAPE from option-key roman mapping `\(string ?? " ")` -> `\(character ?? " ")` by \(keyCode) \(flags) \(String(describing: romanComposer))")
                    guard let character = character else {
                        return InputResult(processed: false, action: .commit)
                    }

                    cancelAndCommit()
                    enqueueCommitString("\(character)")
                    return InputResult(processed: true, action: .commit)
                default:
                    assertionFailure()
                }
            } else {
                return .notProcessed
            }
        }
        return delegate.input(text: string, key: keyCode, modifiers: flags, client: sender)
    }
}

extension GureumComposer {
    var inputMode: String {
        get {
            return _inputMode
        }
        set {
            guard inputMode != newValue else { return }

            if let romanComposerType = RomanComposer.ComposerType(inputMode: newValue) {
                romanComposer = romanComposer(by: romanComposerType)
                delegate = romanComposer
                Configuration.shared.lastRomanInputMode = newValue
            } else {
                guard let keyboardIdentifier = GureumInputSource(rawValue: newValue)?.keyboardIdentifier else {
                    #if DEBUG
                        assertionFailure()
                    #endif
                    return
                }
                delegate = hangulComposer
                // 단축키 지원을 위해 마지막 자판을 기억
                hangulComposer.setKeyboard(identifier: keyboardIdentifier)
                Configuration.shared.lastHangulInputMode = newValue
            }

            _inputMode = newValue
        }
    }

    func cancelAndCommit() {
        delegate.cancelComposition()
        enqueueCommitString(delegate.dequeueCommitString())
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

        if delegate is SearchComposer {
            searchComposer.cancelSearch()
        }
        switch layout {
        case .hangul, .roman:
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            let config = Configuration.shared
            cancelAndCommit()
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
            assertionFailure()
            return .notProcessed
        }
    }

    func filterCommand(keyCode: KeyCode,
                       modifiers flags: NSEvent.ModifierFlags,
                       client _: Any) -> InputEvent?
    {
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
            // 이미 연속 입력모드라면 한자 단축키로 탈출
            if let searchComposer = delegate as? SearchComposer {
                searchComposer.exitComposer()
                if searchComposer.delegate is HangulComposer {
                    return .changeLayout(.hangul, true)
                } else if searchComposer.delegate is RomanComposer {
                    return .changeLayout(.roman, true)
                }
            }
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

    func romanComposer(by romanComposerType: RomanComposer.ComposerType) -> RomanComposer {
        switch romanComposerType {
        case .system:
            return systemRomanComposer
        case .qwerty:
            return qwertyComposer
        case .dvorak:
            return dvorakComposer
        case .colemak:
            return colemakComposer
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
