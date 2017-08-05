//
//  DvorakComposer.swift
//  Gureum
//
//  Created by Jeong YunWon on 2017. 7. 12..
//  Copyright © 2017년 youknowone.org. All rights reserved.
//

import Foundation


class RomanComposer: CIMComposer {

    var _commitString: String? = nil

    override var composedString: String! {
        get {
            return "";
        }
    }

    override var originalString: String! {
        get {
            return self._commitString ?? "";
        }
    }

    override var commitString: String! {
        get {
            return self._commitString ?? "";
        }
    }

    override func dequeueCommitString() -> String! {
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
        get {
            return false
        }
    }

    override var candidates: [Any]! {
        return nil
    }

/*
    #pragma -

    - (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    if (string.length > 0 && keyCode < 0x33 && !(flags & NSAlternateKeyMask)) {
    unichar chr = [string characterAtIndex:0];
    if (flags & NSAlphaShiftKeyMask && 'a' <= chr && chr <= 'z') {
    chr -= 0x20;
    string = [NSString stringWithCharacters:&chr length:1];
    }
    self._commitString = string;
    return CIMInputTextProcessResultProcessed;
    } else {
    self._commitString = nil;
    return CIMInputTextProcessResultNotProcessed;
    }
    }
*/
    
}
