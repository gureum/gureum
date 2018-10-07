//
//  ThemeViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ThemeViewController: PreviewViewController, UITableViewDataSource, UITableViewDelegate, GADInterstitialDelegate {
    var interstitial: GADInterstitial!
    
    @IBOutlet var tableView: UITableView! = nil
    @IBOutlet var doneButton: UIBarButtonItem! = nil
    @IBOutlet var cancelButton: UIBarButtonItem! = nil
    @IBOutlet var restoreButton: UIBarButtonItem! = nil

    var themePath = preferences.themePath

    var entries: Array<Dictionary<String, Any>> = []

    func loadEntries() {
        let url = NSURL(string: "http://w.youknowone.org/gureum/shop-preview.json")!
        guard let data = try? Data(contentsOf: url as URL) else {
            return
        }

        guard let items = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Array<Dictionary<String, Any>> else {
            assert(false)
            return
        }
        entries = items
    }
    
    func readyTheme() {
         if self.navigationItem.rightBarButtonItem == self.doneButton {
              return
         }
         self.navigationItem.rightBarButtonItem = self.doneButton
         self.navigationItem.leftBarButtonItem = self.cancelButton
    
//        if ADMOB_INTERSTITIAL_ID != "" {
//            self.interstitial = self.loadInterstitialAds()
//        }
    }


    @IBAction func applyTheme(sender: UIButton!) {
        guard self.themePath.hasPrefix("res://") else {
            let alert = UIAlertController(title: "출시 대기 중!", message: "이 테마는 아직 미리볼 수만 있습니다. 다음 버전에서 정식으로 이용할 수 있습니다!", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return;
        }
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
        
        if self.interstitial?.isReady ?? false {
            self.interstitial.present(fromRootViewController: self)
        }
        
        Theme.themeWithAddress(addr: self.themePath).dump()
        preferences.themePath = self.themePath
        preferences.resourceCaches = [:]
    }

    @IBAction func cancelTheme(sender: UIButton!) {
        self.themePath = preferences.themePath
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themePath))
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = restoreButton;
        self.tableView.reloadData()
        
        self.interstitial = nil
    }

    @IBAction func restorePurchasedTheme(sender: UIButton!) {
        
    }

     func numberOfSections(in tableView: UITableView) -> Int {
        return self.entries.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.entries.count > 0 {
            let sub: Any? = self.entries[section]["items"]
            assert(sub != nil)
            let items = sub! as! Array<Any>
            return items.count
        } else {
            return 0
        }
    }

    override func viewDidLoad() {
        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themePath))
        super.viewDidLoad()
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let mainQueue = DispatchQueue.main
        
        UIActivityIndicatorView.globalActivityIndicatorView().startAnimating()
        backgroundQueue.async {
            self.loadEntries()
            mainQueue.async {
                if self.entries.count > 0 {
                    self.tableView.reloadData()
                } else {
                    UIAlertView(title: "네트워크 오류", message: "테마 목록을 불러올 수 없습니다. LTE 또는 Wi-Fi 연결을 확인하고 잠시 후에 다시 시도해 주세요.", delegate: nil, cancelButtonTitle: "확인").show()
                }
                UIActivityIndicatorView.globalActivityIndicatorView().stopAnimating()
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
            let selected = item["addr"] == self.themePath
            cell.accessoryType = selected ? .checkmark : .none
            cell.detailTextLabel!.text = (selected || item["tier"] == "free") ? "무료" : "미리보기"
            cell.detailTextLabel!.textColor = cell.detailTextLabel!.text == "무료" ? UIColor.clear : UIColor.lightGray
            return cell
        } else {
            assert(false);
            return UITableViewCell()
        }

    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        guard entries.count > 0 else {
            return ""
        }
        let category = self.entries[section]
        let sub: Any? = category["section"]
        assert(sub != nil)
        return sub! as? String
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sub: Any? = self.entries[indexPath.section]["items"]
        assert(sub != nil)
        let item = (sub as! Array<Dictionary<String, String>>)[indexPath.row]
        self.themePath = item["addr"]!

        self.readyTheme()

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)

        self.inputPreviewController.inputMethodView.theme = CachedTheme(theme: Theme.themeWithAddress(addr: self.themePath))
        self.inputPreviewController.reloadInputMethodView()
    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial!) {
        self.interstitial = ad
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {

    }

    func interstitial(_ ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        self.interstitial = nil
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
        // assert(false) -- TODO: 
        return [:]
    }
}


public class URLTheme: Theme {
    func URLForResource(name: String) -> URL! {
        if name.hasSmartURLPrefix() {
            return name.smartURL()
        }
        return nil
    }

    override public func dataForFilename(name: String) -> Data? {
        if let url = self.URLForResource(name: name) {
            return try? Data(contentsOf: url)
        } else {
            return nil
        }
    }
}

public class EmbeddedTheme: URLTheme {
    let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    override func URLForResource(name: String) -> URL? {
        return super.URLForResource(name: name) ?? Bundle.main.url(forResource: name, withExtension: nil, subdirectory: self.name)
    }
}

public class HTTPTheme: URLTheme {
    let URLString: String

    init(URLString: String) {
        self.URLString = URLString
    }

    override func URLForResource(name: String) -> URL? {
        let URLString = self.URLString + (name as NSString).addingPercentEscapes(using: 4)!
        let url = URL(string: URLString)
        return super.URLForResource(name: name) ?? url
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

    func dumpData() -> [String: String] {
        let traitsConfiguration = self.mainConfiguration["trait"] as! NSDictionary?
        var resources = Dictionary<String, String>()
        assert(traitsConfiguration != nil, "config.json에서 trait 속성을 찾을 수 없습니다.")
        for traitFilename in traitsConfiguration!.allValues {
            let datastr = self.encodedDataForFilename(filename: traitFilename as! String)
            assert(datastr != nil)
            resources[traitFilename as! String] = datastr!
            var error: NSError? = nil
            let root: Any? = self.jsonObjectForFilename(name: traitFilename as! String, error: &error)
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
        return resources
    }
    
    func dump() {
        let baseData = EmbeddedTheme(name: "default").dumpData()
        let data = self.dumpData()
        
        preferences.baseThemeResources = baseData
        preferences.themeResources = data
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
                return PreferencedTheme(resources: [:])
        }
    }
}
