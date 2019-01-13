//
//  GureumTests.swift
//  OSX
//
//  Created by Jim Jeon on 16/09/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

@testable import GureumCore
import Hangul
import XCTest

class GureumTests: XCTestCase {
    static let domainName: String = "org.youknowone.Gureum"
    static var oldConfiguration: [String: Any]?
    let moderate: VirtualApp = ModerateApp()
    let terminal: VirtualApp! = nil
//    let terminal: VirtualApp = TerminalApp()
//    let greedy: VirtualApp = GreedyApp()
    var apps: [VirtualApp] = []

    override class func setUp() {
        super.setUp()
        oldConfiguration = UserDefaults.standard.persistentDomain(forName: domainName)
    }

    override class func tearDown() {
        if let oldConfiguration = self.oldConfiguration {
            UserDefaults.standard.setPersistentDomain(oldConfiguration, forName: domainName)
        }
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        UserDefaults.standard.removePersistentDomain(forName: GureumTests.domainName)
        apps = [self.moderate]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPreferencePane() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        let loaded = bundle.instantiatePrefPaneObject()
        XCTAssertTrue(loaded)
    }

    func testLayoutChange() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText(nil, key: -1, modifiers: NSEvent.ModifierFlags.capsLock)

            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags.shift)
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testSearchEmoticonTable() {
        let bundle: Bundle = Bundle.main
        let path: String? = bundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")
        let table: HGHanjaTable = HGHanjaTable(contentOfFile: path!)!
        let list: HGHanjaList = table.hanjas(byPrefixSearching: "hushed") ?? HGHanjaList() // 현재 5글자 이상만 가능
        XCTAssert(list.count > 0)
    }

    func testCommandkeyAndControlkey() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("a", key: Int(kVK_ANSI_A), modifiers: NSEvent.ModifierFlags.command)
            app.inputText("a", key: Int(kVK_ANSI_A), modifiers: NSEvent.ModifierFlags.control)
            XCTAssertEqual("", app.client.string, "")
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testCapslockRoman() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("2", key: Int(kVK_ANSI_2), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("mr2", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            app.inputText("2", key: Int(kVK_ANSI_2), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            XCTAssertEqual("MR2", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSyllable() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: Int(kVK_Return), modifiers: NSEvent.ModifierFlags.option)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "韓: 나라 이름 한"))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "韓: 나라 이름 한"))
            XCTAssertEqual("韓", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaWord() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: Int(kVK_Return), modifiers: NSEvent.ModifierFlags.option)
            app.inputText("i", key: Int(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: Int(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: Int(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: Int(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: Int(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")

            // 연달아 다음 한자 입력에 들어간다
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("i", key: Int(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("b", key: Int(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: Int(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("n", key: Int(kVK_ANSI_N), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("b", key: Int(kVK_ANSI_B), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水 水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSelection() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = "물 수"
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue,
                                    forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.client.setSelectedRange(NSMakeRange(0, 3))
            XCTAssertEqual("물 수", app.client.selectedString(), "")
            app.inputText("\n", key: Int(kVK_Return), modifiers: NSEvent.ModifierFlags.option)
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan2() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: Int(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("₩", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputText("~", key: Int(kVK_ANSI_Grave), modifiers: .shift)
            XCTAssertEqual("₩~", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteOnComposing() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("가", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputText("`", key: Int(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("가₩", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteQwerty() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: Int(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("`", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan3Final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: Int(kVK_ANSI_Grave), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("*", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHan3Gureum() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("\"", key: Int(kVK_ANSI_Quote), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("\"", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testDvorak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.dvorak", forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("j", key: Int(kVK_ANSI_J), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("d", key: Int(kVK_ANSI_D), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("p", key: Int(kVK_ANSI_P), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("p", key: Int(kVK_ANSI_P), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("hello", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test3Number() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("K", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("2", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBlock() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("g", key: Int(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: Int(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("mfskgw", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))

            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("", key: Int(kVK_LeftArrow), modifiers: NSEvent.ModifierFlags(rawValue: 0))
        }
    }

    func test3final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("g", key: Int(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: Int(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("g", key: Int(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("w", key: Int(kVK_ANSI_W), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: Int(kVK_Return), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testColemak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.colemak.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("h", key: Int(kVK_ANSI_H), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("u", key: Int(kVK_ANSI_U), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("u", key: Int(kVK_ANSI_U), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText(";", key: Int(kVK_ANSI_Semicolon), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("?", key: Int(kVK_ANSI_Slash), modifiers: NSEvent.ModifierFlags.shift)
            XCTAssertEqual("hello?", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test2() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("g", key: Int(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputText("g", key: Int(kVK_ANSI_G), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("k", key: Int(kVK_ANSI_K), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: Int(kVK_Return), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testCapslockHangul() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("2", key: Int(kVK_ANSI_2), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("했", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("했", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))

            app.client.string = ""
            app.inputText("m", key: Int(kVK_ANSI_M), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            app.inputText("r", key: Int(kVK_ANSI_R), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            app.inputText("2", key: Int(kVK_ANSI_2), modifiers: NSEvent.ModifierFlags(rawValue: 0x10000))
            XCTAssertEqual("했", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("했", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testRomanEmoticon() {
        for app in apps {
            if app == terminal {
                continue
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            let composer = app.controller.composer as! GureumComposer
            let emoticonComposer = composer.emoticonComposer
            emoticonComposer.delegate = composer.delegate // roman?
            composer.delegate = emoticonComposer

            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("l", key: Int(kVK_ANSI_L), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("e", key: Int(kVK_ANSI_E), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("e", key: Int(kVK_ANSI_E), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("p", key: Int(kVK_ANSI_P), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("y", key: Int(kVK_ANSI_Y), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("sleepy", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("sleepy ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("a", key: Int(kVK_ANSI_A), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("c", key: Int(kVK_ANSI_C), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("e", key: Int(kVK_ANSI_E), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("😪", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.client.string = ""
            app.inputText("h", key: Int(kVK_ANSI_H), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("u", key: Int(kVK_ANSI_U), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("h", key: Int(kVK_ANSI_H), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("e", key: Int(kVK_ANSI_E), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("d", key: Int(kVK_ANSI_D), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("hushed", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("hushed ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("f", key: Int(kVK_ANSI_F), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("a", key: Int(kVK_ANSI_A), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("c", key: Int(kVK_ANSI_C), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("e", key: Int(kVK_ANSI_E), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("hushed face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "😯: hushed face"))
            XCTAssertEqual("hushed face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "😯:, hushed face"))
            XCTAssertEqual("😯", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHan3UnicodeArea() {
        for app in apps {
            // 두벌식 ㅑㄴ
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("i", key: Int(kVK_ANSI_I), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual("ㅑㄴ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let han2 = app.client.string
            app.inputText(" ", key: Int(kVK_Space), modifiers: NSEvent.ModifierFlags(rawValue: 0))

            // 세벌식 ㅑㄴ
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputText("6", key: Int(kVK_ANSI_6), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            app.inputText("s", key: Int(kVK_ANSI_S), modifiers: NSEvent.ModifierFlags(rawValue: 0))
            XCTAssertEqual(han2, app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testEscapeOrCntrlAndLeftBracketHan3Gureum() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("[", key: Int(kVK_ANSI_LeftBracket), modifiers: NSEvent.ModifierFlags.control)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testEscapeOrCntrlAndLeftBracketWithShiftHan3Gureum() {
        for app in apps {
            let controlAndShift = NSEvent.ModifierFlags.control.union(.shift)
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("[", key: Int(kVK_ANSI_LeftBracket), modifiers: controlAndShift)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }
}
