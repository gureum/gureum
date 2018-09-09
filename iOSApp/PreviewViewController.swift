//
//  PreviewViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit


@objc class PreviewInputViewController: InputViewController {
    var previewController: PreviewViewController! = nil

    override func input(_ sender: GRInputButton) {
        super.input(sender)
        self.previewController.update()
    }

    override func inputDelete(_ sender: GRInputButton) {
        super.inputDelete(sender)
        self.previewController.update()
    }
}

@objc class PreviewViewController: UIViewController {
    @IBOutlet var preview: UIView!

    let inputPreviewController = PreviewInputViewController()
    var loaded = false

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.inputPreviewController.view.frame = self.preview.bounds
        //println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
        self.inputPreviewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.inputPreviewController.previewController = self
        self.preview.addSubview(self.inputPreviewController.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputPreviewController.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.loaded = true
        super.viewDidAppear(animated)
        self.inputPreviewController.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if loaded {
            self.inputPreviewController.view.frame = self.preview.bounds
            self.inputPreviewController.viewWillLayoutSubviews()
        }
    }

    override func viewDidLayoutSubviews() {
        if loaded {
            self.inputPreviewController.viewDidLayoutSubviews()
        }
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //print out the previousTrait's info
        //println("previous tarit collection: \(previousTraitCollection)")
        //println("current tarit collection: \(self.traitCollection)")
    }

    func update() {
    }
}
