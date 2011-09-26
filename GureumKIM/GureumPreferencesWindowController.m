//
//  GureumPreferences.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 22..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumPreferencesWindowController.h"


@implementation GureumPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark -

- (void)selectTab:(NSToolbarItem *)sender {
    [self->contentTabView selectTabViewItemWithIdentifier:[sender itemIdentifier]];
}

#pragma mark NSToolbar delegate

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    return YES;
}

@end
