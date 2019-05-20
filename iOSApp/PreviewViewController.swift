//
//  PreviewViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

@objc class PreviewInputViewController: InputViewController {
    var previewController: PreviewViewController!

    override func input(_ sender: GRInputButton) {
        super.input(sender)
        previewController.update()
    }

    override func inputDelete(_ sender: GRInputButton) {
        super.inputDelete(sender)
        previewController.update()
    }
}

@objc class PreviewViewController: UIViewController {
    @IBOutlet var preview: UIView!

    let inputPreviewController = PreviewInputViewController()
    var loaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        inputPreviewController.view.frame = preview.bounds
        // println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
        inputPreviewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        inputPreviewController.previewController = self
        preview.addSubview(inputPreviewController.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputPreviewController.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        loaded = true
        super.viewDidAppear(animated)
        inputPreviewController.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if loaded {
            inputPreviewController.view.frame = preview.bounds
            inputPreviewController.viewWillLayoutSubviews()
        }
    }

    override func viewDidLayoutSubviews() {
        if loaded {
            inputPreviewController.viewDidLayoutSubviews()
        }
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        // print out the previousTrait's info
        // println("previous tarit collection: \(previousTraitCollection)")
        // println("current tarit collection: \(self.traitCollection)")
    }

    func update() {}
}
