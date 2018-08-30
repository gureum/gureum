//
//  Preferences.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import Foundation

class Preferences {
    var defaults = UserDefaults(suiteName: "group.org.youknowone.Gureum")!
    lazy var theme = PreferencedTheme()

    func object(forKey key: String, defaultValue: Any) -> Any {
        let result: Any = self.defaults.object(forKey: key) ?? defaultValue
        return result
    }

    func getArrayForKey(key: String, defaultValue: Array<Any>) -> Array<Any> {
        if let object = self.defaults.array(forKey: key) {
            if object.count == 0 {
                return defaultValue
            }
            return object
        } else {
            return defaultValue
        }
    }

    func getDictionaryForKey(key: String, defaultValue: [String: Any]) -> [String: Any] {
        let object = self.defaults.dictionary(forKey: key)
        if object == nil {
            return defaultValue
        }
        if object!.count == 0 {
            return defaultValue
        }
        return object!
    }

    func setObject(_ value: Any, forKey key: String) {
        self.defaults.set(value, forKey: key)
        assert(self.defaults.object(forKey: key) != nil)
        self.defaults.synchronize()
    }

    var layouts: [String] {
        get {
            let defaultValue: [String] = ["qwerty", "danmoum", "ksx5002"/*, "numpad", "cheonjiin"*/]
            let result = getArrayForKey(key: "layouts", defaultValue: defaultValue)
            return result as! [String]
        }

        set {
            self.setObject(newValue, forKey: "layouts")
        }
    }

    var defaultLayoutIndex: Int {
        get {
            let defaultValue = NSNumber(value: 1)
            let rawIndex = self.object(forKey: "layoutindex", defaultValue: defaultValue) as! NSNumber
            let index: Int = rawIndex.intValue
            if index >= self.layouts.count {
                return self.layouts.count - 1
            } else {
                return index
            }
        }

        set {
            self.setObject(newValue, forKey: "layoutindex")
        }
    }

    var themeAddress: String {
        get {
            let result = self.object(forKey: "themeaddr", defaultValue: "res://default") as! NSString
            return result as String
        }

        set {
            self.setObject(newValue, forKey: "themeaddr")
        }
    }

    var themeResources: [String: Any] {
        get {
            return getDictionaryForKey(key: "themeresource", defaultValue: [:]) 
        }

        set {
            var dict: [String: Any] = [:]
            for (key, value) in newValue {
                dict[key] = value
            }
            self.setObject(dict, forKey: "themeresource")
        }
    }

    var resourceCaches: [String: Any] {
        get {
            return self.getDictionaryForKey(key: "rcache", defaultValue: [:])
        }
        set {
            return self.setObject(newValue, forKey: "rcache")
        }
    }

    func setResourceCache(data: NSData, forKey key: String) {
        var caches = self.resourceCaches // copy
        let encoded = ThemeResourceCoder.defaultCoder().encodeFromData(data: data)
        caches[key] = encoded
        self.setObject(caches, forKey: "rcache")
    }

    func resourceCacheForKey(key: String) -> NSData! {
        if let encoded = self.resourceCaches[key] as! String? {
            return ThemeResourceCoder.defaultCoder().decodeToData(data: encoded)
        } else {
            return nil
        }
    }
}

let preferences = Preferences()

class PreferencedTheme: Theme {
    override func dataForFilename(name: String) -> Data? {
        if let rawData = preferences.themeResources[name] as! String? {
            return ThemeResourceCoder.defaultCoder().decodeToData(data: rawData) as Data
        } else {
            return nil
        }
    }

//    override func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
//        let key = name + "::\(Int(margin))"
//        if let data = preferences.resourceCacheForKey(key) {
//            return UIImage(data: data, scale: 2)
//        }
//        let image = super.imageForFilename(name, withTopMargin: margin)
//        if image != nil {
//            let data = UIImagePNGRepresentation(image)
//            preferences.setResourceCache(data, forKey: key)
//        }
//        return image
//    }
}
