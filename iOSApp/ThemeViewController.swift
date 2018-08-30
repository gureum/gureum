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

    var themeAddress = preferences.themeAddress

    var entries: Array<Dictionary<String, Any>> = []

    func loadEntries() {
        let url = NSURL(string: "http://w.youknowone.org/gureum/shop.json")!
        guard let data = try? Data(contentsOf: url as URL) else {
            return
        }

        guard let items = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Array<Dictionary<String, Any>> else {
            assert(false)
            return
        }
        entries = items
    }

    @IBAction func applyTheme(sender: UIButton!) {
        Theme.themeWithAddress(addr: self.themeAddress).dump()
        preferences.themeAddress = self.themeAddress
        preferences.resourceCaches = [:]
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
    }

    @IBAction func cancelTheme(sender: UIButton!) {
        self.themeAddress = preferences.themeAddress
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themeAddress))
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
        self.tableView.reloadData()
    }

    @IBAction func restorePurchasedTheme(sender: UIButton!) {
        
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.entries.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sub: Any? = self.entries[section]["items"]
        assert(sub != nil)
        let items = sub! as! Array<Any>
        return items.count
    }

    override func viewDidLoad() {
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themeAddress))
        super.viewDidLoad()
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let mainQueue = DispatchQueue.main
        
        backgroundQueue.async {
            self.loadEntries()
            mainQueue.async {
                if self.entries.count > 0 {
                    self.tableView.reloadData()
                } else {
                    UIAlertView(title: "네트워크 오류", message: "테마 목록을 불러올 수 없습니다. LTE 또는 Wi-Fi 연결을 확인하고 잠시 후에 다시 시도해 주세요.", delegate: nil, cancelButtonTitle: "확인").show()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputPreviewController.reloadInputMethodView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sub: Any? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub! as! Array<Dictionary<String, String>>)[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell? {
            cell.textLabel?.text = item["title"]
            cell.accessoryType = item["addr"] == self.themeAddress ? .checkmark : .none
            return cell
        } else {
            assert(false);
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = self.entries[section]
        let sub: Any? = category["section"]
        assert(sub != nil)
        return sub! as? String
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sub: Any? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub as! Array<Dictionary<String, String>>)[indexPath.row]
        self.themeAddress = item["addr"]!

        self.navigationItem.rightBarButtonItem = self.doneButton
        self.navigationItem.leftBarButtonItem = self.cancelButton

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)

        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themeAddress))
        self.inputPreviewController.reloadInputMethodView()
    }
}


// nested function cause swiftc fault
func collectResources(node: Any!) -> Dictionary<String, Bool> {
    //println("\(node)")
    if node is String {
        let str = node as! String
        return [str: true]
    }
    else if node is Dictionary<String, Any> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in (node as! Dictionary<String, Any>).values {
            let collection = collectResources(node: subnode)
            for collected in collection.keys {
                resources[collected] = true
            }
        }
        return resources
    }
    else if node is Array<Any> {
        var resources: Dictionary<String, Bool> = [:]
        for subnode in node as! Array<Any> {
            let collection = collectResources(node: subnode)
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
        // TODO: assert 살리기
        // assert(false)
        return [:]
    }
}


class EmbeddedTheme: Theme {
    let name: String

    init(name: String) {
        self.name = name
    }

    func pathForResource(name: String?) -> String? {
        return Bundle.main.path(forResource: name, ofType: nil, inDirectory: self.name)
    }

    override func dataForFilename(name: String) -> Data? {
        if let path = self.pathForResource(name: name) {
            return try? Data(contentsOf: URL(fileURLWithPath: path))
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
        let URLString = self.URLString + (name as NSString).addingPercentEscapes(using: 4)!
        let URL = NSURL(string: URLString)
        return URL
    }

    override func dataForFilename(name: String) -> Data? {
        if let URL = self.URLForResource(name: name) {
            return try? Data(contentsOf: URL as URL)
        } else {
            return nil
        }
    }
}

extension Theme {
    func encodedDataForFilename(filename: String) -> String! {
        if let data = self.dataForFilename(name: filename) {
            let str = ThemeResourceCoder.defaultCoder().encodeFromData(data: data as NSData)
            return str
        } else {
            return nil
        }
    }

    func dump() {
        let traitsConfiguration = self.mainConfiguration["trait"] as! NSDictionary?
        var resources = Dictionary<String, String>()
        assert(traitsConfiguration != nil, "config.json에서 trait 속성을 찾을 수 없습니다.")
        for traitFilename in traitsConfiguration!.allValues {
            let datastr = self.encodedDataForFilename(filename: traitFilename as! String)
            assert(datastr != nil)
            resources[traitFilename as! String] = datastr!
            var error: NSError? = nil
            let root: Any? = self.JSONObjectForFilename(name: traitFilename as! String, error: &error)
            assert(error == nil, "trait 파일이 올바른 JSON 파일이 아닙니다. \(traitFilename)")
            var collection = collectResources(node: root)
            collection["config.json"] = true
            for collected in collection.keys {
                let filename = collected.components(separatedBy: "::")[0]
                if let datastr = self.encodedDataForFilename(filename: filename) {
                    resources[filename] = datastr
                } else {
                    print("파일이 존재하지 않습니다: \(filename)")
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
        let components = addr.components(separatedBy: "://")
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
