//
//  GureumTests.m
//  GureumTests
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import XCTest;
@import PreferencePanes;

#import "CIMInputController.h"
#import "GureumMockObjects.h"

#import "Gureum-Swift.h"




@interface GureumObjCTests : XCTestCase

@property(nonatomic,strong) NSArray *apps;
@property(nonatomic,strong) VirtualApp *moderate, *terminal, *greedy;

@end


static NSString *domainName = @"org.youknowone.Gureum";
static NSDictionary<NSString *, id> *oldConfiguration;

@implementation GureumObjCTests

+ (void)setUp {
    [super setUp];
    oldConfiguration = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
}

+ (void)tearDown {
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:oldConfiguration forName:domainName];
    [super tearDown];
}

- (void)setUp {
    [super setUp];

    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    self.moderate = [[ModerateApp alloc] init];
    self.terminal = [[TerminalApp alloc] init];
    self.greedy = [[GreedyApp alloc] init];


    self.apps = @[
        self.moderate,
//        self.terminal,
//        self.greedy,
    ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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
