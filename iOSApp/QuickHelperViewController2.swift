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
    override var doneButtonTitle: String? { return nil }

    var result = NSMutableDictionary()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.isEnabled = true

        let mainIndexPath = (QuickHelperResult["main"] as! [NSIndexPath])[0]
        let leftIndexPath = (QuickHelperResult["left"] as! [NSIndexPath])[0]
        let rightIndexPaths = QuickHelperResult["right"] as! [NSIndexPath]
        result["main"] = ["ksx5002", "danmoum", "cheonjiin"][mainIndexPath.row]
        if result["main"] as! String != "cheonjiin" {
            result["left"] = ["qwerty"][leftIndexPath.row] as Any
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                let right = ["emoticon", "symbol", "cheonjiin"][row]
                rights.add(right)
            }
            result["right"] = rights
        } else {
            result["left"] = ["", "ksx5002", "danmoum", "qwerty"][leftIndexPath.row]
            let rights = NSMutableArray()
            for indexPath in rightIndexPaths {
                let row = indexPath.row
                let right = ["emoticon", "ksx5002", "danmoum", "qwerty", "symbol"][row]
                rights.add(right)
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

        tableView.reloadData()
    }

    @objc override func done(_: UIBarButtonItem) {
        var layouts: [String] = []
        let left = result["left"] as! String
        if left != "" {
            layouts.append(left)
        }
        layouts.append(result["main"] as! String)
        layouts += result["right"] as! [String]

        preferences.layouts = layouts
        preferences.defaultLayoutIndex = left == "" ? 0 : 1

        let previousQuickhelper = preferences.object(forKey: "quickhelper", defaultValue: false) as! Bool
        preferences.setObject(true, forKey: "quickhelper")
        preferences.setObject(result["swipe"] as! Bool, forKey: "swipe")
        preferences.setObject(result["inglobe"] as! Bool, forKey: "inglobe")

        let navigationController = self.navigationController!
        navigationController.popToRootViewController(animated: previousQuickhelper)

        if !previousQuickhelper {
            navigationController.topViewController!.performSegue(withIdentifier: "installation", sender: self)
            let alert = UIAlertController(title: "처음 설치하기", message: "구름 키보드 설정을 마치셨습니다. 서드 파티 키보드를 처음 설치하시는 분은 도움말에서 '처음 설치하기'를 선택해 iOS 설정에서 서드 파티 키보드를 활성화 하는 설정에 대해 참고할 수 있습니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if result.count == 0 {
            return cell
        }
        switch indexPath.row {
        case 0:
            cell.textLabel!.text = "주 자판"
            cell.detailTextLabel!.text = NSLocalizedString(result["main"] as! String, comment: "")
        case 1:
            cell.textLabel!.text = "왼쪽 보조자판"
            cell.detailTextLabel!.text = NSLocalizedString(result["left"] as! String, comment: "")
        case 2:
            cell.textLabel!.text = "오른쪽 보조자판"
            let parts = (result["right"] as! Array).map { NSLocalizedString($0, comment: "") }
            let text = parts.joined()
            cell.detailTextLabel!.text = text.count > 0 ? text : "없음"
        case 3:
            cell.textLabel!.text = "좌, 우로 쓸어서 자판 이동"
            cell.detailTextLabel!.text = (result["swipe"] as! Bool) ? "사용함" : "사용 안함"
        case 4:
            cell.textLabel!.text = "키보드 전환 키로 왼쪽 보조자판 이용 (두 번 터치로 다른 키보드 이용)"
            cell.detailTextLabel!.text = (result["inglobe"] as! Bool) ? "사용함" : "사용 안함"
        default:
            assert(false)
        }
        return cell
    }
}
