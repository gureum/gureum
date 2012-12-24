//
//  GureumAppDelegate.h
//  GureumKIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMApplicationDelegate.h"

@interface GureumAppDelegate : NSObject <NSApplicationDelegate, CIMApplicationDelegate> {
@private
    CIMInputManager *sharedInputManager;
    IBOutlet NSMenu *menu;
}

- (NSDictionary *)getRecentVersion;
+ (GureumAppDelegate *)sharedAppDelegate;

@end

#define CIMSharedConfiguration CIMAppDelegate.sharedInputManager.configuration