//
//  ThemeViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class ThemeViewController: PreviewViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView! = nil
    @IBOutlet var doneButton: UIBarButtonItem! = nil
    @IBOutlet var cancelButton: UIBarButtonItem! = nil
    @IBOutlet var restoreButton: UIBarButtonItem! = nil

    var themePath = preferences.themePath

    var entries: Array<Dictionary<String, AnyObject>> = []

    func loadEntries() {
        let URL = NSURL(string: "http://w.youknowone.org/gureum/shop-preview.json")!
        let data: NSData? = NSData(contentsOfURL: URL)

        if let data = data {
            var error: NSError? = nil
            let items = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as! Array<Dictionary<String, AnyObject>>
            assert(error == nil)
            entries = items
        }
    }

    @IBAction func applyTheme(sender: UIButton!) {
        Theme.themeWithAddress(self.themePath).dump()
        preferences.themePath = self.themePath
        preferences.resourceCaches = [:]
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
    }

    @IBAction func cancelTheme(sender: UIButton!) {
        self.themePath = preferences.themePath
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(self.themePath))
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
        self.tableView.reloadData()
    }

    @IBAction func restorePurchasedTheme(sender: UIButton!) {
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.entries.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sub: AnyObject? = self.entries[section]["items"]
        assert(sub != nil)
        let items = sub! as! Array<AnyObject>
        return items.count
    }

    override func viewDidLoad() {
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(self.themePath))
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            self.loadEntries()
            dispatch_async(dispatch_get_main_queue(), {
                if self.entries.count > 0 {
                    self.tableView.reloadData()
                } else {
                    UIAlertView(title: "네트워크 오류", message: "테마 목록을 불러올 수 없습니다. LTE 또는 Wi-Fi 연결을 확인하고 잠시 후에 다시 시도해 주세요.", delegate: nil, cancelButtonTitle: "확인").show()
                }
            })
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.inputPreviewController.reloadInputMethodView()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sub: AnyObject? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub! as! Array<Dictionary<String, String>>)[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell {
            cell.textLabel!.text = item["title"]
            cell.accessoryType = item["addr"] == self.themePath ? .Checkmark : .None
            return cell
        } else {
            assert(false);
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = self.entries[section]
        let sub: AnyObject? = category["section"]
        assert(sub != nil)
        return sub as? String
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sub: AnyObject? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub as! Array<Dictionary<String, String>>)[indexPath.row]
        self.themePath = item["addr"]!

        self.navigationItem.rightBarButtonItem = self.doneButton
        self.navigationItem.leftBarButtonItem = self.cancelButton

        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(self.themePath))
        self.inputPreviewController.reloadInputMethodView()
    }
}


// nested function cause swiftc fault
func collectResources(node: AnyObject!) -> Dictionary<String, Bool> {
    //println("\(node)")
    if node is String {
        let str = node as! String
        return [str: true]
    }
    else if node is Dictionary<String, AnyObject> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in (node as! Dictionary<String, AnyObject>).values {
            let collection = collectResources(subnode)
            for collected in collection.keys {
                resources[collected] = true
            }
        }
        return resources
    }
    else if node is Array<AnyObject> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in node as! Array<AnyObject> {
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
    func encodedDataForFilename(filename: String) -> String! {
        if let data = self.dataForFilename(filename) {
            println("case \"\(filename)\": return \"\(data.base64EncodedStringWithOptions(.allZeros))\"")
            let str = ThemeResourceCoder.defaultCoder().encodeFromData(data)
            return str
        } else {
            return nil
        }
    }

    func dump() {
        let traitsConfiguration = self.mainConfiguration["trait"] as? NSDictionary
        var resources = Dictionary<String, String>()
        assert(traitsConfiguration != nil, "config.json에서 trait 속성을 찾을 수 없습니다.")
        for traitFilename in traitsConfiguration!.allValues as! [String] {
            let datastr = self.encodedDataForFilename(traitFilename)
            assert(datastr != nil)
            resources[traitFilename] = datastr!
            var error: NSError? = nil
            let root: AnyObject? = self.JSONObjectForFilename(traitFilename as String, error: &error)
            assert(error == nil, "trait 파일이 올바른 JSON 파일이 아닙니다. \(traitFilename)")
            var collection = collectResources(root)
            collection["config.json"] = true
            for collected in collection.keys {
                let filename = collected.componentsSeparatedByString("::")[0]
                if let datastr = self.encodedDataForFilename(filename) {
                    resources[filename] = datastr
                } else {
                    println("파일이 존재하지 않습니다: \(filename)")
                    continue
                }
                //println("파일을 저장했습니다: \(collected) \(collected.dynamicType)")
            }
            //println("dumped resources: \(resources)")
            assert(resources.count > 0)
        }
        preferences.themeResources = resources
        preferences.resourceCaches = [:]
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
                return PreferencedTheme()
        }
    }
}
