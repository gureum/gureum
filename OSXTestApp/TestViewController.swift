//
//  TestViewController.swift
//  PreferencesApp
//
//  Created by Jeong YunWon on 2018. 9. 20..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    override func loadView() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        assert(bundle.bundle != nil)
        assert(bundle.bundle.principalClass != nil)
        let loaded = bundle.instantiatePrefPaneObject()
        assert(loaded)
        let pane = bundle.prefPaneObject()!
        // pane.loadMainView()
        view = pane.mainView
    }
}
