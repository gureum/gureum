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

    var layouts: Array<String> {
    get {
        let layouts = self.defaults.arrayForKey("layouts") as Array<String>?
        if !layouts || layouts?.count == 0 {
            return ["qwerty", "2set", "emoticon"]
        }
        return layouts!
    }

    set {
        self.defaults.setValue(newValue, forKey: "layouts")
        self.defaults.synchronize()
    }
    }

    var defaultLayoutIndex: Int {
    get {
        let saved = self.defaults.objectForKey("layoutindex") as NSNumber!
        let index: Int = saved ? saved.integerValue : 1
        if index >= self.layouts.count {
            return self.layouts.count - 1
        } else {
            return index
        }
    }

    set {
        self.defaults.setInteger(newValue, forKey: "layoutindex")
        self.defaults.synchronize()
    }
    }
}

let preferences = Preferences()
