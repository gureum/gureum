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

private var lastNotification: NSUserNotification!

extension NSUserNotificationCenter {
    func deliver(_ notification: NSUserNotification) {
        lastNotification = notification
    }
}

class GureumTests: XCTestCase {
    static let domainName = "org.youknowone.Gureum.test"
    lazy var moderate: VirtualApp = ModerateApp()
    // lazy var xcode: VirtualApp = XcodeApp()
    lazy var terminal: VirtualApp! = nil
    // lazy var terminal: VirtualApp = TerminalApp()
    // lazy var greedy: VirtualApp = GreedyApp()
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

    func testNotifyUpdate() {
        let data = """
        {
            "version": "1.10.0",
            "description": "Mojave 대응을 포함한 대형 업데이트",
            "url": "https://github.com/gureum/gureum/releases/tag/1.10.0"
        }
        """.data(using: .utf8)
        let update = try! JSONDecoder().decode(UpdateManager.UpdateInfo.self, from: data!)

        let versionInfo = UpdateManager.VersionInfo(update: update, experimental: true)
        UpdateManager.notifyUpdate(info: versionInfo)
        XCTAssertEqual("최신 버전: 1.10.0 현재 버전: \(Bundle.main.version ?? "-")\nMojave 대응을 포함한 대형 업데이트", lastNotification.informativeText)
        XCTAssertEqual(["url": "https://github.com/gureum/gureum/releases/tag/1.10.0"], lastNotification.userInfo as! [String: String])
    }

    func testLayoutChange() {
        Configuration.shared.inputModeExchangeKey = Configuration.Shortcut(.space, .shift)
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputFlags(.capsLock)

            app.inputText(" ", key: .space, modifiers: .shift)
            app.inputText(" ", key: .space, modifiers: .shift)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testLayoutChangeCommit() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han2", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiG)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.inputFlags(.capsLock)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testSearchEmoticonTable() {
        let bundle = Bundle(for: HGKeyboard.self)
        let path: String? = bundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")
        let table = HGHanjaTable(contentOfFile: path!)!
        let list: HGHanjaList = table.hanjas(byPrefixSearching: "hushed") ?? HGHanjaList() // 현재 5글자 이상만 가능
        XCTAssert(list.count > 0)
    }

