//
//  RomanComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2017. 7. 12..
//  Copyright © 2017년 youknowone.org. All rights reserved.
//

import Foundation


class QwertyComposer: CIMComposer {

    var _commitString: String? = nil

    override var composedString: String {
        get {
            return "";
        }
    }

    override var originalString: String {
        get {
            return self._commitString ?? "";
        }
    }

    override var commitString: String {
        get {
            return self._commitString ?? "";
        }
    }

    override func dequeueCommitString() -> String {
        let dequeued = self._commitString
        self._commitString = ""
        return dequeued ?? ""
    }

    override func cancelComposition() {
    }

    override func clearContext() {
        self._commitString = nil
    }

    override var hasCandidates: Bool {
        return false
    }

    override var candidates: [NSAttributedString]? {
        return nil
    }

    override func input(controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        guard let string = string else {
            assert(false)
            return .notProcessed
        }
        if !string.isEmpty && keyCode < 0x33 && !flags.contains(.option) {
            var newString = string
            let chr = string.first!
            if flags.contains(.capsLock) && "a" <= chr && chr <= "z" {
                let newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
                newString = String(newChr)
                self._commitString = newString
                return CIMInputTextProcessResult.processed;
            }
        }
        self._commitString = nil
        return CIMInputTextProcessResult.notProcessed
    }
    
}


class RomanDataComposer: CIMComposer {
    public static let dvorakData: String = ["`1234567890[]\\",
                                            "',.pyfgcrl/=",
                                            "aoeuidhtns-",
                                            ";qjkxbmwvz",
                                            "~!@#$%^&*(){}|",
                                            "\"<>PYFGCRL?+",
                                            "AOEUIDHTNS_",
                                            ":QJKXBMWVZ"].reduce("", +)
    public static let colemakData: String = ["`1234567890-=\\",
                                             "qwfpgjluy;[]",
                                             "arstdhneio'",
                                             "zxcvbkm,./",
                                             "~!@#$%^&*()_+|",
                                             "QWFPGJLUY:{}",
                                             "ARSTDHNEIO\"",
                                             "ZXCVBKM<>?"].reduce("", +)

    var _commitString: String? = nil
    var _keyboard: String = ""

    init(keyboardData: String) {
        super.init()
        self._keyboard = keyboardData
    }

    override var composedString: String {
        get {
            return "";
        }
    }

    override var originalString: String {
        get {
            return self._commitString ?? "";
        }
    }

    override var commitString: String {
        get {
            return self._commitString ?? "";
        }
    }

    override func dequeueCommitString() -> String {
        let dequeued = self._commitString
        self._commitString = nil
        return dequeued ?? ""
    }

    override func cancelComposition() {
    }

    override func clearContext() {
        self._commitString = nil
    }

    override var hasCandidates: Bool {
        return false
    }

    override var candidates: [NSAttributedString]? {
        return nil
    }

    override func input(controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        guard let string = string else {
            assert(false)
            return .notProcessed
        }

        let qwerty = ["`1234567890-=\\",
                      "qwertyuiop[]",
                      "asdfghjkl;'",
                      "zxcvbnm,./",
                      "~!@#$%^&*()_+|",
                      "QWERTYUIOP{}",
                      "ASDFGHJKL:\"",
                      "ZXCVBNM<>?"].reduce("", +)

        var map: [Character: Character] = [:]
        zip(qwerty, self._keyboard).forEach {
            map[$0] = $1
        }

        if !string.isEmpty && keyCode < 0x33 && !flags.contains(.option) {
            let newChr: Character
            let chr = string.first!
            if flags.contains(.capsLock) && "a" <= chr && chr <= "z" {
                newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
            } else {
                newChr = chr
            }
            self._commitString = String(map[newChr]!)
            return CIMInputTextProcessResult.processed
        } else {
            self._commitString = nil
            return CIMInputTextProcessResult.notProcessed
        }
    }

}
