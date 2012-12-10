//
//  CharmAppDelegate.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 15..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CharmAppDelegate.h"

#import "CIMInputManager.h"
#import "CIMComposer.h"

@implementation CharmAppDelegate
@synthesize menu;

- (CIMInputManager *)sharedInputManager {
    return self->sharedInputManager;
}

- (CIMComposer *)composerWithServer:(IMKServer *)server client:(id)client {
    dlog(TRUE, @"**** New blank composer generated ****");
    CIMComposer *composer = [[CIMBaseComposer alloc] init];
    return [composer autorelease];                         
}

@end