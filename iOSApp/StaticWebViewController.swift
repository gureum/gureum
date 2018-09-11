//
//  StaticWebViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class StaticWebViewController: UIViewController {
    @IBOutlet var webView: UIWebView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    class func url() -> URL {
        assert(false)
    }

    override func viewDidLoad() {
        let url = type(of: self).url()
        let request = URLRequest(url: url)
        assert(self.webView != nil)
        self.webView.loadRequest(request)
    }
}

class InstallHelpViewController: StaticWebViewController {
    override class func url() -> URL {
        let url = Bundle.main.url(forResource: "install", withExtension: "html", subdirectory: "help")
        assert(url != nil)
        return url!
    }
}
