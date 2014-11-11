//
//  RomanComposer.m
//  Gureum
//
//  Created by Jeong YunWon on 2014. 10. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import "RomanComposer.h"

@interface RomanComposer ()

@property(nonatomic,retain) NSString *_commitString;

@end


@implementation RomanComposer

- (NSString *)composedString {
    return @"";
}

- (NSString *)originalString {
    return self._commitString ?: @"";
}

- (NSString *)commitString {
    return self._commitString ?: @"";
}

- (NSString *)dequeueCommitString {
    NSString *dequeued = self._commitString;
    self._commitString = nil;
    return dequeued ?: @"";
}

- (void)cancelComposition { }

- (void)clearContext {
    self._commitString = nil;
}

- (BOOL)hasCandidates { return NO; }

- (NSArray *)candidates { return nil; }

#pragma -

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    if (string.length > 0 && keyCode < 0x33 && !(flags & NSAlternateKeyMask)) {
        unichar chr = [string characterAtIndex:0];
        if (flags & NSAlphaShiftKeyMask && 'a' <= chr && chr <= 'z') {
            chr -= 0x20;
            string = [NSString stringWithCharacters:&chr length:1];
        }
        self._commitString = string;
        return CIMInputTextProcessResultProcessed;
    } else {
        self._commitString = nil;
        return CIMInputTextProcessResultNotProcessed;
    }
}

@end
