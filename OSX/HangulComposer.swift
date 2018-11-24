//
//  HangulComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 8. 13..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation
import Hangul

let DEBUG_HANGULCOMPOSER = false

class HangulComposerCombination {
    /*!
     @brief  설정에 따라 조합 완료할 문자 최종처리
     */
    public class func commitString(ucsString: UnsafePointer<HGUCSChar>) -> String {
        return NSString.stringByRemovingFillerWithUCSString(ucsString) as String
    }

    /*!
     @brief  설정에 따라 조합중으로 보여줄 문자 최종처리
     */
    public class func composedString(ucsString: UnsafePointer<HGUCSChar>) -> String {
        return NSString.stringByRemovingFillerWithUCSString(ucsString) as String
    }
}

/*!
 @brief  libhangul을 사용하는 합성기

 libhangul의 input context를 사용하는 합성기이다. -init 로는 두벌식 합성기가 설정된다.

 @coclass HGInputContext
 */
@objcMembers public class HangulComposer: NSObject, CIMComposerDelegate {
    let inputContext: HGInputContext
    var _commitString: String
    let configuration = GureumConfiguration.shared

    init?(keyboardIdentifier: String) {
        self._commitString = String()
        guard let inputContext = HGInputContext(keyboardIdentifier: keyboardIdentifier) else {
            return nil
        }
        self.inputContext = inputContext
        self.inputContext.setOption(HANGUL_IC_OPTION_AUTO_REORDER, value: configuration.hangulAutoReorder)
        self.inputContext.setOption(HANGUL_IC_OPTION_NON_CHOSEONG_COMBI, value: configuration.hangulNonChoseongCombination)
        super.init()
        configuration.addObserver(self, forKeyPath: GureumConfigurationName.hangulAutoReorder.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        configuration.addObserver(self, forKeyPath: GureumConfigurationName.hangulNonChoseongCombination.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        configuration.addObserver(self, forKeyPath: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == GureumConfigurationName.hangulForceStrictCombinationRule.rawValue {
            let keyboard = GureumInputSourceIdentifier(rawValue: configuration.lastHangulInputMode)?.keyboardIdentifier ?? "2"
            self.setKeyboard(identifier: keyboard)
        } else {
            self.inputContext.setOption(HANGUL_IC_OPTION_AUTO_REORDER, value: configuration.hangulAutoReorder)
            self.inputContext.setOption(HANGUL_IC_OPTION_NON_CHOSEONG_COMBI, value: configuration.hangulNonChoseongCombination)
        }
    }

    deinit {
        configuration.removeObserver(self, forKeyPath: GureumConfigurationName.hangulAutoReorder.rawValue)
        configuration.removeObserver(self, forKeyPath: GureumConfigurationName.hangulNonChoseongCombination.rawValue)
        configuration.removeObserver(self, forKeyPath: GureumConfigurationName.hangulForceStrictCombinationRule.rawValue)
    }

    /*!
     @brief  현재 context의 배열을 바꾼다.
     @param  identifier  libhangul의 @ref hangul_ic_select_keyboard 를 참고한다.
     */
    public func setKeyboard(identifier: String) {
        if configuration.hangulForceStrictCombinationRule && (identifier == "39" || identifier == "3f") {
            let strictCombinationIdentifier = "\(identifier)s"
            self.inputContext.setKeyboardWithIdentifier(strictCombinationIdentifier)
        } else {
            self.inputContext.setKeyboardWithIdentifier(identifier)
        }
    }

    public var commitString: String {
        get{
            return self._commitString;
        }
    }

    // CIMComposerDelegate

    public func input(controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        // libhangul은 backspace를 키로 받지 않고 별도로 처리한다.
        if (keyCode == kVK_Delete) {
            return self.inputContext.backspace() ? CIMInputTextProcessResult.processed : CIMInputTextProcessResult.notProcessed
        }

        if (keyCode > 50 || keyCode == kVK_Delete || keyCode == kVK_Return || keyCode == kVK_Tab || keyCode == kVK_Space) {
            dlog(DEBUG_HANGULCOMPOSER, " ** ESCAPE from outbound keyCode: %lu", keyCode);
            return CIMInputTextProcessResult.notProcessedAndNeedsCommit;
        }

        var string = string!
        // 한글 입력에서 캡스락 무시
        if flags.contains(.capsLock) {
            if !flags.contains(.shift) {
                string = string.lowercased();
            }
        }
        let handled = self.inputContext.process(string.first!.unicodeScalars.first!.value)
        let UCSString = self.inputContext.commitUCSString
        let recentCommitString = HangulComposerCombination.commitString(ucsString: UCSString)
        if configuration.hangulWonCurrencySymbolForBackQuote && keyCode == kVK_ANSI_Grave && flags.isSubset(of: .capsLock) {
            if !handled {
                self._commitString += recentCommitString + "₩"
                return CIMInputTextProcessResult.processed
            } else if recentCommitString.last! == "`" {
                self._commitString += recentCommitString.dropLast() + "₩"
                return CIMInputTextProcessResult.processed
            }
        }

        self._commitString += recentCommitString
        // dlog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->_commitString, recentCommitString);
        return handled ? .processed : .notProcessedAndNeedsCancel;
    }

    public func input(controller: CIMInputController, command string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        assert(false)
        return .notProcessed;
    }

    public var composedString: String {
        get {
            let preedit = self.inputContext.preeditUCSString
            return HangulComposerCombination.composedString(ucsString: preedit)
        }
    }

    public var originalString: String {
        get {
            let preedit = self.inputContext.preeditUCSString
            return HangulComposerCombination.commitString(ucsString: preedit)
        }
    }

    public func dequeueCommitString() -> String {
        let queuedCommitString = self._commitString
        self._commitString = ""
        return queuedCommitString
    }

    public func cancelComposition() {
        let flushedString: String! = HangulComposerCombination.commitString(ucsString: self.inputContext.flushUCSString())
        self._commitString += flushedString
    }

    public func clearContext() {
        self.inputContext.reset()
        self._commitString = ""
    }

    public var hasCandidates: Bool {
        get {
            return false
        }
    }

    #if DEBUG
    public func candidateSelected(_ candidateString: NSAttributedString) {
        assert(false)
    }

    public func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        assert(false)
    }
    #endif
}

let table: [HGUCSChar:HGUCSChar]=[
    //{'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'}
    0x1161:0x314f, 0x1162:0x3150, 0x1163:0x3151,0x1164: 0x3152, 0x1165:0x3153, 0x1166:0x3154, 0x1167:0x3155, 0x1168:0x3156, 0x1169:0x3157, 0x116A:0x3158, 0x116B:0x3159,0x116C: 0x315a, 0x116D:0x315b, 0x116E:0x315c, 0x116F:0x315d, 0x1170:0x315e, 0x1171:0x315f, 0x1172:0x3160, 0x1173:0x3161, 0x1174:0x3162, 0x1175:0x3163,
    // {JONGSUNG ' ', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'}
    0x0000: 0x0000, 0x11A8 :0x3131, 0x11A9 :0x3132, 0x11AA :0x3133, 0x11AB :0x3134, 0x11AC:0x3135, 0x11AD:0x3136, 0x11AE:0x3137, 0x11AF:0x3139, 0x11B0:0x313a, 0x11B1:0x313b, 0x11B2:0x313c, 0x11B3:0x313d, 0x11B4:0x313e, 0x11B5:0x313f, 0x11B6:0x3140, 0x11B7:0x3141, 0x11B8:0x3142, 0x11B9:0x3144, 0x11BA:0x3145, 0x11BB:0x3146, 0x11BC:0x3147, 0x11BD:0x3148, 0x11BE:0x314a, 0x11BF:0x314b, 0x11C0:0x314c, 0x11C1:0x314d, 0x11C2:0x314e
]

//한글호환 자모 유니코드로 바꿔주는 함수
func convertUnicode(_ ucsString: UnsafePointer<HGUCSChar>)->UnsafeMutablePointer<HGUCSChar> {
    var index:Int = 0
    let newUcsString = UnsafeMutablePointer<HGUCSChar>.allocate(capacity: 4)
    while ucsString[index] != UInt32(0) {
        if let chr = table[ucsString[index]] {
            newUcsString[index] = chr
        } else {
            newUcsString[index] = ucsString[index]
        }
        index+=1
    }
    newUcsString[index] = UInt32(0)
    return newUcsString
}

extension NSString {
    @objc class func stringByRemovingFillerWithUCSString(_ ucsString: UnsafePointer<HGUCSChar>) -> NSString {

        // 채움문자로 조합 중 판별
        if !HGCharacterIsChoseong(ucsString[0]) {
            return NSString(ucsString: convertUnicode(ucsString))
        }
        if ucsString[0] == 0x115f {
            return NSString(ucsString: convertUnicode(ucsString) + 1)
        }
        
        /* if (UCSString[1] == 0x1160) */
        let fill: NSMutableString = NSMutableString(ucsString: ucsString, length: 1)
        fill.append(NSString(ucsString: ucsString + 2, length: 1) as String)
        return fill
    }
}
