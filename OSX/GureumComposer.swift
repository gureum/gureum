//
//  GureumComposer.swift
//  OSX
//
//  Created by Hyewon on 2018. 9. 7..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//
/*!
 @brief  구름 입력기의 합성기
 
 입력 모드에 따라 libhangul을 이용하여 문자를 합성해 준다.
 */

import Foundation

let kGureumInputSourceIdentifierQwerty = "org.youknowone.inputmethod.Gureum.qwerty"
let kGureumInputSourceIdentifierDvorak = "org.youknowone.inputmethod.Gureum.dvorak"
let kGureumInputSourceIdentifierDvorakQwertyCommand = "org.youknowone.inputmethod.Gureum.dvorakq"
let kGureumInputSourceIdentifierColemak = "org.youknowone.inputmethod.Gureum.colemak"
let kGureumInputSourceIdentifierColemakQwertyCommand = "org.youknowone.inputmethod.Gureum.colemakq"
let kGureumInputSourceIdentifierHan2 = "org.youknowone.inputmethod.Gureum.han2"
let kGureumInputSourceIdentifierHan2Classic = "org.youknowone.inputmethod.Gureum.han2classic"
let kGureumInputSourceIdentifierHan3Final = "org.youknowone.inputmethod.Gureum.han3final"
let kGureumInputSourceIdentifierHan3FinalLoose = "org.youknowone.inputmethod.Gureum.han3finalloose"
let kGureumInputSourceIdentifierHan390 = "org.youknowone.inputmethod.Gureum.han390"
let kGureumInputSourceIdentifierHan390Loose = "org.youknowone.inputmethod.Gureum.han390loose"
let kGureumInputSourceIdentifierHan3NoShift = "org.youknowone.inputmethod.Gureum.han3noshift"
let kGureumInputSourceIdentifierHan3Classic = "org.youknowone.inputmethod.Gureum.han3classic"
let kGureumInputSourceIdentifierHan3Layout2 = "org.youknowone.inputmethod.Gureum.han3layout2"
let kGureumInputSourceIdentifierHanAhnmatae = "org.youknowone.inputmethod.Gureum.han3ahnmatae"
let kGureumInputSourceIdentifierHanRoman = "org.youknowone.inputmethod.Gureum.hanroman"
let kGureumInputSourceIdentifierHan3_2011 = "org.youknowone.inputmethod.Gureum.han3-2011"
let kGureumInputSourceIdentifierHan3_2011Loose = "org.youknowone.inputmethod.Gureum.han3-2011loose"
let kGureumInputSourceIdentifierHan3_2012 = "org.youknowone.inputmethod.Gureum.han3-2012"
let kGureumInputSourceIdentifierHan3_2012Loose = "org.youknowone.inputmethod.Gureum.han3-2012loose"
let kGureumInputSourceIdentifierHan3FinalNoShiftCompat = "org.youknowone.inputmethod.Gureum.han3finalnoshiftcompat"
let kGureumInputSourceIdentifierHan3FinalNoShiftSymbol = "org.youknowone.inputmethod.Gureum.han3finalnoshiftsymbol"
let kGureumInputSourceIdentifierHan3_2014 = "org.youknowone.inputmethod.Gureum.han3-2014"
let kGureumInputSourceIdentifierHan3_2015 = "org.youknowone.inputmethod.Gureum.han3-2015"

let GureumInputSourceToHangulKeyboardIdentifierTable: [String: String] = [
    kGureumInputSourceIdentifierQwerty : "",
    kGureumInputSourceIdentifierHan2 : "2",
    kGureumInputSourceIdentifierHan2Classic : "2y",
    kGureumInputSourceIdentifierHan3Final : "3f",
    kGureumInputSourceIdentifierHan390 : "39",
    kGureumInputSourceIdentifierHan3NoShift : "3s",
    kGureumInputSourceIdentifierHan3Classic : "3y",
    kGureumInputSourceIdentifierHan3Layout2 : "32",
    kGureumInputSourceIdentifierHanRoman : "ro",
    kGureumInputSourceIdentifierHanAhnmatae : "ahn",
    kGureumInputSourceIdentifierHan3FinalNoShiftCompat: "3gc",
    kGureumInputSourceIdentifierHan3FinalNoShiftSymbol : "3gs",
    kGureumInputSourceIdentifierHan3_2011 : "3-2011",
    kGureumInputSourceIdentifierHan3_2012 : "3-2012",
    kGureumInputSourceIdentifierHan3_2014 : "3-2014",
    kGureumInputSourceIdentifierHan3_2015 : "3-2015",
]

@objcMembers class GureumComposer: CIMComposer {
    @objc var romanComposer: RomanComposer
    @objc var hangulComposer: HangulComposer
    @objc var hanjaComposer: HanjaComposer

    override init() {
        romanComposer = RomanComposer()
        hangulComposer = HangulComposer(keyboardIdentifier: "2")!
        hanjaComposer = HanjaComposer()
        hanjaComposer.delegate = hangulComposer
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
    
    @objc override func inputController(_ controller: CIMInputController!, command string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        let configuration = GureumConfiguration.shared()
        let inputModifier = flags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask).intersection(NSEvent.ModifierFlags(rawValue: ~NSEvent.ModifierFlags.capsLock.rawValue))
        var need_exchange = false
        var need_hanjamode = false
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
        var lastModifier = 0
        
        if keyCode == -1 {
            if !flags.intersection(NSEvent.ModifierFlags.capsLock).isEmpty && self.delegate === romanComposer {
                need_exchange = true
            } else if flags.rawValue == 0 && self.delegate === hangulComposer {
                need_exchange = true
            } else {
                return CIMInputTextProcessResult.processed
            }
        }
       
        if Int(inputModifier.rawValue) == configuration.inputModeExchangeKeyModifier && keyCode == configuration.inputModeExchangeKeyCode {
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
        
        if Int(inputModifier.rawValue) == configuration.inputModeHanjaKeyModifier && keyCode == configuration.inputModeHanjaKeyCode {
            need_hanjamode = true
        }
//    }
        
        if need_exchange {
            // 한영전환을 위해 현재 입력 중인 문자 합성 취소
            self.delegate.cancelComposition()
            if self.delegate === romanComposer {
                var lastHangulInputMode = GureumConfiguration.shared().lastHangulInputMode
                if lastHangulInputMode == nil {
                    lastHangulInputMode = kGureumInputSourceIdentifierHan2
                }
                (sender as AnyObject).selectMode(lastHangulInputMode)
            } else {
                (sender as AnyObject).selectMode(kGureumInputSourceIdentifierQwerty)
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
            if need_hanjamode {
                // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
                let isComposing = hangulComposer.composedString.count > 0
                hanjaComposer.mode = !isComposing // 조합 중이 아니면 1회만 사전을 띄운다
                self.delegate = hanjaComposer
                self.delegate.composerSelected!(self)
                hanjaComposer.update(fromController: controller)
                return CIMInputTextProcessResult.processed
            }
            // Vi-mode: esc로 로마자 키보드로 전환
            if GureumConfiguration.shared().romanModeByEscapeKey != 0 && (keyCode == kVK_Escape || false) {
                self.delegate.cancelComposition()
                (sender as AnyObject).selectMode(kGureumInputSourceIdentifierQwerty)
                return CIMInputTextProcessResult.notProcessedAndNeedsCommit
            }
        }
        return CIMInputTextProcessResult.notProcessed
    }
}
