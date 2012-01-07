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
@synthesize inputContext=_inputContext;

- (id)init {
    // 두벌식을 기본 값으로 갖는다.
    return  [self initWithKeyboardIdentifier:@"2"];
}

- (id)initWithKeyboardIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self->_inputContext = [[HGInputContext alloc] initWithKeyboardIdentifier:identifier];
        // 생성 실패 처리
        if (self->_inputContext == nil) {
            [self release];
            return nil;   
        }
        self->_commitString = [[NSMutableString alloc] init];
    }
    return self;
}

- (BOOL)hasCandidates {
    return NO;
}

- (void)dealloc {
    [self->_commitString release];
    [self->_inputContext release];
    [super dealloc];
}

- (void)setKeyboardWithIdentifier:(NSString *)identifier {
    [self->_inputContext setKeyboardWithIdentifier:identifier];
}

#pragma - IMKInputServerTextData

- (CIMInputTextProcessResult)inputController:(CIMInputController *)inputController inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {    
    // libhangul은 backspace를 키로 받지 않고 별도로 처리한다.
    if (keyCode == 51) {
        return [self->_inputContext backspace];
    }
    // 한글 입력에서 캡스락 무시
    if (flags & NSAlphaShiftKeyMask) {
        if (!(flags & NSShiftKeyMask)) {
            string = [string lowercaseString];
        }
    }
    BOOL handled = [self->_inputContext process:[string characterAtIndex:0]];
    NSString *recentCommitString = [[self class] commitStringByCombinationModeWithUCSString:[self->_inputContext commitUCSString]];
    [self->_commitString appendString:recentCommitString];
    ICLog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->_commitString, recentCommitString);
    return handled ? CIMInputTextProcessResultProcessed : CIMInputTextProcessResultNotProcessedAndNeedsCancel;
}

#pragma - CIMComposer

- (NSString *)originalString {
    const HGUCSChar *preedit = [self->_inputContext preeditUCSString];
    return [[self class] commitStringByCombinationModeWithUCSString:preedit];
}

- (NSString *)composedString {
    const HGUCSChar *preedit = [self->_inputContext preeditUCSString];
    return [[self class] composedStringByCombinationModeWithUCSString:preedit];
}

- (NSString *)commitString {
    return self->_commitString;
}

- (NSString *)dequeueCommitString {
    NSString *queuedCommitString = [NSString stringWithString:self->_commitString];
    [self->_commitString setString:@""];
    return queuedCommitString;
}

- (void)cancelComposition {
    NSString *flushedString = [[self class] commitStringByCombinationModeWithUCSString:[self->_inputContext flushUCSString]];
    [self->_commitString appendString:flushedString];
}

- (void)clearContext {
    [self->_inputContext reset];
    [self->_commitString setString:@""];
}

@end

@implementation HanjaComposer
@synthesize hanjaCandidates=_hanjaCandidates, mode=_mode;

- (id)init {
    self = [super init];
    if (self != nil) {
        self->bufferedString = [[NSMutableString alloc] init];
    }
    return self;
}

- (HangulComposer *)hangulComposer {
    return (id)self.delegate;
}

// 한글 입력기가 지금까지 완료한 조합 + 현재 진행 중인 조합
- (NSString *)originalString {
    return [self->bufferedString stringByAppendingString:self.hangulComposer.composedString];
}

- (NSString *)composedString {
    return self->composedString;
}

- (void)setComposedString:(NSString *)string {
    [self->composedString autorelease];
    self->composedString = [string retain];
}

- (NSString *)commitString {
    return self->commitString;
}

- (void)setCommitString:(NSString *)string {
    [self->commitString autorelease];
    self->commitString = [string retain];
}

- (void)dealloc {
    self.composedString = nil;
    self.commitString = nil;
    [super dealloc];
}

- (NSString *)dequeueCommitString {
    NSString *res = self->commitString;
    if (res.length > 0) {
        [self->bufferedString setString:@""];
        self.commitString = @"";
    }
    return res;
}

- (void)cancelComposition {
    [self.hangulComposer cancelComposition];
    [self.hangulComposer dequeueCommitString];
    self.commitString = [self.commitString stringByAppendingString:self.composedString];
    [self->bufferedString setString:@""];
    self.composedString = @"";
}

