//
//  CIMComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include "CIMComposer.h"

@implementation CIMBaseComposer
@synthesize originalString;

- (id)init {
    self = [super init];
    if (self != nil) {
        self.originalString = @"";
    }
    return self;
}

- (void)dealloc {
    self.originalString = nil;
    [super dealloc];
}

- (NSString *)commitString {
    return @"";
    return originalString;
}

- (NSString *)composedString {
    return @"";
}

- (NSString *)endComposing {
    return @"";
}

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    self.originalString = string;
    return NO;
}

@end