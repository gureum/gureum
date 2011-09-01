//
//  main.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *connectionName = [[mainBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];
    IMKServer *server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:[mainBundle bundleIdentifier]];
    
    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
    
    [[NSApplication sharedApplication] run];
    
    [server release];
    
    [pool release];
    return 0;
}
