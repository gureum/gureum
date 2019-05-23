//
//  TISInputSource.swift
//  OSXCore
//
//  Created by Jeong YunWon on 13/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import CoreFoundation

class TISProperty {
    static let InputSourceIsEnabled = kTISPropertyInputSourceIsEnabled as String
    static let InputSourceID = kTISPropertyInputSourceID as String
    static let LocalizedName = kTISPropertyLocalizedName as String
}

extension TISInputSource {
    class func currentKeyboard() -> TISInputSource? {
        guard let unmanaged = TISCopyCurrentKeyboardInputSource() else {
            return nil
        }
        return unmanaged.takeRetainedValue()
    }

    class func currentKeyboardLayout() -> TISInputSource? {
        guard let unmanaged = TISCopyCurrentKeyboardLayoutInputSource() else {
            return nil
        }
        return unmanaged.takeRetainedValue()
    }

    class func sources(withProperties properties: NSDictionary, includeAllInstalled: Bool) -> [TISInputSource]? {
        guard let unmanaged = TISCreateInputSourceList(properties, includeAllInstalled) else {
            return nil
        }
        return unmanaged.takeRetainedValue() as? [TISInputSource]
    }

    func property(forKey key: String) -> Any? {
        guard let unmanaged = TISGetInputSourceProperty(self, key as CFString) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(unmanaged).takeUnretainedValue()
    }

    var enabled: Bool {
        return property(forKey: TISProperty.InputSourceIsEnabled) as! Bool
    }

    var identifier: String {
        return property(forKey: TISProperty.InputSourceID) as! String
    }

    var localizedName: String {
        return property(forKey: TISProperty.LocalizedName) as! String
    }
}
