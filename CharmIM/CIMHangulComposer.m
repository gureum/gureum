//
//  CIMHangulComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Hangul/HGInputContext.h>
#import "CIMHangulComposer.h"

bool cb_libhangul_transition(HangulInputContext *context, ucschar c, const ucschar* buf, id data);
@implementation CIMHangulComposer

- (id)init {
    // 두벌식을 기본 값으로 갖는다.
    return self = [self initWithKeyboardIdentifier:@"2"];
}

- (id)initWithKeyboardIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self->inputContext = [[HGInputContext alloc] initWithKeyboardIdentifier:identifier];
    }
    
    if (self->inputContext == nil) {
        [self release];
        return nil;   
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

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    // libhangul은 backspace를 키 대신 별도로 처리한다.
    if (keyCode == 51) {
        return [self->inputContext backspace];
    }
    string = [string lowercaseString]; // 한글 입력에서 캡스락 무시
    return [self->inputContext process:[string characterAtIndex:0]];
}

#pragma - CIMComposer

- (NSString *)composedString {
    return [self->inputContext preeditString];
}

- (NSString *)commitString {
    return [self->inputContext commitString];
}

- (NSString *)endComposing {
    return [self->inputContext flushString];
}

@end