- (void)setHanjaCandidates:(HGHanjaList *)hanjaCandidates {
    [self->_hanjaCandidates release];
    self->_hanjaCandidates = [hanjaCandidates retain];
}

- (void)composerSelected:(id)sender {
    [self->bufferedString setString:@""];
    self.commitString = @"";
    [self updateHanjaCandidates];
}

- (void)updateHanjaCandidates {
    // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
    [self->bufferedString appendString:self.hangulComposer.dequeueCommitString];
    // step 2: 일단 화면에 한글이 표시되도록 조정
    self.composedString = self.originalString;
    // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
    if (self.originalString.length == 0) {
        self.hanjaCandidates = nil;
    } else {
        self.hanjaCandidates = [self.hanjaTable hanjasByPrefixMatching:self.composedString];
        if (![self.composedString isEqualToString:self.hanjaCandidates.key]) {
            self.hanjaCandidates = nil;
        }
    }
}

- (BOOL)hasCandidates {
    return self.hanjaCandidates.count > 0;
}

- (NSArray *)candidates {
    HGHanjaList *hanjas = self.hanjaCandidates;
    NSMutableArray *candidates = [NSMutableArray arrayWithObject:hanjas.key];
    for (HGHanja *hanja in hanjas) {
        [candidates addObject:[NSString stringWithFormat:@"%@: %@", hanja.value, hanja.comment]];
    }
    return candidates;
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    NSString *value = [[[candidateString string] componentsSeparatedByString:@":"] objectAtIndex:0];
    self.composedString = @"";
    self.commitString = value;
    [self.hangulComposer cancelComposition];
    [self.hangulComposer dequeueCommitString];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    if (candidateString.length == 0) {
        self.composedString = self.originalString;   
    } else {
        NSString *value = [[[candidateString string] componentsSeparatedByString:@":"] objectAtIndex:0];
        self.composedString = value;
    }
}

- (HGHanjaTable *)hanjaTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        sharedHanjaTable = [[HGHanjaTable alloc] init];
    }
    return sharedHanjaTable;
}

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    CIMInputTextProcessResult result = [self.delegate inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
    switch (keyCode) {
        // backspace
        case 51: if (result == CIMInputTextProcessResultNotProcessed) {
            if (self.originalString.length > 0) {
                // 조합 중인 글자가 없을 때 backspace가 들어오면 조합이 완료된 글자 중 마지막 글자를 지운다.
                [self->bufferedString deleteCharactersInRange:NSMakeRange(self->bufferedString.length - 1, 1)];
                self.composedString = self.originalString;
                result = CIMInputTextProcessResultProcessed;
            } else {
                // 글자를 모두 지우면 한자 모드에서 빠져 나간다.
                self.mode = NO;
            }
        }   break;
        // space
        case 49: {
            [self->bufferedString appendString:self.hangulComposer.dequeueCommitString];
            // 단어 뜻 검색을 위해 공백 문자도 후보 검색에 포함한다.
            if (self->bufferedString.length > 0) {
                [self->bufferedString appendString:@" "];
                result = CIMInputTextProcessResultProcessed;
            } else {
                self.commitString = @" ";
                result = CIMInputTextProcessResultNotProcessedAndNeedsCommit;
            }
        }   break;
        // esc
        case 0x35: {
            self.mode = NO;
            // step 1: 조합중인 한글을 모두 가져옴
            [self.hangulComposer cancelComposition];
            [self->bufferedString appendString:self.hangulComposer.dequeueCommitString];
            // step 2: 한글을 그대로 커밋
            self.composedString = self.originalString;
            [self cancelComposition];
            // step 3: 한자 후보 취소
            self.hanjaCandidates = nil; // 후보 취소
            return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
        }   break;
        default:
            break;
    }
    [self updateHanjaCandidates];
    if (result == CIMInputTextProcessResultNotProcessedAndNeedsCommit) {
        [self cancelComposition];
        return result;
    }
    if (self.commitString.length == 0) {
        return result == CIMInputTextProcessResultProcessed;   
    } else {
        return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
    }
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
