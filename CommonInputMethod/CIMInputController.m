//
//  CIMInputController.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "CIMCommon.h"
#import "CIMApplicationDelegate.h"

#import "CIMInputManager.h"
#import "CIMComposer.h"

#import "CIMInputController.h"
#import "CIMConfiguration.h"

#define DEBUG_INPUTCONTROLLER FALSE
#define DEBUG_LOGGING FALSE

#define CIMSharedInputManager CIMAppDelegate.sharedInputManager


@interface CIMInputReceiver(IMKServerInput)

- (BOOL)commitComposition:(id)sender controller:(CIMInputController *)controller;
- (void)updateComposition:(CIMInputController *)controller;
- (void)cancelComposition:(CIMInputController *)controller;
- (BOOL)commitCompositionEvent:(id)sender controller:(CIMInputController *)controller;
- (void)updateCompositionEvent:(CIMInputController *)controller;
- (void)cancelCompositionEvent:(CIMInputController *)controller;
- (NSString *)_internalComposedString;

@end


@implementation CIMInputReceiver
@synthesize composer=_composer, inputClient=_inputClient;

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super init];
    if (self != nil) {
        dlog(DEBUG_INPUTCONTROLLER, @"**** NEW INPUT CONTROLLER INIT **** WITH SERVER: %@ / DELEGATE: %@ / CLIENT: %@", server, delegate, inputClient);
        if (!CIMSharedInputManager.configuration->sharedInputManager) {
            self->_composer = [[CIMAppDelegate composerWithServer:server client:inputClient] retain];
            self->_composer->manager = CIMSharedInputManager;
        }
        _inputClient = inputClient;
    }
    return self;
}

- (CIMComposer *)composer {
    return self->_composer ? self->_composer : CIMSharedInputManager.sharedComposer;
}

- (void)dealloc {
    [self->_composer release];
    [super dealloc];
}

// IMKServerInput 프로토콜에 대한 공용 핸들러
- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    dlog(DEBUG_LOGGING, @"LOGGING::KEY::(%@)(%ld)(%lu)", [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"], keyCode, flags);
    CIMInputTextProcessResult handled = [CIMSharedInputManager inputController:controller inputText:string key:keyCode modifiers:flags client:sender];

    CIMSharedInputManager.inputting = YES;

    switch (handled) {
        case CIMInputTextProcessResultNotProcessed:
        case CIMInputTextProcessResultProcessed:
            break;
        case CIMInputTextProcessResultNotProcessedAndNeedsCancel:
            [self cancelComposition:controller];
            break;
        case CIMInputTextProcessResultNotProcessedAndNeedsCommit:
            [self cancelComposition:controller];
            [self commitComposition:sender controller:controller];
            return handled;
        default:
            dlog(TRUE, @"WRONG RESULT: %d", handled);
            dassert(NO);
            break;
    }

    BOOL commited = [self commitComposition:sender controller:controller]; // 조합 된 문자 반영
    if (commited || [sender markedRange].length > 0 || self._internalComposedString.length > 0) {
        [self updateComposition:controller]; // 조합 중인 문자 반영
    }

    CIMSharedInputManager.inputting = NO;

    dlog(DEBUG_INPUTCONTROLLER, @"*** End of Input handling ***");
    return handled;
}

@end

@implementation CIMInputReceiver (IMKServerInput)

// Committing a Composition
// 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
- (BOOL)commitComposition:(id)sender controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::COMMIT-INTERNAL");
    return [self commitCompositionEvent:sender controller:controller];
}

- (void)updateComposition:(CIMInputController *)controller  {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::UPDATE-INTERNAL");
    [controller updateComposition];
}

- (void)cancelComposition:(CIMInputController *)controller  {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::CANCEL-INTERNAL");
    [controller cancelComposition];
}

