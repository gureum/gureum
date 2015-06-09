//
//  QuickHelperViewController2.swift
//  Gureum
//
//  Created by Jeong YunWon on 2015. 5. 21..
//  Copyright (c) 2015년 youknowone.org. All rights reserved.
//

import UIKit

// Separated file prevents Swift compiler crash

class DoneQuickHelperTableViewController: QuickHelperTableViewController {
    override var doneButtonTitle: String? {
        get { return nil }
    }
    var result = NSMutableDictionary()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.doneButton.enabled = true

        let mainIndexPath = (QuickHelperResult["main"] as! [NSIndexPath])[0]
        let leftIndexPath = (QuickHelperResult["left"] as! [NSIndexPath])[0]
        let rightIndexPaths = QuickHelperResult["right"] as! [NSIndexPath]
        result["main"] = ["ksx5002", "danmoum", "cheonjiin"][mainIndexPath.row]
        if result["main"] as! String != "cheonjiin" {
            result["left"] = ["qwerty"][leftIndexPath.row]
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                let right = ["symbol", "cheonjiin"][row]
                rights.addObject(right)
            }
            result["right"] = rights
        } else {
            result["left"] = ["", "ksx5002", "danmoum", "qwerty"][leftIndexPath.row]
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                let right = ["ksx5002", "danmoum", "qwerty", "symbol"][row]
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

        let previousQuickhelper = preferences.getObjectForKey("quickhelper", defaultValue: false) as! Bool
        preferences.setObjectForKey("quickhelper", value: true)
        preferences.setObjectForKey("swipe", value: result["swipe"] as! Bool)
        preferences.setObjectForKey("inglobe", value: result["inglobe"] as! Bool)

        let navigationController = self.navigationController!
        navigationController.popToRootViewControllerAnimated(previousQuickhelper)

        if !previousQuickhelper {
            navigationController.topViewController.performSegueWithIdentifier("installation", sender: self)
            let alert = UIAlertController(title: "처음 설치하기", message: "구름 키보드 설정을 마치셨습니다. 서드 파티 키보드를 처음 설치하시는 분은 도움말에서 '처음 설치하기'를 선택해 iOS 설정에서 서드 파티 키보드를 활성화 하는 설정에 대해 참고할 수 있습니다.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "확인", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
            cell.detailTextLabel!.text = NSLocalizedString(self.result["main"] as! String, comment: "")
        case 1:
            cell.textLabel!.text = "왼쪽 보조자판"
            cell.detailTextLabel!.text = NSLocalizedString(self.result["left"] as! String, comment: "")
        case 2:
            cell.textLabel!.text = "오른쪽 보조자판"
            let text = ", ".join((self.result["right"] as! Array).map({ NSLocalizedString($0, comment: "") }))
            cell.detailTextLabel!.text = count(text) > 0 ? text : "없음"
        case 3:
            cell.textLabel!.text = "좌, 우로 쓸어서 자판 이동"
            cell.detailTextLabel!.text = (self.result["swipe"] as! Bool) ? "사용함" : "사용 안함"
        case 4:
            cell.textLabel!.text = "키보드 전환 키로 왼쪽 보조자판 이용 (두 번 터치로 다른 키보드 이용)"
            cell.detailTextLabel!.text = (self.result["inglobe"] as! Bool) ? "사용함" : "사용 안함"
        default:
            assert(false)
        }
        return cell
    }
}
