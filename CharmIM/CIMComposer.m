//
//  CIMComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include "CIMComposer.h"

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

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    return NO;
}

@end