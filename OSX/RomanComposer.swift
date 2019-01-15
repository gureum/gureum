//
//  RomanComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2017. 7. 12..
//  Copyright © 2017년 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

class QwertyComposer: CIMComposer {
    var _commitString: String?

    override var composedString: String {
        return ""
    }

    override var originalString: String {
        return self._commitString ?? ""
    }

    override var commitString: String {
        return self._commitString ?? ""
    }

    override func dequeueCommitString() -> String {
        let dequeued = _commitString
        _commitString = ""
        return dequeued ?? ""
    }

    override func cancelComposition() {}

    override func clearContext() {
        _commitString = nil
    }

    override var hasCandidates: Bool {
        return false
    }

    override var candidates: [NSAttributedString]? {
        return nil
    }

    override func input(controller _: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client _: Any) -> CIMInputTextProcessResult {
        guard let string = string else {
            assert(false)
            return .notProcessed
        }
        if !string.isEmpty, keyCode < 0x33, !flags.contains(.option) {
            var newString = string
            let chr = string.first!
            if flags.contains(.capsLock), "a" <= chr, chr <= "z" {
                let newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
                newString = String(newChr)
                _commitString = newString
                return CIMInputTextProcessResult.processed
            }
        }
        _commitString = nil
        return CIMInputTextProcessResult.notProcessed
    }
}

class RomanDataComposer: CIMComposer {
    static let dvorakData: String = ["`1234567890[]\\",
                                     "',.pyfgcrl/=",
                                     "aoeuidhtns-",
                                     ";qjkxbmwvz",
                                     "~!@#$%^&*(){}|",
                                     "\"<>PYFGCRL?+",
                                     "AOEUIDHTNS_",
                                     ":QJKXBMWVZ"].reduce("", +)
    static let colemakData: String = ["`1234567890-=\\",
                                      "qwfpgjluy;[]",
                                      "arstdhneio'",
                                      "zxcvbkm,./",
                                      "~!@#$%^&*()_+|",
                                      "QWFPGJLUY:{}",
                                      "ARSTDHNEIO\"",
                                      "ZXCVBKM<>?"].reduce("", +)

    var _commitString: String?
    var _keyboard: String = ""

    init(keyboardData: String) {
        super.init()
        _keyboard = keyboardData
    }

    override var composedString: String {
        return ""
    }

    override var originalString: String {
        return self._commitString ?? ""
    }

    override var commitString: String {
        return self._commitString ?? ""
    }

    override func dequeueCommitString() -> String {
        let dequeued = _commitString
        _commitString = nil
        return dequeued ?? ""
    }

    override func cancelComposition() {}

    override func clearContext() {
        _commitString = nil
    }

    override var hasCandidates: Bool {
        return false
    }

    override var candidates: [NSAttributedString]? {
        return nil
    }

    override func input(controller _: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client _: Any) -> CIMInputTextProcessResult {
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
        zip(qwerty, _keyboard).forEach {
            map[$0] = $1
        }

        if !string.isEmpty, keyCode < 0x33, !flags.contains(.option) {
            let newChr: Character
            let chr = string.first!
            if flags.contains(.capsLock), "a" <= chr, chr <= "z" {
                newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
            } else {
                newChr = chr
            }
            _commitString = String(map[newChr]!)
            return CIMInputTextProcessResult.processed
        } else {
            _commitString = nil
            return CIMInputTextProcessResult.notProcessed
        }
    }
}
