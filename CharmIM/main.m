//
//  main.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
    
    [[NSApplication sharedApplication] run];
    
    [pool release];
    return 0;
}
