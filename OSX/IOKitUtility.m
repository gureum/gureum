//
//  IOKitUtility.m
//  OSX
//
//  Created by Jeong YunWon on 2018. 9. 1..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

#import "IOKitUtility.h"

#define IOKIT_DEBUG 0

NSEventModifierFlags CurrentModifierFlags() {
    NSMutableDictionary *serviceMatchingOptions = (NSMutableDictionary *)IOServiceMatching(kIOHIDSystemClass);
    dlog(IOKIT_DEBUG, @"options: %@", serviceMatchingOptions);
    const io_service_t ios = IOServiceGetMatchingService(kIOMasterPortDefault, (CFDictionaryRef)serviceMatchingOptions);
    if (!ios) {
        if (serviceMatchingOptions) {
            CFRelease(serviceMatchingOptions);
        }
        return 0;
    }
    io_connect_t ioc;
    kern_return_t kr;
    kr = IOServiceOpen(ios, mach_task_self(), kIOHIDParamConnectType, &ioc);
    IOObjectRelease(ios);
    if (kr != KERN_SUCCESS) {
        return 0;
    }
    bool state;
    kr = IOHIDGetModifierLockState(ioc, kIOHIDCapsLockState, &state);
    dassert(kr == KERN_SUCCESS);
    IOServiceClose(ioc);
    if (state) {
        return NSAlphaShiftKeyMask;
    } else {
        return 0;
    }
}
