//
//  Preferences.swift
//  Preferences
//
//  Created by Jeong YunWon on 2017. 11. 29..
//  Copyright © 2017 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation
import MASShortcut
import PreferencePanes

@objcMembers class GureumPreferencePane: NSPreferencePane {
    @IBOutlet var viewController: NSViewController!

    override func mainViewDidLoad() {
        super.mainViewDidLoad()
    }
}

@objcMembers class PreferenceViewController: NSViewController, NSComboBoxDataSource {
    @IBOutlet var inputModeExchangeShortcutView: MASShortcutView!
    @IBOutlet var inputModeHanjaShortcutView: MASShortcutView!
    @IBOutlet var inputModeEnglishShortcutView: MASShortcutView!
    @IBOutlet var inputModeKoreanShortcutView: MASShortcutView!
    @IBOutlet var hangulWonCurrencySymbolForBackQuoteButton: NSButton!
    @IBOutlet var optionKeyComboBox: NSComboBoxCell!
    @IBOutlet var romanModeByEscapeKeyButton: NSButton!
    @IBOutlet var hangulAutoReorderButton: NSButton!
    @IBOutlet var hangulNonChoseongCombinationButton: NSButton!
    @IBOutlet var hangulForceStrictCombinationRuleButton: NSButton!

    var configuration = GureumConfiguration()
    let pane: GureumPreferencePane! = nil
    let shortcutValidator = GureumShortcutValidator()

//    @IBOutlet var _window: NSWindow!

    func boolToButtonState(_ value: Bool) -> NSButton.StateValue {
        return value ? .on : .off
    }

    func loadShortcutValues() {
        if let key = configuration.inputModeExchangeKey {
            inputModeExchangeShortcutView.shortcutValue = MASShortcut(keyCode: key.0, modifierFlags: key.1.rawValue)
        } else {
            inputModeExchangeShortcutView.shortcutValue = nil
        }

        if let key = configuration.inputModeHanjaKey {
            inputModeHanjaShortcutView.shortcutValue = MASShortcut(keyCode: key.0, modifierFlags: key.1.rawValue)
        } else {
            inputModeHanjaShortcutView.shortcutValue = nil
        }

        if let key = configuration.inputModeEnglishKey {
            inputModeEnglishShortcutView.shortcutValue = MASShortcut(keyCode: key.0, modifierFlags: key.1.rawValue)
        } else {
            inputModeEnglishShortcutView.shortcutValue = nil
        }

        if let key = configuration.inputModeKoreanKey {
            inputModeKoreanShortcutView.shortcutValue = MASShortcut(keyCode: key.0, modifierFlags: key.1.rawValue)
        } else {
            inputModeKoreanShortcutView.shortcutValue = nil
        }
    }

    func setupShortcutViewValueChangeEvents() {
        func masShortcutToShortcut(_ mas: MASShortcut?) -> GureumConfiguration.Shortcut? {
            guard let mas = mas else {
                return nil
            }
            return (mas.keyCode, NSEvent.ModifierFlags(rawValue: mas.modifierFlags))
        }
        inputModeExchangeShortcutView.shortcutValueChange = { sender in
            guard let sender = sender else {
                return
            }
            self.configuration.inputModeExchangeKey = masShortcutToShortcut(sender.shortcutValue)
        }

        inputModeHanjaShortcutView.shortcutValueChange = { sender in
            guard let sender = sender else {
                return
            }
            self.configuration.inputModeHanjaKey = masShortcutToShortcut(sender.shortcutValue)
        }

        inputModeEnglishShortcutView.shortcutValueChange = { sender in
            guard let sender = sender else {
                return
            }
            self.configuration.inputModeEnglishKey = masShortcutToShortcut(sender.shortcutValue)
        }

        inputModeKoreanShortcutView.shortcutValueChange = { sender in
            guard let sender = sender else {
                return
            }
            self.configuration.inputModeKoreanKey = masShortcutToShortcut(sender.shortcutValue)
        }
    }

