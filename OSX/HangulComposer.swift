//
//  HangulComposer.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 8. 13..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objc public class HangulComposerBridge: NSObject {
    unowned let composer: CIMComposerDelegate

    @objc public init(composer: CIMComposerDelegate) {
        self.composer = composer
        super.init()
    }

    // CIMComposerDelegate

    public func inputController(_ controller: CIMInputController!, inputText string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        return CIMInputTextProcessResult.notProcessed
    }
    
    public var composedString: String!
    
    public var originalString: String!
    
    public var commitString: String!
    
    public func dequeueCommitString() -> String! {
        return ""
    }
    
    public func cancelComposition() {

    }
    
    public func clearContext() {

    }
    
    public var hasCandidates: Bool = false
    
    public func inputController(_ controller: CIMInputController!, command string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        return CIMInputTextProcessResult.notProcessed
    }
}
