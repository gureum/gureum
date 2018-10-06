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

@objc public class GureumInputSourceIdentifier: NSObject {
    @objc public static let qwerty = "org.youknowone.inputmethod.Gureum.qwerty"
    @objc static let dvorak = "org.youknowone.inputmethod.Gureum.dvorak"
    @objc static let dvorakQwertyCommand = "org.youknowone.inputmethod.Gureum.dvorakq"
    @objc static let colemak = "org.youknowone.inputmethod.Gureum.colemak"
    @objc static let colemakQwertyCommand = "org.youknowone.inputmethod.Gureum.colemakq"
    @objc static let han2 = "org.youknowone.inputmethod.Gureum.han2"
    @objc static let han2Classic = "org.youknowone.inputmethod.Gureum.han2classic"
    @objc static let han3Final = "org.youknowone.inputmethod.Gureum.han3final"
    @objc static let han3FinalLoose = "org.youknowone.inputmethod.Gureum.han3finalloose"
    @objc static let han390 = "org.youknowone.inputmethod.Gureum.han390"
    @objc static let han390Loose = "org.youknowone.inputmethod.Gureum.han390loose"
    @objc static let han3NoShift = "org.youknowone.inputmethod.Gureum.han3noshift"
    @objc static let han3Classic = "org.youknowone.inputmethod.Gureum.han3classic"
    @objc static let han3Layout2 = "org.youknowone.inputmethod.Gureum.han3layout2"
    @objc static let hanAhnmatae = "org.youknowone.inputmethod.Gureum.han3ahnmatae"
    @objc static let hanRoman = "org.youknowone.inputmethod.Gureum.hanroman"
    @objc static let han3_2011 = "org.youknowone.inputmethod.Gureum.han3-2011"
    @objc static let han3_2011Loose = "org.youknowone.inputmethod.Gureum.han3-2011loose"
    @objc static let han3_2012 = "org.youknowone.inputmethod.Gureum.han3-2012"
    @objc static let han3_2012Loose = "org.youknowone.inputmethod.Gureum.han3-2012loose"
    @objc static let han3FinalNoShiftCompat = "org.youknowone.inputmethod.Gureum.han3finalnoshiftcompat"
    @objc static let han3FinalNoShiftSymbol = "org.youknowone.inputmethod.Gureum.han3finalnoshiftsymbol"
    @objc static let han3_2014 = "org.youknowone.inputmethod.Gureum.han3-2014"
    @objc static let han3_2015 = "org.youknowone.inputmethod.Gureum.han3-2015"
}

let GureumInputSourceToHangulKeyboardIdentifierTable: [String: String] = [
    GureumInputSourceIdentifier.qwerty : "",
    GureumInputSourceIdentifier.han2 : "2",
    GureumInputSourceIdentifier.han2Classic : "2y",
    GureumInputSourceIdentifier.han3Final : "3f",
    GureumInputSourceIdentifier.han390 : "39",
    GureumInputSourceIdentifier.han3NoShift : "3s",
    GureumInputSourceIdentifier.han3Classic : "3y",
    GureumInputSourceIdentifier.han3Layout2 : "32",
    GureumInputSourceIdentifier.hanRoman : "ro",
    GureumInputSourceIdentifier.hanAhnmatae : "ahn",
    GureumInputSourceIdentifier.han3FinalNoShiftCompat: "3gc",
    GureumInputSourceIdentifier.han3FinalNoShiftSymbol : "3gs",
    GureumInputSourceIdentifier.han3_2011 : "3-2011",
    GureumInputSourceIdentifier.han3_2012 : "3-2012",
    GureumInputSourceIdentifier.han3_2014 : "3-2014",
    GureumInputSourceIdentifier.han3_2015 : "3-2015",
]

@objcMembers class GureumComposer: CIMComposer {
    @objc var romanComposer: RomanComposer
    @objc var hangulComposer: HangulComposer
    @objc var hanjaComposer: HanjaComposer
    @objc var emoticonComposer: EmoticonComposer

