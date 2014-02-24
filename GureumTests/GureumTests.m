//
//  GureumTests.m
//  GureumTests
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <objc/runtime.h>
#import <XCTest/XCTest.h>
#import "CIMCommon.h"
#import "GureumComposer.h"
#import "CIMInputController.h"
#import "GureumMockObjects.h"


@interface GureumTests : XCTestCase

@property(nonatomic,strong) NSArray *apps;
@property(nonatomic,strong) VirtualApp *moderate, *terminal, *greedy;

@end


@implementation GureumTests

- (void)setUp {
    [super setUp];

    self.moderate = [[ModerateApp alloc] init];
    self.terminal = [[TerminalApp alloc] init];
    self.greedy = [[GreedyApp alloc] init];


    self.apps = @[
        self.moderate,
        self.terminal,
        self.greedy,
    ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEvent {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"k" key:40 modifiers:0];
        XCTAssertEqualObjects(@"한ㄱ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"한글", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"한글 \u200b", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"\u200b", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);

        [app inputText:@"m" key:46 modifiers:0];
        XCTAssertEqualObjects(@"한글 ㅎ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"ㅎ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한글 한", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"k" key:40 modifiers:0];
        XCTAssertEqualObjects(@"한글 한ㄱ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"한글 한글", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"\n" key:36 modifiers:0];
        if (app != self.terminal) {
            XCTAssertEqualObjects(@"한글 한글\n", app.client.string,@"app: %@ buffer: (%@)", app, app.client.string);
        }
    }
}

- (void)testBlock {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierQwerty forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        [app inputText:@"k" key:40 modifiers:0];
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"mfskgw", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@" " key:49 modifiers:0];

        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        //XCTAssertEqualObjects(@"fskgw ", app.client.selectedString, @"app: %@ buffer: (%@)", app, app.client.string);
    }
}

- (void)testLayoutChange {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierQwerty forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@" " key:49 modifiers:131072];
        [app inputText:@" " key:49 modifiers:131072];
        XCTAssertEqualObjects(@"\u200b", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
    }
}

- (void)testIPMDServerClientWrapper {
    Class IPMDServerClientWrapper = NSClassFromString(@"IPMDServerClientWrapper");
    dassert(IPMDServerClientWrapper != Nil);
    unsigned count = 0;
    Method *methods = class_copyMethodList(IPMDServerClientWrapper, &count);
    for (int i = 0; i < count; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *name = NSStringFromSelector(selector);
        NSLog(@"IPMDServerClientWrapper selector: %@", name);
    }
}

- (void)testNumber {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"K" key:40 modifiers:131072];
        XCTAssertEqualObjects(@"2", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
    }
}

- (void)testHanjaSyllable {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"\n" key:36 modifiers:524288];
        XCTAssertEqualObjects(@"한", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"韓: 나라 이름 한"]];
        XCTAssertEqualObjects(@"韓", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"韓", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"韓: 나라 이름 한"]];
        XCTAssertEqualObjects(@"韓", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
    }
}

- (void)testHanjaWord {
    for (VirtualApp *app in @[self.moderate]) {
        if (app == self.terminal) {
            continue; // 터미널은 한자 모드 진입이 불가
        }
        app.client.string = @"";
        [app.controller setValue:kGureumInputSourceIdentifierHan3Final forTag:kTextServiceInputModePropertyTag client:app.client];
        // hanja search mode
        [app inputText:@"\n" key:36 modifiers:524288];
        [app inputText:@"i" key:34 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"물", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"물 ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물 ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"n" key:45 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        XCTAssertEqualObjects(@"물 수", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"水", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);

        // 연달아 다음 한자 입력에 들어간다
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"水 ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);

        [app inputText:@"i" key:34 modifiers:0];
        XCTAssertEqualObjects(@"水 ㅁ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"ㅁ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);

        [app inputText:@"b" key:11 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"水 물", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"水 물 ", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물 ", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app inputText:@"n" key:45 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        XCTAssertEqualObjects(@"水 물 수", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水 水", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"水", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水 水", app.client.string, @"app: %@ buffer: (%@)", app, app.client.string);
        XCTAssertEqualObjects(@"", app.client.markedString, @"app: %@ buffer: (%@)", app, app.client.string);
    }
}

@end