    override func viewDidLoad() {
        hangulWonCurrencySymbolForBackQuoteButton.state = boolToButtonState(configuration.hangulWonCurrencySymbolForBackQuote)
        romanModeByEscapeKeyButton.state = boolToButtonState(configuration.romanModeByEscapeKey)
        hangulAutoReorderButton.state = boolToButtonState(configuration.hangulAutoReorder)
        hangulNonChoseongCombinationButton.state = boolToButtonState(configuration.hangulNonChoseongCombination)
        hangulForceStrictCombinationRuleButton.state = boolToButtonState(configuration.hangulForceStrictCombinationRule)
        if (0 ..< optionKeyComboBox.numberOfItems).contains(configuration.optionKeyBehavior) {
            optionKeyComboBox.selectItem(at: configuration.optionKeyBehavior)
        }
        inputModeExchangeShortcutView.shortcutValidator = shortcutValidator
        inputModeHanjaShortcutView.shortcutValidator = shortcutValidator
        inputModeEnglishShortcutView.shortcutValidator = shortcutValidator
        inputModeKoreanShortcutView.shortcutValidator = shortcutValidator

        loadShortcutValues()
        setupShortcutViewValueChangeEvents()
    }

    @IBAction func openKeyboardPreference(sender _: NSControl) {
        let myAppleScript = "reveal anchor \"ShortcutsTab\" of pane id \"com.apple.preference.keyboard\""
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error
            )
            print("pref event descriptor: \(output.stringValue ?? "nil")")
        }
    }

    @IBAction func optionKeyComboBoxValueChanged(_ sender: NSComboBox) {
        configuration.optionKeyBehavior = sender.indexOfSelectedItem
    }

    @IBAction func romanModeByEscapeKeyValueChanged(_ sender: NSButton) {
        configuration.romanModeByEscapeKey = sender.state == .on
    }
/*
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
*/
    @IBAction func hangulWonCurrencySymbolForBackQuoteValueChanged(_ sender: NSButton) {
        configuration.hangulWonCurrencySymbolForBackQuote = sender.state == .on
    }

    @IBAction func hangulAutoReorderValueChanged(_ sender: NSButton) {
        configuration.hangulAutoReorder = sender.state == .on
    }

    @IBAction func hangulNonChoseongCombinationValueChanged(_ sender: NSButton) {
        configuration.hangulNonChoseongCombination = sender.state == .on
    }

    @IBAction func hangulForceStrictCombinationRuleValueChanged(_ sender: NSButton) {
        configuration.hangulForceStrictCombinationRule = sender.state == .on
    }
}

@objc class GureumLayoutTable: NSObject {
    let gureumPreferencesHangulLayouts = [
        "org.youknowone.inputmethod.Gureum.han2",
        "org.youknowone.inputmethod.Gureum.han2classic",
        "org.youknowone.inputmethod.Gureum.han3final",
        "org.youknowone.inputmethod.Gureum.han390",
        "org.youknowone.inputmethod.Gureum.han3noshift",
        "org.youknowone.inputmethod.Gureum.han3classic",
        "org.youknowone.inputmethod.Gureum.hanroman",
        "org.youknowone.inputmethod.Gureum.hanahnmatae",
        "org.youknowone.inputmethod.Gureum.han3-2011",
        "org.youknowone.inputmethod.Gureum.han3-2012",
        "org.youknowone.inputmethod.Gureum.han3finalnoshift",
        "org.youknowone.inputmethod.Gureum.han3-2014",
        "org.youknowone.inputmethod.Gureum.han3-2015",
    ]

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

class GureumShortcutValidator: MASShortcutValidator {
    override init() {
        super.init()
        allowAnyShortcutWithOptionModifier = true
    }

    override func isShortcutAlreadyTaken(bySystem _: MASShortcut!, explanation _: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        return false
    }

    override func isShortcutValid(_ shortcut: MASShortcut!) -> Bool {
        if super.isShortcutValid(shortcut) {
            return true
        }
        let modifiers = shortcut.modifierFlags
        let keyCode = shortcut.keyCode
        guard (modifiers & NSEvent.ModifierFlags.shift.rawValue) > 0 else {
            return false
        }
        return keyCode >= 0x33 || [kVK_Return, kVK_Tab, kVK_Space].contains(Int(keyCode))
    }

    override func isShortcut(_: MASShortcut!, alreadyTakenIn _: NSMenu!, explanation _: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        return false
    }
}
