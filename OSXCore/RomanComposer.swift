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

extension Character {
    /// 문자가 소문자인지 나타낸다.
    var isLowercaseCharacter: Bool {
        return self >= "a" && self <= "z"
    }
}

/// 로마자 합성기의 종류를 정의한 열거형.
///
/// 각 케이스의 원시 값은 그에 대응하는 키보드 식별자를 나타낸다.
enum RomanComposerType: String {
    /// 쿼티 자판.
    case qwerty
    /// 드보락 자판.
    case dvorak
    /// 콜맥 자판.
    case colemak
}

// MARK: - RomanComposer 클래스

/// 로마자 합성기 오브젝트.
final class RomanComposer: Composer {
    private var _commitString: String?
    private var _composerType: RomanComposerType

    init(composer romanComposerType: RomanComposerType) {
        _composerType = romanComposerType
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

        if !string.isEmpty, keyCode.isKeyMappable, !flags.contains(.option) {
            if _composerType == .qwerty {
                var newString = string
                let chr = string.first!
                if flags.contains(.capsLock), chr.isLowercaseCharacter {
                    let newChr = Character(UnicodeScalar(String(chr).unicodeScalars.first!.value - 0x20)!)
                    newString = String(newChr)
                    _commitString = newString
                    return .processed
                }
            } else {
                let qwerty = RomanComposerType.qwerty.keyboardData
                let keyboardData = _composerType.keyboardData
                let map = zip(qwerty, keyboardData).reduce(into: [:]) { $0[$1.0] = $1.1 }

                let newChr: Character
                let chr = string.first!
                if flags.contains(.capsLock), chr.isLowercaseCharacter {
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
            }
        }
        _commitString = nil
        return .notProcessed
    }
}

// MARK: - RomanComposerType 열거형 확장

extension RomanComposerType {
    /// 자판 배열 데이터.
    var keyboardData: String {
        switch self {
        case .qwerty:
            return ["`1234567890-=\\",
                    "qwertyuiop[]",
                    "asdfghjkl;'",
                    "zxcvbnm,./",
                    "~!@#$%^&*()_+|",
                    "QWERTYUIOP{}",
                    "ASDFGHJKL:\"",
                    "ZXCVBNM<>?"].reduce("", +)
        case .dvorak:
            return ["`1234567890[]\\",
                    "',.pyfgcrl/=",
                    "aoeuidhtns-",
                    ";qjkxbmwvz",
                    "~!@#$%^&*(){}|",
                    "\"<>PYFGCRL?+",
                    "AOEUIDHTNS_",
                    ":QJKXBMWVZ"].reduce("", +)
        case .colemak:
            return ["`1234567890-=\\",
                    "qwfpgjluy;[]",
                    "arstdhneio'",
                    "zxcvbkm,./",
                    "~!@#$%^&*()_+|",
                    "QWFPGJLUY:{}",
                    "ARSTDHNEIO\"",
                    "ZXCVBKM<>?"].reduce("", +)
        }
    }
}
