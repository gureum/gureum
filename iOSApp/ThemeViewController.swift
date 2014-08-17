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
        let data = NSData(contentsOfURL: URL)

        var error: NSError? = nil
        let items = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as Array<Dictionary<String, AnyObject>>
        assert(error == nil)
        assert(items != nil)
        return items
    }()

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.entries.count
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sub = self.entries[section]["items"]
        let items = sub as Array<AnyObject>
        return items.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let sub = self.entries[indexPath.section]["items"]
        let item = (sub as Array<Dictionary<String, String>>)[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        assert(cell)
        cell.textLabel.text = item["title"]
        cell.accessoryType = item["name"] == preferences.themeName ? .Checkmark : .None
        return cell
    }

    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let category = self.entries[section]
        let sub = category["section"]
        assert(sub != nil)
        return sub as String
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let sub = self.entries[indexPath.section]["items"]
        let item = (sub as Array<Dictionary<String, String>>)[indexPath.row]
        let themeName = item["name"]
        assert(themeName != nil)

        // 옮기자
        
        // 끝

        preferences.themeName = themeName!
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


// nested function cause swiftc fault
func collectResources(node: AnyObject!) -> Dictionary<String, Bool> {
    println("\(node)")
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

extension Theme {
    func pathForResource(name: String?) -> String? {
        return NSBundle.mainBundle().pathForResource(name, ofType: nil, inDirectory: self.name)
    }

    func embeddedConfiguration() -> [String: AnyObject?] {
        let path = self.pathForResource("config.json")
        println("설정 파일 위치: \(path)")
        var error: NSError? = nil
        let data = NSData.dataWithContentsOfFile(path, options: NSDataReadingOptions(0), error: &error)
        assert(error == nil, "설정 파일을 찾을 수 없습니다.")
        assert(data != nil, "설정 파일을 읽을 수 없습니다.")
        let JSONObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error:&error) as Dictionary<String, AnyObject>?
        assert(error == nil, "설정 파일에 오류가 있습니다.")
        assert(JSONObject != nil, "설정 파일을 해석할 수 없습니다.")
        return JSONObject!
    }

    func dump() {
        let root: AnyObject = self.embeddedConfiguration() as Dictionary<String, AnyObject>
        var collection = collectResources(root)
        collection["config.json"] = true
        var resources = Dictionary<String, String>()
        for collected in collection.keys {
            let path = self.pathForResource(collected)
            let data = NSData(contentsOfFile: path)
            if data == nil {
                println("파일이 존재하지 않습니다: \(collected)")
                continue
            }
            let str = themeResourceCoder.encodeFromData(data)
            resources[collected] = str
            println("파일을 저장했습니다: \(collected) \(collected.dynamicType)")
        }
        println("dumped resources: \(resources)")
        assert(resources.count > 0)
        preferences.themeResources = resources
        assert(preferences.themeResources.count > 0)
    }
}