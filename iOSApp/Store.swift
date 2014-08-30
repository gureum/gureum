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

    init(owner: Store, data: AnyObject) {
        self.owner = owner
        self.data = data as NSDictionary
    }

    lazy var title: String = self.data["section"] as String
    func itemForRow(row: Int) -> StoreItem {
        let items: AnyObject? = self.data["items"]
        assert(items != nil)
        return StoreItem(owner: self.owner, data: (items as NSArray)[row])
    }
}

class StoreItem {
    let owner: Store
    let data: NSDictionary

    init(owner: Store, data: AnyObject) {
        self.owner = owner
        self.data = data as NSDictionary
    }

    lazy var title: String = self.data["title"] as String

    lazy var product: SKProduct! = {
        if let pid = self.data["id"] as String? {
            let product = self.owner.products[pid]
            return product
        } else {
            return nil
        }
    }()
}

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    var entries: NSArray = []
    var products: Dictionary<String, SKProduct> = [:]

    override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        dispatch_async(self.backgroundQueue, {
            self.refresh()
        })
    }

    func refresh() {
        let URL = NSURL(string: "http://w.youknowone.org/gureum/store.json")
        let data = NSData(contentsOfURL: URL)
        var error: NSError? = nil
        let items = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as NSArray
        self.entries = items

        var names = NSMutableSet()
        for category in entries {
            let items = category["items"]
            assert(items != nil)
            for ritem in items as NSArray {
                let item = ritem as NSDictionary
                if let pid: AnyObject = item["id"] {
                    names.addObject(pid)
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
        let sub: AnyObject? = self.entries[section]
        assert(sub != nil)
        return StoreCategory(owner: self, data: sub!)
    }

    func itemForIndexPath(indexPath: NSIndexPath) -> StoreItem {
        return self.categoryForSection(indexPath.section).itemForRow(indexPath.row)
    }

    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        for product in response.products {
            self.products[product.productIdentifier] = product as SKProduct
        }

        for invalidProductIdentifier in response.invalidProductIdentifiers {
            println("invalid product identifier \(invalidProductIdentifier)")
        }
    }

    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for rawTransaction in transactions {
            let transaction = rawTransaction as SKPaymentTransaction
            println("transaction: \(transaction)")
            switch transaction.transactionState {
                    ///< 서버에 거래 처리중
                case .Purchasing:
                    println("InAppPurchase SKPaymentTransactionStatePurchasing");
                    let alertView = UIAlertView(title: "구매를 시도합니다", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    break;
                    ///< 구매 완료
                case .Purchased:
                    println("InAppPurchase SKPaymentTransactionStatePurchased");
//                let alertView = UIAlertView(title: "구매가 완료되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
//                    alertView.show()
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    ///< 거래 실패 또는 취소
                case .Failed:
                    println("InAppPurchase SKPaymentTransactionStateFailed");
                    let alertView = UIAlertView(title: "구매 실패", message: transaction.error.localizedDescription, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    println("error code: \(transaction.error)")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)

                    ///< 재구매
                case .Restored:
                    let alertView = UIAlertView(title: "구매가 복원되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    println("InAppPurchase SKPaymentTransactionStateRestore");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                case .Deferred:
                    let alertView = UIAlertView(title: "뭐셔?", message: transaction.error.localizedDescription, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    println("InAppPurchase SKPaymentTransactionStateDeferred");
            }
        }
    }
}

let store = Store()
