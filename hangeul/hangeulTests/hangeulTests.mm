//
//  hangeulTests.m
//  hangeulTests
//
//  Created by Jeong YunWon on 2014. 6. 7..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <hangeul/hangeul.h>
#include <hangeul/hangul.h>

using namespace hangeul;
using namespace hangeul::KSX5002;

@interface hangeulTests : XCTestCase

@end

@implementation hangeulTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testOptional {
    auto opt1 = Optional<int>::None();
    XCTAssertEqual(opt1.is_none, true, @"");
    int v = 10;
    auto opt2 = Optional<int>::Some(v);
    XCTAssertEqual(opt2.is_none, false, @"");
    XCTAssertEqual(opt2.some, 10, @"");
}

- (void)testStrokePhase {
    QwertyToKeyStrokePhase phase;
    StateList ss;
    auto r = phase.put_state(ss, State::InputSource('r'));
    XCTAssertTrue(r.processed, @"");
    ss = r.states;
    auto s = ss.front();
    XCTAssertEqual(s[2], 20, @"");
}

- (void)testKSX5002Phase {
    KSX5002::FromQwertyPhase phase;
    StateList ss;
    auto r = phase.put_state(ss, State::InputSource('r'));
    auto s = r.states.front();
    XCTAssertEqual(r.states.size(), 1, @"");
    XCTAssertEqual(s[0], 0, @"");
    XCTAssertEqual(s['a'], Consonant::G, @"");
    XCTAssertEqual(s['b'], 0, @"");
    XCTAssertEqual(s['c'], 0, @"");
    r = phase.put_state(r.states, State::InputSource('n'));
    s = r.states.front();
    XCTAssertEqual(r.states.size(), 1, @"");
    XCTAssertEqual(s['a'], Consonant::G, @"");
    XCTAssertEqual(s['b'], Vowel::U, @"");
    XCTAssertEqual(s['c'], 0, @"");
    r = phase.put_state(r.states, State::InputSource('f'));
    s = r.states.front();
    XCTAssertEqual(r.states.size(), 1, @"");
    XCTAssertEqual(s['a'], Consonant::G, @"");
    XCTAssertEqual(s['b'], Vowel::U, @"");
    XCTAssertEqual(s['c'], Consonant::R, @"");
    r = phase.put_state(r.states, State::InputSource('m'));
    XCTAssertEqual(r.states.size(), 2, @"");
    s = r.states.front();
    XCTAssertEqual(s['a'], Consonant::R, @"");
    XCTAssertEqual(s['b'], Vowel::Eu, @"");
    XCTAssertEqual(s['c'], 0, @"");
}

- (void)testCBinding {
    void *c = _context();
    auto r = _put(c, 'r');
    r = _put(c, 'n');
    r = _put(c, 'f');
}

@end
