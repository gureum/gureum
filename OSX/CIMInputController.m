//
//  InputController.m
//  Gureum
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

@import Cocoa;
@import Carbon;

#import "TISInputSource.h"
#import "GureumCore-Swift.h"

NS_ASSUME_NONNULL_BEGIN

#define DEBUG_INPUTCONTROLLER FALSE
#define DEBUG_LOGGING FALSE

TISInputSource *_USSource() {
    static NSString *mainSourceID = @"com.apple.keylayout.US";
    static TISInputSource *source = nil;
    if (source == nil) {
        NSArray *mainSources = [TISInputSource sourcesWithProperties:@{(NSString *)kTISPropertyInputSourceID: mainSourceID} includeAllInstalled:YES];
        dlog(1, @"main sources: %@", mainSources);
        source = mainSources[0];
    }
    return source;
}

NS_ASSUME_NONNULL_END
