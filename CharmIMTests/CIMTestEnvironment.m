//
//  CIMTestEnvironment.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

@implementation CIMInputManager (SharedObject)
 
CIMInputManager *CIMInputManagerSharedObject;
 
+ (void)initialize {
    CIMInputManagerSharedObject = [[self alloc] init];
}
 
+ (CIMInputManager *)sharedManager {
    return CIMInputManagerSharedObject;
}
 
@end

