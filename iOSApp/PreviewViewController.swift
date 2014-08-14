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
    let inputMethodViewController: InputMethodViewController! = InputMethodViewController(nibName: "InputMethod", bundle: nil)

    override func viewDidLoad()  {
        super.viewDidLoad()
        self.preview.addSubview(self.inputMethodViewController.view)
        self.inputMethodViewController.loadFromPreferences()
    }
}