//
//  CIMInputManager.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

#import "CIMConfiguration.h"
#import "CIMInputHandler.h"
#import "CIMHangulComposer.h"

#define DEBUG_INPUTMANAGER TRUE

@implementation CIMInputManager
@synthesize server, candidates, configuration, handler, currentComposer;
@synthesize inputting;

- (id)init
{
    self = [super init];
    ICLog(DEBUG_INPUTMANAGER, @"** CIMInputManager Init: %@", self);
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *connectionName = [[mainBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];
        self->server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:[mainBundle bundleIdentifier]];
        self->candidates = [[IMKCandidates alloc] initWithServer:self->server panelType:kIMKSingleColumnScrollingCandidatePanel];
        self->handler = [[CIMInputHandler alloc] initWithManager:self];
        self->composers = [[NSMutableDictionary alloc] init];
        ICLog(DEBUG_INPUTMANAGER, @"\tserver: %@ / candidates: %@ / handler: %@", self->server, self->candidates, self->handler);

        // 임시로 한글 입력기만 할당
        self->currentComposer = [[CIMHangulComposer alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self->composers release];
    [self->handler release];
    [self->candidates release];
    [self->server release];
    [super dealloc];
}

#pragma - IMKServerInputTextData

//  받은 입력은 모두 핸들러로 넘겨준다.
- (BOOL)inputController:(IMKInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    return [self->handler inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
}

@end
