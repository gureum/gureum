//
//  CIMInputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objcMembers class CIMMockInputController: CIMInputController {
    @objc var _receiver: CIMInputReceiver
    
    @objc override init(server: IMKServer, delegate: Any!, client: Any!) {
        self._receiver = CIMInputReceiver(server: server, delegate: delegate, client: client)
        super.init()
    }
    
    @objc func repoduceTextLog(_ text: String) throws {
        for row in text.components(separatedBy: "\n") {
            guard let regex = try? NSRegularExpression(pattern: "LOGGING::([A-Z]+)::(.*)", options: []) else {
                throw NSException(name: NSExceptionName("CIMMockInputControllerLogParserError"), reason: "Log is not readable format", userInfo: nil) as! Error
            }
            let matches = regex.matches(in: row, options: [], range: NSRangeFromString(row))
            let type = matches[1]
            let data = matches[2]
            print("test: \(type) \(data)")
        }
    }
    
//    Implemented in objc file
//    @objc override func client() -> (IMKTextInput & NSObjectProtocol)! {
//        return self._receiver.inputClient
//    }
//
    @objc override var composer: CIMComposer {
        return self._receiver.composer
    }
    
    @objc override func selectionRange() -> NSRange {
        return (self._receiver.inputClient as AnyObject).selectedRange
    }
}

extension CIMMockInputController {
    @objc override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any!) -> Bool {
        print("** CIMInputController -inputText:key:modifiers:client  with string: \(string) / keyCode: \(keyCode) / modifier flags: \(flags) / client: \((self.client() as AnyObject).bundleIdentifier)(\((self.client() as AnyObject).class))")
        let v1 = (self._receiver.inputController(self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: NSEvent.ModifierFlags.RawValue(flags)), client: sender).rawValue)
        let v2 = (CIMInputTextProcessResult.notProcessed.rawValue)
        let processed: Bool = v1 > v2
        if !processed {
            //[self cancelComposition];
        }
        return processed
    }
    
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    @objc override func commitComposition(_ sender: Any) {
        self._receiver.commitCompositionEvent(sender, controller: self)
        // COMMIT triggered
    }
    
    
}
