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
#import "CIMInputController.h"
#import "GureumMockObjects.h"

#import "Gureum-Swift.h"


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
//        self.terminal,
//        self.greedy,
    ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test2 {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han2] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"k" key:40 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"r" key:15 modifiers:0];
        XCTAssertEqualObjects(@"한ㄱ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        XCTAssertEqualObjects(@"한글", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"한글 ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        [app inputText:@"g" key:5 modifiers:0];
        XCTAssertEqualObjects(@"한글 ㅎ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㅎ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"k" key:40 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한글 한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"r" key:15 modifiers:0];
        XCTAssertEqualObjects(@"한글 한ㄱ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        XCTAssertEqualObjects(@"한글 한글", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"\n" key:36 modifiers:0];
        if (app != self.terminal) {
            XCTAssertEqualObjects(@"한글 한글\n", app.client.string,@"buffer: %@ app: (%@)", app.client.string, app);
        }
    }
}

- (void)test3final {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"k" key:40 modifiers:0];
        XCTAssertEqualObjects(@"한ㄱ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"한글", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"한글 ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        [app inputText:@"m" key:46 modifiers:0];
        XCTAssertEqualObjects(@"한글 ㅎ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㅎ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한글 한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"k" key:40 modifiers:0];
        XCTAssertEqualObjects(@"한글 한ㄱ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㄱ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"한글 한글", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"글", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"\n" key:36 modifiers:0];
        if (app != self.terminal) {
            XCTAssertEqualObjects(@"한글 한글\n", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        }
    }
}

- (void)testCapslockRoman {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier qwerty] forTag:kTextServiceInputModePropertyTag client:app.client];

        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"r" key:15 modifiers:0];
        [app inputText:@"2" key:19 modifiers:0];
        XCTAssertEqualObjects(@"mr2", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);

        app.client.string = @"";
        [app inputText:@"m" key:46 modifiers:0x10000];
        [app inputText:@"r" key:15 modifiers:0x10000];
        [app inputText:@"2" key:19 modifiers:0x10000];
        XCTAssertEqualObjects(@"MR2", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testCapslockHangul {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];

        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"r" key:15 modifiers:0];
        [app inputText:@"2" key:19 modifiers:0];
        XCTAssertEqualObjects(@"했", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"했", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        [app inputText:@" " key:49 modifiers:0];

        app.client.string = @"";
        [app inputText:@"m" key:46 modifiers:0x10000];
        [app inputText:@"r" key:15 modifiers:0x10000];
        [app inputText:@"2" key:19 modifiers:0x10000];
        XCTAssertEqualObjects(@"했", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"했", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testBlock {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier qwerty] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        [app inputText:@"k" key:40 modifiers:0];
        [app inputText:@"g" key:5 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"mfskgw", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];

        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        [app inputText:@"" key:123 modifiers:10616832];
        //XCTAssertEqualObjects(@"fskgw ", app.client.selectedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testLayoutChange {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier qwerty] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:nil key:-1 modifiers:NSAlphaShiftKeyMask];

        [app inputText:@" " key:kVK_Space modifiers:NSShiftKeyMask];
        [app inputText:@" " key:kVK_Space modifiers:NSShiftKeyMask];
        XCTAssertEqualObjects(@"", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
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

- (void)test3Number {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"K" key:40 modifiers:131072];
        XCTAssertEqualObjects(@"2", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testHanjaSyllable {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"m" key:46 modifiers:0];
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        XCTAssertEqualObjects(@"한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"\n" key:36 modifiers:524288];
        XCTAssertEqualObjects(@"한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"韓: 나라 이름 한"]];
        XCTAssertEqualObjects(@"한", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"한", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"韓: 나라 이름 한"]];
        XCTAssertEqualObjects(@"韓", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testHanjaWord {
    for (VirtualApp *app in @[self.moderate]) {
        if (app == self.terminal) {
            continue; // 터미널은 한자 모드 진입이 불가
        }
        app.client.string = @"";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];
        // hanja search mode
        [app inputText:@"\n" key:36 modifiers:524288];
        [app inputText:@"i" key:34 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"물", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"물 ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"n" key:45 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        XCTAssertEqualObjects(@"물 수", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"물 수", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        // 연달아 다음 한자 입력에 들어간다
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"水 ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        [app inputText:@"i" key:34 modifiers:0];
        XCTAssertEqualObjects(@"水 ㅁ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"ㅁ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        [app inputText:@"b" key:11 modifiers:0];
        [app inputText:@"w" key:13 modifiers:0];
        XCTAssertEqualObjects(@"水 물", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"水 물 ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"n" key:45 modifiers:0];
        [app inputText:@"b" key:11 modifiers:0];
        XCTAssertEqualObjects(@"水 물 수", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水 물 수", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水 水", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testHanjaSelection {
    for (VirtualApp *app in @[self.moderate]) {
        if (app == self.terminal) {
            continue; // 터미널은 한자 모드 진입이 불가
        }
        app.client.string = @"물 수";
        [app.controller setValue:[GureumInputSourceIdentifier han3Final] forTag:kTextServiceInputModePropertyTag client:app.client];
        // hanja search mode
        [app.client setSelectedRange:NSMakeRange(0, 3)];
        XCTAssertEqualObjects(@"물 수", app.client.selectedString, @"");

        [app inputText:@"\n" key:36 modifiers:524288];
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"물 수", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"물 수", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"水: 물 수, 고를 수"]];
        XCTAssertEqualObjects(@"水", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

@end
