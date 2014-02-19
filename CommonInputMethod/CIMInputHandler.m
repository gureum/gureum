//
//  CIMInputHandler.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

#import "CIMInputHandler.h"
#import "CIMInputController.h"
#import "CIMComposer.h"
#import "CIMConfiguration.h"

#define DEBUG_INPUTHANDLER TRUE

@implementation CIMInputHandler
@synthesize manager;

- (id)initWithManager:(CIMInputManager *)aManager {
    self = [super init];
    dlog(DEBUG_INPUTHANDLER, @"** CIMInputHandler inited: %@ / with manage: %@", self, aManager);
    if (self) {
        self->manager = aManager;
    }
    return self;
}

- (void)setManager:(CIMInputManager *)aManager {
    self->manager = aManager;
}

#pragma - IMKServerInputTextData

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    // 입력기용 특수 커맨드 우선 처리
    CIMInputTextProcessResult result = [controller.composer inputController:controller commandString:string key:keyCode modifiers:flags client:sender];
    if (result == CIMInputTextProcessResultNotProcessedAndNeedsCommit) {
        return result;
    }
    if (result == CIMInputTextProcessResultProcessed) {
        goto finalize;
    }

    // 옵션 키 변환 처리
    if (flags & NSAlternateKeyMask) {
        switch (self.manager.configuration->optionKeyBehavior) {
            case 0: {
                // default
                dlog(DEBUG_INPUTHANDLER, @" ** ESCAPE from option-key default behavior");
                return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
            }   break;
            case 1: {
                // ignore
                if (keyCode < 0x33) {
                    char key[2] = {0, 0};
                    key[0] = (flags & NSAlphaShiftKeyMask || flags & NSShiftKeyMask) ? CIMKeyMapUpper[keyCode] : CIMKeyMapLower[keyCode];
                    string = @(key);
                }
            }   break;
        }
    }

    // 특정 애플리케이션에서 커맨드/옵션 키 입력을 선점하지 못하는 문제를 회피한다
    if (flags & (NSCommandKeyMask|NSAlternateKeyMask)) {
        dlog(TRUE, @"-- CIMInputHandler -inputText: Command/Option key input / returned NO");
        return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
    }
    
    result = [controller.composer inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
    
finalize:
    dlog(FALSE, @"******* FINAL STATE: %d", result);
    // 합성 후보가 있다면 보여준다
    if (controller.composer.hasCandidates) {
        IMKCandidates *candidates = self.manager.candidates;
        [candidates updateCandidates];
        [candidates show:kIMKLocateCandidatesLeftHint];
    }
    return result;
}

@end