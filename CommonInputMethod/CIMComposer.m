//
//  CIMComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include "CIMComposer.h"

@implementation CIMComposer
@synthesize delegate = _delegate;
@synthesize inputMode = _inputMode;

- (void)dealloc {
    self.delegate = nil;
    self.inputMode = nil;
    [super dealloc];
}

#pragma - delegate

- (NSString *)composedString {
    return _delegate.composedString;
}

- (NSString *)originalString {
    return _delegate.originalString;
}

- (NSString *)commitString {
    return _delegate.commitString;
}

- (NSString *)dequeueCommitString {
    return [_delegate dequeueCommitString];
}

- (void)cancelComposition {
    [_delegate cancelComposition];
}

- (void)clearContext {
    [_delegate clearContext];
}

- (BOOL)hasCandidates {
    return _delegate.hasCandidates;
}

- (NSArray *)candidates {
    return _delegate.candidates;
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    [_delegate candidateSelected:candidateString];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    [_delegate candidateSelectionChanged:candidateString];
}

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller commandString:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    return [_delegate inputController:controller commandString:string key:keyCode modifiers:flags client:sender];
}

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    return [_delegate inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
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

- (BOOL)hasCandidates { return NO; }

- (NSArray *)candidates { return nil; }

#pragma -

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    return CIMInputTextProcessResultNotProcessed;
}

@end
