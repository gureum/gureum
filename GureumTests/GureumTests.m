//
//  GureumTests.m
//  GureumTests
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIMCommon.h"
#import "GureumComposer.h"
#import "CIMInputController.h"

@interface GureumTests : XCTestCase

@property(nonatomic,retain) CIMInputController *controller;
@property(nonatomic,retain) CIMMockClient *client;

@end


@implementation GureumTests

- (void)setUp {
    [super setUp];
    self.controller = (id)[[CIMMockInputController alloc] initWithServer:nil delegate:nil client:nil];
    self.client = [[CIMMockClient alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEvent {
    CIMMockClient *client = self.client;
    [client clearBuffer];
    [self.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:client];
    [self.controller inputText:@"m" key:46 modifiers:0 client:client];
    [self.controller inputText:@"f" key:3 modifiers:0 client:client];
    [self.controller inputText:@"s" key:1 modifiers:0 client:client];
    [self.controller inputText:@"k" key:40 modifiers:0 client:client];
    [self.controller inputText:@"g" key:5 modifiers:0 client:client];
    [self.controller inputText:@"w" key:13 modifiers:0 client:client];
    [self.controller inputText:@" " key:36 modifiers:0 client:client];
    XCTAssertEqualObjects(@"한글 ", self.client.buffer, @"buffer: %@", self.client.buffer);

    [client clearBuffer];
    [self.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:client];
    [self.controller inputText:@"m" key:46 modifiers:0 client:client];
    [self.controller inputText:@"f" key:3 modifiers:0 client:client];
    [self.controller inputText:@"s" key:1 modifiers:0 client:client];
    [self.controller inputText:@"k" key:40 modifiers:0 client:client];
    [self.controller inputText:@"g" key:5 modifiers:0 client:client];
    [self.controller inputText:@"w" key:13 modifiers:0 client:client];
    [self.controller inputText:@"\n" key:36 modifiers:0 client:client];
    XCTAssertEqualObjects(@"한글\n", client.buffer, @"buffer: %@", client.buffer);
}

- (void)testLayoutChange {
    [self.client clearBuffer];
    [self.controller inputText:@" " key:49 modifiers:131072 client:self.client];
    [self.controller inputText:@" " key:49 modifiers:131072 client:self.client];
    XCTAssertEqualObjects(@"", self.client.buffer, @"buffer: %@", self.client.buffer);
}

@end
