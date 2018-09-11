//
//  Preferences.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import Foundation

class Preferences {
    var defaults = UserDefaults(suiteName: "group.org.gureum")!
    lazy var baseTheme: PreferencedTheme = PreferencedTheme(resources: self.baseThemeResources)
    lazy var theme: PreferencedTheme = PreferencedTheme(resources: self.themeResources)
    
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
        self.defaults.set(NSDate(), forKey: "edited_time")
        self.defaults.synchronize()
    }
    
    var layouts: [String] {
        get {
            let defaultValue: [String] = ["qwerty", "ksx5002", "emoticon"]
            let result = getArrayForKey(key: "layouts", defaultValue: defaultValue)
            return result as! [String]
        }
        
        set {
            self.setObject(newValue, forKey: "layouts")
        }
    }
    
    var defaultLayoutIndex: Int {
        get {
            let index = object(forKey: "layout_index", defaultValue: 1) as! Int
            if index >= self.layouts.count {
                return self.layouts.count - 1
            } else {
                return index
            }
        }
        
        set {
            self.setObject(newValue, forKey: "layout_index")
        }
    }
    
    public var themePath: String {
        get {
            return self.object(forKey: "theme_url", defaultValue: "res://default") as! String
        }
        
        set {
            self.setObject(newValue, forKey: "theme_url")
        }
    }
    
    var baseThemeResources: [String: Any] {
        get {
            return getDictionaryForKey(key: "theme_resource_", defaultValue: [:])
        }
        
        set {
            var dict: [String: Any] = [:]
            for (key, value) in newValue {
                dict[key] = value
            }
            self.setObject(dict, forKey: "theme_resource_")
        }
    }
    
    var themeResources: [String: Any] {
        get {
            return getDictionaryForKey(key: "theme_resource", defaultValue: [:])
        }
        
        set {
            var dict: [String: Any] = [:]
            for (key, value) in newValue {
                dict[key] = value
            }
            self.setObject(dict, forKey: "theme_resource")
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
    
    var swipe: Bool {
        get {
            return self.object(forKey: "swipe", defaultValue: true) as! Bool
        }
        set {
            self.setObject(newValue, forKey: "swipe")
        }
    }
    
    var inglobe: Bool {
        get {
            return self.object(forKey: "inglobe", defaultValue: true) as! Bool
        }
        set {
            self.setObject(newValue, forKey: "inglobe")
        }
    }
    
    var emoticonFrequencies: [String: Any] {
        get {
            return self.getDictionaryForKey(key: "emoticon_frequency", defaultValue: [:])
        }
        
        set {
            self.setObject(newValue, forKey: "emoticon_frequency")
        }
    }
    
    var emoticonHistory: NSArray {
        get {
            return self.getArrayForKey(key: "emoticon_history", defaultValue: ["😂", "❤️", "😍", "😒", "👌", "☺️", "😊", "😘", "😭", "😩", "💕", "😔", "😏", "😁", "😳", "👍", "✌", "😉", "😌", "💁", "🙈", "😎", "🎶", "👀", "😑", "😴", "😄", "😜", "😋", "👏"]) as NSArray
        }
        
        set {
            self.setObject(newValue, forKey: "emoticon_history")
        }
    }
    
    var emoticonSection: Int {
        get {
            return self.object(forKey: "emoticon_section", defaultValue: 1) as! Int
        }
        set {
            self.setObject(newValue, forKey: "emoticon_section")
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
    let resources: [String: Any]
    
    init(resources: [String: Any]) {
        self.resources = resources
    }
    
    override public func dataForFilename(name: String) -> Data? {
        if let rawData = self.resources[name] as? String {
            let data = ThemeResourceCoder.defaultCoder().decodeToData(data: rawData)
            return data as Data?
        } else {
            return nil
        }
    }
}
