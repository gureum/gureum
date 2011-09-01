//
//  CharmInputMethodController.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputController.h"


@implementation CIMInputController

@end

#pragma - IMKServerInput Protocol

// priority 1
@implementation CIMInputController (IMKServerInputTextData)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    ICLog(TRUE, @"input text: %@ / key: %d / modifier: %u / client: %@", string, keyCode, flags, sender);
    return NO;
    
}
@end

// priority 2
@implementation CIMInputController (IMKServerInputHandleEvent)

// Receiving Events Directly from the Text Services Manager
- (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
    ICLog(TRUE, @"event: %@ / key: %d / modifier: %d / chars: %@ / chars ignoreMod: %@ / client: %@", event, [event keyCode], [event modifierFlags], [event characters], [event charactersIgnoringModifiers], [[self client] bundleIdentifier]);
    return NO;
}

@end

// priority 3
/*
@implementation CIMInputController (IMKServerInputKeyBinding)

- (BOOL)inputText:(NSString *)string client:(id)sender {
    NSLog(@"input text: %@ / client: %@", string, sender);
    return NO;
}

- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    NSLog(@"sel? %@", aSelector);
    
    return NO;
}

@end
*/

@implementation CIMInputController (IMKServerInputCommitComposition)

/*
 // Committing a Composition
 - (void)commitComposition:(id)sender {
 
 }
*/

@end

@implementation CIMInputController (IMKServerInputCandidates)

/*
// Getting Input Strings and Candidates
- (id)composedString:(id)sender {
    return @"!";
}

- (NSAttributedString *)originalString:(id)sender {
    return @"#";
}

- (NSArray *)candidates:(id)sender {
    return [NSArray arrayWithObjects:@"1", @"2", nil];
}
*/
@end
