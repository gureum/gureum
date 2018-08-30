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

    init(owner: Store, data: Any) {
        self.owner = owner
        self.data = data as NSDictionary
    }

    lazy var title: String = self.data["section"] as String
    func itemForRow(row: Int) -> StoreItem {
        let items: Any? = self.data["items"]
        assert(items != nil)
        return StoreItem(owner: self.owner, data: (items as! NSArray)[row])
    }
}

class StoreItem {
    let owner: Store
    let data: NSDictionary

    init(owner: Store, data: Any) {
        self.owner = owner
        self.data = data as! NSDictionary
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
    var entries: [Any] = []
    var products: Dictionary<String, SKProduct> = [:]

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)

        backgroundQueue.async {
             self.refresh()
        }
    }

    func refresh() {
        let url =  NSURL(string: "http://w.youknowone.org/gureum/store.json")!
        var error: NSError? = nil

        guard let data = try? Data(contentsOf: url as URL, options: Data.ReadingOptions(rawValue: 0)) else {
            print("fixme: internet not availble")
            return
        }

        guard let items: [Any] = JSONSerialization.JSONObjectWithData(data, options: JSONSerialization.ReadingOptions(0)) {
            print("FIXME: store not available")
        }
        self.entries = items

        var names = NSMutableSet()
        for category in entries {
            let items = category["items"]
            assert(items != nil)
            for ritem in items as NSArray {
                let item = ritem as NSDictionary
                if let pid: Any = item["id"] {
                    names.addObject(pid)
                }
            }
        }
        let req = SKProductsRequest(productIdentifiers: names as! Set<String>)
        req.delegate = self
        req.start()
    }

    func canMakePayments() -> Bool {
        let available = SKPaymentQueue.canMakePayments()
        return available
    }

    func categoryForSection(section: Int) -> StoreCategory {
        let sub: Any? = self.entries[section]
        assert(sub != nil)
        return StoreCategory(owner: self, data: sub!)
    }

    func itemForIndexPath(indexPath: NSIndexPath) -> StoreItem {
        return self.categoryForSection(section: indexPath.section).itemForRow(row: indexPath.row)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            self.products[product.productIdentifier] = product
        }

        for invalidProductIdentifier in response.invalidProductIdentifiers {
            print("invalid product identifier \(invalidProductIdentifier)")
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("transaction: \(transaction)")
            switch transaction.transactionState {
                    ///< 서버에 거래 처리중
            case .purchasing:
                print("InAppPurchase SKPaymentTransactionStatePurchasing");
                    let alertView = UIAlertView(title: "구매를 시도합니다", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    break;
                    ///< 구매 완료
            case .purchased:
                print("InAppPurchase SKPaymentTransactionStatePurchased");
//                let alertView = UIAlertView(title: "구매가 완료되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
//                    alertView.show()
                SKPaymentQueue.default().finishTransaction(transaction)
                    ///< 거래 실패 또는 취소
            case .failed:
                print("InAppPurchase SKPaymentTransactionStateFailed");
                let alertView = UIAlertView(title: "구매 실패", message: (transaction.error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                print("error code: \(transaction.error)")
                SKPaymentQueue.default().finishTransaction(transaction)

                    ///< 재구매
            case .restored:
                    let alertView = UIAlertView(title: "구매가 복원되었습니다.", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    print("InAppPurchase SKPaymentTransactionStateRestore");
                    SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                let alertView = UIAlertView(title: "뭐셔?", message: (transaction.error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
                    alertView.show()
                    print("InAppPurchase SKPaymentTransactionStateDeferred");
            }
        }
    }
}

let store = Store()
