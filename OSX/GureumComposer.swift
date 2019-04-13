//
//  GureumComposer.swift
//  Gureum
//
//  Created by Hyewon on 2018. 9. 7..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//
/*!
 @brief  구름 입력기의 합성기
 
 입력 모드에 따라 libhangul을 이용하여 문자를 합성해 준다.
 */

import Foundation

public enum GureumInputSourceIdentifier: String {
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

@objcMembers public class GureumComposer: CIMComposer {
    var romanComposer: CIMComposer
    let qwertyComposer: QwertyComposer = QwertyComposer()
    let dvorakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.dvorakData)
    let colemakComposer: RomanDataComposer = RomanDataComposer(keyboardData: RomanDataComposer.colemakData)
    let hangulComposer: HangulComposer = HangulComposer(keyboardIdentifier: "2")!
    let hanjaComposer: HanjaComposer = HanjaComposer()
    public let emoticonComposer: EmoticonComposer = EmoticonComposer()
    let romanComposersByIdentifier: [String: CIMComposer]
    
    let ioConnect: IOConnect

    override init() {
        romanComposer = qwertyComposer
        hanjaComposer.delegate = hangulComposer
        self.romanComposersByIdentifier = [
            "qwerty": qwertyComposer,
            "dvorak": dvorakComposer,
            "colemak": colemakComposer,
        ]
        
        let service = try! IOService.init(name: kIOHIDSystemClass)
        ioConnect = service.open(owningTask: mach_task_self_, type: kIOHIDParamConnectType)!
        super.init()
        self.delegate = qwertyComposer
    }
    
    @objc override public var inputMode: String {
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
    
    @objc override public func input(controller: CIMInputController, command string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        let configuration = GureumConfiguration.shared
        let inputModifier = flags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask).intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))
        var need_exchange = false
        var delegatedComposer: CIMComposerDelegate? = nil
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
            if self.delegate === romanComposer || self.delegate === hangulComposer {
                need_exchange = true
            }
            self.ioConnect.setCapsLockLed(false)

            if !need_exchange {
                return CIMInputTextProcessResult.processed
            }

        case CIMInputControllerSpecialKeyCode.capsLockFlagsChanged.rawValue:
            guard configuration.enableCapslockToToggleInputMode else {
                return CIMInputTextProcessResult.processed
            }

            self.ioConnect.setCapsLockLed(false)
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
                delegatedComposer = hanjaComposer
            }
    //        if (inputModifier, keyCode) == configuration.inputModeEmoticonKey {
    //            delegatedComposer = emoticonComposer
    //        }
    //    }
        }
        
        if need_exchange {
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            self.delegate.cancelComposition()
            if self.delegate === romanComposer {
                let lastHangulInputMode = GureumConfiguration.shared.lastHangulInputMode
                (sender as AnyObject).selectMode(lastHangulInputMode)
            } else {
                let lastRomanInputMode = GureumConfiguration.shared.lastRomanInputMode
                (sender as AnyObject).selectMode(lastRomanInputMode)
            }
            return CIMInputTextProcessResult.processed
        }
        
        if self.delegate === hanjaComposer {
            if !hanjaComposer.mode && hanjaComposer.composedString.count == 0 && hanjaComposer.commitString.count == 0 {
                // 한자 입력이 완료되었고 한자 모드도 아님
                self.delegate = hangulComposer
            }
        }
        
        if self.delegate === emoticonComposer {
            if !emoticonComposer.mode {
                self.emoticonComposer.mode = true
                self.delegate = romanComposer
            }
        }

        if delegatedComposer === hanjaComposer {
            // 한글 입력 상태에서 한자 및 이모티콘 입력기로 전환
            if self.delegate === hangulComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = !isComposing // 조합 중이 아니면 1회만 사전을 띄운다
                self.delegate = hanjaComposer
                self.delegate.composerSelected!(self)
                hanjaComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
            // 영어 입력 상태에서 이모티콘 입력기로 전환
            if self.delegate === romanComposer {
                emoticonComposer.delegate = self.delegate
                self.delegate = emoticonComposer
                emoticonComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
        }

        if self.delegate === hangulComposer {
            // Vi-mode: esc로 로마자 키보드로 전환
            if GureumConfiguration.shared.romanModeByEscapeKey {
                if keyCode == kVK_Escape || (keyCode, inputModifier) == (kVK_ANSI_LeftBracket, NSEvent.ModifierFlags.control) {
                    self.delegate.cancelComposition()
                    (sender as AnyObject).selectMode(GureumConfiguration.shared.lastRomanInputMode)
                    return CIMInputTextProcessResult.notProcessedAndNeedsCommit
                }
            }
        }
        return CIMInputTextProcessResult.notProcessed
    }
}
