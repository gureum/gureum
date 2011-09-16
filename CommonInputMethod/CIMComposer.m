//
//  CIMComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include "CIMComposer.h"

@implementation CIMComposer
@synthesize delegate;
@synthesize inputMode;

#pragma - delegate

- (NSString *)composedString {
    return [delegate composedString];
}

- (NSString *)originalString {
    return [delegate originalString];
}

- (NSString *)commitString {
    return [delegate commitString];
}

- (NSString *)dequeueCommitString {
    return [delegate dequeueCommitString];
}

- (void)cancelComposition {
    [delegate cancelComposition];
}

- (void)clearContext {
    [delegate clearContext];
}

- (BOOL)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    return [delegate inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
}

@end

@implementation CIMBaseComposer

- (NSString *)composedString {
    return @"";
}

- (NSString *)originalString {
    return @"";
}

- (NSString *)commitString {
    return @"";
}

- (NSString *)dequeueCommitString {
    return @"";
}

- (void)cancelComposition { }

- (void)clearContext { }

#pragma -

- (BOOL)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    return NO;
}

@end