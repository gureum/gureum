//
//  TestViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TestViewController: InputViewController {
    @IBOutlet var preview: UIView!
    @IBOutlet var compositionField: UITextField!

    override func viewDidLoad() {
        self.preview.addSubview(self.inputMethodViewController.view)
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
