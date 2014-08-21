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
        println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
        self.preview.addSubview(self.inputPreviewController.view)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inputPreviewController.view.frame = self.preview.bounds
        self.inputPreviewController.viewWillAppear(animated)
        println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.inputPreviewController.viewDidAppear(animated)
        println("preview bounds: \(self.preview.frame) / input bounds: \(self.inputPreviewController.view.frame)")
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        var newSize = self.preview.bounds.size
        newSize.width = size.width
        self.inputPreviewController.viewWillTransitionToSize(newSize, withTransitionCoordinator: coordinator)
    }
}