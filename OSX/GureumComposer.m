//
//  GureumComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 16..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumComposer.h"

#import "CIMConfiguration.h"
#import "GureumAppDelegate.h"

#define DEBUG_GUREUM FALSE
#define DEBUG_SHORTCUT FALSE

NSString *kGureumInputSourceIdentifierQwerty = @"org.youknowone.inputmethod.Gureum.qwerty";
NSString *kGureumInputSourceIdentifierDvorak = @"org.youknowone.inputmethod.Gureum.dvorak";
NSString *kGureumInputSourceIdentifierDvorakQwertyCommand = @"org.youknowone.inputmethod.Gureum.dvorakq";
NSString *kGureumInputSourceIdentifierColemak = @"org.youknowone.inputmethod.Gureum.colemak";
NSString *kGureumInputSourceIdentifierColemakQwertyCommand = @"org.youknowone.inputmethod.Gureum.colemakq";
NSString *kGureumInputSourceIdentifierHan2 = @"org.youknowone.inputmethod.Gureum.han2";
NSString *kGureumInputSourceIdentifierHan2Classic = @"org.youknowone.inputmethod.Gureum.han2classic";
NSString *kGureumInputSourceIdentifierHan3Final = @"org.youknowone.inputmethod.Gureum.han3final";
NSString *kGureumInputSourceIdentifierHan3FinalLoose = @"org.youknowone.inputmethod.Gureum.han3finalloose";
NSString *kGureumInputSourceIdentifierHan390 = @"org.youknowone.inputmethod.Gureum.han390";
NSString *kGureumInputSourceIdentifierHan390Loose = @"org.youknowone.inputmethod.Gureum.han390loose";
NSString *kGureumInputSourceIdentifierHan3NoShift = @"org.youknowone.inputmethod.Gureum.han3noshift";
NSString *kGureumInputSourceIdentifierHan3Classic = @"org.youknowone.inputmethod.Gureum.han3classic";
NSString *kGureumInputSourceIdentifierHan3Layout2 = @"org.youknowone.inputmethod.Gureum.han3layout2";
NSString *kGureumInputSourceIdentifierHanAhnmatae = @"org.youknowone.inputmethod.Gureum.han3ahnmatae";
NSString *kGureumInputSourceIdentifierHanRoman = @"org.youknowone.inputmethod.Gureum.hanroman";
NSString *kGureumInputSourceIdentifierHan3_2011 = @"org.youknowone.inputmethod.Gureum.han3-2011";
NSString *kGureumInputSourceIdentifierHan3_2011Loose = @"org.youknowone.inputmethod.Gureum.han3-2011loose";
NSString *kGureumInputSourceIdentifierHan3_2012 = @"org.youknowone.inputmethod.Gureum.han3-2012";
NSString *kGureumInputSourceIdentifierHan3_2012Loose = @"org.youknowone.inputmethod.Gureum.han3-2012loose";
NSString *kGureumInputSourceIdentifierHan3FinalNoShift = @"org.youknowone.inputmethod.Gureum.han3finalnoshift";
NSString *kGureumInputSourceIdentifierHan3_2014 = @"org.youknowone.inputmethod.Gureum.han3-2014";

#import "RomanComposer.h"
#import "HangulComposer.h"

@implementation GureumComposer

- (id)init
{
    self = [super init];
    if (self) {
        self->romanComposer = [[RomanComposer alloc] init];
        self->hangulComposer = [[HangulComposer alloc] init];
        self->hanjaComposer = [[HanjaComposer alloc] init];
        self->hanjaComposer.delegate = self->hangulComposer;
        self.delegate = self->romanComposer;
    }
    return self;
}

- (void)dealloc
{
    self.inputMode = nil;
    [self->romanComposer release];
    [self->hangulComposer release];
    [self->hanjaComposer release];
    [super dealloc];
}

NSDictionary *GureumInputSourceToHangulKeyboardIdentifierTable = nil;
+ (void)initialize {
    GureumInputSourceToHangulKeyboardIdentifierTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                        @"", kGureumInputSourceIdentifierQwerty,
                                                        @"2", kGureumInputSourceIdentifierHan2,
                                                        @"2y", kGureumInputSourceIdentifierHan2Classic,
                                                        @"3f", kGureumInputSourceIdentifierHan3Final,
                                                        @"3fl", kGureumInputSourceIdentifierHan3FinalLoose,
                                                        @"39", kGureumInputSourceIdentifierHan390,
                                                        @"39l", kGureumInputSourceIdentifierHan390Loose,
                                                        @"3s", kGureumInputSourceIdentifierHan3NoShift,
                                                        @"3y", kGureumInputSourceIdentifierHan3Classic,
                                                        @"32", kGureumInputSourceIdentifierHan3Layout2,
                                                        @"ro", kGureumInputSourceIdentifierHanRoman,
                                                        @"ahn", kGureumInputSourceIdentifierHanAhnmatae,
                                                        @"3-2011", kGureumInputSourceIdentifierHan3_2011,
                                                        @"3-2011l", kGureumInputSourceIdentifierHan3_2011Loose,
                                                        @"3-2012", kGureumInputSourceIdentifierHan3_2012,
                                                        @"3-2012l", kGureumInputSourceIdentifierHan3_2012Loose,
                                                        @"3fs", kGureumInputSourceIdentifierHan3FinalNoShift,
                                                        @"3-2014", kGureumInputSourceIdentifierHan3_2014,
                                                        nil];
}

