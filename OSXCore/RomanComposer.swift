//
//  RomanComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2017. 7. 12..
//  Copyright © 2017년 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation
import InputMethodKit

class QwertyComposer: DelegatedComposer {
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

    override func input(text string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client _: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        guard let string = string else {
            assert(false)
            return .notProcessed
        }
        if !string.isEmpty, keyCode < 0x33, !flags.contains(.option) {
            var newString = string
            let chr = string.first!
            if flags.contains(.capsLock), chr >= "a", chr <= "z" {
                let newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
                newString = String(newChr)
                _commitString = newString
                return .processed
            }
        }
        _commitString = nil
        return .notProcessed
    }
}

class RomanDataComposer: DelegatedComposer {
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

    override func input(text string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client _: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
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
            if flags.contains(.capsLock), chr >= "a", chr <= "z" {
                newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
            } else {
                newChr = chr
            }

            guard let mappedChr = map[newChr] else {
                _commitString = nil
                return .notProcessed
            }

            _commitString = String(mappedChr)
            return .processed
        } else {
            _commitString = nil
            return .notProcessed
        }
    }
}
