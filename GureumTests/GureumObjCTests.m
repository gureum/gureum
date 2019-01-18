//
//  GureumTests.m
//  GureumTests
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import XCTest;

#import "NSPrefPaneBundle.h"
#import "Gureum-Swift.h"


@interface GureumObjCTests : XCTestCase

@end

@implementation GureumObjCTests

- (void)testIPMDServerClientWrapper {
    Class IPMDServerClientWrapper = NSClassFromString(@"IPMDServerClientWrapper");
    XCTAssertTrue(IPMDServerClientWrapper != Nil);
    unsigned count = 0;
    Method *methods = class_copyMethodList(IPMDServerClientWrapper, &count);
    for (int i = 0; i < count; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *name = NSStringFromSelector(selector);
        NSLog(@"IPMDServerClientWrapper selector: %@", name);
    }
}

@end
