//
//  CIMComposer.swift
//  OSX
//
//  Created by Jeong YunWon on 20/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation

/*!
 @brief  일반적인 합성기 구조
 
 @warning    이 자체로는 동작하지 않는다. 상속하여 동작을 구현하거나 @ref CIMBaseComposer 를 사용한다.
 */
@objcMembers public class CIMComposer: NSObject, CIMComposerDelegate {
    public var delegate: CIMComposerDelegate! = nil
    public var inputMode: String = ""
    public var manager: CIMInputManager! = nil
    
    public var composedString: String {
        return delegate.composedString
    }
    
    public var originalString: String {
        return delegate.originalString
    }
    
    public var commitString: String {
        return delegate.commitString
    }
    
    public func dequeueCommitString() -> String {
        return delegate.dequeueCommitString()
    }

    public func cancelComposition() {
        delegate.cancelComposition()
    }
    
    public func clearContext() {
        delegate.clearContext()
    }
    
    public var hasCandidates: Bool {
        return delegate.hasCandidates
    }
    
    public var candidates: [String]? {
        return delegate.candidates ?? nil
    }
    
    public func candidateSelected(_ candidateString: NSAttributedString) {
        return delegate.candidateSelected!(candidateString)
    }
    
    public func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        return delegate.candidateSelectionChanged!(candidateString)
    }

    public func inputController(_ controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        return delegate.inputController(controller, inputText: string, key: keyCode, modifiers: flags, client: sender)
    }
    
    public func inputController(_ controller: CIMInputController, command string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        return delegate.inputController(controller, command: string, key: keyCode, modifiers: flags, client: sender)
    }
}

