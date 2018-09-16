//
//  GureumTests.swift
//  GureumTests
//
//  Created by Jeong YunWon on 2014. 6. 5..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import XCTest
import Gureum

class GureumTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBaseTheme() {
        // This is an example of a functional test case.
        let theme = EmbeddedTheme(name: "base")
        let trait = theme.phonePortraitConfiguration
        let caption = trait.captionForIdentifier(identifier: "test1", needsMargin: true, classes: { [trait.qwerty.key(key: "q"), trait.qwerty.key, trait.qwerty.base, trait.common.key(key: "q"), trait.common.key, trait.common.base ] })
        XCTAssert(caption.position == CGPoint(x: 0, y: 4), "")

        let function = trait.captionForIdentifier(identifier: "test2", needsMargin: true, classes: { [trait.qwerty.caption(key: "delete"), trait.qwerty.function, trait.qwerty.base, trait.common.key(key: "delete"), trait.common.function, trait.common.base ] })
        XCTAssert(caption.position == CGPoint(x: 0, y: 4), "")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
