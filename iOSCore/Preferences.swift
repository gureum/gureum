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

    func setObjectForKey(key: String, value: AnyObject) {
        self.defaults.setValue(value, forKey: key)
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

    var themeName: String {
    get {
        return getObjectForKey("themename", defaultValue: "default") as String
    }

    set {
        setObjectForKey("themename", value: newValue)
    }
    }

    var theme: Theme {
    get {
        let name = self.themeName
        let theme = Theme(name: name)
        return theme
    }
    }
}

let preferences = Preferences()
