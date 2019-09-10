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

enum GureumInputSourceIdentifier: String {
    case qwerty = "org.youknowone.inputmethod.Gureum.qwerty"
    case dvorak = "org.youknowone.inputmethod.Gureum.dvorak"
    case colemak = "org.youknowone.inputmethod.Gureum.colemak"
    case han2 = "org.youknowone.inputmethod.Gureum.han2"
    case han2Classic = "org.youknowone.inputmethod.Gureum.han2classic"
    case han3Final = "org.youknowone.inputmethod.Gureum.han3final"
    case han390 = "org.youknowone.inputmethod.Gureum.han390"
    case han3NoShift = "org.youknowone.inputmethod.Gureum.han3noshift"
    case han3Classic = "org.youknowone.inputmethod.Gureum.han3classic"
    case han3Layout2 = "org.youknowone.inputmethod.Gureum.han3layout2"
    case hanAhnmatae = "org.youknowone.inputmethod.Gureum.hanahnmatae"
    case hanRoman = "org.youknowone.inputmethod.Gureum.hanroman"
    case han3FinalNoShift = "org.youknowone.inputmethod.Gureum.han3finalnoshift"
    case han3_2011 = "org.youknowone.inputmethod.Gureum.han3-2011"
    case han3_2012 = "org.youknowone.inputmethod.Gureum.han3-2012"

    var keyboardIdentifier: String {
        guard let value = GureumInputSourceToHangulKeyboardIdentifierTable[self] else {
            assert(false)
            return "qwerty"
        }
        return value
    }
}

let GureumInputSourceToHangulKeyboardIdentifierTable: [GureumInputSourceIdentifier: String] = [
    .qwerty: "qwerty",
    .dvorak: "dvorak",
    .colemak: "colemak",
    .han2: "2-full",
    .han2Classic: "2y-full",
    .han3Final: "3f",
    .han390: "39",
    .han3NoShift: "3s",
    .han3Classic: "3y",
    .han3Layout2: "32",
    .hanRoman: "ro",
    .hanAhnmatae: "ahn",
    .han3FinalNoShift: "3gs",
    .han3_2011: "3-2011",
    .han3_2012: "3-2012",
]

/// 구름 입력기의 합성기 오브젝트.
///
/// 입력 모드에 따라 `libhangul`을 이용하여 문자를 합성해 준다.
final class GureumComposer: Composer {
    var romanComposer: RomanComposer
    let qwertyComposer = QwertyComposer()
    let dvorakComposer = RomanDataComposer(keyboardData: RomanDataComposer.dvorakData)
    let colemakComposer = RomanDataComposer(keyboardData: RomanDataComposer.colemakData)
    let hangulComposer = HangulComposer(keyboardIdentifier: GureumInputSourceToHangulKeyboardIdentifierTable[.han2]!)!
    let hanjaComposer = HanjaComposer()
    let emoticonComposer = EmoticonComposer()
    let romanComposersByIdentifier: [String: RomanComposer]

    private var _inputMode: String = ""
    private var _commitStrings: [String] = []

