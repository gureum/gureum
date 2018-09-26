//
//  CIMInputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objcMembers class CIMMockInputController: NSObject {
    @objc var _receiver: CIMInputReceiver
    
    @objc init(server: IMKServer, delegate: Any!, client: Any!) {
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
    
    @objc func client() -> Any {
        return self._receiver.inputClient
    }
    
    @objc func composer() -> CIMComposer {
        return self._receiver.composer
    }
    
    @objc func selectionRange() -> NSRange {
        return (self._receiver.inputClient as AnyObject).selectedRange
    }
}
