//
//  Preferences.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import Foundation

class Preferences {
    var defaults = NSUserDefaults(suiteName: "group.org.youknowone.Gureum")

    func getObjectForKey(key: String, defaultValue: AnyObject) -> AnyObject {
        let object = self.defaults.objectForKey(key)
        if !object {
            return defaultValue
        }
        return object
    }

    func getArrayForKey(key: String, defaultValue: Array<AnyObject>) -> AnyObject {
        let object = self.defaults.arrayForKey(key) as Array!
        if !object || object.count == 0 {
            return defaultValue
        }
        return object
    }

    func getDictionaryForKey(key: String, defaultValue: Dictionary<String, AnyObject>) -> AnyObject {
        let object = self.defaults.dictionaryForKey(key) as Dictionary!
        if !object {
            return defaultValue
        }
        if object.count == 0 {
            return defaultValue
        }
        return object
    }

    func setObjectForKey(key: String, value: AnyObject) {
        self.defaults.setObject(value, forKey: key)
        assert(self.defaults.objectForKey(key) != nil)
        self.defaults.synchronize()
    }

    var layouts: Array<String> {
        get {
            return getArrayForKey("layouts", defaultValue: ["qwerty", "ksx5002", "emoticon"]) as Array<String>
        }

        set {
            setObjectForKey("layouts", value: newValue)
        }
    }

    var defaultLayoutIndex: Int {
        get {
            let index = getObjectForKey("layoutindex", defaultValue: NSNumber(integer: 1)) as NSNumber
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
            return getObjectForKey("themeaddr", defaultValue: "res://default") as String
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

    var themeResources: Dictionary<String, String> {
        get {
            return getDictionaryForKey("themeresource", defaultValue: [:]) as Dictionary<String, String>
        }

        set {
            // FIXME: Dictionary to NSDictioanry
            var dict: NSMutableDictionary = [:]
            for (key, value) in newValue {
                dict[key] = value
            }
            self.setObjectForKey("themeresource", value: dict)
        }
    }
}

let preferences = Preferences()
