//
//  CIMComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include "CIMComposer.h"

@implementation CIMBaseComposer

- (NSString *)originalString {
    return @"";
}

- (NSString *)commitString {
    return @"";
}

- (NSString *)composedString {
    return @"";
}

- (NSString *)endComposing {
    return @"";
}

- (void)clearContext { }

#pragma - 

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    return NO;
}

@end