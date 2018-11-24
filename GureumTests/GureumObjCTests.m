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


@interface NSPrefPaneBundle: NSObject

- (instancetype)initWithPath:(id)arg1;
- (BOOL)instantiatePrefPaneObject;
- (NSPreferencePane *)prefPaneObject;

@end


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

- (void)testPreferencePane {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"prefPane"];
    NSPrefPaneBundle *bundle = [[NSPrefPaneBundle alloc] initWithPath:path];
    BOOL loaded = [bundle instantiatePrefPaneObject];
    XCTAssertTrue(loaded);
    
}

- (void)test2 {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.han2" forTag:kTextServiceInputModePropertyTag client:app.client];
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

- (void)testCapslockHangul {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.han3final" forTag:kTextServiceInputModePropertyTag client:app.client];

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

- (void)testLayoutChange {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.qwerty" forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:nil key:-1 modifiers:NSEventModifierFlagCapsLock];

        [app inputText:@" " key:kVK_Space modifiers:NSEventModifierFlagShift];
        [app inputText:@" " key:kVK_Space modifiers:NSEventModifierFlagShift];
        XCTAssertEqualObjects(@"", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
    }
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

- (void)testRomanEmoticon {
    for (VirtualApp *app in @[self.moderate]) {
        if (app == self.terminal) {
            continue; // 터미널은 이모티콘 모드 진입이 불가
        }
        app.client.string = @"";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.qwerty" forTag:kTextServiceInputModePropertyTag client:app.client];

        GureumComposer *composer = (GureumComposer *)app.controller.composer;
        EmoticonComposer *emoticonComposer = composer.emoticonComposer;
        emoticonComposer.delegate = composer.delegate;  // roman?
        composer.delegate = emoticonComposer;
        
//        [app inputText:@"\n" key:36 modifiers:655360]; // change to emoticon mode
        [app inputText:@"s" key:1 modifiers:0];
        [app inputText:@"l" key:37 modifiers:0];
        [app inputText:@"e" key:14 modifiers:0];
        [app inputText:@"e" key:14 modifiers:0];
        [app inputText:@"p" key:35 modifiers:0];
        [app inputText:@"y" key:16 modifiers:0];
        XCTAssertEqualObjects(@"sleepy", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"sleepy", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:kVK_Space modifiers:0];
        XCTAssertEqualObjects(@"sleepy ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"sleepy ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"a" key:0 modifiers:0];
        [app inputText:@"c" key:8 modifiers:0];
        [app inputText:@"e" key:14 modifiers:0];
        XCTAssertEqualObjects(@"sleepy face", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"sleepy face", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"😪: sleepy face"]];
        XCTAssertEqualObjects(@"sleepy face", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"sleepy face", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"😪: sleepy face"]];
        XCTAssertEqualObjects(@"😪", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);

        app.client.string = @"";
        [app inputText:@"h" key:4 modifiers:0];
        [app inputText:@"u" key:32 modifiers:0];
        [app inputText:@"s" key:1 modifiers:0];
        [app inputText:@"h" key:4 modifiers:0];
        [app inputText:@"e" key:14 modifiers:0];
        [app inputText:@"d" key:2 modifiers:0];
        XCTAssertEqualObjects(@"hushed", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"hushed", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@" " key:49 modifiers:0];
        XCTAssertEqualObjects(@"hushed ", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"hushed ", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app inputText:@"f" key:3 modifiers:0];
        [app inputText:@"a" key:0 modifiers:0];
        [app inputText:@"c" key:8 modifiers:0];
        [app inputText:@"e" key:14 modifiers:0];
        XCTAssertEqualObjects(@"hushed face", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"hushed face", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelectionChanged:[[NSAttributedString alloc] initWithString:@"😯: hushed face"]];
        XCTAssertEqualObjects(@"hushed face", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"hushed face", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
        [app.controller candidateSelected:[[NSAttributedString alloc] initWithString:@"😯: hushed face"]];
        XCTAssertEqualObjects(@"😯", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
        XCTAssertEqualObjects(@"", app.client.markedString, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

- (void)testHanjaSelection {
    for (VirtualApp *app in @[self.moderate]) {
        if (app == self.terminal) {
            continue; // 터미널은 한자 모드 진입이 불가
        }
        app.client.string = @"물 수";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.han3final" forTag:kTextServiceInputModePropertyTag client:app.client];
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

- (void)testColemak {
    for (VirtualApp *app in self.apps) {
        app.client.string = @"";
        [app.controller setValue:@"org.youknowone.inputmethod.Gureum.colemak" forTag:kTextServiceInputModePropertyTag client:app.client];
        [app inputText:@"h" key:4 modifiers:0];
        [app inputText:@"k" key:40 modifiers:0];
        [app inputText:@"u" key:32 modifiers:0];
        [app inputText:@"u" key:32 modifiers:0];
        [app inputText:@";" key:41 modifiers:0];
        XCTAssertEqualObjects(@"hello", app.client.string, @"buffer: %@ app: (%@)", app.client.string, app);
    }
}

@end
