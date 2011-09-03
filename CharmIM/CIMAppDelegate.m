//
//  CIMAppDelegate.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"
#import "CIMAppDelegate.h"

@implementation CIMAppDelegate
@synthesize inputManager;

@end

@implementation CIMAppDelegate (SharedObject)

+ (CIMAppDelegate *)sharedAppDelegate {
    return [[NSApplication sharedApplication] delegate];
}

@end

// CIMInputManager (SharedObject)의 IM 구현
@implementation CIMInputManager (SharedObject)

+ (CIMInputManager *)sharedManager {
    return [[CIMAppDelegate sharedAppDelegate] inputManager];
}

@end