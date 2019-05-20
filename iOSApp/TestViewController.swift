//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import GoogleMobileAds
import UIKit

@objc class TestViewController: PreviewViewController {
    @IBOutlet var _bannerAdsView: GADBannerView!
    @objc override var bannerAdsView: GADBannerView! { return _bannerAdsView }

    @IBOutlet var keyboardTypeScrollView: UIScrollView!
    @IBOutlet var previewField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardTypeScrollView.setContentSizeBySubviewBoundaryWithAutoMargins()
        update()

        // self.loadBannerAds()
    }

    override func update() {
        inputPreviewController.textWillChange(previewField)
        super.update()
        let proxy = inputPreviewController.textDocumentProxy
        previewField.text = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        inputPreviewController.textDidChange(previewField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func keyboardTypeChanged(sender: UISegmentedControl) {
        previewField.keyboardType = UIKeyboardType(rawValue: sender.selectedSegmentIndex)!
        update()
    }
}
