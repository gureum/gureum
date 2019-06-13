//
//  MockInputClient.m
//  OSXTestApp
//
//  Created by Jeong YunWon on 13/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

#import "MockInputClient.h"

@implementation MockInputClient

- (void)selectInputMode:(NSString *)modeIdentifier {
    NSLog(@"select input mode: %@", modeIdentifier);
}

- (NSInteger)length {
    return self.string.length;
}

- (NSString *)markedString {
    return [self.string substringWithRange:self.markedRange];
}

- (NSString *)selectedString {
    return [self.string substringWithRange:self.selectedRange];
}

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {
    // NSAssert(replacementRange.location == NSNotFound || replacementRange.length != 0, @"-");
    [super insertText:string replacementRange:replacementRange];
}

- (void)setMarkedText:(id)string selectionRange:(NSRange)selectionRange replacementRange:(NSRange)replacementRange {
    NSRange selected = NSMakeRange(replacementRange.location + selectionRange.location, selectionRange.length);
    [self setMarkedText:string selectedRange:selected replacementRange:replacementRange];
    [self setSelectedRange:selected];

//    NSRange s = self.selectedRange;
//    NSRange m = self.markedRange;
//    NSAssert(selected.location == s.location && selected.length == s.length, @"");
//    NSAssert(selected.location == m.location && selected.length == m.length, @"");
}

- (void)overrideKeyboardWithKeyboardNamed:(NSString *)keyboardUniqueName {
    // do nothing
}

- (NSString *)bundleIdentifier {
    return [NSBundle mainBundle].bundleIdentifier;
}

@end
