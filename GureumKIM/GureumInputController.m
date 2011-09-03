//
//  GureumInputController.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "CIMCommon.h"

#import "GureumInputManager.h"
#import "CIMComposer.h"

#import "GureumInputController.h"

#define DEBUG_INPUTCONTROLLER TRUE

@implementation GureumInputController

@end

#pragma - IMKServerInput Protocol

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현

@implementation GureumInputController (IMKServerInputTextData)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %d / modifier flags: %u / client: %@(%@)", string, keyCode, flags, [[self client] bundleIdentifier], [[self client] class]);
    
    BOOL handled = [GureumManager inputText:string key:keyCode modifiers:flags client:self.client]; // 쓸모없는 sender 대신 self.client 전달
    [self updateComposition];
    return handled;
}

@end

/*
 @implementation CIMInputController (IMKServerInputHandleEvent)
 
 // Receiving Events Directly from the Text Services Manager
 - (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
 ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -handleEvent:client: with event: %@ / key: %d / modifier: %d / chars: %@ / chars ignoreMod: %@ / client: %@", event, [event keyCode], [event modifierFlags], [event characters], [event charactersIgnoringModifiers], [[self client] bundleIdentifier]);
 return NO;
 }
 
 @end
 */
/*
 @implementation CIMInputController (IMKServerInputKeyBinding)
 
 - (BOOL)inputText:(NSString *)string client:(id)sender {
 ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:client: with string: %@ / client: %@", string, sender);
 return NO;
 }
 
 - (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
 ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -didCommandBySelector: with selector: %@", aSelector);
 
 return NO;
 }
 
 @end
 */

@implementation GureumInputController (IMKServerInput)

// Committing a Composition
// 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
- (void)commitComposition:(id)sender {
    // 한글 합성기 의존적인 구현
    NSString *commitString = [GureumManager.currentComposer endComposing];
    ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -commitComposition: with sender: %@ / strings: %@", sender, commitString);
    [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [commitString release];
}

// Getting Input Strings and Candidates
// 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
- (id)composedString:(id)sender {
    NSString *string = GureumManager.currentComposer.composedString;
    ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -composedString: with sender: %@ / return: %@", sender, string);
    return string;
}

/*
 // libhangul 입력에서 쓸데가 없다
 - (NSAttributedString *)originalString:(id)sender {
 ICLog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -originalString: with sender: %@", sender);
 return [[[NSAttributedString alloc] initWithString:@""] autorelease];
 }
 */

@end

@implementation GureumInputController (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(id)sender
{
    // does NSFlagsChangedMask work?
    return NSKeyDownMask | NSFlagsChangedMask | NSLeftMouseDownMask | NSRightMouseDownMask | NSLeftMouseDraggedMask |    NSRightMouseDraggedMask;
}

- (id)valueForTag:(long)tag client:(id)sender {
    return [super valueForTag:tag client:sender];
    
}

//! @brief  자판 전환을 감지한다.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender {
    ICLog(DEBUG_INPUTCONTROLLER, @"** GureumInputController -setValue:forTag:client: with value: %@ / tag: %x / sender: %@ / client: %@", value, tag, sender, self.client);
    switch (tag) {
        case kTextServiceInputModePropertyTag:
            if (![value isEqualToString:GureumManager.inputMode]) {
                [self commitComposition:sender];
                GureumManager.inputMode = value;
            }
            break;
        default:
            return;
    }
}


@end

@implementation GureumInputController (IMKMouseHandling)

/*!
 @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
 */
- (BOOL)mouseDownOnCharacterIndex:(NSUInteger)index coordinate:(NSPoint)point withModifier:(NSUInteger)flags continueTracking:(BOOL *)keepTracking client:(id)sender
{
    [self commitComposition:sender];
    return NO;
}

@end

