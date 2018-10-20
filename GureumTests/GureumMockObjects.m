//
//  GureumMockObjects.m
//  CharmIM
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import "CIMInputController.h"
#import "GureumMockObjects.h"

#import "Gureum-Swift.h"

#define DEBUG_INPUTCONTROLLER TRUE


@implementation CIMMockClient

- (id)init {
    self = [super init];
    if (self != nil) {

    }
    return self;
}

- (void)selectInputMode:(NSString *)modeIdentifier {
    NSLog(@"select input mode: %@", modeIdentifier);
}

- (NSString *)markedString {
    return [self.string substringWithRange:self.markedRange];
}

- (NSString *)selectedString {
    return [self.string substringWithRange:self.selectedRange];
}

- (void)setMarkedText:(id)string selectionRange:(NSRange)selectionRange replacementRange:(NSRange)replacementRange {
    [self setMarkedText:string selectedRange:selectionRange replacementRange:replacementRange];
}

@end


@implementation VirtualApp

- (id)init {
    self = [super init];
    if (self != nil) {
        self.client = [[CIMMockClient alloc] init];
        self.controller = (id)[[CIMMockInputController alloc] initWithServer:nil delegate:nil client:self.client];
    }
    return self;
}

- (BOOL)inputText:(NSString *)text key:(NSUInteger)keyCode modifiers:(NSEventModifierFlags)flags {
    CIMInputController *controller = self.controller;
    CIMMockClient *client = self.client;
    BOOL processed = [controller inputText:text key:keyCode modifiers:flags client:client];
    [self.controller updateComposition];
    return processed;
}

@end


@implementation ModerateApp

- (BOOL)inputText:(NSString *)text key:(NSUInteger)keyCode modifiers:(NSEventModifierFlags)flags {
    BOOL processed = [super inputText:text key:keyCode modifiers:flags];
    BOOL specialFlags = (flags & (NSEventModifierFlagCommand | NSEventModifierFlagControl)) > 0;
    if (!processed && !specialFlags) {
        [self.client insertText:text replacementRange:self.client.markedRange];
    }
    return processed;
}

@end


@implementation TerminalApp

- (BOOL)inputText:(NSString *)text key:(NSUInteger)keyCode modifiers:(NSEventModifierFlags)flags {
    BOOL processed = NO;
    if (self.client.hasMarkedText) {
        processed = [super inputText:text key:keyCode modifiers:flags];
        if (keyCode == 36) {
            processed = YES;
        }
    }
    else {
        if (keyCode == 36) {
            [self.client insertText:text];
            processed = YES;
        } else {
            processed = [super inputText:text key:keyCode modifiers:flags];
        }
    }
    if (!processed) {
        [self.client insertText:text replacementRange:self.client.markedRange];
    }
    return processed;
}

@end


@implementation GreedyApp

- (BOOL)inputText:(NSString *)text key:(NSUInteger)keyCode modifiers:(NSEventModifierFlags)flags {
    BOOL processed = NO;
    if (self.client.hasMarkedText) {
        processed = [super inputText:text key:keyCode modifiers:flags];
    }
    else {
        processed = [super inputText:text key:keyCode modifiers:flags];
        if (self.client.markedRange.length == 0 || !processed) {
            // FIXME: Commited string should be removed too.
            [self.client insertText:text replacementRange:self.client.markedRange];
        }
    }
    return processed;
}

@end
