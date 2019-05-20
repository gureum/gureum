//
//  IOKitUtility.swift
//  Gureum
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
            let kr = IOHIDGetModifierLockState(self.id, Int32(kIOHIDCapsLockState), &state)
            guard kr == KERN_SUCCESS else {
                return false
            }
            return state
        }
    }
    
    @objc func setCapsLockLed(_ state: Bool) {
        IOHIDSetModifierLockState(self.id, Int32(kIOHIDCapsLockState), state)
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
        let matching = IOServiceMatching(name)
        try! self.init(port: kIOMasterPortDefault, matching: matching)
    }

    deinit {
        IOObjectRelease(self.id)
    }

    func open(owningTask: mach_port_t, type: Int) -> IOConnect? {
        var connectId: io_connect_t = 0
        let r = IOServiceOpen(self.id, owningTask, UInt32(type), &connectId)
        guard r == KERN_SUCCESS else {
            return nil
        }
        return IOConnect(id: connectId)
    }
}

extension IOHIDManager {

    public class func deviceMatching(page: Int, usage: Int) -> NSDictionary {
        return [
            kIOHIDDeviceUsagePageKey as NSString: NSNumber(value: page),
            kIOHIDDeviceUsageKey as NSString: NSNumber(value: usage),
        ]
    }

    public class func inputValueMatching(min: Int, max: Int) -> NSDictionary {
        return [
            kIOHIDElementUsageMinKey as NSString: NSNumber(value: min),
            kIOHIDElementUsageMaxKey as NSString: NSNumber(value: max),
        ]
    }

    public func setDeviceMatching(page: Int, usage: Int) {
        let deviceMatching = IOHIDManager.deviceMatching(page: page, usage: usage)
        IOHIDManagerSetDeviceMatching(self, deviceMatching)
    }

    public func setInputValueMatching(min: Int, max: Int) {
        let inputValueMatching = IOHIDManager.inputValueMatching(min: min, max: max)
        IOHIDManagerSetInputValueMatching(self, inputValueMatching)
    }

    public class func capsLockManager() -> IOHIDManager {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        manager.setDeviceMatching(page: kHIDPage_GenericDesktop, usage: kHIDUsage_GD_Keyboard)
        manager.setInputValueMatching(min: kHIDUsage_KeyboardCapsLock, max: kHIDUsage_KeyboardCapsLock)
        return manager
    }
}

@objc public class IOHIDManagerBridge: NSObject {

    @objc public class func capsLockManager() -> IOHIDManager {
        return IOHIDManager.capsLockManager()
    }
}
