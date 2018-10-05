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
import MASShortcut

@objcMembers class GureumPreferencePane: NSPreferencePane {
    @IBOutlet var viewController: NSViewController! = nil
    
    override func mainViewDidLoad() {
        super.mainViewDidLoad()
        self.viewController.viewDidLoad()
    }
}

@objcMembers class PreferenceViewController: NSViewController, NSComboBoxDataSource {
    @IBOutlet weak var defaultInputHangulComboBox: NSComboBox!
    @IBOutlet weak var inputModeExchangeShortcutView: MASShortcutView!
    @IBOutlet weak var inputModeHanjaShortcutView: MASShortcutView!
    @IBOutlet weak var inputModeEnglishShortcutView: MASShortcutView!
    @IBOutlet weak var inputModeKoreanShortcutView: MASShortcutView!
    @IBOutlet weak var hangulWonCurrencySymbolForBackQuoteButton: NSButton!
    @IBOutlet weak var optionKeyComboBox: NSComboBoxCell!
    @IBOutlet weak var autoSaveDefaultInputModeButton: NSButton!
    @IBOutlet weak var enableCapslockToToggleInputModeButton: NSButton!
    @IBOutlet weak var romanModeByEscapeKeyButton: NSButton!
    
    var configuration = GureumConfiguration()
    let layoutTable = GureumLayoutTable()
    let pane: GureumPreferencePane! = nil
    
//    @IBOutlet var _window: NSWindow!
    
    func boolToButtonState(_ value: Bool) -> NSButton.StateValue {
        return value ? .on : .off
    }
    
    override func viewDidLoad() {
        enableCapslockToToggleInputModeButton.state = boolToButtonState(configuration.enableCapslockToToggleInputMode)
        hangulWonCurrencySymbolForBackQuoteButton.state = boolToButtonState(configuration.hangulWonCurrencySymbolForBackQuote)
        romanModeByEscapeKeyButton.state = boolToButtonState(configuration.romanModeByEscapeKey)
        autoSaveDefaultInputModeButton.state = boolToButtonState(configuration.autosaveDefaultInputMode)
        if let index = layoutTable.gureumPreferencesHangulLayouts.index(of: configuration.lastHangulInputMode!) {
            defaultInputHangulComboBox.selectItem(at: index)
        }
        optionKeyComboBox.selectItem(at: configuration.optionKeyBehavior)
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
        if sender.state == .on {
            configuration.autosaveDefaultInputMode = true
        } else {
            configuration.autosaveDefaultInputMode = false
        }
    }
    
    @IBAction func defaultHangulInputModeComboBoxValueChanged(_ sender: NSComboBox) {
        let index = layoutTable.layoutNames.index(of: defaultInputHangulComboBox.stringValue)!
        configuration.lastHangulInputMode = layoutTable.gureumPreferencesHangulLayouts[index]
    }
    
    @IBAction func didTapRomanModeByEscapeKey(_ sender: NSButton) {
        if sender.state == .on {
            configuration.romanModeByEscapeKey = true
        } else {
            configuration.romanModeByEscapeKey = false
        }
    }
    
    @IBAction func enableCapslockToToggleInputMode(_ sender: NSButton) {
        if sender.state == .on {
            configuration.enableCapslockToToggleInputMode = true
        } else {
            configuration.enableCapslockToToggleInputMode = false
        }
    }
    
    @IBAction func didTapHelpShortCut(_ sender: NSButton) {
        let helpAlert: NSAlert = {
            let alert = NSAlert()
            alert.messageText = "도움말"
            alert.addButton(withTitle: "확인")
            alert.informativeText = "Space 또는 ⇧Space 로 초기화하고 새로 설정할 수 있습니다."
            return alert
        }()
        helpAlert.beginSheetModal(for: self.pane.mainView.window!, completionHandler: nil)
    }
    
    @IBAction func didTapHangulWonCurrencySymbolForBackQuoteCheckBox(_ sender: NSButton) {
        if sender.state == .on {
            configuration.hangulWonCurrencySymbolForBackQuote = true
        }
        else {
            configuration.hangulWonCurrencySymbolForBackQuote = false
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return layoutTable.gureumPreferencesHangulLayouts.count
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return layoutTable.layoutNames.index(of: string) ?? NSNotFound
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return layoutTable.layoutNames[index]
    }
}


@objc class GureumLayoutTable: NSObject {
    let gureumPreferencesHangulLayouts = [
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

}
