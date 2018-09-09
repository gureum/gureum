//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit
import GoogleMobileAds

@objc class TestViewController: PreviewViewController {
    @IBOutlet var _bannerAdsView: GADBannerView!
    @objc override var bannerAdsView: GADBannerView! { get { return self._bannerAdsView; } }

    @IBOutlet var keyboardTypeScrollView: UIScrollView!
    @IBOutlet var previewField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardTypeScrollView.setContentSizeBySubviewBoundaryWithAutoMargins()
        self.update()

        //self.loadBannerAds()
    }

    override func update() {
        self.inputPreviewController.textWillChange(self.previewField)
        super.update()
        let proxy = self.inputPreviewController.textDocumentProxy
        self.previewField.text = (proxy.documentContextBeforeInput ?? "") + (proxy.documentContextAfterInput ?? "")
        self.inputPreviewController.textDidChange(self.previewField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func keyboardTypeChanged(sender: UISegmentedControl) {
        self.previewField.keyboardType = UIKeyboardType(rawValue: sender.selectedSegmentIndex)!
        self.update()
    }
}
