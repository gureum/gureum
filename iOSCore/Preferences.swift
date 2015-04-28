//
//  Preferences.swift
//  iOS
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
            let index = getObjectForKey("layoutindex", defaultValue: 1) as! Int
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
            let result = self.getObjectForKey("themeaddr", defaultValue: "res://default") as! NSString
            return result as String
        }

        set {
            setObjectForKey("themeaddr", value: newValue)
        }
    }

    var themeResources: NSDictionary {
        get {
            return getDictionaryForKey("themeresource", defaultValue: [:])
        }

        set {
            // FIXME: Dictionary to NSDictioanry
            var dict: NSMutableDictionary = [:]
            for (key, value) in newValue {
                dict[key as! String] = value
            }
            self.setObjectForKey("themeresource", value: dict)
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
