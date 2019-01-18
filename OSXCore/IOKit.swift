//
//  IOKitUtility.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 9. 1..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import IOKit
import IOKit.hid
import IOKit.hidsystem

class IOKitError: Error {
    init() {}
}

public extension io_connect_t {
    func close() -> IOReturn {
        return IOServiceClose(self)
    }

    func getModifierLockState(_ selector: Int) -> (kern_return_t, Bool) {
        var state: Bool = false
        let kr = IOHIDGetModifierLockState(self, Int32(selector), &state)
        return (kr, state)
    }

    func setModifierLockState(_ selector: Int, state: Bool) -> kern_return_t {
        return IOHIDSetModifierLockState(self, Int32(selector), state)
    }
}

@objcMembers class IOConnect: NSObject {
    let id: io_connect_t

    init(id: io_connect_t) {
        self.id = id
    }

    deinit {
        _ = self.id.close()
    }

    var capsLockState: Bool {
        get {
            let (kr, state) = id.getModifierLockState(kIOHIDCapsLockState)
            guard kr == KERN_SUCCESS else {
                return false
            }
            return state
        }
        set {
            let kr = id.setModifierLockState(kIOHIDCapsLockState, state: newValue)
            // NSLog("set capslock state: \(newValue) \(kr == KERN_SUCCESS)")
        }
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
        let r = IOServiceOpen(id, owningTask, UInt32(type), &connectId)
        guard r == KERN_SUCCESS else {
            return nil
        }
        return IOConnect(id: connectId)
    }
}

public extension IOHIDValue {
    public typealias Callback = IOHIDValueCallback
    public typealias MultipleCallback = IOHIDValueMultipleCallback

    var element: IOHIDElement {
        return IOHIDValueGetElement(self)
    }

    var length: CFIndex {
        return IOHIDValueGetLength(self)
    }

    var integerValue: CFIndex {
        return IOHIDValueGetIntegerValue(self)
    }
}

public extension IOHIDManager {
    public class func create(options: IOOptionBits) -> IOHIDManager {
        return IOHIDManagerCreate(kCFAllocatorDefault, options)
    }

    public class func create() -> IOHIDManager {
        return create(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func open() -> IOReturn {
        return open(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func open(options: IOOptionBits) -> IOReturn {
        return IOHIDManagerOpen(self, options)
    }

    public func close() -> IOReturn {
        return close(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func close(options: IOOptionBits) -> IOReturn {
        return IOHIDManagerClose(self, options)
    }

    public func schedule(runloop: RunLoop, mode: RunLoop.Mode) {
        IOHIDManagerScheduleWithRunLoop(self, runloop.getCFRunLoop(), mode.rawValue as CFString)
    }

    public func unschedule(runloop: RunLoop, mode: RunLoop.Mode) {
        IOHIDManagerUnscheduleFromRunLoop(self, runloop.getCFRunLoop(), mode.rawValue as CFString)
    }

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

    public func registerInputValueCallback(_ callback: @escaping IOHIDValue.Callback, context: UnsafeMutableRawPointer?) {
        IOHIDManagerRegisterInputValueCallback(self, callback, context)
    }

    public func unregisterInputValueCallback() {
        IOHIDManagerRegisterInputValueCallback(self, nil, nil)
    }
}
