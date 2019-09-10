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
        let versionInfoString = """
        {
            "version": "1.10.0",
            "description": "Mojave 대응을 포함한 대형 업데이트",
            "url": "https://github.com/gureum/gureum/releases/tag/1.10.0"
        }
        """
        guard let versionInfoJSON = try? JSONSerialization.jsonObject(with: versionInfoString) as? [String: String] else {
            XCTFail()
            return
        }
        let versionInfo = UpdateManager.VersionInfo(data: versionInfoJSON, experimental: true)
        UpdateManager.shared.notifyUpdate(info: versionInfo)
        XCTAssertEqual("최신 버전: 1.10.0 현재 버전: \(UpdateManager.bundleVersion ?? "-")\nMojave 대응을 포함한 대형 업데이트", lastNotification.informativeText)
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
            app.inputKey(.g)
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
            app.inputKey(.a, modifiers: .command)
            app.inputKey(.a, modifiers: .control)
            XCTAssertEqual("", app.client.string, "")
            XCTAssertEqual("", app.client.markedString(), "")
        }
    }

    func testCapslockRoman() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.m)
            app.inputKey(.r)
            app.inputKey(.number2)
            XCTAssertEqual("mr2", app.client.string, "buffer: \(app.client.string), app: \(app)")
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.m, modifiers: .capsLock)
            app.inputKey(.r, modifiers: .capsLock)
            app.inputKey(.number2, modifiers: .capsLock)
            XCTAssertEqual("MR2", app.client.string, "buffer: \(app.client.string), app: \(app)")
        }
    }

    func testHanjaSyllable() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.m)
            app.inputKey(.f)
            app.inputKey(.s)
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
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: .return, modifiers: .option)
            app.inputKey(.i)
            app.inputKey(.b)
            app.inputKey(.w)
            XCTAssertEqual("물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.n)
            app.inputKey(.b)
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
            app.inputKey(.i)
            XCTAssertEqual("水 ㅁ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("ㅁ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.b)
            app.inputKey(.w)
            XCTAssertEqual("水 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("水 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.n)
            app.inputKey(.b)
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
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            // hanja search mode
            app.inputText("\n", key: .return, modifiers: .option)
            app.inputText(" ", key: .space)
            app.inputKey(.a)
            app.inputKey(.n)
            app.inputKey(.f)
            XCTAssertEqual(" 물", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual(" 물 ", app.client.string, "buffer: \(app.client.string), app: \(app)")
            XCTAssertEqual("물 ", app.client.markedString(), "buffer: \(app.client.string), app: \(app)")
            app.inputKey(.t)
            app.inputKey(.n)
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
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue,
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

    func testBackQuoteHan2() {
        Configuration.shared.hangulWonCurrencySymbolForBackQuote = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.grave)
            XCTAssertEqual("₩", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.grave, modifiers: .shift)
            XCTAssertEqual("₩~", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteOnComposing() {
        Configuration.shared.hangulWonCurrencySymbolForBackQuote = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.r)
            app.inputKey(.k)
            XCTAssertEqual("가", app.client.string, "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.grave)
            XCTAssertEqual("가₩", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteQwerty() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.qwerty.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.grave)
            XCTAssertEqual("`", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBackQuoteHan3Final() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputText("`", key: .grave)
            XCTAssertEqual("*", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHan3Gureum() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.quote, modifiers: .shift)
            XCTAssertEqual("\"", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testDvorak() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.dvorak", forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.j)
            app.inputKey(.d)
            app.inputKey(.p)
            app.inputKey(.p)
            app.inputKey(.s)
            XCTAssertEqual("hello", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test3Number() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.han3final", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.k, modifiers: .shift)
            XCTAssertEqual("2", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testBlock() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue("org.youknowone.inputmethod.Gureum.qwerty", forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.m)
            app.inputKey(.f)
            app.inputKey(.s)
            app.inputKey(.k)
            app.inputKey(.g)
            app.inputKey(.w)
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
            app.inputKey(.m)
            app.inputKey(.f)
            app.inputKey(.s)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.k)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.g)
            XCTAssertEqual("한그", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("그", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.w)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.m)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.f)
            app.inputKey(.s)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.k)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.g)
            app.inputKey(.w)
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
            app.controller.setValue(GureumInputSourceIdentifier.colemak.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.h)
            app.inputKey(.k)
            app.inputKey(.u)
            app.inputKey(.u)
            app.inputKey(.semicolon)
            app.inputKey(.slash, modifiers: .shift)
            XCTAssertEqual("hello?", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func test2() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.g)
            app.inputKey(.k)
            app.inputKey(.s)
            XCTAssertEqual("한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.r)
            XCTAssertEqual("한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.m)
            app.inputKey(.f)
            XCTAssertEqual("한글", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("글", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("한글 ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputKey(.g)
            XCTAssertEqual("한글 ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅎ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.k)
            app.inputKey(.s)
            XCTAssertEqual("한글 한", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("한", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.r)
            XCTAssertEqual("한글 한ㄱ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㄱ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.m)
            app.inputKey(.f)
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
            app.controller.setValue(GureumInputSourceIdentifier.han3Final.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.m)
            app.inputKey(.r)
            app.inputKey(.number2)
            XCTAssertEqual("했", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("했", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.inputText(" ", key: .space)

            app.client.string = ""
            app.inputKey(.m, modifiers: .capsLock)
            app.inputKey(.r, modifiers: .capsLock)
            app.inputKey(.number2, modifiers: .capsLock)
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

            let composer = app.controller.receiver.composer
            let emoticonComposer = composer.emoticonComposer
            emoticonComposer.delegate = composer.delegate // roman?
            composer.delegate = emoticonComposer

            app.inputKey(.s)
            app.inputKey(.l)
            app.inputKey(.e)
            app.inputKey(.e)
            app.inputKey(.p)
            app.inputKey(.y)
            XCTAssertEqual("sleepy", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("sleepy ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.f)
            app.inputKey(.a)
            app.inputKey(.c)
            app.inputKey(.e)
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelectionChanged(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("sleepy face", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("sleepy face", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.controller.candidateSelected(NSAttributedString(string: "😪: sleepy face"))
            XCTAssertEqual("😪", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")

            app.client.string = ""
            app.inputKey(.h)
            app.inputKey(.u)
            app.inputKey(.s)
            app.inputKey(.h)
            app.inputKey(.e)
            app.inputKey(.d)
            XCTAssertEqual("hushed", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText(" ", key: .space)
            XCTAssertEqual("hushed ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("hushed ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.f)
            app.inputKey(.a)
            app.inputKey(.c)
            app.inputKey(.e)
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
            app.inputKey(.i)
            app.inputKey(.s)
            XCTAssertEqual("ㅑㄴ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let han2 = app.client.string
            app.inputText(" ", key: .space)

            // 세벌식 ㅑㄴ
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.number6)
            app.inputKey(.s)
            XCTAssertEqual(han2, app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testViModeEscape() {
        XCTAssertFalse(Configuration.shared.romanModeByEscapeKey)
        Configuration.shared.romanModeByEscapeKey = true
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.m)
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
            app.controller.setValue(GureumInputSourceIdentifier.han3FinalNoShift.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.m)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")

            let processed = app.inputKey(.leftBracket, modifiers: [.control])
            XCTAssertFalse(processed)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))

            app.inputKey(.leftBracket, modifiers: [.control, .shift])
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertTrue(app.controller.receiver.composer.inputMode.hasSuffix("qwerty"))
        }
    }

    func testHanClassic() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han3Classic.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)

            app.inputKey(.m)
            XCTAssertEqual("ㅎ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.f)
            XCTAssertEqual("하", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.f)
            XCTAssertEqual("ᄒᆞ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            app.inputKey(.s)
            XCTAssertEqual("ᄒᆞᆫ", app.client.string, "buffer: \(app.client.string) app: \(app)")
        }
    }

    func testHanDelete() {
        for app in apps {
            app.client.string = ""
            app.controller.setValue(GureumInputSourceIdentifier.han2.rawValue, forTag: kTextServiceInputModePropertyTag, client: app.client)
            app.inputKey(.d)
            XCTAssertEqual("ㅇ", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("ㅇ", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
            app.inputText("", key: .delete)
            XCTAssertEqual("", app.client.string, "buffer: \(app.client.string) app: \(app)")
            XCTAssertEqual("", app.client.markedString(), "buffer: \(app.client.string) app: \(app)")
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
