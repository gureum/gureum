//
//  MainViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 12. 31..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import Crashlytics
import GoogleMobileAds

class MainViewController: UITableViewController {
    @IBOutlet var bannerView: GADBannerView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if ADMOB_BANNER_ID != "" {
            self.bannerView.adUnitID = ADMOB_BANNER_ID
            self.bannerView.rootViewController = self
            self.bannerView.loadRequest(GADRequest())
        }

        let quickhelper = preferences.getObjectForKey("quickhelper", defaultValue: false) as! Bool
        if !quickhelper {
            self.performSegueWithIdentifier("quickhelper", sender: self)
            let alert = UIAlertController(title: "빠른 설정 도우미", message: "구름 키보드를 처음 설치하셨기 때문에 빠른 설정 메뉴로 안내합니다. 빠른 설정에서는 키보드 이용 패턴에 맞게 빠르고 쉽게 배열을 고를 수 있습니다. 언제든 다시 실행할 수 있으니 부담 없이 설정해 보고 맘에 들지 않으면 다시 골라 주세요.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "확인", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 2 {
            switch indexPath.row {
            case 1:
                cell.accessoryType = preferences.swipe ? .Checkmark : .None
            case 2:
                cell.accessoryType = preferences.inglobe ? .Checkmark : .None
            default:
                break
            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            switch indexPath.row {
            case 1:
                preferences.swipe = !preferences.swipe
            case 2:
                preferences.inglobe = !preferences.inglobe
            default:
                return
            }
            tableView.reloadData()
        }
    }
}
