//
//  GureumComposer.swift
//  Gureum
//
//  Created by Hyewon on 2018. 9. 7..
//  Copyright © 2018 youknowone.org. All rights reserved.
//
/*!
 @brief  구름 입력기의 합성기

 입력 모드에 따라 libhangul을 이용하여 문자를 합성해 준다.
 */

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
    case han3_2014 = "org.youknowone.inputmethod.Gureum.han3-2014"
    case han3_2015 = "org.youknowone.inputmethod.Gureum.han3-2015"

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
    .han3_2014: "3-2014",
    .han3_2015: "3-2015",
]

class GureumComposer: CIMComposer {
    var romanComposer: CIMComposer
    let qwertyComposer: QwertyComposer = QwertyComposer()
    let dvorakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.dvorakData)
    let colemakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.colemakData)
    let hangulComposer: HangulComposer = HangulComposer(keyboardIdentifier: "2")!
    let hanjaComposer: HanjaComposer = HanjaComposer()
    let emoticonComposer: EmoticonComposer = EmoticonComposer()
    let romanComposersByIdentifier: [String: CIMComposer]

    override init() {
        romanComposer = qwertyComposer
        hanjaComposer.delegate = hangulComposer
        romanComposersByIdentifier = [
            "qwerty": qwertyComposer,
            "dvorak": dvorakComposer,
            "colemak": colemakComposer,
        ]

        super.init()
        delegate = qwertyComposer
    }

    override var inputMode: String {
        get {
            return super.inputMode
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
                self.romanComposer = romanComposersByIdentifier[keyboardIdentifier]!
                self.delegate = self.romanComposer
                GureumConfiguration.shared.lastRomanInputMode = newValue
            } else {
                self.delegate = hangulComposer
                // 단축키 지원을 위해 마지막 자판을 기억
                hangulComposer.setKeyboard(identifier: keyboardIdentifier)
                GureumConfiguration.shared.lastHangulInputMode = newValue
            }
            super.inputMode = newValue
        }
    }

    override func input(controller: CIMInputController, command _: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        let configuration = GureumConfiguration.shared
        let inputModifier = flags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask).intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))
        var need_exchange = false
        var need_candidtes = false
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
        switch keyCode {
        case CIMInputControllerSpecialKeyCode.capsLockPressed.rawValue:
            guard configuration.enableCapslockToToggleInputMode else {
                return CIMInputTextProcessResult.processed
            }
            if (delegate as? CIMComposer) === romanComposer || (delegate as? HangulComposer) === hangulComposer {
                need_exchange = true
            }
            if !need_exchange {
                return CIMInputTextProcessResult.processed
            }

        case CIMInputControllerSpecialKeyCode.capsLockFlagsChanged.rawValue:
            guard configuration.enableCapslockToToggleInputMode else {
                return CIMInputTextProcessResult.processed
            }

            return CIMInputTextProcessResult.processed
        default:
            let inputKey = (UInt(keyCode), inputModifier)
            if let shortcutKey = configuration.inputModeExchangeKey, shortcutKey == inputKey {
                need_exchange = true
            }
    //        else if (self.delegate == self->hangulComposer && inputModifier == CIMSharedConfiguration->inputModeEnglishKeyModifier && keyCode == CIMSharedConfiguration->inputModeEnglishKeyCode) {
    //            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to english shortcut ****");
    //            need_exchange = YES;
    //        }
    //        else if (self.delegate == self->romanComposer && inputModifier == CIMSharedConfiguration->inputModeKoreanKeyModifier && keyCode == CIMSharedConfiguration->inputModeKoreanKeyCode) {
    //            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to korean shortcut ****");
    //            need_exchange = YES;
    //        }
            if let shortcutKey = configuration.inputModeHanjaKey, shortcutKey == inputKey {
                need_candidtes = true
            }
        }

        if need_exchange {
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            delegate.cancelComposition()
            if (delegate as? CIMComposer) === romanComposer {
                let lastHangulInputMode = GureumConfiguration.shared.lastHangulInputMode
                if let sender = sender as? IMKTextInput {
                    sender.selectMode(lastHangulInputMode)
                }
            } else {
                let lastRomanInputMode = GureumConfiguration.shared.lastRomanInputMode
                if let sender = sender as? IMKTextInput {
                    sender.selectMode(lastRomanInputMode)
                }
            }
            return CIMInputTextProcessResult.processed
        }

        if (delegate as? HanjaComposer) === hanjaComposer {
            if hanjaComposer.mode == .single, hanjaComposer.composedString.count == 0, hanjaComposer.commitString.count == 0 {
                // 한자 입력이 완료되었고 한자 모드도 아님
                delegate = hangulComposer
            }
        }

        if (delegate as? EmoticonComposer) === emoticonComposer {
            if !emoticonComposer.mode {
                emoticonComposer.mode = true
                delegate = romanComposer
            }
        }

        if need_candidtes {
            // 한글 입력 상태에서 한자 및 이모티콘 입력기로 전환
            if (delegate as? HangulComposer) === hangulComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = isComposing ? .single : .continuous
                delegate = hanjaComposer
                delegate.composerSelected(self)
                hanjaComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
            // 영어 입력 상태에서 이모티콘 입력기로 전환
            if (delegate as? CIMComposer) === romanComposer {
                emoticonComposer.delegate = delegate
                delegate = emoticonComposer
                emoticonComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
        }

        if (delegate as? HangulComposer) === hangulComposer {
            // Vi-mode: esc로 로마자 키보드로 전환
            if GureumConfiguration.shared.romanModeByEscapeKey {
                if keyCode == kVK_Escape || (keyCode, inputModifier) == (kVK_ANSI_LeftBracket, NSEvent.ModifierFlags.control) {
                    delegate.cancelComposition()
                    (sender as AnyObject).selectMode(GureumConfiguration.shared.lastRomanInputMode)
                    return CIMInputTextProcessResult.notProcessedAndNeedsCommit
                }
            }
        }
        return CIMInputTextProcessResult.notProcessed
    }
}
