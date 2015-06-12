//
//  Preferences.swift
//  Gureum
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import Foundation

class Preferences {
    var defaults = NSUserDefaults(suiteName: "group.org.gureum")!
    lazy var theme = PreferencedTheme()

    func getObjectForKey(key: String, defaultValue: AnyObject) -> AnyObject {
        let result: AnyObject = self.defaults.objectForKey(key) ?? defaultValue
        return result
    }

    func getArrayForKey(key: String, defaultValue: [AnyObject]) -> [AnyObject] {
        let object = self.defaults.arrayForKey(key) as Array!
        if object == nil || object.count == 0 {
            return defaultValue
        }
        return object
    }

    func getDictionaryForKey(key: String, defaultValue: NSDictionary) -> NSDictionary {
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
        self.defaults.setObject(NSDate(), forKey: "edited_time")
        self.defaults.synchronize()
    }

    var layouts: Array<String> {
        get {
            let defaultValue = ["qwerty", "ksx5002"]
            let result = getArrayForKey("layouts", defaultValue: defaultValue) as! Array<String>
            return result
        }

        set {
            setObjectForKey("layouts", value: newValue)
        }
    }

    var defaultLayoutIndex: Int {
        get {
            let index = getObjectForKey("layout_index", defaultValue: 1) as! Int
            if index >= self.layouts.count {
                return self.layouts.count - 1
            } else {
                return index
            }
        }

        set {
            setObjectForKey("layout_index", value: newValue)
        }
    }

    var themePath: String {
        get {
            let result = self.getObjectForKey("theme_url", defaultValue: "res://default") as! NSString
            return result as String
        }

        set {
            setObjectForKey("theme_url", value: newValue)
        }
    }

    var themeResources: NSDictionary {
        get {
            return getDictionaryForKey("theme_resource", defaultValue: [:])
        }

        set {
            // FIXME: Dictionary to NSDictioanry
            var dict: NSMutableDictionary = [:]
            for (key, value) in newValue {
                dict[key as! String] = value
            }
            self.setObjectForKey("theme_resource", value: dict)
        }
    }

    var resourceCaches: NSDictionary {
        get {
            return self.getDictionaryForKey("rcache", defaultValue: [:])
        }
        set {
            return self.setObjectForKey("rcache", value: newValue)
        }
    }

    var swipe: Bool {
        get {
            return self.getObjectForKey("swipe", defaultValue: true) as! Bool
        }
        set {
            self.setObjectForKey("swipe", value: newValue)
        }
    }

    var inglobe: Bool {
        get {
            return self.getObjectForKey("inglobe", defaultValue: true) as! Bool
        }
        set {
            self.setObjectForKey("inglobe", value: newValue)
        }
    }

    var emoticonFrequencies: NSDictionary {
        get {
            return self.getDictionaryForKey("emoticon_frequency", defaultValue: [:])
        }

        set {
            self.setObjectForKey("emoticon_frequency", value: newValue)
        }
    }

    var emoticonHistory: NSArray {
        get {
            return self.getArrayForKey("emoticon_history", defaultValue: ["😂", "❤️", "😍", "😒", "👌", "☺️", "😊", "😘", "😭", "😩", "💕", "😔", "😏", "😁", "😳", "👍", "✌", "😉", "😌", "💁", "🙈", "😎", "🎶", "👀", "😑", "😴", "😄", "😜", "😋", "👏"])
        }

        set {
            self.setObjectForKey("emoticon_history", value: newValue)
        }
    }

    var emoticonSection: Int {
        get {
            return self.getObjectForKey("emoticon_section", defaultValue: 1) as! Int
        }
        set {
            self.setObjectForKey("emoticon_section", value: newValue)
        }
    }

    func setResourceCache(data: NSData, forKey key: String) {
        let caches = self.resourceCaches.mutableCopy() as! NSMutableDictionary
        let encoded = ThemeResourceCoder.defaultCoder().encodeFromData(data)
        caches.setObject(encoded, forKey: key)
        self.setObjectForKey("rcache", value: caches)
    }

    func resourceCacheForKey(key: String) -> NSData! {
        if let encoded = self.resourceCaches[key] as? String {
            return ThemeResourceCoder.defaultCoder().decodeToData(encoded)
        } else {
            return nil
        }
    }
}

let preferences = Preferences()

class PreferencedTheme: Theme {
    override func dataForFilename(name: String) -> NSData? {
        if let rawData = preferences.themeResources[name] as? String {
            let data = ThemeResourceCoder.defaultCoder().decodeToData(rawData)
            return data
        } else {
            return nil
        }
    }
}
