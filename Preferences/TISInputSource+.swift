//
//  TISInputSource+.swift
//  Preferences
//
//  Created by Presto on 04/10/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import Foundation

// pod으로 설치하면 정상적으로 불러와지지 않는다
public extension TISInputSource {
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
        return property(forKey: kTISPropertyInputSourceIsEnabled as String) as! Bool
    }

    var identifier: String {
        return property(forKey: kTISPropertyInputSourceID as String) as! String
    }

    var localizedName: String {
        return property(forKey: kTISPropertyLocalizedName as String) as! String
    }
}
