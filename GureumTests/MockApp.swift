//
//  MockApp.swift
//  OSXCore
//
//  Created by Jeong YunWon on 13/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation
@testable import GureumCore

class VirtualApp: NSObject {
    let controller: MockInputController
    let client = MockInputClient()

    override init() {
        controller = MockInputController(server: InputMethodServer.shared.server, delegate: client, client: client)
        super.init()
    }

    @discardableResult
    func inputFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
        let processed = controller.inputFlags(Int(flags.rawValue), client: client)
        controller.updateComposition()
        return processed
    }

    @discardableResult
    func inputText(_ string: String!, key keyCode: KeyCode, modifiers flags: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)) -> Bool {
        let processed = controller.inputText(string, key: keyCode.rawValue, modifiers: Int(flags.rawValue), client: client)
        controller.updateComposition()
        return processed
    }

    @discardableResult
    func inputDelete() -> Bool {
        inputText("", key: .delete)
    }

    @discardableResult
    func inputKey(_ keyCode: KeyCode, modifiers flags: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)) -> Bool {
        var string: String?
        if keyCode.isKeyMappable {
            string = KeyMapLower[keyCode.rawValue]
            if !flags.intersection([.shift]).isEmpty {
                string = KeyMapUpper[keyCode.rawValue]
            }
        } else if keyCode == .delete {
            string = ""
        }
        return inputText(string, key: keyCode, modifiers: flags)
    }

    func inputKeys(_ keys: String) {
        for c in keys {
            let (keyCode, modifiers) = KeyMapReversed["\(c)"]!
            inputKey(keyCode, modifiers: modifiers)
        }
    }
}

class ModerateApp: VirtualApp {
    override func inputText(_ string: String!, key keyCode: KeyCode, modifiers flags: NSEvent.ModifierFlags) -> Bool {
        let processed = super.inputText(string, key: keyCode, modifiers: flags)
        let specialFlags = flags.intersection([.command, .control])

        if !processed {
            if specialFlags.isEmpty, string ?? "" != "" {
                client.insertText(string, replacementRange: client.markedRange())
            } else if keyCode == .delete, !client.string.isEmpty {
                client.string.removeLast()
            }
        }
        return processed
    }
}

/*
 @implementation TerminalApp

 - (BOOL)inputText:(NSString *)text key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags {
 BOOL processed = NO;
 if (self.client.hasMarkedText) {
     processed = [super inputText:text key:keyCode modifiers:flags];
     if (keyCode == 36) {
         processed = YES;
     }
 }
 else {
     if (keyCode == 36) {
         [self.client insertText:text];
         processed = YES;
     } else {
         processed = [super inputText:text key:keyCode modifiers:flags];
     }
 }
 if (!processed) {
     [self.client insertText:text replacementRange:self.client.markedRange];
 }
 return processed;
 }

 @end

 @implementation GreedyApp

 - (BOOL)inputText:(NSString *)text key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags {
 BOOL processed = NO;
 if (self.client.hasMarkedText) {
     processed = [super inputText:text key:keyCode modifiers:flags];
 }
 else {
     processed = [super inputText:text key:keyCode modifiers:flags];
     if (self.client.markedRange.length == 0 || !processed) {
         // FIXME: Commited string should be removed too.
         [self.client insertText:text replacementRange:self.client.markedRange];
     }
 }
 return processed;
 }

 @end
 */