// Committing a Composition
// 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
- (BOOL)commitCompositionEvent:(id)sender controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::COMMIT");
    if (!CIMSharedInputManager.inputting) {
        // 입력기 외부에서 들어오는 커밋 요청에 대해서는 편집 중인 글자도 커밋한다.
        dlog(DEBUG_INPUTCONTROLLER, @"-- CANCEL composition because of external commit request from %@", sender);
        dlog(DEBUG_LOGGING, @"LOGGING::EVENT::CANCEL-INTERNAL");
        [self cancelCompositionEvent:controller];
    }
    // 왠지는 모르겠지만 프로그램마다 동작이 달라서 조합을 반드시 마쳐주어야 한다
    // 터미널과 같이 조합중에 리턴키 먹는 프로그램은 조합 중인 문자가 없고 보통은 있다
    NSString *commitString = [self.composer dequeueCommitString];

    // 커밋할 문자가 없으면 중단
    if ([commitString length] > 0) {
        dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -commitComposition: with sender: %@ / strings: %@", sender, commitString);
        NSRange range = [sender markedRange];
        dlog(DEBUG_LOGGING, @"LOGGING::COMMIT::%lu:%lu:%@", range.location, range.length, commitString);
        if (range.length) {
            [sender insertText:commitString replacementRange:range];
        } else {
            [sender insertText:commitString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        }
        return YES;
    }
    return NO;
}

- (void)updateCompositionEvent:(CIMInputController *)controller  {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::UPDATE");
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -updateComposition");
}

- (void)cancelCompositionEvent:(CIMInputController *)controller  {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::CANCEL");
    [self.composer cancelComposition];
}

- (NSString *)_internalComposedString {
    NSString *string = self.composer.composedString;
    if (string.length == 0 && CIMSharedInputManager.needsFakeComposedString) {
        string = @"\u200b";
    }
    return string;
}

// Getting Input Strings and Candidates
// 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
- (id)composedString:(id)sender controller:(CIMInputController *)controller {
    NSString *string = [self _internalComposedString];
    if ([string isEqualToString:@"\u200b"] && [sender selectedRange].length > 0 && [sender markedRange].length == 0) {
        string = @""; // 선택된 영역이 있을 경우 삭제되지 않도록 보호한다.
    }
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::COMPOSEDSTRING::(%@)", string);
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -composedString: with sender: %@ / return: '%@'", sender, string);
    return string;
}

- (NSAttributedString *)originalString:(id)sender controller:(CIMInputController *)controller {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -originalString: with sender: %@", sender);
    NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[self.composer originalString]] autorelease];
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::ORIGINALSTRING::%@", string.string);
    return string;
}

- (NSArray *)candidates:(id)sender controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::CANDIDATES");
    return self.composer.candidates;
}

- (void)candidateSelected:(NSAttributedString *)candidateString controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::CANDIDATESELECTED::%@", candidateString);
    CIMSharedInputManager.inputting = YES;
    [self.composer candidateSelected:candidateString];
    [self commitComposition:self.inputClient controller:controller];
    CIMSharedInputManager.inputting = NO;
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::CANDIDATESELECTIONCHANGED::%@", candidateString);
    [self.composer candidateSelectionChanged:candidateString];
    [self updateComposition:controller];
}

@end


@implementation CIMInputReceiver (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(id)sender {
    dlog(DEBUG_LOGGING, @"LOGGING::CHECK::RECOGNIZEDEVENTS");
    // NSFlagsChangeMask는 -handleEvent: 에서만 동작
    return NSKeyDownMask | NSFlagsChangedMask | NSLeftMouseDownMask | NSRightMouseDownMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask;
}

//! @brief 자판 전환을 감지한다.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender controller:(CIMInputController *)controller {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::CHANGE-%lu-%@", tag, value);
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -setValue:forTag:client: with value: %@ / tag: %lx / sender: %@ / client: %@", value, tag, sender, controller.client);
    switch (tag) {
        case kTextServiceInputModePropertyTag:
            if (![value isEqualToString:self.composer.inputMode]) {
                dassert(sender != nil);
                [self commitComposition:sender controller:controller];
                self.composer.inputMode = value;
            }
            break;
        default:
            dlog(DEBUG_INPUTCONTROLLER, @"**** UNKNOWN TAG %ld !!! ****", tag);
            break;
    }
}

