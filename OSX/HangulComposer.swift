//
//  HangulComposer.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 8. 13..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objcMembers public class HangulComposerBridge: NSObject {
    unowned let composer: CIMComposerDelegate
    
    public init(composer: CIMComposerDelegate) {
        self.composer = composer
        super.init()
    }

    // CIMComposerDelegate

    public func inputController(_ controller: CIMInputController!, inputText string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        let _self = self.composer as! HangulComposer
        // libhangul은 backspace를 키로 받지 않고 별도로 처리한다.
        if (keyCode == kVK_Delete) {
            return _self.inputContext.backspace() ? CIMInputTextProcessResult.processed : CIMInputTextProcessResult.notProcessed
        }

        if (keyCode > 50 || keyCode == kVK_Delete || keyCode == kVK_Return || keyCode == kVK_Tab || keyCode == kVK_Space) {
            //dlog(DEBUG_HANGULCOMPOSER, @" ** ESCAPE from outbound keyCode: %lu", keyCode);
            return CIMInputTextProcessResult.notProcessedAndNeedsCommit;
        }

        var string = string!
        // 한글 입력에서 캡스락 무시
        if flags.contains(.capsLock) {
            if !flags.contains(.shift) {
                string = string.lowercased();
            }
        }
        let handled = _self.inputContext.process(string.first!.unicodeScalars.first!.value)
        let UCSString = _self.inputContext.commitUCSString;
        // dassert(UCSString);
        let recentCommitString = HangulComposer.commitStringByCombinationMode(withUCSString: UCSString)
        _self.commitString.append(recentCommitString)
        // dlog(DEBUG_HANGULCOMPOSER, @"HangulComposer -inputText: string %@ (%@ added)", self->_commitString, recentCommitString);
        return handled ? .processed : .notProcessedAndNeedsCancel;
    }
    
    public var composedString: String!
    
    public func originalString() -> String! {
        let _self = self.composer as! HangulComposer
        let preedit = _self.inputContext.preeditUCSString
        return HangulComposer.commitStringByCombinationMode(withUCSString: preedit)
    }
    
    public var commitString: String!
    
    public func dequeueCommitString() -> String! {
        let queuedCommitString = commitString
        commitString = ""
        return queuedCommitString
    }
    
    public func cancelComposition() {
        let _self = self.composer as! HangulComposer
        let flushedString: String! = HangulComposer.commitStringByCombinationMode(withUCSString: _self.inputContext.flushUCSString())
        
        _self.commitString.append(flushedString)    // 기본 _commitString 입니다.
    }
    
    public func clearContext() {

    }
    
    public var hasCandidates: Bool = false
    
    public func inputController(_ controller: CIMInputController!, command string: String!, key keyCode: Int, modifier flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        return CIMInputTextProcessResult.notProcessed
    }
}
