//
//  GureumPreferencesWindowController.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 22..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GureumPreferencesWindowController : NSWindowController<NSToolbarDelegate> {
@private
    IBOutlet NSTabView *contentTabView;
}

- (IBAction)selectTab:(id)sender;

@end