@end


@implementation CIMInputController

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self != nil) {
        dlog(DEBUG_INPUTCONTROLLER, @"**** NEW INPUT CONTROLLER INIT **** WITH SERVER: %@ / DELEGATE: %@ / CLIENT: %@", server, delegate, inputClient);
        self->_receiver = [[CIMInputReceiver alloc] initWithServer:server delegate:delegate client:inputClient];
    }
    return self;
}

- (void)dealloc {
    [self->_receiver release];
    [super dealloc];
}

- (CIMComposer *)composer {
    return self->_receiver.composer;
}

@end


#pragma - IMKServerInput Protocol

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
/*
@implementation CIMInputController (IMKServerInputTextData)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@(%@)", string, keyCode, flags, [[self client] bundleIdentifier], [[self client] class]);
    
    BOOL processed = [self->_receiver inputController:self inputText:string key:keyCode modifiers:flags client:sender] > CIMInputTextProcessResultNotProcessed;
    return processed;
}

@end
*/

@implementation CIMInputController (IMKServerInputHandleEvent)

// Receiving Events Directly from the Text Services Manager
- (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
    if ([event type] != NSKeyDown) {
        dlog(DEBUG_LOGGING, @"LOGGING::NONKEYDOWN::%@/%@", event, sender);
        dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -handleEvent:client: with event: %@ / sender: %@", event, sender);
        return NO;
    }
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, [event keyCode], [event modifierFlags], [event characters], [event charactersIgnoringModifiers], [[self client] bundleIdentifier]);
    BOOL processed = [self->_receiver inputController:self inputText:[event characters] key:[event keyCode] modifiers:[event modifierFlags] client:sender] > CIMInputTextProcessResultNotProcessed;
    dlog(DEBUG_LOGGING, @"LOGGING::PROCESSED::%d", processed);
    return processed;
}

@end

/*
@implementation CIMInputController (IMKServerInputKeyBinding)

- (BOOL)inputText:(NSString *)string client:(id)sender {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:client: with string: %@ / client: %@", string, sender);
    return NO;
}

- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -didCommandBySelector: with selector: %@", aSelector);
    
    return NO;
}

@end
*/

@implementation CIMInputController (IMKServerInput)

// Committing a Composition
// 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
- (void)commitComposition:(id)sender {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::COMMIT-RAW?");
    [self->_receiver commitCompositionEvent:sender controller:self];
    //[super commitComposition:sender];
}

#if DEBUG
- (void)updateComposition {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::UPDATE-RAW?");
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -updateComposition");
    [self->_receiver updateCompositionEvent:self];
    [super updateComposition];
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -updateComposition ended");
}
#endif

- (void)cancelComposition {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::CANCEL-RAW?");
    [self->_receiver cancelCompositionEvent:self];
    [super cancelComposition];
}

// Getting Input Strings and Candidates
// 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
- (id)composedString:(id)sender {
    return [self->_receiver composedString:sender controller:self];
}

- (NSAttributedString *)originalString:(id)sender {
    return [self->_receiver originalString:sender controller:self];
}

- (NSArray *)candidates:(id)sender {
    return [self->_receiver candidates:sender controller:self];
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    [self->_receiver candidateSelected:candidateString controller:self];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    [self->_receiver candidateSelectionChanged:candidateString controller:self];
}

@end

@implementation CIMInputController (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(id)sender {
    return [self->_receiver recognizedEvents:sender];
}

//! @brief 자판 전환을 감지한다.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender {
    [self->_receiver setValue:value forTag:tag client:sender controller:self];
}

@end

@implementation CIMInputController (IMKMouseHandling)

/*!
    @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
*/
- (BOOL)mouseDownOnCharacterIndex:(NSUInteger)index coordinate:(NSPoint)point withModifier:(NSUInteger)flags continueTracking:(BOOL *)keepTracking client:(id)sender {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::MOUSEDOWN");
    [self->_receiver commitComposition:sender controller:self];
    return NO;
}

