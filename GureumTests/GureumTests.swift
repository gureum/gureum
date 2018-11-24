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
    static let domainName: String = "org.youknowone.Gureum"
    static var oldConfiguration: [String : Any]?
    let moderate: VirtualApp = ModerateApp()
    let terminal: VirtualApp = TerminalApp()
    let greedy: VirtualApp = GreedyApp()
    var apps: [VirtualApp] = []

    override class func setUp() {
        super.setUp()
        self.oldConfiguration = UserDefaults.standard.persistentDomain(forName: self.domainName)
    }

    override class func tearDown() {
        if let oldConfiguration = self.oldConfiguration {
            UserDefaults.standard.setPersistentDomain(oldConfiguration, forName: self.domainName)
        }
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        UserDefaults.standard.removePersistentDomain(forName: GureumTests.domainName)
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
    
    func testCommandkeyAndControlkey() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("a", key: 0, modifiers: NSEvent.ModifierFlags.command)
            app.inputText("a", key: 0, modifiers: NSEvent.ModifierFlags.control)
            XCTAssertEqual("", app.client.string, "");
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testHanjaSyllable() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: 46, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: 3, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: 1, modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: 36, modifiers: NSEvent.ModifierFlags.option)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "韓: 나라 이름 한"))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "韓: 나라 이름 한"))
            XCTAssertEqual("韓", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaWord() {
        for app in self.apps {
            if app == self.terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: UInt(kVK_Return), modifiers: NSEvent.ModifierFlags.option)
            app.inputText("i", key: UInt(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: UInt(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")

            // 연달아 다음 한자 입력에 들어간다
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("i", key: UInt(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: UInt(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: UInt(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString.init(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testBackQuoteHan2() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: UInt(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("₩", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputText("~", key: UInt(kVK_ANSI_Grave), modifiers: .shift)
            XCTAssertEqual("₩~", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteOnComposing() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("r", key: UInt(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: UInt(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("가", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputText("`", key: UInt(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("가₩", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteQwerty() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: UInt(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("`", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan3Final() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: UInt(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("*", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHan3Gureum() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("\"", key: UInt(kVK_ANSI_Quote), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("\"", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testDvorak() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.dvorak", forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("j", key: UInt(kVK_ANSI_J), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("d", key: UInt(kVK_ANSI_D), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("p", key: UInt(kVK_ANSI_P), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("p", key: UInt(kVK_ANSI_P), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: UInt(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("hello", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test3Number() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("K", key: UInt(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("2", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }       
    }

    func testBlock() {
        for app in self.apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: UInt(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: UInt(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: UInt(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: UInt(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("g", key: UInt(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("mfskgw", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))

            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: UInt(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
        }
    }

    func test3final() {
        for app in self.apps{
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: UInt(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: UInt(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: UInt(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("k", key: UInt(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("g", key: UInt(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: UInt(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("m", key: UInt(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("f", key: UInt(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: UInt(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("k", key: UInt(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("g", key: UInt(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: UInt(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: UInt(kVK_Return), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            if (app != self.terminal) {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }
}