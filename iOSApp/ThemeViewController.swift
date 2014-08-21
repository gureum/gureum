//
//  ThemeViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class ThemeViewController: PreviewViewController, UITableViewDataSource, UITableViewDelegate {
    var entries: Array<Dictionary<String, AnyObject>> = {
        let URL = NSBundle.mainBundle().URLForResource("shop", withExtension: "json")
        assert(URL != nil)
        let data = NSData(contentsOfURL: URL!)

        var error: NSError? = nil
        let items = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as Array<Dictionary<String, AnyObject>>
        assert(error == nil)
        return items
    }()

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.entries.count
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sub: AnyObject? = self.entries[section]["items"]
        assert(sub != nil)
        let items = sub! as Array<AnyObject>
        return items.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let sub: AnyObject? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub! as Array<Dictionary<String, String>>)[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        assert(cell != nil)
        cell.textLabel.text = item["title"]
        cell.accessoryType = item["addr"] == preferences.themeAddress ? .Checkmark : .None
        return cell
    }

    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let category = self.entries[section]
        let sub: AnyObject? = category["section"]
        assert(sub != nil)
        return sub! as String
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let sub: AnyObject? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub as Array<Dictionary<String, String>>)[indexPath.row]
        let themeAddress = item["addr"]
        assert(themeAddress != nil)

        // 옮기자
        Theme.themeWithAddress(themeAddress! as String).dump()
        // 끝

        preferences.themeAddress = themeAddress!
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        self.inputPreviewController.reloadInputMethodView()
    }
}


// nested function cause swiftc fault
func collectResources(node: AnyObject!) -> Dictionary<String, Bool> {
    //println("\(node)")
    if node is String {
        let str = node as String
        return [str: true]
    }
    else if node is Dictionary<String, AnyObject> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in (node as Dictionary<String, AnyObject>).values {
            let collection = collectResources(subnode)
            for collected in collection.keys {
                resources[collected] = true
            }
        }
        return resources
    }
    else if node is Array<AnyObject> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in node as Array<AnyObject> {
            let collection = collectResources(subnode)
            for collected in collection.keys {
                resources[collected] = true
            }
        }
        return resources
    }
    else if node is NSNull || node is Bool {
        return [:]
    }
    else {
        assert(false)
        return [:]
    }
}


class EmbeddedTheme: Theme {
    let name: String

    init(name: String) {
        self.name = name
    }

    func pathForResource(name: String?) -> String? {
        return NSBundle.mainBundle().pathForResource(name, ofType: nil, inDirectory: self.name)
    }

    override func dataForFilename(name: String) -> NSData? {
        if let path = self.pathForResource(name) {
            let data: NSData? = NSData(contentsOfFile: path)
            return data
        } else {
            return nil
        }
    }
}

class HTTPTheme: Theme {
    let URLString: String

    init(URLString: String) {
        self.URLString = URLString
    }

    func URLForResource(name: String) -> NSURL? {
        let URLString = self.URLString + name.stringByAddingPercentEscapesUsingEncoding(4)!
        let URL = NSURL(string: URLString)
        return URL
    }

    override func dataForFilename(name: String) -> NSData? {
        if let URL = self.URLForResource(name) {
            let data: NSData? = NSData(contentsOfURL: URL)
            return data
        } else {
            return nil
        }
    }
}

extension Theme {
    func dump() {
        let root: AnyObject = self.configuration as Dictionary<String, AnyObject>
        var collection = collectResources(root)
        collection["config.json"] = true
        var resources = Dictionary<String, String>()
        for collected in collection.keys {
            let data = self.dataForFilename(collected)
            if data == nil {
                //println("파일이 존재하지 않습니다: \(collected)")
                continue
            }
            let str = themeResourceCoder.encodeFromData(data!)
            resources[collected] = str
            //println("파일을 저장했습니다: \(collected) \(collected.dynamicType)")
        }
        //println("dumped resources: \(resources)")
        assert(resources.count > 0)
        preferences.themeResources = resources
        assert(preferences.themeResources.count > 0)
    }

    class func themeWithAddress(addr: String) -> Theme {
        let components = addr.componentsSeparatedByString("://")
        assert(components.count > 1)
        let type = components[0]
        switch type {
            case "res":
                return EmbeddedTheme(name: components[1])
            case "http", "https":
                return HTTPTheme(URLString: addr)
            default:
                assert(false)
        }
    }
}