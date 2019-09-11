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

protocol RomanComposer: Composer {}

final class QwertyComposer: RomanComposer {
    private var _commitString: String?

    // MARK: Composer 프로토콜 구현

    var composedString: String {
        return ""
    }

    var originalString: String {
        return _commitString ?? ""
    }

    var commitString: String {
        return _commitString ?? ""
    }

    var hasCandidates: Bool {
        return false
    }

    var candidates: [NSAttributedString]? {
        return nil
    }

    func dequeueCommitString() -> String {
        let dequeued = _commitString
        _commitString = ""
        return dequeued ?? ""
    }

    func clearCompositionContext() {
        _commitString = nil
    }

    func cancelComposition() {}

    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client _: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        guard let string = string else {
            assert(false)
            return .notProcessed
        }
        if !string.isEmpty, keyCode.isKeyMappable, !flags.contains(.option) {
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

final class RomanDataComposer: RomanComposer {
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

    private var _commitString: String?
    private var _keyboard: String = ""

    init(keyboardData: String) {
        _keyboard = keyboardData
    }

    // MARK: Composer 프로토콜 구현

    var composedString: String {
        return ""
    }

    var originalString: String {
        return _commitString ?? ""
    }

    var commitString: String {
        return _commitString ?? ""
    }

    var hasCandidates: Bool {
        return false
    }

    var candidates: [NSAttributedString]? {
        return nil
    }

    func dequeueCommitString() -> String {
        let dequeued = _commitString
        _commitString = nil
        return dequeued ?? ""
    }

    func cancelComposition() {}

    func clearCompositionContext() {
        _commitString = nil
    }

    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client _: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
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

        if !string.isEmpty, keyCode.isKeyMappable, !flags.contains(.option) {
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