    init() {
        romanComposer = qwertyComposer
        hanjaComposer.delegate = hangulComposer
        romanComposersByIdentifier = [
            "qwerty": qwertyComposer,
            "dvorak": dvorakComposer,
            "colemak": colemakComposer,
        ]

        delegate = qwertyComposer
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var commitString: String {
        return _commitStrings.joined() + delegate.commitString
    }

    func enqueueCommitString(_ string: String) {
        _commitStrings.append(string)
    }

    func dequeueCommitString() -> String {
        let r = commitString
        delegate.dequeueCommitString()
        _commitStrings.removeAll()
        return r
    }

    func clear() {
        hangulComposer.clear()
        romanComposer.clear()
        hanjaComposer.clear()
        emoticonComposer.clear()
    }
}

extension GureumComposer {
    var inputMode: String {
        get {
            return _inputMode
        }
        set {
            guard self.inputMode != newValue else {
                return
            }

            guard let keyboardIdentifier = GureumInputSourceIdentifier(rawValue: newValue)?.keyboardIdentifier else {
                #if DEBUG
                    assert(false)
                #endif
                return
            }

            if romanComposersByIdentifier.keys.contains(keyboardIdentifier) {
                romanComposer = romanComposersByIdentifier[keyboardIdentifier]!
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

        if [.hangul, .roman].contains(layout) {
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            let config = Configuration.shared
            delegate.cancelComposition()
            enqueueCommitString(delegate.dequeueCommitString())
            inputMode = layout == .hangul ? config.lastHangulInputMode : config.lastRomanInputMode
            return InputResult(processed: true, action: .layout(inputMode))
        }

        if layout == .hanja {
            // 한글 입력 상태에서 한자 및 이모티콘 입력기로 전환
            if delegate is HangulComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = isComposing ? .single : .continuous
                delegate = hanjaComposer
                delegate.composerSelected()
                hanjaComposer.update(client: sender as! IMKTextInput)
            } else if delegate is RomanComposer {
                emoticonComposer.delegate = delegate
                delegate = emoticonComposer
                emoticonComposer.update(client: sender as! IMKTextInput)
            } else {
                return .notProcessed
            }
            return .processed
        }

        assert(false)
        return .notProcessed
    }

    func filterCommand(keyCode: KeyCode,
                       modifiers flags: NSEvent.ModifierFlags,
                       client _: Any) -> InputEvent? {
        let configuration = Configuration.shared
        let inputModifier = flags
            .intersection(.deviceIndependentFlagsMask)
            .intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))
//    if (string == nil) {
//        NSUInteger modifierKey = flags & 0xff;
//        if (self->lastModifier != 0 && modifierKey == 0) {
//            dlog(DEBUG_SHORTCUT, @"**** Trigger modifier: %lx ****", self->lastModifier);
//            NSDictionary *correspondedConfigurations = @{
//                                                         @(0x01): @(CIMSharedConfiguration->leftControlKeyShortcutBehavior),
//                                                         @(0x20): @(CIMSharedConfiguration->leftOptionKeyShortcutBehavior),
//                                                         @(0x08): @(CIMSharedConfiguration->leftCommandKeyShortcutBehavior),
//                                                         @(0x10): @(CIMSharedConfiguration->leftCommandKeyShortcutBehavior),
//                                                         @(0x40): @(CIMSharedConfiguration->leftOptionKeyShortcutBehavior),
//                                                         };
//            for (NSNumber *marker in @[@(0x01), @(0x20), @(0x08), @(0x10), @(0x40)]) {
//                if (self->lastModifier == marker.unsignedIntegerValue ) {
//                    NSInteger configuration = [correspondedConfigurations[marker] integerValue];
//                    switch (configuration) {
//                        case 0:
//                            break;
//                        case 1: {
//                            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by exchange modifier ****");
//                            need_exchange = YES;
//                        }   break;
//                        case 2: {
//                            dlog(DEBUG_SHORTCUT, @"**** Hanja mode by hanja modifier ****");
//                            need_hanjamode = YES;
//                        }   break;
//                        case 3: if (self.delegate == self->hangulComposer) {
//                            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to english modifier ****");
//                            need_exchange = YES;
//                        }   break;
//                        case 4: if (self.delegate == self->romanComposer) {
//                            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to korean modifier ****");
//                            need_exchange = YES;
//                        }   break;
//                        default:
//                            dassert(NO);
//                            break;
//                    }
//                }
//            }
//        } else {
//            self->lastModifier = modifierKey;
//            dlog(DEBUG_SHORTCUT, @"**** Save modifier: %lx ****", self->lastModifier);
//        }
//    } else
//    {

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
        if let shortcutKey = configuration.inputModeHanjaKey, shortcutKey == inputKey {
            return .changeLayout(.hanja, true)
        }

        if delegate is HanjaComposer {
            if hanjaComposer.mode == .single, hanjaComposer.composedString.isEmpty, hanjaComposer.commitString.isEmpty {
                // 한자 입력이 완료되었고 한자 모드도 아님
                delegate = hangulComposer
            }
        }

        if delegate is EmoticonComposer {
            if !emoticonComposer.mode {
                emoticonComposer.mode = true
                delegate = romanComposer
            }
        }

        if delegate is HangulComposer {
            // Vi-mode: esc로 로마자 키보드로 전환
            if Configuration.shared.romanModeByEscapeKey {
                if keyCode == .escape || (keyCode, inputModifier) == (.leftBracket, .control) {
                    return .changeLayout(.roman, false)
                }
            }
        }

        return nil
    }
}
