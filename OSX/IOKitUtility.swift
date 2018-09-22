//
//  IOKitUtility.swift
//  OSX
//
//  Created by Jeong YunWon on 2018. 9. 1..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

class IOKitError: Error {
    init() {}
}

@objcMembers class IOConnect: NSObject {
    let id: io_connect_t

    init(id: io_connect_t) {
        self.id = id
    }

    deinit {
        IOServiceClose(self.id)
    }

    @objc var capsLockState: Bool {
        get {
            var state: Bool = false
            let kr = IOHIDGetModifierLockState(self.id, Int32(kIOHIDCapsLockState), &state);
            guard kr == KERN_SUCCESS else {
                return false
            }
            return state
        }
    }
    
    @objc func setCapsLockLed(_ state: Bool) {
        IOHIDSetModifierLockState(self.id, Int32(kIOHIDCapsLockState), state);
    }
}

@objcMembers class IOService: NSObject {
    let id: io_service_t

    init(id: io_service_t) {
        self.id = id
    }
    convenience init(port: mach_port_t, matching: NSDictionary?) throws {
        let id = IOServiceGetMatchingService(port, matching)
        if id == 0 {
            throw IOKitError()
        }
        self.init(id: id)
    }
    convenience init(name: String) throws {
        let matching = IOServiceMatching(name);
        try! self.init(port: kIOMasterPortDefault, matching: matching)
    }

    deinit {
        IOObjectRelease(self.id);
    }

    func open(owningTask: mach_port_t, type: Int) -> IOConnect? {
        var connect_id: io_connect_t = 0
        let r = IOServiceOpen(self.id, owningTask, UInt32(type), &connect_id)
        guard r == KERN_SUCCESS else {
            return nil
        }
        return IOConnect(id: connect_id)
    }
}
