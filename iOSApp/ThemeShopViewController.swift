//
//  ThemeShopViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import StoreKit
import UIKit

class ThemeShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    @IBOutlet var tableView: UITableView!

    override func viewWillAppear(_: Bool) {
        let window = sharedAppDelegate.window!
        UIActivityIndicatorViewForWindow(window: window).pushAnimating()

        store.backgroundQueue.async {
            let previousCount = store.entries.count
            store.refresh()

            let mainQueue = DispatchQueue.main
            mainQueue.async {
                if previousCount > store.entries.count {
                    self.tableView.reloadData()
                }
                UIActivityIndicatorViewForWindow(window: window).popAnimating()
            }
        }
    }

    func numberOfSectionsInTableView(tableView _: UITableView) -> Int {
        return store.entries.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items: [String: Any] = store.entries[section]["items"]! as! [String: Any]
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = store.itemForIndexPath(indexPath: indexPath as NSIndexPath)

        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        cell.textLabel?.text = item.title
        if let product = item.product {
            let formatter = NumberFormatter()
            formatter.formatterBehavior = .behavior10_4
            formatter.numberStyle = .currencyISOCode
            formatter.locale = product.priceLocale
            cell.detailTextLabel!.text = formatter.string(from: product.price)
        } else {
            if let _ = item.data["id"] {
                cell.detailTextLabel!.text = "구매 불가"
            } else {
                cell.detailTextLabel!.text = "무료"
            }
        }
        return cell
    }

    private func tableView(tableView _: UITableView, titleForHeaderInSection section: Int) -> String! {
        return store.categoryForSection(section: section).title
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !store.canMakePayments() {
            let alert = UIAlertController(title: "구매 불가", message: "일시적인 문제로 지금은 iTunes Store를 이용할 수 없습니다. 잠시 후에 다시 시도해 주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let item = store.itemForIndexPath(indexPath: indexPath as NSIndexPath)
        if item.product == nil {
            let alertView = UIAlertView(title: "구매 불가한 상품입니다.", message: "안돼", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
            alertView.show()
        } else {
            let alertView = UIAlertView(title: item.product.localizedTitle, message: item.product.localizedDescription, delegate: self, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
            alertView.tag = (indexPath.section << 15) + indexPath.row
            alertView.show()
        }
    }

    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex _: Int) {
        let (section, row) = (alertView.tag >> 15, alertView.tag & 0xFFFF)
        let item = store.categoryForSection(section: section).itemForRow(row: row)
        let payment = SKPayment(product: item.product)
        SKPaymentQueue.default().add(payment)
    }
}
