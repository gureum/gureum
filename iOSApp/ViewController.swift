//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TestViewController: UIInputViewController {
    @IBOutlet var keyboardView: UIView
    let keyboard: KeyboardLayout
    var helper: GRKeyboardLayoutHelper

    func _init() {
        self.keyboard.inputViewController = self
        self.helper.delegate = keyboard
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.helper = GRKeyboardLayoutHelper(delegate: nil)
        self.keyboard = QwertyKeyboardLayout(nibName: "Container", bundle: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }

    init(coder: NSCoder?) {
        self.helper = GRKeyboardLayoutHelper(delegate: nil)
        self.keyboard = QwertyKeyboardLayout(nibName: "Container", bundle: nil)
        super.init(coder: coder)
        _init()
    }

    @IBAction func layout() {
        self.helper.layoutIn(self.keyboard.view);
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = self.keyboardView.frame
        self.keyboardView.removeFromSuperview()

        self.keyboardView = self.keyboard.view
        self.keyboard.view.frame = frame
        self.view.addSubview(self.keyboardView)

        self.layout()
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */

}
