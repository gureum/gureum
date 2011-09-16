//
//  CIMTestEnvironment.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CharmInputManager.h"

@implementation CharmInputManager (SharedObject)
 
CharmInputManager *CharmInputManagerSharedObject;
 
+ (void)initialize {
    CharmInputManagerSharedObject = [[self alloc] init];
}
 
+ (CharmInputManager *)sharedManager {
    return CharmInputManagerSharedObject;
}
 
@end

