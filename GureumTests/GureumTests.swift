//
//  GureumTests.swift
//  OSX
//
//  Created by Jim Jeon on 16/09/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import XCTest
import Gureum


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
        for app: VirtualApp in self.apps {
            if (app == self.terminal) {
                continue
            }

            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty, forTag:kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("\n", key: 36, modifiers: NSEvent.ModifierFlags(rawValue: 786432))
        }
    }
}
