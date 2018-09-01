//
//  CIMBaseComposer.swift
//  OSX
//
//  Created by 김민주 on 2018. 9. 1..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objcMembers class CIMBaseComposer {
    
    func composedString() -> NSString {
        return "";
    }

    func originalString() -> NSString {
        return "";
    }

    func commitString() -> NSString {
        return "";
    }
    
    func dequeueCommitString() -> NSString {
        return "";
    }
    
    func cancelComposition() -> Void { }

    func clearContext() -> Void { }
    
    func hasCandidates() -> Bool { return false; }
    
    func candidates() -> NSArray? {
        return nil;
    }
    
    public func inputController(_ controller: CIMInputController!, command string: String!, key keyCode: Int, modifier flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        return CIMInputTextProcessResult.notProcessed
    }
}
