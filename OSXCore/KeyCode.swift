//
//  KeyCode.swift
//  OSXCore
//
//  Created by Presto on 10/09/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

/// 키보드 레이아웃과 독립적인 키에 대한 키 코드를 정의한 열거형.
public enum KeyCode: Int {
    // MARK: ANSI-standard US keyboard

    case ansiA = 0x00
    case ansiS = 0x01
    case ansiD = 0x02
    case ansiF = 0x03
    case ansiH = 0x04
    case ansiG = 0x05
    case ansiZ = 0x06
    case ansiX = 0x07
    case ansiC = 0x08
    case ansiV = 0x09
    case ansiB = 0x0B
    case ansiQ = 0x0C
    case ansiW = 0x0D
    case ansiE = 0x0E
    case ansiR = 0x0F
    case ansiY = 0x10
    case ansiT = 0x11
    case ansi1 = 0x12
    case ansi2 = 0x13
    case ansi3 = 0x14
    case ansi4 = 0x15
    case ansi6 = 0x16
    case ansi5 = 0x17
    case ansiEqual = 0x18
    case ansi9 = 0x19
    case ansi7 = 0x1A
    case ansiMinus = 0x1B
    case ansi8 = 0x1C
    case ansi0 = 0x1D
    case ansiRightBracket = 0x1E
    case ansiO = 0x1F
    case ansiU = 0x20
    case ansiLeftBracket = 0x21
    case ansiI = 0x22
    case ansiP = 0x23
    case ansiL = 0x25
    case ansiJ = 0x26
    case ansiQuote = 0x27
    case ansiK = 0x28
    case ansiSemicolon = 0x29
    case ansiBackslash = 0x2A
    case ansiComma = 0x2B
    case ansiSlash = 0x2C
    case ansiN = 0x2D
    case ansiM = 0x2E
    case ansiPeriod = 0x2F
    case ansiGrave = 0x32
    case ansiKeypadDecimal = 0x41
    case ansiKeypadMultiply = 0x43
    case ansiKeypadPlus = 0x45
    case ansiKeypadClear = 0x47
    case ansiKeypadDivide = 0x4B
    case ansiKeypadEnter = 0x4C
    case ansiKeypadMinus = 0x4E
    case ansiKeypadEquals = 0x51
    case ansiKeypad0 = 0x52
    case ansiKeypad1 = 0x53
    case ansiKeypad2 = 0x54
    case ansiKeypad3 = 0x55
    case ansiKeypad4 = 0x56
    case ansiKeypad5 = 0x57
    case ansiKeypad6 = 0x58
    case ansiKeypad7 = 0x59
    case ansiKeypad8 = 0x5B
    case ansiKeypad9 = 0x5C

    // MARK: Keycodes for keys that are independent of keyboard layout

    case `return` = 0x24
    case tab = 0x30
    case space = 0x31
    case delete = 0x33
    case escape = 0x35
    case command = 0x37
    case shift = 0x38
    case capsLock = 0x39
    case option = 0x3A
    case control = 0x3B
    case rightCommand = 0x36
    case rightShift = 0x3C
    case rightOption = 0x3D
    case rightControl = 0x3E
    case function = 0x3F
    case f17 = 0x40
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
    case f18 = 0x4F
    case f19 = 0x50
    case f20 = 0x5A
    case f5 = 0x60
    case f6 = 0x61
    case f7 = 0x62
    case f3 = 0x63
    case f8 = 0x64
    case f9 = 0x65
    case f11 = 0x67
    case f13 = 0x69
    case f16 = 0x6A
    case f14 = 0x6B
    case f10 = 0x6D
    case f12 = 0x6F
    case f15 = 0x71
    case help = 0x72
    case home = 0x73
    case pageUp = 0x74
    case forwardDelete = 0x75
    case f4 = 0x76
    case end = 0x77
    case f2 = 0x78
    case pageDown = 0x79
    case f1 = 0x7A
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E

    // MARK: ISO keyboards only

    case isoSection = 0x0A

    // MARK: JIS keyboards only

    case jisYen = 0x5D
    case jisUnderscore = 0x5E
    case jisKeypadComma = 0x5F
    case jisEisu = 0x66
    case jisKana = 0x68
}

public extension KeyCode {
    /// 키보드 상에 있는 일반적인 키인지를 나타낸다.
    ///
    /// `KeyMapLower` 및 `KeyMapUpper`에 정의된 문자인지를 나타낸다.
    /// 일반적인 키보드 상에서 영문자, 숫자, 리턴, 탭, 스페이스, 역따옴표가 위치해 있는 키를 포함한다.
    var isNormal: Bool {
        return self <= .ansiGrave
    }

    /// 키보드 상에 있는 특수한 키인지를 나타낸다.
    ///
    /// `KeyMapLower` 및 `KeyMapUpper`에 정의되지 않은 문자인지를 나타낸다.
    var isSpecial: Bool {
        return self >= .delete
    }

    /// 방향키 위치에 있는 키들을 반환한다.
    ///
    /// `.upArrow`, `.downArrow`, `.leftArrow`, `.rightArrow` 케이스를 포함하는 키 코드 배열을 나타낸다.
    static let arrows: [KeyCode] = [.upArrow, .downArrow, .leftArrow, .rightArrow]
}

// MARK: - Comparable 프로토콜 준수

extension KeyCode: Comparable {
    public static func < (lhs: KeyCode, rhs: KeyCode) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
