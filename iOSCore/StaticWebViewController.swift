//
//  StaticWebViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class StaticWebViewController: UIViewController {
    @IBOutlet var webView: UIWebView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    class func URL() -> NSURL {
        assert(false)
        return NSURL()
    }

    override func viewDidLoad() {
        let URL = self.dynamicType.URL()
        let request = NSURLRequest(URL: URL)
        assert(self.webView != nil)
        self.webView.loadRequest(request)
    }
}

class InstallHelpViewController: StaticWebViewController {
    override class func URL() -> NSURL {
        let URL = NSBundle.mainBundle().URLForResource("install", withExtension: "html", subdirectory: "help")
        assert(URL != nil)
        return URL!
    }
}