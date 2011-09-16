//
//  CharmAppDelegate.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 15..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMApplicationDelegate.h"

@interface CharmAppDelegate : NSObject<CIMApplicationDelegate> {
@private
    IBOutlet CIMInputManager *sharedInputManager;
    IBOutlet NSMenu *menu;
}

@end
