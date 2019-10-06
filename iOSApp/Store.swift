//
//  Store.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import StoreKit

class StoreCategory {
    let owner: Store
    let data: NSDictionary

    init(owner: Store, data: NSDictionary) {
        self.owner = owner
        self.data = data
    }

    lazy var title = self.data["section"] as! String
    func itemForRow(row: Int) -> StoreItem {
        let items: Any? = data["items"]
        assert(items != nil)
        return StoreItem(owner: owner, data: (items as! NSArray)[row] as! NSDictionary)
    }
}

class StoreItem {
    let owner: Store
    let data: NSDictionary

    init(owner: Store, data: NSDictionary) {
        self.owner = owner
        self.data = data
    }

    lazy var title: String = self.data["title"] as! String

    lazy var product: SKProduct! = {
        if let pid = self.data["id"] as! String? {
            let product = self.owner.products[pid]
            return product
        } else {
            return nil
        }
    }()
}

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    var entries: [[String: Any]] = []
    var products: [String: SKProduct] = [:]

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)

        backgroundQueue.async {
            self.refresh()
        }
    }

    func refresh() {
        let url = NSURL(string: "http://w.youknowone.org/gureum/store.json")
        guard let data = try? Data(contentsOf: url! as URL, options: Data.ReadingOptions(rawValue: 0)) else {
            print("fixme: internet not availble")
            return
        }

        guard let items: [[String: Any]] = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [[String: Any]] else {
            print("FIXME: store not available")
            return
        }
        entries = items

        var names = Set<String>()
        for category in entries {
            let items = category["items"]
            assert(items != nil)
            for ritem in items as! NSArray {
                let item = ritem as! NSDictionary
                if let pid: String = item["id"] as? String {
                    names.insert(pid)
                }
            }
        }
        let req = SKProductsRequest(productIdentifiers: names)
        req.delegate = self
        req.start()
    }

    func canMakePayments() -> Bool {
        let available = SKPaymentQueue.canMakePayments()
        return available
    }

    func categoryForSection(section: Int) -> StoreCategory {
        let data = entries[section] as NSDictionary
        return StoreCategory(owner: self, data: data)
    }

    func itemForIndexPath(indexPath: NSIndexPath) -> StoreItem {
        return categoryForSection(section: indexPath.section).itemForRow(row: indexPath.row)
    }

    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            products[product.productIdentifier] = product
        }

        for invalidProductIdentifier in response.invalidProductIdentifiers {
            print("invalid product identifier \(invalidProductIdentifier)")
        }
    }

    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("transaction: \(transaction)")
            switch transaction.transactionState {
            /// < 서버에 거래 처리중
            case .purchasing:
                print("InAppPurchase SKPaymentTransactionStatePurchasing")
                let alertView = UIAlertView(title: "구매를 시도합니다", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                alertView.show()
            /// < 구매 완료
            case .purchased:
                print("InAppPurchase SKPaymentTransactionStatePurchased")
//                let alertView = UIAlertView(title: "구매가 완료되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
//                    alertView.show()
                SKPaymentQueue.default().finishTransaction(transaction)
            /// < 거래 실패 또는 취소
            case .failed:
                print("InAppPurchase SKPaymentTransactionStateFailed")
                let alertView = UIAlertView(title: "구매 실패", message: (transaction.error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                alertView.show()
                print("error code: \(String(describing: transaction.error))")
                SKPaymentQueue.default().finishTransaction(transaction)

            /// < 재구매
            case .restored:
                let alertView = UIAlertView(title: "구매가 복원되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                alertView.show()
                print("InAppPurchase SKPaymentTransactionStateRestore")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                let alertView = UIAlertView(title: "뭐셔?", message: (transaction.error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                alertView.show()
                print("InAppPurchase SKPaymentTransactionStateDeferred")
            }
        }
    }
}

let store = Store()
