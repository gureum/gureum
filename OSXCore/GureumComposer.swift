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

import Carbon
import Cocoa
import Foundation

enum GureumInputSourceIdentifier: String {
    case qwerty = "org.youknowone.inputmethod.Gureum.qwerty"
    case dvorak = "org.youknowone.inputmethod.Gureum.dvorak"
    case colemak = "org.youknowone.inputmethod.Gureum.colemak"
    case han2 = "org.youknowone.inputmethod.Gureum.han2"
    case han2noshift = "org.youknowone.inputmethod.Gureum.han2noshift"
    case han2n9256 = "org.youknowone.inputmethod.Gureum.han2n9256"
    case han390 = "org.youknowone.inputmethod.Gureum.han390"
    case han3Final = "org.youknowone.inputmethod.Gureum.han3final"
    case han3_p3 = "org.youknowone.inputmethod.Gureum.han3-p3"
    case han3moa_semoe_2018 = "org.youknowone.inputmethod.Gureum.han3moa-semoe-2018"
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
    .han2: "2",
    .han2noshift: "2noshift",
    .han2n9256: "2n9256",
    .han390: "3-90",
    .han3Final: "3-91",
    .han3_p3: "3-p3",
    .han3moa_semoe_2018: "3moa-semoe-2018",
    .han3sun_2014: "3sun-2014",
    .han3shin_p2: "3shin-p2",
    .han2Classic: "2y",
    .han3Layout2: "32",
    .hanRoman: "ro",
    .hanAhnmatae: "ahn",
    .han3sun_1990: "3sun-1990",
    .han3_89: "3-89",
    .han3NoShift: "3-91-noshift",
    .han3_93_yet: "3-93-yet",
    .han3_95: "3-95",
    .han3ahnmatae: "3-ahn",
    .han3_2011: "3-2011",
    .han3_2011_yet: "3-2011-yet",
    .han3_2012: "3-2012",
    .han3_2012_yet: "3-2012-yet",
    .han3_2014: "3-2014",
    .han3_2014_yet: "3-2014-yet",
    .han3_2015: "3-2015",
    .han3_2015_yet: "3-2015-yet",
    .han3_2015_metal: "3-2015-metal",
    .han3_2015_patal: "3-2015-patal",
    .han3_2015_patal_yet: "3-2015-patal-yet",
    .han3_p2: "3-p2",
    .han3_14_proposal: "3-14-proposal",
    .han3moa_semoe_2014: "3moa-semoe-2014",
    .han3moa_semoe_2015: "3moa-semoe-2015",
    .han3moa_semoe_2016: "3moa-semoe-2016",
    .han3moa_semoe_2017: "3moa-semoe-2017",
    .han3gimguk_38a_yet: "3gimguk-38a-yet",
    .han3shin_1995: "3shin-1995",
    .han3shin_2003: "3shin-2003",
    .han3shin_2012: "3shin-2012",
    .han3shin_2015: "3shin-2015",
    .han3shin_m: "3shin-m",
    .han3shin_p: "3shin-p",
    .han3shin_p_yet: "3shin-p-yet",
    .han3shin_p2_yet: "3shin-p2-yet",
]

class GureumComposer: DelegatedComposer {
    var romanComposer: DelegatedComposer
    let qwertyComposer: QwertyComposer = QwertyComposer()
    let dvorakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.dvorakData)
    let colemakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.colemakData)
    let hangulComposer: HangulComposer = HangulComposer(keyboardIdentifier: "2")!
    let hanjaComposer: HanjaComposer = HanjaComposer()
    let emoticonComposer: EmoticonComposer = EmoticonComposer()
    let romanComposersByIdentifier: [String: DelegatedComposer]

    var _inputMode: String = ""
    var _commitStrings: [String] = []
    override var commitString: String {
        return _commitStrings.joined() + delegate.commitString
    }

    func enqueueCommitString(_ string: String) {
        _commitStrings.append(string)
    }

    override func dequeueCommitString() -> String {
        let r = commitString
        delegate.dequeueCommitString()
        _commitStrings.removeAll()
        return r
    }

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

    override func clear() {
        hangulComposer.clear()
        romanComposer.clear()
        hanjaComposer.clear()
        emoticonComposer.clear()
    }

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
            if (delegate as AnyObject) === romanComposer {
                layout = .hangul
            } else if (delegate as AnyObject) === hangulComposer {
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
            if (delegate as? HangulComposer) === hangulComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = isComposing ? .single : .continuous
                delegate = hanjaComposer
                delegate.composerSelected()
                hanjaComposer.update(client: sender as! IMKTextInput)
            } else if (delegate as? DelegatedComposer) === romanComposer {
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

    func filterCommand(key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client _: Any) -> InputEvent? {
        let configuration = Configuration.shared
        let inputModifier = flags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask).intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))
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
        let inputKey = (UInt(keyCode), inputModifier)
        if let shortcutKey = configuration.inputModeExchangeKey, shortcutKey == inputKey {
            return .changeLayout(.toggle)
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
            return .changeLayout(.hanja)
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

        if (delegate as? HangulComposer) === hangulComposer {
            // Vi-mode: esc로 로마자 키보드로 전환
            if Configuration.shared.romanModeByEscapeKey {
                if keyCode == kVK_Escape || (keyCode, inputModifier) == (kVK_ANSI_LeftBracket, NSEvent.ModifierFlags.control) {
                    return .changeLayout(.roman)
                }
            }
        }

        return nil
    }
}
