//
//  Preferences.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import Foundation

class Preferences {
    var defaults = NSUserDefaults(suiteName: "group.org.youknowone.test")

    func getObjectForKey(key: String, defaultValue: AnyObject) -> AnyObject {
        let result: AnyObject = self.defaults.objectForKey(key) ?? defaultValue
        return result
    }

    func getArrayForKey(key: String, defaultValue: Array<AnyObject>) -> Array<AnyObject> {
        let object = self.defaults.arrayForKey(key) as Array!
        if object == nil || object.count == 0 {
            return defaultValue
        }
        return object
    }

    func getDictionaryForKey(key: String, defaultValue: NSDictionary) -> AnyObject {
        let object = self.defaults.dictionaryForKey(key)
        if object == nil {
            return defaultValue
        }
        if object!.count == 0 {
            return defaultValue
        }
        return object!
    }

    func setObjectForKey(key: String, value: AnyObject) {
        self.defaults.setObject(value, forKey: key)
        assert(self.defaults.objectForKey(key) != nil)
        self.defaults.synchronize()
    }

    var layouts: Array<String> {
        get {
            let defaultValue: Array<AnyObject> = ["qwerty", "ksx5002", "emoticon"]
            let result = getArrayForKey("layouts", defaultValue: defaultValue)
            return result as AnyObject as Array<String>
        }

        set {
            setObjectForKey("layouts", value: newValue)
        }
    }

    var defaultLayoutIndex: Int {
        get {
            let defaultValue: AnyObject = NSNumber(integer: 1)
            let rawIndex = getObjectForKey("layoutindex", defaultValue: defaultValue) as NSNumber
            let index: Int = rawIndex.integerValue
            if index >= self.layouts.count {
                return self.layouts.count - 1
            } else {
                return index
            }
        }

        set {
            setObjectForKey("layoutindex", value: newValue)
        }
    }

    var themeAddress: String {
        get {
            let result: NSString = self.getObjectForKey("themeaddr", defaultValue: "res://default") as NSString
            return result as String
        }

        set {
            setObjectForKey("themeaddr", value: newValue)
        }
    }

    var theme: Theme {
        get {
            return PreferencedTheme()
        }
    }

    var themeResources: NSDictionary {
        get {
            return getDictionaryForKey("themeresource", defaultValue: [:]) as Dictionary<String, String>
        }

        set {
            // FIXME: Dictionary to NSDictioanry
            var dict: NSMutableDictionary = [:]
            for (key, value) in newValue {
                dict[key as String] = value
            }
            self.setObjectForKey("themeresource", value: dict)
        }
    }
}

let preferences = Preferences()

class PreferencedTheme: Theme {
    override func dataForFilename(name: String) -> NSData? {
        if let rawData = preferences.themeResources[name] as String? {
            let data = ThemeResourceCoder.defaultCoder().decodeToData(rawData)
            return data
        } else {
            return nil
        }
    }
}
