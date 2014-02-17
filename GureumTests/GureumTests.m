//
//  CharmIMTests.m
//  CharmIMTests
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumTests.h"

#import "GureumComposer.h"

@implementation CharmIMTests

- (void)setUp {
    [super setUp];

    self->controller = (id)[[CIMMockInputController alloc] initWithServer:nil delegate:nil client:nil];
    self->client = [[CIMMockClient alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEvent {
    [self->controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:client];
    [self->controller inputText:@"m" key:46 modifiers:0 client:client];
    [self->controller inputText:@"f" key:3 modifiers:0 client:client];
    [self->controller inputText:@"s" key:1 modifiers:0 client:client];
    [self->controller inputText:@"k" key:40 modifiers:0 client:client];
    [self->controller inputText:@"g" key:5 modifiers:0 client:client];
    [self->controller inputText:@"w" key:13 modifiers:0 client:client];
    [self->controller inputText:@"\n" key:36 modifiers:0 client:client];
    STAssertEqualObjects(@"한글", client.buffer, @"buffer: %@", client.buffer);
}

@end
