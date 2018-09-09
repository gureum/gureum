//
//  MainViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 12. 31..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import Crashlytics
import GoogleMobileAds

@objc class MainViewController: UITableViewController {
    @IBOutlet var _bannerAdsView: GADBannerView!
    @objc override var bannerAdsView: GADBannerView! { get { return self._bannerAdsView; } }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.loadBannerAds()

        let quickhelper = preferences.object(forKey: "quickhelper", defaultValue: false) as! Bool
        if !quickhelper {
            if QuickHelperJoined {
                let alert = UIAlertController(title: "빠른 설정 도우미", message: "빠른 설정 도우미를 취소할까요? 취소하면 기본 설정이 그대로 사용됩니다.", preferredStyle: .alert)
                let continueAction = UIAlertAction(title: "계속", style: .default) {
                    (UIAlertAction) in
                    self.performSegue(withIdentifier: "quickhelper", sender: self)
                }
                alert.addAction(continueAction)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
                    (UIAlertAction) in
                    preferences.setObject(true, forKey: "quickhelper")
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "quickhelper", sender: self)
                let alert = UIAlertController(title: "빠른 설정 도우미", message: "구름 키보드를 처음 설치하셨기 때문에 빠른 설정 메뉴로 안내합니다. 빠른 설정에서는 키보드 이용 패턴에 맞게 빠르고 쉽게 배열을 고를 수 있습니다. 언제든 다시 실행할 수 있으니 부담 없이 설정해 보고 맘에 들지 않으면 다시 골라 주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == 2 {
            switch indexPath.row {
            case 1:
                cell.accessoryType = preferences.swipe ? .checkmark : .none
            case 2:
                cell.accessoryType = preferences.inglobe ? .checkmark : .none
            default:
                break
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
