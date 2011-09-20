//
//  HangulComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Hangul/HGInputContext.h>
#import "HangulComposer.h"

#import "CIMConfiguration.h"
#import "GureumAppDelegate.h"

#define DEBUG_HANGULCOMPOSER FALSE

typedef enum {
    // filter 문자는 모두 지우고 결합해 표현한다.
    HangulCharacterCombinationWithoutFilter = 0,
    // 없는 자소가 있더라도 모두 filter 문자와 결합해 표현한다.
    HangulCharacterCombinationWithFilter = 1,
    // 중성이 빠졌을 경우만 filter 문자를 이용한다.
    HangulCharacterCombinationWithOnlyJungseongFilter = 2,
    // filter 문자 뒤는 숨긴다.
    HangulCharacterCombinationHiddenOnFilter = 3,
    // 중성 filter 문자 뒤는 숨긴다.
    HangulCharacterCombinationHiddenOnJungseongFilter = 4,
}   HangulCharacterCombinationMode;
#define HangulCharacterCombinationModeCount 5

@class CIMInputController;

@interface HangulComposer (HangulCharacterCombinationMode)

+ (NSString *)commitStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString *)composedStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;

@end

@interface NSString (HangulCharacterCombinationMode)

+ (NSString *)stringByRemovingFilterWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString *)stringByHidingFilterFollowersWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString *)stringByHidingJungseongFilterFollowersWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString *)stringByRemovingNonJungseongFilterWithUCSString:(const HGUCSChar *)UCSString;

@end

@implementation HangulComposer
@synthesize inputContext;

- (id)init {
    // 두벌식을 기본 값으로 갖는다.
    return  [self initWithKeyboardIdentifier:@"2"];
}

- (id)initWithKeyboardIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self->inputContext = [[HGInputContext alloc] initWithKeyboardIdentifier:identifier];
        // 생성 실패 처리
        if (self->inputContext == nil) {
            [self release];
            return nil;   
        }
        self->composedString = [[NSString alloc] init];
        self->commitString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self->inputContext release];
    [super dealloc];
}

- (void)setKeyboardWithIdentifier:(NSString *)identifier {
    [self->inputContext setKeyboardWithIdentifier:identifier];
}

#pragma - IMKInputServerTextData

- (BOOL)inputController:(CIMInputController *)inputController inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    // libhangul은 backspace를 키로 받지 않고 별도로 처리한다.
    if (keyCode == 51) {
        return [self->inputContext backspace];
    }
    // 한글 입력에서 캡스락 무시
    if (flags & NSAlphaShiftKeyMask) {
        if (!(flags & NSShiftKeyMask)) {
            string = [string lowercaseString];
        }
    }
    BOOL handled = [self->inputContext process:[string characterAtIndex:0]];
    NSString *recentCommitString = [[self class] commitStringByCombinationModeWithUCSString:[self->inputContext commitUCSString]];
    [self->commitString appendString:recentCommitString];
    ICLog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->commitString, recentCommitString);
    return handled;
}

#pragma - CIMComposer

- (NSString *)originalString {
    const HGUCSChar *preedit = [self->inputContext preeditUCSString];
    return [[self class] commitStringByCombinationModeWithUCSString:preedit];
}

- (NSString *)composedString {
    const HGUCSChar *preedit = [self->inputContext preeditUCSString];
    return [[self class] composedStringByCombinationModeWithUCSString:preedit];
}

- (NSString *)commitString {
    return self->commitString;
}

- (NSString *)dequeueCommitString {
    NSString *queuedCommitString = [NSString stringWithString:self->commitString];
    [self->commitString setString:@""];
    return queuedCommitString;
}

- (void)cancelComposition {
    NSString *flushedString = [[self class] commitStringByCombinationModeWithUCSString:[self->inputContext flushUCSString]];
    [self->commitString appendString:flushedString];
}

- (void)clearContext {
    [self->inputContext reset];
    [self->commitString setString:@""];
}

@end

@implementation HangulComposer (HangulCharacterCombinationMode)

static NSString *HangulCombinationModefilters[HangulCharacterCombinationModeCount] = {
    @"stringByRemovingFilterWithUCSString:",
    @"stringWithUCSString:",
    @"stringByRemovingNonJungseongFilterWithUCSString:",
    @"stringByHidingFilterFollowersWithUCSString:",
    @"stringByHidingJungseongFilterFollowersWithUCSString:",
};

/*!
    @brief  설정에 따라 조합 완료할 문자 최종처리
*/
+ (NSString *)commitStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString {
    SEL filter = NSSelectorFromString(HangulCombinationModefilters[CIMSharedConfiguration->hangulCombinationModeCommiting]);
    return [NSString performSelector:filter withObject:(id)UCSString];
}

/*!
    @brief  설정에 따라 조합중으로 보여줄 문자 최종처리
*/
+ (NSString *)composedStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString {
    SEL filter = NSSelectorFromString(HangulCombinationModefilters[CIMSharedConfiguration->hangulCombinationModeComposing]);
    return [NSString performSelector:filter withObject:(id)UCSString];
}

@end

@implementation NSString (HangulCharacterCombinationMode)

+ (NSString *)stringByRemovingFilterWithUCSString:(const HGUCSChar *)UCSString {
    // 조합중인지 판별하는 magic
    if (!HGCharacterIsChoseong(UCSString[0])) {
        return [NSString stringWithUCSString:UCSString];
    }
    if (UCSString[0] == 0x115f) {
        return [NSString stringWithUCSString:UCSString + 1];
    }
    /* if (UCSString[1] == 0x1160) */ {
        NSMutableString *filtered = [[NSMutableString alloc] initWithUCSString:UCSString length:1];
        [filtered appendString:[NSString stringWithUCSString:UCSString + 2 length:1]];
        return [filtered autorelease];
    }
}

+ (NSString *)stringByHidingFilterFollowersWithUCSString:(const HGUCSChar *)UCSString {
    // 조합중인지 판별하는 magic
    if (!HGCharacterIsChoseong(UCSString[0])) {
        return [NSString stringWithUCSString:UCSString];
    }
    
    if (UCSString[0] == 0x115f) return @"";
    /* if (UCSString[1] == 0x1160) */
    return [NSString stringWithUCSString:UCSString length:1];
}

+ (NSString *)stringByHidingJungseongFilterFollowersWithUCSString:(const HGUCSChar *)UCSString {
    // 조합중인지 판별하는 magic
    if (!HGCharacterIsChoseong(UCSString[0])) {
        return [NSString stringWithUCSString:UCSString];
    }
    
    if (UCSString[0] == 0x115f) {
        return [NSString stringWithUCSString:UCSString + 1];   
    }
    /* if (UCSString[1] == 0x1160) */
    return [NSString stringWithUCSString:UCSString length:1];
}

+ (NSString *)stringByRemovingNonJungseongFilterWithUCSString:(const HGUCSChar *)UCSString {
    // 초성이 필터문자일 때를 제외하면 항상 
    if (UCSString[0] == 0x115f) {
        return [NSString stringWithUCSString:UCSString + 1];
    }
    return [NSString stringWithUCSString:UCSString];
}

@end
