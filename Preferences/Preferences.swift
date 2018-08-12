//
//  Preferences.swift
//  Preferences
//
//  Created by Jeong YunWon on 2017. 11. 29..
//  Copyright © 2017 youknowone.org. All rights reserved.
//

import Foundation
import PreferencePanes
import Cocoa


class GureumPreferencePane: NSPreferencePane {
    // @IBOutlet var _window: UIWindow  documented in NSPreferencePane but not automatically supported by IB
    @IBOutlet var capslockCheckbox: NSButton!
    var configuration: GureumConfiguration = GureumConfiguration();

    func loadFromData() {

    }

    func saveToData() {

    }

    @IBAction func openKeyboardPreference(sender: NSControl) {
        let myAppleScript = "reveal anchor \"ShortcutsTab\" of pane id \"com.apple.preference.keyboard\""
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error)
            print("pref event descriptor: \(output.stringValue ?? "nil")")
        }
    }

}
