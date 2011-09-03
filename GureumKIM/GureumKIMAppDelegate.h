//
//  GureumKIMAppDelegate.h
//  GureumKIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GureumInputManager;
@interface GureumKIMAppDelegate : NSObject <NSApplicationDelegate> {
@private
    IBOutlet GureumInputManager *inputManager;
    IBOutlet NSMenu *menu;
}

@property(nonatomic, readonly) GureumInputManager *inputManager;

@end

@interface GureumKIMAppDelegate (SharedObject)

+ (GureumKIMAppDelegate *)sharedAppDelegate;

@end
