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