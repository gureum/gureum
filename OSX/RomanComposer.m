//
//  RomanComposer.m
//  Gureum
//
//  Created by Jeong YunWon on 2014. 10. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import "Gureum-Swift.h"


@implementation RomanComposer (delegate)

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
