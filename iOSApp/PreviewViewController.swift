//
//  PreviewViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 14..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    @IBOutlet var preview: UIView!

    let inputPreviewController = InputViewController()

    override func viewDidLoad()  {
        super.viewDidLoad()
        self.inputPreviewController.view.frame = self.preview.bounds
        //println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
        self.inputPreviewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.preview.addSubview(self.inputPreviewController.view)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inputPreviewController.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.inputPreviewController.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.inputPreviewController.view.frame = self.preview.bounds
        //self.inputPreviewController.viewDidLayoutSubviews()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.inputPreviewController.viewDidAppear(animated)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        var newSize = self.preview.bounds.size
        newSize.width = size.width
        self.inputPreviewController.viewWillTransitionToSize(newSize, withTransitionCoordinator: coordinator)
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {
        //print out the previousTrait's info
        //println("previous tarit collection: \(previousTraitCollection)")
        //println("current tarit collection: \(self.traitCollection)")
    }
}
