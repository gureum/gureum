//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TestViewController: KeyboardViewController {
    @IBOutlet var keyboardView: UIView

    @IBAction func layout() {
        self.helper.layoutIn(self.keyboard.view);
    }

    override func viewDidLoad() {
        //super.viewDidLoad()

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
