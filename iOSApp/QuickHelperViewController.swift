//
//  QuickHelperViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 12. 26..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let QuickHelperResult: NSMutableDictionary = NSMutableDictionary()

class QuickHelperTableViewController: UITableViewController {

    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
        button.enabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.doneButton
    }

    func helperKey() -> String {
        assert(false)
        return ""
    }

    func nextSegueIdentifier() -> String {
        assert(false)
        return ""
    }

    func done(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(self.nextSegueIdentifier(), sender: sender)
    }
}

class SelectableQuickHelperTableViewController: QuickHelperTableViewController {
    var selectedIndexPaths: [NSIndexPath] = []

    override func viewWillDisappear(animated: Bool) {
        let key = self.helperKey()
        QuickHelperResult[key] = self.selectedIndexPaths
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if contains(self.selectedIndexPaths, indexPath) {
            self.selectedIndexPaths = self.selectedIndexPaths.filter({ !indexPath.isEqual($0) })
        } else {
            self.selectedIndexPaths.append(indexPath)
        }
        self.doneButton.enabled = self.selectedIndexPaths.count > 0
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.accessoryType = contains(self.selectedIndexPaths, indexPath) ? .Checkmark : .None
        return cell
    }
}

class SingleSelectableQuickHelperTableViewController: SelectableQuickHelperTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPaths = [indexPath]
        self.doneButton.enabled = self.selectedIndexPaths.count > 0
        tableView.reloadData()
    }
}


class MainLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }

    override func helperKey() -> String {
        return "main"
    }

    override func nextSegueIdentifier() -> String {
        if let indexPath: NSIndexPath = self.selectedIndexPaths.last {
            return indexPath.row < 2 ? "hangeul" : "10key"
        } else {
            assert(false)
            return ""
        }
    }
}

class RomanLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }

    override func helperKey() -> String {
        return "left"
    }

    override func nextSegueIdentifier() -> String {
        return "right"
    }
}

class TenKeyLeftLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {

    override func helperKey() -> String {
        return "left"
    }

    override func nextSegueIdentifier() -> String {
        return "right"
    }
}

class RightLayoutQuickHelperTableViewController: SelectableQuickHelperTableViewController {

    override func helperKey() -> String {
        return "right"
    }

    override func nextSegueIdentifier() -> String {
        return "settings"
    }
}

class SettingsQuickHelperTableViewController: SelectableQuickHelperTableViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndexPaths = [NSIndexPath(forRow: 0, inSection: 0)]
        self.doneButton.enabled = true
    }

    override func helperKey() -> String {
        return "settings"
    }

    override func nextSegueIdentifier() -> String {
        return "done"
    }
}

class DoneQuickHelperTableViewController: QuickHelperTableViewController {
    var result: NSMutableDictionary = NSMutableDictionary()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.doneButton.enabled = true

        let mainIndexPath: NSIndexPath = (QuickHelperResult["main"] as! [NSIndexPath])[0]
        let leftIndexPath: NSIndexPath = (QuickHelperResult["left"] as! [NSIndexPath])[0]
        let rightIndexPaths: [NSIndexPath] = QuickHelperResult["right"] as! [NSIndexPath]
        result["main"] = ["ksx5002", "danmoum", "cheonjiin"][mainIndexPath.row]
        if result["main"] as! String != "cheonjiin" {
            result["left"] = ["qwerty"][leftIndexPath.row]
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                if row == 0 {
                    continue
                }
                let right = ["", "symbol", "cheonjiin"][row]
                rights.addObject(right)
            }
            result["right"] = rights
        } else {
            result["left"] = ["", "ksx5002", "danmoum", "qwerty"][leftIndexPath.row]
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                if row == 0 {
                    continue
                }
                let right = ["", "ksx5002", "danmoum", "qwerty", "symbol"][row]
                rights.addObject(right)
            }
            result["right"] = rights
        }

        result["swipe"] = false
        result["inglobe"] = false
        let settingsIndexPaths = QuickHelperResult["settings"] as! [NSIndexPath]
        for indexPath in settingsIndexPaths {
            let row = indexPath.row
            switch row {
            case 0:
                result["swipe"] = true
            case 1:
                result["inglobe"] = true
            default:
                assert(false)
            }
        }

        self.tableView.reloadData()
    }

    override func done(sender: UIBarButtonItem) {
        var layouts: [String] = []
        let left = result["left"] as! String
        if left != "" {
            layouts.append(left)
        }
        layouts.append(result["main"] as! String)
        layouts += result["right"] as! [String]

        preferences.layouts = layouts
        preferences.defaultLayoutIndex = left == "" ? 0 : 1

        preferences.setObjectForKey("quickhelper", value: true)
        preferences.setObjectForKey("swipe", value: result["swipe"] as! Bool)
        preferences.setObjectForKey("inglobe", value: result["inglobe"] as! Bool)

        self.navigationController!.popToRootViewControllerAnimated(true)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        if self.result.count == 0 {
            return cell
        }
        switch indexPath.row {
        case 0:
            cell.textLabel!.text = "주 자판"
            cell.detailTextLabel!.text = self.result["main"] as? String
        case 1:
            cell.textLabel!.text = "왼쪽 보조자판"
            cell.detailTextLabel!.text = self.result["left"] as? String
        case 2:
            cell.textLabel!.text = "오른쪽 보조자판"
            cell.detailTextLabel!.text = (self.result["right"] as? NSArray)!.componentsJoinedByString(", ")
        case 3:
            cell.textLabel!.text = "좌, 우로 쓸어서 자판 이동"
            cell.detailTextLabel!.text = (self.result["swipe"] as? Bool)! ? "사용함" : "사용 안함"
        case 4:
            cell.textLabel!.text = "키보드 전환 키로 왼쪽 보조자판 이용 (두 번 터치로 다른 키보드 이용)"
            cell.detailTextLabel!.text = (self.result["inglobe"] as? Bool)! ? "사용함" : "사용 안함"
        default:
            assert(false)
        }
        return cell
    }
}
