//
//  CIMInputController.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

@import Cocoa;
@import Carbon;

#import "CIMInputController.h"

#import "TISInputSource.h"
#import "Gureum-Swift.h"

NS_ASSUME_NONNULL_BEGIN

#define DEBUG_INPUTCONTROLLER FALSE
#define DEBUG_LOGGING FALSE

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

#if DEBUG

@implementation CIMMockInputController (IMKServerInputTextData)

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
- (id _Null_unspecified)composedString:(id _Null_unspecified)sender {
    return [self._receiver composedString:sender controller:(id)self];
}

- (NSAttributedString *_Null_unspecified)originalString:(id _Null_unspecified)sender {
    return [self._receiver originalString:sender controller:(id)self];
}

- (NSArray *_Null_unspecified)candidates:(id _Null_unspecified)sender {
    return [self._receiver candidates:sender controller:(id)self];
}

- (void)candidateSelected:(NSAttributedString *_Null_unspecified)candidateString {
    [self._receiver candidateSelected:candidateString controller:(id)self];
}

- (void)candidateSelectionChanged:(NSAttributedString *_Null_unspecified)candidateString {
    [self._receiver candidateSelectionChanged:candidateString controller:(id)self];
}

@end


@implementation CIMMockInputController (IMKStateSetting)

//! @brief  마우스 이벤트를 잡을 수 있게 한다.
- (NSUInteger)recognizedEvents:(_Null_unspecified id)sender {
    return [self._receiver recognizedEvents:sender];
}

//! @brief 자판 전환을 감지한다.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender {
    [self._receiver setValue:value forTag:tag client:sender controller:(id)self];
}

@end

#endif

NS_ASSUME_NONNULL_END
