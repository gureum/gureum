//
//  GureumTests.swift
//  OSX
//
//  Created by Jim Jeon on 16/09/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

@testable import GureumCore
import Hangul
import InputMethodKit
import XCTest

class GureumTests: XCTestCase {
    static let domainName = "org.youknowone.Gureum.test"
    let moderate: VirtualApp = ModerateApp()
    // let xcode: VirtualApp = XcodeApp()
    let terminal: VirtualApp! = nil
//    let terminal: VirtualApp = TerminalApp()
//    let greedy: VirtualApp = GreedyApp()
    lazy var apps: [VirtualApp] = [moderate]

    override class func setUp() {
        Configuration.shared = Configuration(suiteName: "org.youknowone.Gureum.test")!
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        Configuration.shared.removePersistentDomain(forName: GureumTests.domainName)
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
            app.inputFlags(.capsLock)

            app.inputText(" ", key: kVK_Space, modifiers: .shift)
            app.inputText(" ", key: kVK_Space, modifiers: .shift)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testLayoutChangeCommit() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han2", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_G)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.inputFlags(.capsLock)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testSearchEmoticonTable() {
        let bundle = Bundle(for: HGKeyboard.self)
        let path: String? = bundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")
        let table: HGHanjaTable = HGHanjaTable(contentOfFile: path!)!
        let list: HGHanjaList = table.hanjas(byPrefixSearching: "hushed") ?? HGHanjaList() // 현재 5글자 이상만 가능
        XCTAssert(list.count > 0)
    }

