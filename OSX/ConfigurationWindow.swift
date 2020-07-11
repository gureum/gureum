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

    func viewForFailure() -> NSView {
        let rect = NSRect(x: 0, y: 0, width: 200, height: 100)
        let label = NSTextView(frame: rect)
        label.isEditable = false
        label.string = "환경설정 GUI 읽기에 실패했습니다. 버그 리포트를 남겨주세요.\n\nhttps://github.com/gureum/gureum/issues"
        let view = NSView(frame: rect)
        view.addSubview(label)
        return view
    }

    func viewFromPrefPane() -> NSView {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        guard bundle.bundle != nil, bundle.bundle.principalClass != nil else {
            return viewForFailure()
        }
        if _isAtLeast10_15 {
            let pane = NSPreferencePane(bundle: bundle.bundle)
            return pane.loadMainView()
        } else {
            let loaded = bundle.instantiatePrefPaneObject()
            assert(loaded)
            let pane = bundle.prefPaneObject()!
            return pane.mainView
        }
    }

    func viewFromNib() -> NSView {
        var topLevelObjects: NSArray?
        let succeed = Bundle.main.loadNibNamed("Preferences", owner: self, topLevelObjects: &topLevelObjects)
        guard let nibObjects = topLevelObjects, succeed else {
            NSLog("Preferences nib loading failed.")
            return viewForFailure()
        }
        guard let vc = nibObjects.filter({
            ($0 as! NSObject).className == "PreferenceViewController"
        }).first as? PreferenceViewController else {
            NSLog("Preferences lookup failed.")
            return viewForFailure()
        }
        return vc.view
    }

    override func loadView() {
        #if USE_PREFPANE
            view = viewFromPrefPane()
        #else
            view = viewFromNib()
        #endif
    }
}
