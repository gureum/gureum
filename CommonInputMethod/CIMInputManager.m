//
//  CIMInputManager.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 15..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

#import "CIMApplicationDelegate.h"
#import "CIMInputHandler.h"
#import "CIMConfiguration.h"

const char CIMInputManagerKeyMapLower[0x33] = {
    'a', 's', 'd', 'f', 'h', 'g', 'z', 'x',
    'c', 'v', 'b',   0, 'q', 'w', 'e', 'r',
    'y', 't', '1', '2', '3', '4', '6', '5',
    '=', '9', '7', '-', '8', '0', ']', 'o',
    'u', '[', 'i', 'p',   0, 'l', 'j','\'',
    'k', ';','\\', ',', '/', 'n', 'm', '.',
    0,   0, '`',
};
const char CIMInputManagerKeyMapUpper[0x33] = {
    'A', 'S', 'D', 'F', 'H', 'G', 'Z', 'X',
    'C', 'V', 'B',   0, 'Q', 'W', 'E', 'R',
    'Y', 'T', '!', '@', '#', '$', '^', '%',
    '+', '(', '&', '_', '*', ')', '}', 'O',
    'U', '{', 'I', 'P',   0, 'L', 'J', '"',
    'K', ':', '|', '<', '?', 'N', 'M', '>',
    0,   0, '~',
};

@implementation CIMInputManager
@synthesize server, candidates, configuration, handler, sharedComposer;
@synthesize inputting;

#define DEBUG_INPUTMANAGER TRUE

- (id)init
{
    self = [super init];
    dlog(DEBUG_INPUTMANAGER, @"** CharmInputManager Init: %@", self);
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *connectionName = [[mainBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];
        self->server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:[mainBundle bundleIdentifier]];
        self->candidates = [[IMKCandidates alloc] initWithServer:self->server panelType:kIMKSingleColumnScrollingCandidatePanel];
        self->handler = [[CIMInputHandler alloc] initWithManager:self];
        self->configuration = [CIMConfiguration userDefaultConfiguration];
        self->sharedComposer = [CIMAppDelegate composerWithServer:nil client:nil];
        dlog(DEBUG_INPUTMANAGER, @"\tserver: %@ / candidates: %@ / handler: %@", self->server, self->candidates, self->handler);
       
    }
    return self;
}

- (void)dealloc
{
    [self->sharedComposer release];
    [self->configuration release];
    [self->handler release];
    [self->candidates release];
    [self->server release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ server:%@ candidates:%@ handler:%@ configuration:%@>", NSStringFromClass([self class]), self->server, self->candidates, self->handler, self->configuration];
}

#pragma - IMKServerInputTextData

//  일단 받은 입력은 모두 핸들러로 넘겨준다.
- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    if (flags & NSAlternateKeyMask) {
        switch (self.configuration->optionKeyBehavior) {
            case 0: {
                // default
                dlog(DEBUG_INPUTMANAGER, @" ** ESCAPE from option-key default behavior");
                return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
            }   break;
            case 1: {
                // ignore
                if (keyCode < 0x33) {
                char key[2] = {0, 0};
                    key[0] = (flags & NSAlphaShiftKeyMask || flags & NSShiftKeyMask) ? CIMInputManagerKeyMapUpper[keyCode] : CIMInputManagerKeyMapLower[keyCode];
                    string = [NSString stringWithUTF8String:key];
                }
            }   break;
        }
    }
    return [self->handler inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
}

@end