    func testCommandkeyAndControlkey() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_A, modifiers: .command)
            app.inputKey(kVK_ANSI_A, modifiers: .control)
            XCTAssertEqual("", app.client.string, "")
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testCapslockRoman() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_R)
            app.inputKey(kVK_ANSI_2)
            XCTAssertEqual("mr2", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_M, modifiers: .capsLock)
            app.inputKey(kVK_ANSI_R, modifiers: .capsLock)
            app.inputKey(kVK_ANSI_2, modifiers: .capsLock)
            XCTAssertEqual("MR2", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSyllable() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: kVK_Return, modifiers: .option)
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
            app.inputText("\n", key: kVK_Return, modifiers: .option)
            app.inputKey(kVK_ANSI_I)
            app.inputKey(kVK_ANSI_B)
            app.inputKey(kVK_ANSI_W)
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(kVK_ANSI_N)
            app.inputKey(kVK_ANSI_B)
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")

            // 연달아 다음 한자 입력에 들어간다
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("水 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(kVK_ANSI_I)
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(kVK_ANSI_B)
            app.inputKey(kVK_ANSI_W)
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(kVK_ANSI_N)
            app.inputKey(kVK_ANSI_B)
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
            app.inputText("\n", key: kVK_Return, modifiers: .option)
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
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

            app.inputKey(kVK_ANSI_Grave)
            XCTAssertEqual("₩", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(kVK_ANSI_Grave, modifiers: .shift)
            XCTAssertEqual("₩~", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteOnComposing() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_R)
            app.inputKey(kVK_ANSI_K)
            XCTAssertEqual("가", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(kVK_ANSI_Grave)
            XCTAssertEqual("가₩", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteQwerty() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_Grave)
            XCTAssertEqual("`", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan3Final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: kVK_ANSI_Grave)
            XCTAssertEqual("*", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHan3Gureum() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_Quote, modifiers: .shift)
            XCTAssertEqual("\"", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testDvorak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.dvorak", forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_J)
            app.inputKey(kVK_ANSI_D)
            app.inputKey(kVK_ANSI_P)
            app.inputKey(kVK_ANSI_P)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("hello", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test3Number() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_K, modifiers: .shift)
            XCTAssertEqual("2", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBlock() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_S)
            app.inputKey(kVK_ANSI_K)
            app.inputKey(kVK_ANSI_G)
            app.inputKey(kVK_ANSI_W)
            XCTAssertEqual("mfskgw", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: kVK_Space)

            app.inputText("", key: kVK_LeftArrow)
            app.inputText("", key: kVK_LeftArrow)
            app.inputText("", key: kVK_LeftArrow)
            app.inputText("", key: kVK_LeftArrow)
            app.inputText("", key: kVK_LeftArrow)
            app.inputText("", key: kVK_LeftArrow)
        }
    }

    func test3final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_K)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_G)
            XCTAssertEqual("한그", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("그", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_W)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_M)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_K)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_G)
            app.inputKey(kVK_ANSI_W)
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: kVK_Return)
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testColemak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.colemak.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_H)
            app.inputKey(kVK_ANSI_K)
            app.inputKey(kVK_ANSI_U)
            app.inputKey(kVK_ANSI_U)
            app.inputKey(kVK_ANSI_Semicolon)
            app.inputKey(kVK_ANSI_Slash, modifiers: .shift)
            XCTAssertEqual("hello?", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test2() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_G)
            app.inputKey(kVK_ANSI_K)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_R)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_F)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputKey(kVK_ANSI_G)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_K)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_R)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_F)
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: kVK_Return)
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testCapslockHangul() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_M)
            app.inputKey(kVK_ANSI_R)
            app.inputKey(kVK_ANSI_2)
            XCTAssertEqual("했", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("했", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputText(" ", key: kVK_Space)

            app.client.string = ""
            app.inputKey(kVK_ANSI_M, modifiers: .capsLock)
            app.inputKey(kVK_ANSI_R, modifiers: .capsLock)
            app.inputKey(kVK_ANSI_2, modifiers: .capsLock)
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

            let composer = app.controller.receiver.composer as! GureumComposer
            let emoticonComposer = composer.emoticonComposer
            emoticonComposer.delegate = composer.delegate // roman?
            composer.delegate = emoticonComposer

            app.inputKey(kVK_ANSI_S)
            app.inputKey(kVK_ANSI_L)
            app.inputKey(kVK_ANSI_E)
            app.inputKey(kVK_ANSI_E)
            app.inputKey(kVK_ANSI_P)
            app.inputKey(kVK_ANSI_Y)
            XCTAssertEqual("sleepy", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("sleepy ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_A)
            app.inputKey(kVK_ANSI_C)
            app.inputKey(kVK_ANSI_E)
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("😪", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.client.string = ""
            app.inputKey(kVK_ANSI_H)
            app.inputKey(kVK_ANSI_U)
            app.inputKey(kVK_ANSI_S)
            app.inputKey(kVK_ANSI_H)
            app.inputKey(kVK_ANSI_E)
            app.inputKey(kVK_ANSI_D)
            XCTAssertEqual("hushed", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: kVK_Space)
            XCTAssertEqual("hushed ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_F)
            app.inputKey(kVK_ANSI_A)
            app.inputKey(kVK_ANSI_C)
            app.inputKey(kVK_ANSI_E)
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
            app.inputKey(kVK_ANSI_I)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("ㅑㄴ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let han2 = app.client.string
            app.inputText(" ", key: kVK_Space)

            // 세벌식 ㅑㄴ
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_6)
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual(han2, app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testEscapeOrCtrlAndLeftBracketHan3Gureum() {
        XCTAssertFalse(Configuration.shared.romanModeByEscapeKey)
        Configuration.shared.romanModeByEscapeKey = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_M)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(kVK_ANSI_LeftBracket, modifiers: [.control])
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))

            app.inputKey(kVK_ANSI_LeftBracket, modifiers: [.control, .shift])
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))
        }
    }

    func testHanClassic() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Classic.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(kVK_ANSI_M)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_F)
            XCTAssertEqual("하", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_F)
            XCTAssertEqual("ᄒᆞ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(kVK_ANSI_S)
            XCTAssertEqual("ᄒᆞᆫ", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHanDelete() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(kVK_ANSI_D)
            XCTAssertEqual("ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅇ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("", key: kVK_Delete)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testSelection() {
        for app in apps {
            app.client.string = "한"
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            _ = app.inputKey(kVK_ANSI_D)
            XCTAssertEqual("한ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅇ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.client.setSelectedRange(NSRange(location: 0, length: 0))
            _ = app.inputKey(kVK_ANSI_R)
            XCTAssertEqual("ㄱ한ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }
}
