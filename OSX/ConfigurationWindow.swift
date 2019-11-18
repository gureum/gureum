//
//  ConfigurationWindow.swift
//  OSX
//
//  Created by Jeong YunWon on 2019/11/03.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

final class ConfiguraionWindowController: NSWindowController {}

final class PreferencePaneViewController: NSViewController {
    private let _isAtLeast10_15 = ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 15, patchVersion: 0))

    override func loadView() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        assert(bundle.bundle != nil)
        assert(bundle.bundle.principalClass != nil)
        if _isAtLeast10_15 {
            let pane = NSPreferencePane(bundle: bundle.bundle)
            pane.loadMainView()
            view = pane.mainView
        } else {
            let loaded = bundle.instantiatePrefPaneObject()
            assert(loaded)
            let pane = bundle.prefPaneObject()!
            view = pane.mainView
        }
    }
}
