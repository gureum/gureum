//
//  GureumAppDelegate.m
//  GureumKIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumAppDelegate.h"

#import "CIMInputManager.h"
#import "GureumComposer.h"

#import "GureumPreferencesWindowController.h"

@implementation GureumAppDelegate
@synthesize menu;

- (void)awakeFromNib {
    self->sharedInputManager = [[CIMInputManager alloc] init];
}

- (void)dealloc {
    [self->sharedInputManager release];
    [super dealloc];
}

- (CIMInputManager *)sharedInputManager {
    return self->sharedInputManager;
}

- (CIMComposer *)composerWithServer:(IMKServer *)server client:(id)client {
    ICLog(TRUE, @"**** New blank composer generated ****");
    CIMComposer *composer = [[GureumComposer alloc] init];
    return [composer autorelease];                         
}

@end
