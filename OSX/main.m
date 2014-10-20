//
//  main.m
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

int main(int argc, char *argv[]) {
    @autoreleasepool {
        dlog(TRUE, @"******* CharmIM initialized! *******");
        NSString *mainNibName = [[NSBundle mainBundle] infoDictionary][@"NSMainNibFile"];
        if ([NSBundle loadNibNamed:mainNibName owner:[NSApplication sharedApplication]] == NO) {
            NSLog(@"!! CharmIM fails to load Main Nib File !!");
        }
        dlog(TRUE, @"****   Main bundle %@ loaded   ****", mainNibName);
        
        [[NSApplication sharedApplication] run];
        
        dlog(TRUE, @"******* CharmIM finalized! *******");
    }
    return 0;
}