    func testCommandkeyAndControlkey() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiA, modifiers: .command)
            app.inputKey(.ansiA, modifiers: .control)
            XCTAssertEqual("", app.client.string, "")
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testCapslockRoman() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiM)
            app.inputKey(.ansiR)
            app.inputKey(.ansi2)
            XCTAssertEqual("mr2", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.client.string = ""
            app.controller.setValue(GureumInputSource.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiM, modifiers: .capsLock)
            app.inputKey(.ansiR, modifiers: .capsLock)
            app.inputKey(.ansi2, modifiers: .capsLock)
            XCTAssertEqual("MR2", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSyllable() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiM)
            app.inputKey(.ansiF)
            app.inputKey(.ansiS)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: .return, modifiers: .option)
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
            app.controller.setValue(GureumInputSource.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: .return, modifiers: .option)
            app.inputKey(.ansiI)
            app.inputKey(.ansiB)
            app.inputKey(.ansiW)
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiN)
            app.inputKey(.ansiB)
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")

            // 연달아 다음 한자 입력에 들어간다
            app.inputText(" ", key: .space)
            XCTAssertEqual("水 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiI)
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiB)
            app.inputKey(.ansiW)
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiN)
            app.inputKey(.ansiB)
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

    func testHanjaBlank() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: .return, modifiers: .option)
            app.inputText(" ", key: .space)
            app.inputKey(.ansiA)
            app.inputKey(.ansiN)
            app.inputKey(.ansiF)
            XCTAssertEqual(" 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual(" 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiT)
            app.inputKey(.ansiN)
            app.inputText(" ", key: .space)
            XCTAssertEqual(" 물 수 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual(" 물 수 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual(" 水", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSelection() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = "물 수"
            app.controller.setValue(GureumInputSource.han3Final.rawValue,
                                    forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.client.setSelectedRange(NSMakeRange(0, 3))
            XCTAssertEqual("물 수", app.client.selectedString(), "")
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("水", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHanjaEscapeSyllable() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiG)
            app.inputKey(.ansiK)
            app.inputKey(.ansiS)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "韓: 나라 이름 한"))
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            // Escape from Hanja mode
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHanjaEscapeWord() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: .return, modifiers: .option)
            app.inputKey(.ansiA)
            app.inputKey(.ansiN)
            app.inputKey(.ansiF)
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.ansiT)
            app.inputKey(.ansiN)
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            // Escape from Hanja mode
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaEscapeSelection() {
        for app in apps {
            if app == terminal {
                continue // 터미널은 한자 모드 진입이 불가능
            }
            app.client.string = "물 수"
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.client.setSelectedRange(NSMakeRange(0, 3))
            XCTAssertEqual("물 수", app.client.selectedString(), "")
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "水: 물 수, 고를 수"))
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("물 수", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            // Escape from Hanja mode
            app.inputText("\n", key: .return, modifiers: .option)
            XCTAssertEqual("물 수", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan2() {
        Configuration.shared.hangulWonCurrencySymbolForBackQuote = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiGrave)
            XCTAssertEqual("₩", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.ansiGrave, modifiers: .shift)
            XCTAssertEqual("₩~", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteOnComposing() {
        Configuration.shared.hangulWonCurrencySymbolForBackQuote = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiR)
            app.inputKey(.ansiK)
            XCTAssertEqual("가", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.ansiGrave)
            XCTAssertEqual("가₩", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteQwerty() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiGrave)
            XCTAssertEqual("`", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan3Final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: .ansiGrave)
            XCTAssertEqual("*", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testDvorak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.dvorak", forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiJ)
            app.inputKey(.ansiD)
            app.inputKey(.ansiP)
            app.inputKey(.ansiP)
            app.inputKey(.ansiS)
            XCTAssertEqual("hello", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test3Number() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiK, modifiers: .shift)
            XCTAssertEqual("2", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBlock() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiM)
            app.inputKey(.ansiF)
            app.inputKey(.ansiS)
            app.inputKey(.ansiK)
            app.inputKey(.ansiG)
            app.inputKey(.ansiW)
            XCTAssertEqual("mfskgw", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)

            app.inputText("", key: .leftArrow)
            app.inputText("", key: .leftArrow)
            app.inputText("", key: .leftArrow)
            app.inputText("", key: .leftArrow)
            app.inputText("", key: .leftArrow)
            app.inputText("", key: .leftArrow)
        }
    }

    func test3final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiM)
            app.inputKey(.ansiF)
            app.inputKey(.ansiS)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiK)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiG)
            XCTAssertEqual("한그", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("그", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiW)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiM)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiF)
            app.inputKey(.ansiS)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiK)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiG)
            app.inputKey(.ansiW)
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: .return)
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testColemak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.colemak.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiH)
            app.inputKey(.ansiK)
            app.inputKey(.ansiU)
            app.inputKey(.ansiU)
            app.inputKey(.ansiSemicolon)
            app.inputKey(.ansiSlash, modifiers: .shift)
            XCTAssertEqual("hello?", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test2() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiG)
            app.inputKey(.ansiK)
            app.inputKey(.ansiS)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiR)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiM)
            app.inputKey(.ansiF)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.ansiG)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiK)
            app.inputKey(.ansiS)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiR)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiM)
            app.inputKey(.ansiF)
            XCTAssertEqual("한글 한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("\n", key: .return)
            if app != terminal {
                XCTAssertEqual("한글 한글\n", app.client.string, "buffer: \(app.client.string) app: \(app)")
            }
        }
    }

    func testCapslockHangul() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiM)
            app.inputKey(.ansiR)
            app.inputKey(.ansi2)
            XCTAssertEqual("했", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("했", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputText(" ", key: .space)

            app.client.string = ""
            app.inputKey(.ansiM, modifiers: .capsLock)
            app.inputKey(.ansiR, modifiers: .capsLock)
            app.inputKey(.ansi2, modifiers: .capsLock)
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
            app.controller.setValue(GureumInputSource.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            let composer = app.controller.receiver.composer
            let emoticonComposer = composer.searchComposer
            emoticonComposer.delegate = composer.delegate
            composer.delegate = emoticonComposer

            app.inputKey(.ansiS)
            app.inputKey(.ansiL)
            app.inputKey(.ansiE)
            app.inputKey(.ansiE)
            app.inputKey(.ansiP)
            app.inputKey(.ansiY)
            XCTAssertEqual("sleepy", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("sleepy ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiF)
            app.inputKey(.ansiA)
            app.inputKey(.ansiC)
            app.inputKey(.ansiE)
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("😪", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.client.string = ""
            app.inputKey(.ansiH)
            app.inputKey(.ansiU)
            app.inputKey(.ansiS)
            app.inputKey(.ansiH)
            app.inputKey(.ansiE)
            app.inputKey(.ansiD)
            XCTAssertEqual("hushed", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("hushed ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiF)
            app.inputKey(.ansiA)
            app.inputKey(.ansiC)
            app.inputKey(.ansiE)
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
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiI)
            app.inputKey(.ansiS)
            XCTAssertEqual("ㅑㄴ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let han2 = app.client.string
            app.inputText(" ", key: .space)

            // 세벌식 ㅑㄴ
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansi6)
            app.inputKey(.ansiS)
            XCTAssertEqual(han2, app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testViModeEscape() {
        XCTAssertFalse(Configuration.shared.romanModeByEscapeKey)
        Configuration.shared.romanModeByEscapeKey = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiM)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let processed = app.inputKey(.escape)
            XCTAssertFalse(processed)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))
        }
    }

    func testViModeCtrlAndLeftBracket() {
        XCTAssertFalse(Configuration.shared.romanModeByEscapeKey)
        Configuration.shared.romanModeByEscapeKey = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiM)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let processed = app.inputKey(.ansiLeftBracket, modifiers: [.control])
            XCTAssertFalse(processed)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))

            app.inputKey(.ansiLeftBracket, modifiers: [.control, .shift])
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))
        }
    }

    func testHanClassic() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han3Classic.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.ansiM)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiF)
            XCTAssertEqual("하", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiF)
            XCTAssertEqual("ᄒᆞ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.ansiS)
            XCTAssertEqual("ᄒᆞᆫ", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHanDelete() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSource.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.ansiD)
            XCTAssertEqual("ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅇ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("", key: .delete)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testSearchPool() {
        for (pool, key, test) in [
            (SearchSourceConst.emojiKorean, "사과", "사과"),
            (SearchSourceConst.hanjaReversed, "물 수", "水"),
        ] {
            let workItem = DispatchWorkItem {}
            let candidates = pool.collect(key, workItem: workItem)
            let c = candidates[0]
            XCTAssertTrue(c.candidate.value == test || c.candidate.description.contains(test))
        }
    }

    func testSearchPoolWithoutDuplicate() {
        for (pool, key, test) in [
            (SearchSourceConst.koreanSingle, "구", "九"),
        ] {
            let workItem = DispatchWorkItem {}
            let candidates = pool.collect(key, workItem: workItem)
            XCTAssertEqual(1, candidates.filter { $0.candidate.value == test }.count)
        }
    }

    //    func testSelection() {
    //        for app in apps {
    //            app.client.string = "한"
    //            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
    //            _ = app.inputKey(kVK_ANSI_D)
    //            XCTAssertEqual("한ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
    //            XCTAssertEqual("ㅇ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
    //            app.client.setSelectedRange(NSRange(location: 0, length: 0))
    //            _ = app.inputKey(kVK_ANSI_R)
    //            XCTAssertEqual("ㄱ한ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
    //            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
    //        }
    //    }
}

