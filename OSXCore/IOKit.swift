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

enum IOError: Error {
    case kernel(kern_return_t)
}

public class IOConnect {
    let rawValue: io_connect_t

    init(rawValue: io_connect_t) {
        self.rawValue = rawValue
    }

    deinit {
        try? close()
        IOObjectRelease(rawValue)
    }

    public struct IOConnectSelector {
        let rawValue: Int32

        static let capsLock = IOConnectSelector(rawValue: Int32(kIOHIDCapsLockState))
        static let numLock = IOConnectSelector(rawValue: Int32(kIOHIDNumLockState))
        static let activityUserIdle = IOConnectSelector(rawValue: Int32(kIOHIDActivityUserIdle))
        static let activityDisplayOn = IOConnectSelector(rawValue: Int32(kIOHIDActivityDisplayOn))
    }

    public func close() throws {
        let kr = IOServiceClose(rawValue)
        guard kr == KERN_SUCCESS else {
            throw IOError.kernel(kr)
        }
    }

    public func getState(selector: IOConnectSelector) throws -> UInt32 {
        var state: UInt32 = 0
        let kr = IOHIDGetStateForSelector(rawValue, selector.rawValue, &state)
        if kr != KERN_SUCCESS {
            throw IOError.kernel(kr)
        }
        return state
    }

    public func setState(selector: IOConnectSelector, state: UInt32) throws {
        let kr = IOHIDSetStateForSelector(rawValue, selector.rawValue, state)
        if kr != KERN_SUCCESS {
            throw IOError.kernel(kr)
        }
    }

    public func getModifierLock(selector: IOConnectSelector) throws -> Bool {
        var state: Bool = false
        let kr = IOHIDGetModifierLockState(rawValue, selector.rawValue, &state)
        if kr != KERN_SUCCESS {
            throw IOError.kernel(kr)
        }
        return state
    }

    public func setModifierLock(selector: IOConnectSelector, state: Bool) throws {
        let kr = IOHIDSetModifierLockState(rawValue, selector.rawValue, state)
        if kr != KERN_SUCCESS {
            throw IOError.kernel(kr)
        }
    }
}

class IOService {
    let rawValue: io_service_t

    init?(port: mach_port_t, matching: NSDictionary?) {
        rawValue = IOServiceGetMatchingService(port, matching)
        guard rawValue != 0 else {
            return nil
        }
    }

    convenience init?(name: String) {
        self.init(port: kIOMasterPortDefault, matching: IOService.matching(name: name))
    }

    deinit {
        IOObjectRelease(rawValue)
    }

    static func matching(name: String) -> NSDictionary? {
        return IOServiceMatching(name)
    }

    func open(owningTask: mach_port_t, type: Int) throws -> IOConnect {
        var connect: io_connect_t = 0
        let kr = IOServiceOpen(rawValue, owningTask, UInt32(type), &connect)
        guard kr == KERN_SUCCESS else {
            throw IOError.kernel(kr)
        }
        return IOConnect(rawValue: connect)
    }
}

public extension IOHIDValueScaleType {
    static let Calibrated = kIOHIDValueScaleTypeCalibrated
    static let Physical = kIOHIDValueScaleTypePhysical
    static let Exponent = kIOHIDValueScaleTypeExponent
}

public extension IOHIDValue {
    typealias ScaleType = IOHIDValueScaleType
    typealias Callback = IOHIDValueCallback
    typealias MultipleCallback = IOHIDValueMultipleCallback

    var element: IOHIDElement {
        return IOHIDValueGetElement(self)
    }

    var timestamp: UInt64 {
        return IOHIDValueGetTimeStamp(self)
    }

    var length: CFIndex {
        return IOHIDValueGetLength(self)
    }

    var integerValue: CFIndex {
        return IOHIDValueGetIntegerValue(self)
    }

    func scaledValue(ofType type: ScaleType) -> Double {
        return IOHIDValueGetScaledValue(self, type)
    }
}

public extension IOHIDManager {
    class func create(options: IOOptionBits) -> IOHIDManager {
        return IOHIDManagerCreate(kCFAllocatorDefault, options)
    }

    class func create() -> IOHIDManager {
        return create(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func open() -> IOReturn {
        return open(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func open(options: IOOptionBits) -> IOReturn {
        return IOHIDManagerOpen(self, options)
    }

    func close() -> IOReturn {
        return close(options: IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func close(options: IOOptionBits) -> IOReturn {
        return IOHIDManagerClose(self, options)
    }

    func schedule(runloop: RunLoop, mode: RunLoop.Mode) {
        IOHIDManagerScheduleWithRunLoop(self, runloop.getCFRunLoop(), mode.rawValue as CFString)
    }

    func unschedule(runloop: RunLoop, mode: RunLoop.Mode) {
        IOHIDManagerUnscheduleFromRunLoop(self, runloop.getCFRunLoop(), mode.rawValue as CFString)
    }

    class func deviceMatching(page: Int, usage: Int) -> NSDictionary {
        return [
            kIOHIDDeviceUsagePageKey as NSString: NSNumber(value: page),
            kIOHIDDeviceUsageKey as NSString: NSNumber(value: usage),
        ]
    }

    class func inputValueMatching(min: Int, max: Int) -> NSDictionary {
        return [
            kIOHIDElementUsageMinKey as NSString: NSNumber(value: min),
            kIOHIDElementUsageMaxKey as NSString: NSNumber(value: max),
        ]
    }

    func setDeviceMatching(page: Int, usage: Int) {
        let deviceMatching = IOHIDManager.deviceMatching(page: page, usage: usage)
        IOHIDManagerSetDeviceMatching(self, deviceMatching)
    }

    func setInputValueMatching(min: Int, max: Int) {
        let inputValueMatching = IOHIDManager.inputValueMatching(min: min, max: max)
        IOHIDManagerSetInputValueMatching(self, inputValueMatching)
    }

    func registerInputValueCallback(_ callback: @escaping IOHIDValue.Callback, context: UnsafeMutableRawPointer?) {
        IOHIDManagerRegisterInputValueCallback(self, callback, context)
    }

    func unregisterInputValueCallback() {
        IOHIDManagerRegisterInputValueCallback(self, nil, nil)
    }
}