    override init() {
        romanComposer = RomanComposer()
        hangulComposer = HangulComposer(keyboardIdentifier: "2")!
        hanjaComposer = HanjaComposer()
        hanjaComposer.delegate = hangulComposer
        emoticonComposer = EmoticonComposer()
        super.init()
        self.delegate = romanComposer
    }
    
    @objc override var inputMode: String {
        get {
            return super.inputMode
        }
        set {
            guard self.inputMode != newValue else {
                return
            }

            guard let keyboardIdentifier = GureumInputSourceToHangulKeyboardIdentifierTable[newValue] else {
                return
            }
            
            if keyboardIdentifier.count == 0 {
                self.delegate = romanComposer
            } else {
                self.delegate = hangulComposer
                // 단축키 지원을 위해 마지막 자판을 기억
                hangulComposer.setKeyboardWithIdentifier(keyboardIdentifier)
                GureumConfiguration.shared().lastHangulInputMode = newValue
            }
            super.inputMode = newValue
        }
    }
    
    @objc override func inputController(_ controller: CIMInputController, command string: String, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        let configuration = GureumConfiguration.shared()
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
        if configuration.enableCapslockToToggleInputMode {
            if keyCode == -1 {
                if !flags.intersection(NSEvent.ModifierFlags.capsLock).isEmpty && self.delegate === romanComposer {
                    need_exchange = true
                } else if flags.rawValue == 0 && self.delegate === hangulComposer {
                    need_exchange = true
                } else {
                    return CIMInputTextProcessResult.processed
                }
            }
        }

        if (inputModifier, keyCode) == configuration.inputModeExchangeKey {
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
        if (inputModifier, keyCode) == configuration.inputModeHanjaKey {
            delegatedComposer = hanjaComposer
        }
        if (inputModifier, keyCode) == configuration.inputModeEmojiKey {
            delegatedComposer = emoticonComposer
        }
//    }
        
        if need_exchange {
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            self.delegate.cancelComposition()
            if self.delegate === romanComposer {
                var lastHangulInputMode = GureumConfiguration.shared().lastHangulInputMode
                if lastHangulInputMode == nil {
                    lastHangulInputMode = GureumInputSourceIdentifier.han2
                }
                (sender as AnyObject).selectMode(lastHangulInputMode)
            } else {
                (sender as AnyObject).selectMode(GureumInputSourceIdentifier.qwerty)
            }
            manager.needsFakeComposedString = true
            return CIMInputTextProcessResult.processed
        }
        
        if self.delegate === hanjaComposer {
            if !hanjaComposer.mode && hanjaComposer.composedString.count == 0 && hanjaComposer.commitString.count == 0 {
                // 한자 입력이 완료되었고 한자 모드도 아님
                self.delegate = hangulComposer
            }
        }
        
        if self.delegate === hangulComposer {
            if delegatedComposer === hanjaComposer {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = !isComposing // 조합 중이 아니면 1회만 사전을 띄운다
                self.delegate = hanjaComposer
                self.delegate.composerSelected!(self)
                hanjaComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
            // Vi-mode: esc로 로마자 키보드로 전환
            if GureumConfiguration.shared().romanModeByEscapeKey && (keyCode == kVK_Escape || false) {
                self.delegate.cancelComposition()
                (sender as AnyObject).selectMode(GureumInputSourceIdentifier.qwerty)
                return CIMInputTextProcessResult.notProcessedAndNeedsCommit
            }
        }
        if self.delegate === romanComposer {
            if delegatedComposer === emoticonComposer {
                emoticonComposer.delegate = self.delegate
                self.delegate = emoticonComposer
                emoticonComposer.updateFromController(controller)
                return CIMInputTextProcessResult.processed
            }
        }
        return CIMInputTextProcessResult.notProcessed
    }
}
