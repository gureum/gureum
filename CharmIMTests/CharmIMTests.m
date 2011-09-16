//
//  CharmIMTests.m
//  CharmIMTests
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CharmIMTests.h"

#import "CharmInputManager.h"
#import "HGInputContext.h"

@implementation CharmIMTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTestEnvironment
{
    CharmInputManager *inputManager = [CharmInputManager sharedManager];
    STAssertNotNil(inputManager, @"InputManager shared object is not working");
}

- (void)testHGInputContext
{
#define STAssertPreeditString(VALUE) { \
    NSString *s = [inputContext preeditString];    \
    STAssertTrue([s isEqualToString:VALUE], @"Input Context has wrong preedit string: %@", s); \
}
#define STAssertCommitString(VALUE) { \
    NSString *s = [inputContext commitString];    \
    STAssertTrue([s isEqualToString:VALUE], @"Input Context has wrong commit string: %@", s); \
}
#define STAssertFlushString(VALUE) { \
    NSString *s = [inputContext flushString];    \
    STAssertTrue([s isEqualToString:VALUE], @"Input Context has wrong flush string: %@", s); \
}
    
    HGInputContext *inputContext = [[HGInputContext alloc] initWithKeyboardIdentifier:@"2"];
    
    STAssertTrue([inputContext isEmpty], @"Input Context is not empty before input");
    
    STAssertTrue([inputContext process:'g'], @"");
    STAssertPreeditString(@"ㅎ");
    STAssertTrue([inputContext process:'k'], @"");
    STAssertPreeditString(@"하");
    STAssertTrue([inputContext process:'s'], @"");
    STAssertPreeditString(@"한");
    STAssertCommitString(@"");
    STAssertFalse([inputContext isEmpty], @"Input Context is empty after input");
    
    STAssertTrue([inputContext process:'r'], @"");
    STAssertCommitString(@"한");
    STAssertCommitString(@"한"); // 상태 변화는 없다!
    STAssertPreeditString(@"ㄱ");
    STAssertTrue([inputContext process:'m'], @"");
    STAssertPreeditString(@"그");
    STAssertCommitString(@""); // 다음 글자 조합 시작 후 사라짐
    STAssertTrue([inputContext process:'f'], @"");
    STAssertPreeditString(@"글");
    STAssertCommitString(@"");
    STAssertFlushString(@"글");
    STAssertPreeditString(@""); // flush 하여 사라짐
    STAssertFlushString(@""); // flush 할게 없음
    
    STAssertTrue([inputContext process:'g'], @"");
    STAssertPreeditString(@"ㅎ");
    STAssertFalse([inputContext process:' '], @"");
    STAssertPreeditString(@"");
    STAssertCommitString(@"ㅎ");
    
    [inputContext release];
}

- (void)testExample
{

}

@end
