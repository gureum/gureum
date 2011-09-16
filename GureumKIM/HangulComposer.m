//
//  HangulComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Hangul/HGInputContext.h>
#import "HangulComposer.h"

#define DEBUG_HANGULCOMPOSER FALSE

@class CIMInputController;

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
    NSString *recentCommitString = [self->inputContext commitString];
    [self->commitString appendString:recentCommitString];
    ICLog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->commitString, recentCommitString);
    return handled;
}

#pragma - CIMComposer

- (NSString *)originalString {
    // 입력된 문자 여부에 따라 다르게 표시해주자..!
    return [self->inputContext preeditString];
}

- (NSString *)composedString {
    // 입력된 문자 여부에 따라 다르게 표시해주자..!
    return [self originalString];
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
    [self->commitString appendString:[self->inputContext flushString]];
}

- (void)clearContext {
    [self->inputContext reset];
}

@end
