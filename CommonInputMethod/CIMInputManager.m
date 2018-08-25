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
#import "Gureum-Swift.h"


@implementation CIMInputManager
@synthesize server, candidates, configuration, handler, sharedComposer;
@synthesize inputting;

#define DEBUG_INPUTMANAGER FALSE

- (instancetype)init
{
    self = [super init];
    dlog(DEBUG_INPUTMANAGER, @"** CharmInputManager Init: %@", self);
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *connectionName = mainBundle.infoDictionary[@"InputMethodConnectionName"];
        self->server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:mainBundle.bundleIdentifier];
        self->candidates = [[IMKCandidates alloc] initWithServer:self->server panelType:kIMKSingleColumnScrollingCandidatePanel];
        self->handler = [[CIMInputHandler alloc] initWithManager:self];
        self->configuration = [NSUserDefaults standardUserDefaults];
        self->sharedComposer = [CIMAppDelegate composerWithServer:nil client:nil];
        dlog(DEBUG_INPUTMANAGER, @"\tserver: %@ / candidates: %@ / handler: %@", self->server, self->candidates, self->handler);
       
    }
    return self;
}

- (void)dealloc {
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
- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    assert([[controller className] hasSuffix:@"InputController"]);
    self.needsFakeComposedString = NO;
    CIMInputTextProcessResult handled = [self->handler inputController:controller inputText:string key:keyCode modifiers:flags client:sender];

    return handled;
}

@end
