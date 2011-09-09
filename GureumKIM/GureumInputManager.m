//
//  GureumInputManager.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumInputManager.h"

#import "CIMInputHandler.h"
#import "CIMHangulComposer.h"

#define DEBUG_INPUTMANAGER TRUE

@interface GureumInputManager ()

- (void)setCurrentComposer:(NSObject<CIMComposer> *)composer;

@end

NSString *kGureumInputSourceIdentifierQwerty = @"org.youknowone.inputmethod.GureumKIM.qwerty";
NSString *kGureumInputSourceIdentifierDvorak = @"org.youknowone.inputmethod.GureumKIM.dvorak";
NSString *kGureumInputSourceIdentifierDvorakQwertyCommand = @"org.youknowone.inputmethod.GureumKIM.dvorakq";
NSString *kGureumInputSourceIdentifierColemak = @"org.youknowone.inputmethod.GureumKIM.colemak";
NSString *kGureumInputSourceIdentifierColemakQwertyCommand = @"org.youknowone.inputmethod.GureumKIM.colemakq";
NSString *kGureumInputSourceIdentifierHan2 = @"org.youknowone.inputmethod.GureumKIM.han2";
NSString *kGureumInputSourceIdentifierHan2Classic = @"org.youknowone.inputmethod.GureumKIM.han2classic";
NSString *kGureumInputSourceIdentifierHan3Final = @"org.youknowone.inputmethod.GureumKIM.han3final";
NSString *kGureumInputSourceIdentifierHan390 = @"org.youknowone.inputmethod.GureumKIM.han390";
NSString *kGureumInputSourceIdentifierHan3NoShift = @"org.youknowone.inputmethod.GureumKIM.han3noshift";
NSString *kGureumInputSourceIdentifierHan3Classic = @"org.youknowone.inputmethod.GureumKIM.han3classic";
NSString *kGureumInputSourceIdentifierHan3Layout2 = @"org.youknowone.inputmethod.GureumKIM.han3layout2";
NSString *kGureumInputSourceIdentifierHanAhnmatae = @"org.youknowone.inputmethod.GureumKIM.han3ahnmatae";
NSString *kGureumInputSourceIdentifierHanRoman = @"org.youknowone.inputmethod.GureumKIM.hanroman";

@implementation GureumInputManager
@synthesize server, candidates, configuration, handler;
@synthesize inputMode, currentComposer;
@synthesize inputting;

- (id)init
{
    self = [super init];
    ICLog(DEBUG_INPUTMANAGER, @"** GureumInputManager Init: %@", self);
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *connectionName = [[mainBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];
        self->server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:[mainBundle bundleIdentifier]];
        self->candidates = [[IMKCandidates alloc] initWithServer:self->server panelType:kIMKSingleColumnScrollingCandidatePanel];
        self->configuration = [[CIMConfiguration alloc] init];
        self->handler = [[CIMInputHandler alloc] initWithManager:(id)self];

        self->romanComposer = [[CIMBaseComposer alloc] init];
        self->hangulComposer = [[CIMHangulComposer alloc] init];

        self->currentComposer = self->romanComposer;
    }
    return self;
}

- (void)dealloc
{
    [self->romanComposer release];
    [self->hangulComposer release];
    [self->handler release];
    [self->candidates release];
    [self->server release];
    [super dealloc];
}

NSDictionary *GureumInputSourceToHangulKeyboardIdentifierTable = nil;
+ (void)initialize {
    GureumInputSourceToHangulKeyboardIdentifierTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                        @"", kGureumInputSourceIdentifierQwerty,
                                                        @"2", kGureumInputSourceIdentifierHan2,
                                                        @"2y", kGureumInputSourceIdentifierHan2Classic,
                                                        @"3f", kGureumInputSourceIdentifierHan3Final,
                                                        @"39", kGureumInputSourceIdentifierHan390,
                                                        @"3s", kGureumInputSourceIdentifierHan3NoShift,
                                                        @"3y", kGureumInputSourceIdentifierHan3Classic,
                                                        @"32", kGureumInputSourceIdentifierHan3Layout2,
                                                        @"ro", kGureumInputSourceIdentifierHanRoman,
                                                        @"ahn", kGureumInputSourceIdentifierHanAhnmatae,
                                                        nil];
}

#pragma - IMKServerInputTextData

//  받은 입력은 모두 핸들러로 넘겨준다.
- (BOOL)inputController:(IMKInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    // hardcoded shortcut handling
    if ((flags|NSAlphaShiftKeyMask) == (NSAlphaShiftKeyMask|self->configuration->inputModeExchangeKeyModifier) && keyCode == self->configuration->inputModeExchangeKeyCode) {
        ICLog(TRUE, @"-- Keyboard Change!!");
        // 한영전환
        [self.currentComposer cancelComposition];
        if (self.currentComposer == self->romanComposer) {
            NSString *lastHangulInputMode = self->configuration->lastHangulInputMode;
            if (lastHangulInputMode == nil) lastHangulInputMode = kGureumInputSourceIdentifierHan2;
            [sender selectInputMode:lastHangulInputMode];
        } else {
            [sender selectInputMode:kGureumInputSourceIdentifierQwerty];
        }
        return YES;
    }
    // general composer
    return [self->handler inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
}

#pragma - Private methods

- (void)setCurrentComposer:(NSObject<CIMComposer> *)composer; {
    self->currentComposer = composer;
}

- (void)setInputMode:(NSString *)newInputMode {
    ICLog(TRUE, @"** GureumInputManager -setLayoutIdentifier: with input mode: %@", newInputMode);
    if ([self->inputMode isEqualToString:newInputMode]) return;
    
    NSString *keyboardIdentifier = [GureumInputSourceToHangulKeyboardIdentifierTable objectForKey:newInputMode];
    if ([keyboardIdentifier length] == 0) {
        self->currentComposer = self->romanComposer;
    } else {
        self->currentComposer = self->hangulComposer;
        [self->hangulComposer setKeyboardWithIdentifier:keyboardIdentifier];
        CIMConfigurationSetObjectForField(self->configuration, newInputMode, lastHangulInputMode);
        [self->configuration saveConfigurationForStringField:&self->configuration->lastHangulInputMode];
    }
    
    [self->inputMode release];
    self->inputMode = [newInputMode  retain];
}

@end
