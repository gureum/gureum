//
//  HGInputContext.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "HGInputContext.h"

@implementation HGKeyboard 
@synthesize data;

//! @ref hangul_keyboard_new
- (id)init {
    self = [super init];
    if (self) {
        self->data = hangul_keyboard_new();
        // 생성 실패 처리
        if (self->data == NULL) {
            [self release];
            return nil;
        }
        self->flags.freeWhenDone = NO;
    }
    return self;
}

- (id)initWithKeyboardData:(HangulKeyboard *)keyboardData freeWhenDone:(BOOL)freeWhenDone {
    self = [super init];
    if (self) {
        self->data = keyboardData;
        self->flags.freeWhenDone = freeWhenDone;
    }
    return self;
}

+ (id)keyboardWithKeyboardData:(HangulKeyboard *)keyboardData freeWhenDone:(BOOL)YesOrNo {
    return [[[self alloc] initWithKeyboardData:keyboardData freeWhenDone:YesOrNo] autorelease];
}

- (void)dealloc {
    if (self->flags.freeWhenDone) {
        hangul_keyboard_delete(self->data);
    }
    [super dealloc];
}

- (void)setValue:(HGUCSChar)value forKey:(int)key {
    hangul_keyboard_set_value(self->data, key, value);
}

- (void)setType:(int)type {
    hangul_keyboard_set_type(self->data, type);
}

@end

@implementation HGInputContext
@synthesize context;

- (id)initWithKeyboardIdentifier:(NSString *)code
{
    self = [super init];
    if (self) {
        self->context = hangul_ic_new([code UTF8String]);
        // 생성 실패 처리
        if (self->context == NULL) {
            [self release];
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    hangul_ic_delete(self->context);
    [super dealloc];
}

- (BOOL)process:(int)ascii {
    return (BOOL)hangul_ic_process(self->context, ascii);
}

- (void)reset {
    hangul_ic_reset(self->context);
}

- (BOOL)backspace {
    return (BOOL)hangul_ic_backspace(self->context);
}

- (BOOL)isEmpty {
    return (BOOL)hangul_ic_is_empty(self->context);
}

- (BOOL)hasChoseong {
    return (BOOL)hangul_ic_has_choseong(self->context);
}

- (BOOL)hasJungseong {
    return (BOOL)hangul_ic_has_jungseong(self->context);
}

- (BOOL)hasJongseong {
    return (BOOL)hangul_ic_has_jongseong(self->context);
}

- (BOOL)isTransliteration {
    return (BOOL)hangul_ic_is_transliteration(self->context);
}

- (NSString *)preeditString {
    NSString *string = [NSString stringWithHGUCSString:hangul_ic_get_preedit_string(self->context)];
    ICLog(TRUE, @"** HGInputContext -preeditString : %@", string);
    return string;
}

- (NSString *)commitString {
    NSString *string = [NSString stringWithHGUCSString:hangul_ic_get_commit_string(self->context)];
    ICLog(TRUE, @"** HGInputContext -commitString : %@", string);
    return string;
}

- (NSString *)flushString {
    NSString *string = [NSString stringWithHGUCSString:hangul_ic_flush(self->context)];
    ICLog(TRUE, @"** HGInputContext -flushString : %@", string);
    return string;
}

- (void)setOutputMode:(HGOutputMode)mode {
    hangul_ic_set_output_mode(self->context, mode);
}

- (void)setKeyboard:(HGKeyboard *)aKeyboard {
    hangul_ic_set_keyboard(self->context, aKeyboard.data);
}

- (void)setKeyboardWithData:(HangulKeyboard *)keyboardData {
    hangul_ic_set_keyboard(self->context, keyboardData);
}

- (void)setKeyboardWithIdentifier:(NSString *)identifier {
    hangul_ic_select_keyboard(self->context, [identifier UTF8String]);
}

- (void)setCombination:(HangulCombination *)aCombination {
    hangul_ic_set_combination(self->context, aCombination);
}

@end

inline NSString *HGKeyboardIdentifierAtIndex(NSUInteger index) {
    return [NSString stringWithUTF8String:hangul_ic_get_keyboard_id((unsigned)index)];
}

inline NSString *HGKeyboardNameAtIndex(NSUInteger index) {
    return [NSString stringWithUTF8String:hangul_ic_get_keyboard_name((unsigned)index)];
}

#include <wchar.h>

@implementation NSString (HGUCS)

- (id)initWithHGUCSString:(const HGUCSChar *)ucsString {
    NSInteger length = wcslen((const wchar_t *)ucsString)*sizeof(HGUCSChar); // XXX: 길이 알아내는 or 길이 없이 NSString 만드는 방법이 있을까?
    // initWithCString + UTF32LE 로는 안된다. null 문자가 보이면 무조건 종료하는 듯
    //return [self initWithBytesNoCopy:(void *)ucsString length:length encoding:NSUTF32LittleEndianStringEncoding freeWhenDone:NO];
    return [self initWithBytes:ucsString length:length encoding:NSUTF32LittleEndianStringEncoding ];
}

+ (id)stringWithHGUCSString:(const HGUCSChar *)ucsString {
    return [[[self alloc] initWithHGUCSString:ucsString] autorelease];
}

@end