class Han3FinalNoShiftTests: XCTestCase {
    let app = ModerateApp()

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

        app.client.string = ""
        app.controller.setValue(GureumInputSource.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.inputKey(.space)
        app.client.string = ""
        super.tearDown()
    }

    func testSymbol() {
        app.inputKey(.ansiQuote, modifiers: .shift)
        XCTAssertEqual("\"", app.client.string, "buffer: \(app.client.string) app: \(app)")
        app.client.string = ""
    }

    func testModeKeyAsSymbol() {
        app.inputKey(.ansiLeftBracket)
        XCTAssertEqual("[", app.client.string, "buffer: \(app.client.string) app: \(app)")
        XCTAssertEqual("[", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        app.inputKey(.ansiLeftBracket)
        XCTAssertEqual("[[", app.client.string, "buffer: \(app.client.string) app: \(app)")
        XCTAssertEqual("[", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
    }

    func testBufferedJung() {
        app.test(input: "fd", expecteds: ["ㅏ", "ㅏㅣ"], markeds: ["ㅏ", "ㅏㅣ"])
        app.test(input: "fds", expecteds: ["ㅏ", "ㅏㅣ", "ㅏㅣㄴ"], markeds: ["ㅏ", "ㅏㅣ", "ㅣㄴ"])
        app.test(input: "fde", expecteds: ["ㅏ", "ㅏㅣ", "ㅏㅣㅕ"], markeds: ["ㅏ", "ㅏㅣ", "ㅣㅕ"])
        app.test(input: "fdk", expecteds: ["ㅏ", "ㅏㅣ", "ㅏ기"], markeds: ["ㅏ", "ㅏㅣ", "기"])
        app.test(input: "fdk", expecteds: ["ㅏ", "ㅏㅣ", "ㅏ기"], markeds: ["ㅏ", "ㅏㅣ", "기"])
        app.test(input: "fdsk", expecteds: ["ㅏ", "ㅏㅣ", "ㅏㅣㄴ", "ㅏ긴"], markeds: ["ㅏ", "ㅏㅣ", "ㅣㄴ", "긴"])
        app.test(input: "fsdk", expecteds: ["ㅏ", "ㅏㄴ", "ㅏㄴㅣ", "ㅏㄴ기"], markeds: ["ㅏ", "ㅏㄴ", "ㅣ", "기"], removeds: ["ㅏㄴㅣ", "ㅏㄴ"])
    }

    func test까() {
        app.test(input: "jkf", expecteds: [nil, nil, "까"])
        app.test(input: "kjf", expecteds: [nil, nil, "까"])
        app.test(input: "fkj", expecteds: [nil, nil, "까"])
        app.test(input: "fjk", expecteds: [nil, nil, "까"])
        app.test(input: "fkji", expecteds: [nil, nil, "까", "까ㅁ"], removeds: ["까", ""])
        app.test(input: "fjki", expecteds: [nil, nil, "까", "까ㅁ"], removeds: ["까", ""])
        app.test(input: "jfk", expecteds: [nil, nil, "아ㄱ"], removeds: ["아"])
        app.test(input: "kfj", expecteds: [nil, nil, "가ㅇ"], removeds: ["가"])
        app.test(input: "sjkf", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "skjf", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "sfkj", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "sfjk", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "jksf", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "kjsf", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "fskj", expecteds: [nil, nil, nil, "깐"])
        app.test(input: "fsjk", expecteds: [nil, nil, nil, "깐"])
    }

    func testㄺ() {
        app.test(input: "2[", expecteds: ["ㅆ", "ㄺ"], markeds: ["ㅆ", "ㄺ"])
        app.test(input: "[2", expecteds: ["[", "ㄺ"], markeds: ["[", "ㄺ"])
    }

    func test괜() {
        app.test(input: "k/r", expecteds: [nil, nil, "괘"])
        app.test(input: "k/rs", expecteds: [nil, nil, nil, "괜"])
        app.test(input: "kr/s", expecteds: [nil, nil, nil, "괜"])
        app.test(input: "krs/", expecteds: [nil, nil, nil, "괜"])
        app.test(input: "k/sr", expecteds: [nil, nil, nil, "괜"])
        app.test(input: "ks/r", expecteds: [nil, nil, nil, "괜"])
        app.test(input: "ksr/", expecteds: [nil, nil, nil, "괜"])
    }

    func test뚫() {
        app.test(input: "iub[r", expecteds: [nil, nil, nil, "뚜[", "뚫"])
        app.test(input: "iu[br", expecteds: [nil, nil, nil, "뚜[", "뚫"])
        app.test(input: "iubr[", expecteds: [nil, nil, nil, "뚜ㅐ", "뚫"])
        app.test(input: "iubr[[", expecteds: [nil, nil, nil, "뚜ㅐ", "뚫", "뚫["], removeds: ["뚫", ""])
        app.test(input: "bb[r", expecteds: [nil, nil, "ㅜㅜ[", "ㅜㅜㅀ"], markeds: [nil, nil, "ㅜ[", "ㅜㅀ"])
    }

    func test많() {
        app.test(input: "if[s[", expecteds: [nil, nil, "맒", "많", "많["], markeds: [nil, nil, nil, nil, "["], removeds: ["많", ""])
        app.test(input: "ifs[", expecteds: [nil, nil, nil, "많"])
        app.test(input: "i[fs", expecteds: [nil, nil, nil, "많"])
        app.test(input: "i[sf", expecteds: [nil, nil, nil, "많"])
        app.test(input: "isf[", expecteds: [nil, nil, nil, "많"])
        app.test(input: "is[f", expecteds: [nil, nil, nil, "많"])
        app.test(input: "isf[f", expecteds: [nil, nil, nil, "많", "많ㅏ"], markeds: [nil, nil, nil, nil, "ㅏ"], removeds: ["많", ""])
        app.test(input: "is[ff", expecteds: [nil, nil, nil, "많", "많ㅏ"], markeds: [nil, nil, nil, nil, "ㅏ"], removeds: ["많", ""])
        app.test(input: "isff", expecteds: [nil, nil, "만", "만ㅏ"], markeds: [nil, nil, nil, "ㅏ"], removeds: ["만", ""])
        app.test(input: "isf[s", expecteds: [nil, nil, nil, "많", "많ㄴ"], markeds: [nil, nil, nil, nil, "ㄴ"], removeds: ["많", ""])
        app.test(input: "is[fs", expecteds: [nil, nil, nil, "많", "많ㄴ"], markeds: [nil, nil, nil, nil, "ㄴ"], removeds: ["많", ""])
        app.test(input: "ifss", expecteds: [nil, nil, "만", "만ㄴ"], markeds: [nil, nil, nil, "ㄴ"], removeds: ["만", ""])
    }

    func test삶() {
        app.test(input: "nf[f", expecteds: [nil, nil, "삶", "삶"])
        app.test(input: "n[ff", expecteds: [nil, nil, "삶", "삶"])
        app.test(input: "nff[", expecteds: [nil, "사", "사ㅏ", "삶"])
        app.test(input: "f[n", expecteds: [nil, "ㅏㄻ", "삶"])
        app.test(input: "[fn", expecteds: [nil, "ㅏㄻ", "삶"])
        app.test(input: "[nf", expecteds: [nil, "ㅅ[", "삶"])
        app.test(input: "n[[f", expecteds: [nil, "ㅅ[", "ㅅ[[", "ㅅ[ㅏㄻ"])
        app.test(input: "f[[nf", expecteds: [nil, "ㅏㄻ", "ㅏㄻ[", "ㅏㄻㅅ[", "ㅏㄻ삶"], markeds: [nil, nil, "ㅏㄻ[", "ㅅ[", "삶"])
    }

    func test얹() {
        app.test(input: "jt[e", expecteds: [nil, nil, "엀", "얹"])
        app.test(input: "te[j", expecteds: [nil, "ㅓㅕ", "ㅓㄵ", "얹"])
    }
}

extension VirtualApp {
    func test(input: String, expecteds: [String?], markeds: [String?]? = nil, removeds: [String?]? = nil) {
        var results: [(Character, String)] = []

        func strokes() -> String {
            String(Array(results.map { $0.0 }))
        }

        XCTAssertEqual(client.string, "", "app.client.string is not cleared")
        for (i, keyChar) in input.enumerated() {
            let key = "\(keyChar)"
            results.append((keyChar, client.string))
            inputKeys(key)
            if let expected = expecteds[i] {
                XCTAssertEqual(expected, client.string, "strokes: \(strokes()) buffer: \(client.string) marked: \(client.markedString()) app: \(self)")
            }
            if let markeds = markeds {
                if let marked = markeds[i] {
                    XCTAssertEqual(marked, client.markedString(), "buffer: \(client.string) marked: \(client.markedString()) app: \(self)")
                }
            }
        }
        if var removeds = removeds {
            while let removed = removeds.first {
                removeds.remove(at: 0)
                inputDelete()
                XCTAssertEqual(removed, client.string, "buffer: \(client.string) marked: \(client.markedString()) app: \(self)")
            }
        } else {
            while let (keyChar, result) = results.popLast() {
                inputDelete()
                XCTAssertEqual(result, client.string, "strokes: \(strokes())<BS(\(keyChar))> buffer: \(client.string) marked: \(client.markedString()) app: \(self)")
            }
        }

        inputKey(.space)
        client.string = ""

        inputKeys(input)
        let result = client.string
        inputKey(.ansiK)
        inputDelete()
        XCTAssertEqual(result, client.string, "input: \(input) 'k' and delete fails buffer: \(client.string) marked: \(client.markedString()) app: \(self)")

        inputKey(.ansiF)
        inputDelete()
        XCTAssertEqual(result, client.string, "input: \(input) 'f' and delete fails buffer: \(client.string) marked: \(client.markedString()) app: \(self)")

        inputKey(.ansiS)
        inputDelete()
        XCTAssertEqual(result, client.string, "input: \(input) 's' and delete fails buffer: \(client.string) marked: \(client.markedString()) app: \(self)")

        inputKey(.space)
        client.string = ""
    }
}
