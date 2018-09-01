//
//  GureumAppDelegate.h
//  Gureum
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMApplicationDelegate.h"

/*
@interface GureumAppDelegate : NSObject<NSApplicationDelegate, CIMApplicationDelegate> {
  @private
    CIMInputManager *sharedInputManager;
    IBOutlet NSMenu *menu;
}

@property (NS_NONATOMIC_IOSONLY, getter=getRecentVersion, readonly, copy) NSDictionary *recentVersion;
+ (GureumAppDelegate *)sharedAppDelegate;

@end
*/
#define CIMSharedConfiguration CIMAppDelegate.sharedInputManager.configuration
