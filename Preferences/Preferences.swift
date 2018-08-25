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


@objc class GureumLayoutTable: NSObject {
    var gureumPreferencesHangulLayouts = [
        "org.youknowone.inputmethod.Gureum.han2",
        "org.youknowone.inputmethod.Gureum.han2classic",
        "org.youknowone.inputmethod.Gureum.han3final",
        "org.youknowone.inputmethod.Gureum.han3finalloose",
        "org.youknowone.inputmethod.Gureum.han390",
        "org.youknowone.inputmethod.Gureum.han390loose",
        "org.youknowone.inputmethod.Gureum.han3noshift",
        "org.youknowone.inputmethod.Gureum.han3classic",
        "org.youknowone.inputmethod.Gureum.hanroman",
        "org.youknowone.inputmethod.Gureum.hanahnmatae",
        "org.youknowone.inputmethod.Gureum.han3-2011",
        "org.youknowone.inputmethod.Gureum.han3-2011loose",
        "org.youknowone.inputmethod.Gureum.han3-2012",
        "org.youknowone.inputmethod.Gureum.han3-2012loose",
        "org.youknowone.inputmethod.Gureum.han3finalnoshift",
        "org.youknowone.inputmethod.Gureum.han3finalnoshiftsymbol",
        "org.youknowone.inputmethod.Gureum.han3-2014",
        "org.youknowone.inputmethod.Gureum.han3-2015" ]
    
    let layoutNames: [String]
    
    override init() {
        let bundle = Bundle(identifier: "org.youknowone.inputmethod.Gureum")!
        let info = bundle.localizedInfoDictionary!
        var names: [String] = []
        for layout in gureumPreferencesHangulLayouts {
            names.append(info[layout] as! String)
        }
        layoutNames = names
        super.init()
    }
    
    @objc convenience init(bundle: Bundle) {
        self.init()
    }
    
}


@objcMembers class GureumPreferencePane: NSPreferencePane, NSComboBoxDataSource {
    @IBOutlet weak var defaultInputHangulComboBox: NSComboBox!
    var configuration = GureumConfiguration()
    let layoutTable = GureumLayoutTable()
    
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
    
    @IBAction func optionKeyComboBoxValueChanged(_ sender: NSComboBox) {
        configuration.optionKeyBehavior = sender.indexOfSelectedItem
    }
    
    @IBAction func didTapAutoSaveDefaultInputModeCheckBox(_ sender: NSButton) {
        configuration.autosaveDefaultInputMode = sender.integerValue
    }
    
    @IBAction func defaultHangulInputModeComboBoxValueChanged(_ sender: NSComboBox) {
        let index = layoutTable.layoutNames.index(of: defaultInputHangulComboBox.stringValue)!
        configuration.lastHangulInputMode = layoutTable.gureumPreferencesHangulLayouts[index]
    }
    
    @IBAction func didTapRomanModeByEscapeKey(_ sender: NSButton) {
        configuration.romanModeByEscapeKey = sender.integerValue
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return layoutTable.gureumPreferencesHangulLayouts.count
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return layoutTable.layoutNames.index(of: string)!
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return layoutTable.layoutNames[index]
    }
}

