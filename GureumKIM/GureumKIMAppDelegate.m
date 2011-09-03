//
//  GureumKIMAppDelegate.m
//  GureumKIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumInputManager.h"
#import "GureumKIMAppDelegate.h"

@implementation GureumKIMAppDelegate
@synthesize inputManager;

@end

@implementation GureumKIMAppDelegate (SharedObject)

+ (GureumKIMAppDelegate *)sharedAppDelegate {
    return [[NSApplication sharedApplication] delegate];
}

@end

// CIMInputManager (SharedObject)의 IM 구현
@implementation GureumInputManager (SharedObject)

+ (GureumInputManager *)sharedManager {
    return [[GureumKIMAppDelegate sharedAppDelegate] inputManager];
}

@end