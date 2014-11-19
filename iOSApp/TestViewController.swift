//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TestViewController: PreviewViewController {
    @IBOutlet var previewField: UITextField!

    override func update() {
        super.update()
        let proxy = self.inputPreviewController.textDocumentProxy as UITextDocumentProxy
        self.previewField.text = "\(proxy.documentContextBeforeInput)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
