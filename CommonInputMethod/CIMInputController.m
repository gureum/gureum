//
//  CIMInputController.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

@import Cocoa;
@import Carbon;

#import "CIMCommon.h"

#import "CIMInputController.h"

#import "TISInputSource.h"
#import "Gureum-Swift.h"

NS_ASSUME_NONNULL_BEGIN

#define DEBUG_INPUTCONTROLLER FALSE
#define DEBUG_LOGGING FALSE

#define CIMSharedInputManager CIMAppDelegate.sharedInputManager
#define CIMAppDelegate ((NSObject<CIMApplicationDelegate> *)[[NSApplication sharedApplication] delegate])

TISInputSource *_USSource() {
    static NSString *mainSourceID = @"com.apple.keylayout.US";
    static TISInputSource *source = nil;
    if (source == nil) {
        NSArray *mainSources = [TISInputSource sourcesWithProperties:@{(NSString *)kTISPropertyInputSourceID: mainSourceID} includeAllInstalled:YES];
        dlog(1, @"main sources: %@", mainSources);
        source = mainSources[0];
    }
    return source;
}




@implementation CIMInputController

@synthesize receiver=_receiver, ioConnect=_ioConnect, capsLockPressed=_capsLockPressed;

- (instancetype)initWithServer:(nullable IMKServer *)server delegate:(nullable id)delegate client:(nullable id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self != nil) {
        dlog(DEBUG_INPUTCONTROLLER, @"**** NEW INPUT CONTROLLER INIT **** WITH SERVER: %@ / DELEGATE: %@ / CLIENT: %@", server, delegate, inputClient);
        self->_receiver = [[CIMInputReceiver alloc] initWithServer:server delegate:delegate client:inputClient controller:self];

        IOService* service = [[IOService alloc] initWithName:@(kIOHIDSystemClass) error:NULL];
        self->_ioConnect = [service openWithOwningTask:mach_task_self_ type:kIOHIDParamConnectType];
        dlog(DEBUG_INPUTCONTROLLER, @"io_connect: %@", self->_ioConnect);

        self->_hidManager = [IOHIDManagerBridge capsLockManager];
        CFRetain(self->_hidManager);
        
        // Set input value callback
        IOHIDManagerRegisterInputValueCallback(self->_hidManager, handleInputValueCallback, (__bridge void *)(self));
        IOHIDManagerScheduleWithRunLoop(self->_hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOReturn ioReturn = IOHIDManagerOpen(self->_hidManager, kIOHIDOptionsTypeNone);
        if (ioReturn) {
            dlog(DEBUG_INPUTCONTROLLER, @"IOHIDManagerOpen failed");
        }

        self->_capsLockPressed = NO;
    }
    return self;
}

- (void)dealloc {
    IOHIDManagerUnscheduleFromRunLoop(self->_hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDManagerRegisterInputValueCallback(self->_hidManager, nil, nil);
    IOHIDManagerClose(self->_hidManager, kIOHIDOptionsTypeNone);
    CFRelease(self->_hidManager);
}


static void handleInputValueCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDValueRef inIOHIDValueRef) {
    CIMInputController *inputController = (__bridge CIMInputController *)(inContext);
    CFIndex intValue = IOHIDValueGetIntegerValue(inIOHIDValueRef);

    dlog(DEBUG_INPUTCONTROLLER, @"context: %@, caps lock pressed: %lx", inputController, intValue);
    if (intValue == 1) {
        inputController->_capsLockPressed = YES;
    }
}

- (CIMComposer *)composer {
    return self->_receiver.composer;
}

@end


#pragma - IMKServerInput Protocol

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
/*
@implementation CIMInputController (IMKServerInputTextData)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@(%@)", string, keyCode, flags, [[self client] bundleIdentifier], [[self client] class]);
    
    BOOL processed = [self->_receiver inputController:self inputText:string key:keyCode modifiers:flags client:sender] > CIMInputTextProcessResultNotProcessed;
    return processed;
}

@end
*/

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

- (void)updateComposition {
    dlog(DEBUG_LOGGING, @"LOGGING::EVENT::UPDATE-RAW?");
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -updateComposition");
    [self->_receiver updateCompositionEvent:self];
    [super updateComposition];
    dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController -updateComposition ended");
}

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

#if DEBUG

@implementation CIMMockInputController (IMKServerInputTextData)

- (id<IMKTextInput,NSObject>)client {
    return self._receiver.inputClient;
}

- (void)updateComposition {
    [self._receiver updateCompositionEvent:(id)self];
    { // super
        NSTextView *client = self._receiver.inputClient;
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
    [self._receiver cancelCompositionEvent:(id)self];
    { // CANCEL triggered
        id client = self._receiver.inputClient;
        NSRange markedRange = [client markedRange];
        [client setMarkedText:@"" selectedRange:NSMakeRange(markedRange.location, 0) replacementRange:markedRange];
    }
}

// Getting Input Strings and Candidates
// 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
- (id)composedString:(id)sender {
    return [self._receiver composedString:sender controller:(id)self];
}

- (NSAttributedString *)originalString:(id)sender {
    return [self._receiver originalString:sender controller:(id)self];
}

- (NSArray *)candidates:(id)sender {
    return [self._receiver candidates:sender controller:(id)self];
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    [self._receiver candidateSelected:candidateString controller:(id)self];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    [self._receiver candidateSelectionChanged:candidateString controller:(id)self];
}

@end


@implementation CIMMockInputController (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(_Null_unspecified id)sender {
    return [self._receiver recognizedEvents:sender];
}

//! @brief 자판 전환을 감지한다.
- (void)setValue:(_Null_unspecified id)value forTag:(long)tag client:(_Null_unspecified id)sender {
    [self._receiver setValue:value forTag:tag client:sender controller:(id)self];
}

@end

#endif

NS_ASSUME_NONNULL_END