- (void)setInputMode:(NSString *)newInputMode {
    dlog(DEBUG_GUREUM, @"** GureumComposer -setLayoutIdentifier: from input mode %@ to %@", self.inputMode, newInputMode);
    if (self.inputMode == newInputMode || [self.inputMode isEqualToString:newInputMode]) return;

    NSString *keyboardIdentifier = GureumInputSourceToHangulKeyboardIdentifierTable[newInputMode];
    if (keyboardIdentifier.length == 0) {
        self.delegate = self->romanComposer;
    } else {
        self.delegate = self->hangulComposer;
        // 단축키 지원을 위해 마지막 자판을 기억
        [self->hangulComposer setKeyboardWithIdentifier:keyboardIdentifier];
        CIMConfigurationSetObjectForField(CIMSharedConfiguration, newInputMode, lastHangulInputMode);
        [CIMSharedConfiguration saveConfigurationForStringField:&CIMSharedConfiguration->lastHangulInputMode];
    }

    [super setInputMode:newInputMode];
}

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller commandString:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    NSInteger inputModifier = flags & NSDeviceIndependentModifierFlagsMask & ~NSAlphaShiftKeyMask;
    BOOL need_exchange = NO;
    BOOL need_hanjamode = NO;
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
    {
        dlog(DEBUG_SHORTCUT, @"**** Reset modifier ****");
        self->lastModifier = 0;

        if (inputModifier == CIMSharedConfiguration->inputModeExchangeKeyModifier && keyCode == CIMSharedConfiguration->inputModeExchangeKeyCode) {
            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by exchange shortcut ****");
            need_exchange = YES;
        }
        else if (self.delegate == self->hangulComposer && inputModifier == CIMSharedConfiguration->inputModeEnglishKeyModifier && keyCode == CIMSharedConfiguration->inputModeEnglishKeyCode) {
            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to english shortcut ****");
            need_exchange = YES;
        }
        else if (self.delegate == self->romanComposer && inputModifier == CIMSharedConfiguration->inputModeKoreanKeyModifier && keyCode == CIMSharedConfiguration->inputModeKoreanKeyCode) {
            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by change to korean shortcut ****");
            need_exchange = YES;
        }

        if (inputModifier == CIMSharedConfiguration->inputModeHanjaKeyModifier && keyCode == CIMSharedConfiguration->inputModeHanjaKeyCode) {
            dlog(DEBUG_SHORTCUT, @"**** Layout exchange by hanja shortcut ****");
            need_hanjamode = YES;
        }
    }

    if (need_exchange) {
        dlog(DEBUG_GUREUM, @"***** Try to change layout *****");
        // 한영전환을 위해 현재 입력 중인 문자 합성 취소
        [self.delegate cancelComposition];
        if (self.delegate == self->romanComposer) {
            NSString *lastHangulInputMode = CIMSharedConfiguration->lastHangulInputMode;
            if (lastHangulInputMode == nil) lastHangulInputMode = kGureumInputSourceIdentifierHan2;
            [sender selectInputMode:lastHangulInputMode];
        } else {
            [sender selectInputMode:kGureumInputSourceIdentifierQwerty];
        }
        dassert(manager);
        manager.needsFakeComposedString = YES;
        return CIMInputTextProcessResultProcessed;
    }

    if (self.delegate == self->hanjaComposer) {
        if (!self->hanjaComposer.mode && self->hanjaComposer.composedString.length == 0 && self->hanjaComposer.commitString.length == 0) {
            // 한자 입력이 완료되었고 한자 모드도 아님
            self.delegate = self->hangulComposer;
        }
    }

    if (self.delegate == self->hangulComposer) {
        if (need_hanjamode) {
            // 현재 조합 중 여부에 따라 한자 모드 여부를 결정
            BOOL isComposing = self->hangulComposer.composedString.length > 0;
            self->hanjaComposer.mode = !isComposing; // 조합 중이 아니면 1회만 사전을 띄운다
            self.delegate = self->hanjaComposer;
            [self.delegate composerSelected:self];
            [self->hanjaComposer updateFromController:controller];
            return CIMInputTextProcessResultProcessed;
        }
        // Vi-mode: esc로 로마자 키보드로 전환
        if (CIMSharedConfiguration->romanModeByEscapeKey && (keyCode == kVK_Escape || (0))) {
            dlog(DEBUG_GUREUM, @"**** Keyboard Changed by Vi-mode");
            [self.delegate cancelComposition];
            [sender selectInputMode:kGureumInputSourceIdentifierQwerty];
            return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
        }
    }
    return CIMInputTextProcessResultNotProcessed;
}

@end
