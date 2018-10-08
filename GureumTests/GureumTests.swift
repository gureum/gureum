//
//  GureumTests.swift
//  OSX
//
//  Created by Jim Jeon on 16/09/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import XCTest
import Gureum
import Hangul


class GureumTests: XCTestCase {
    let moderate: VirtualApp = ModerateApp()
    let terminal: VirtualApp = TerminalApp()
    let greedy: VirtualApp = GreedyApp()
    var apps: [VirtualApp] = []
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.apps = [self.moderate]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchEmoticonTable() {
        let bundle: Bundle = Bundle.main
        let path: String? = bundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")
        let table: HGHanjaTable = HGHanjaTable.init(contentOfFile: path ?? "")
        let list: HGHanjaList = table.hanjas(byPrefixSearching: "hushed") ?? HGHanjaList() // 현재 5글자 이상만 가능
        XCTAssert(list.count > 0)
    }
}
