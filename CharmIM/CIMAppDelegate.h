//
//  CIMAppDelegate.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CIMInputManager;

@interface CIMAppDelegate : NSObject<NSApplicationDelegate> {
@private
    IBOutlet CIMInputManager *inputManager;
    IBOutlet NSMenu *menu;
}

@property(nonatomic, readonly) CIMInputManager *inputManager;

@end

@interface CIMAppDelegate (SharedObject)

+ (CIMAppDelegate *)sharedAppDelegate;

@end
