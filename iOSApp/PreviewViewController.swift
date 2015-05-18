//
//  PreviewViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit


class PreviewInputViewController: InputViewController {
    var previewController: PreviewViewController! = nil

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let mockTextField = UITextField()
        self.textWillChange(mockTextField)
        self.textDidChange(mockTextField)
    }

    override func input(sender: UIButton) {
        super.input(sender)
        self.previewController.update()
    }

    override func inputDelete(sender: UIButton) {
        super.inputDelete(sender)
        self.previewController.update()
    }

    override func dotcom(sender: UIButton) {
        super.dotcom(sender)
        self.previewController.update() // huh...
    }
}

class PreviewViewController: UIViewController {
    @IBOutlet var preview: UIView!

    let inputPreviewController = PreviewInputViewController()
    var loaded = false

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.inputPreviewController.view.frame = self.preview.bounds
        //println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
        self.inputPreviewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.inputPreviewController.previewController = self
        self.preview.addSubview(self.inputPreviewController.view)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inputPreviewController.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
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

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        //print out the previousTrait's info
        //println("previous tarit collection: \(previousTraitCollection)")
        //println("current tarit collection: \(self.traitCollection)")
    }

    func update() {
    }
}