@end

@implementation CIMInputController (IMKCustomCommands)

- (NSMenu *)menu {
    return [CIMAppDelegate menu];
}

@end

@implementation CIMInputController (CIMMenu)

- (void)showStandardAboutPanel:(id)sender {
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (void)showPreferences:(id)sender {
    [super showPreferences:sender];
}

@end


#if DEBUG

@implementation CIMMockInputController

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super init];
    if (self != nil) {
        self->_receiver = [[CIMInputReceiver alloc] initWithServer:server delegate:delegate client:inputClient];
    }
    return self;
}

- (void)repoduceTextLog:(NSString *)text {
    for (NSString *row in [text componentsSeparatedByString:@"\n"]) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"LOGGING::([A-Z]+)::(.*)" options:0 error:&error];
        if (error) {
            @throw [NSException exceptionWithName:@"CIMMockInputControllerLogParserError" reason:@"Log is not readable format" userInfo:nil];
        }
        NSArray *matches = [regex matchesInString:row options:0 range:NSRangeFromString(row)];
        NSString *type = matches[1];
        NSString *data = matches[2];
        NSLog(@"test: %@ %@", type, data);
    }
}

- (id)client {
    return self->_receiver.inputClient;
}

- (CIMComposer *)composer {
    return self->_receiver.composer;
}

@end


@implementation CIMMockInputController (IMKServerInputTextData)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@(%@)", string, keyCode, flags, [[self client] bundleIdentifier], [[self client] class]);

    BOOL processed = [self->_receiver inputController:(id)self inputText:string key:keyCode modifiers:flags client:sender] > CIMInputTextProcessResultNotProcessed;
    if (!processed) {
        //[self cancelComposition];
    }
    return processed;
}

// Committing a Composition
// 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
- (void)commitComposition:(id)sender {
    [self->_receiver commitCompositionEvent:sender controller:(id)self];
    { // COMMIT triggered

    }
}

- (void)updateComposition {
    [self->_receiver updateCompositionEvent:(id)self];
    { // super
        NSTextView *client = self->_receiver.inputClient;
        dassert(client);
        NSString *composed = [self composedString:client];
        NSRange markedRange = [client markedRange];
        NSRange newMarkedRange = NSMakeRange(markedRange.location, composed.length);
        if (markedRange.length > 0 || newMarkedRange.length > 0) {
            [client setMarkedText:composed selectedRange:newMarkedRange replacementRange:markedRange]; // to show
            BOOL hasMarked1 = client.hasMarkedText;
            [client setSelectedRange:newMarkedRange];
            BOOL hasMarked2 = client.hasMarkedText;
            dassert(hasMarked1 == hasMarked2);
        }
    }
}

- (void)cancelComposition {
    [self->_receiver cancelCompositionEvent:(id)self];
    { // CANCEL triggered
        id client = self->_receiver.inputClient;
        NSRange markedRange = [client markedRange];
        [client setMarkedText:@"" selectedRange:NSMakeRange(markedRange.location, 0) replacementRange:markedRange];
    }
}

// Getting Input Strings and Candidates
// 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
- (id)composedString:(id)sender {
    return [self->_receiver composedString:sender controller:(id)self];
}

- (NSAttributedString *)originalString:(id)sender {
    return [self->_receiver originalString:sender controller:(id)self];
}

- (NSArray *)candidates:(id)sender {
    return [self->_receiver candidates:sender controller:(id)self];
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    [self->_receiver candidateSelected:candidateString controller:(id)self];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    [self->_receiver candidateSelectionChanged:candidateString controller:(id)self];
}

@end


@implementation CIMMockInputController (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(id)sender {
    return [self->_receiver recognizedEvents:sender];
}

//! @brief 자판 전환을 감지한다.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender {
    [self->_receiver setValue:value forTag:tag client:sender controller:(id)self];
}

@end

#endif
