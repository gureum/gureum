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
    @IBOutlet var overridingKeyboardNameComboBox: NSComboBoxCell!
    @IBOutlet var romanModeByEscapeKeyButton: NSButton!
    @IBOutlet var hangulAutoReorderButton: NSButton!
    @IBOutlet var hangulNonChoseongCombinationButton: NSButton!
    @IBOutlet var hangulForceStrictCombinationRuleButton: NSButton!
    
    var configuration = Configuration()
    let pane: GureumPreferencePane! = nil
    let shortcutValidator = GureumShortcutValidator()
    
    lazy var inputSources: [(identifier: String, localizedName: String)] = {
        let abcIdentifier = "com.apple.keylayout.ABC"
        
        guard let rawSources = TISInputSource.sources(withProperties: [kTISPropertyInputSourceType!: kTISTypeKeyboardLayout!, kTISPropertyInputSourceIsASCIICapable!: true], includeAllInstalled: true) else {
            return []
        }
        
        let unsortedSources = rawSources.map { (identifier: $0.identifier, localizedName: $0.localizedName, enabled: $0.enabled) }
        let sortedSources = unsortedSources.sorted {
            if $0.identifier == abcIdentifier {
                return true
            } else if $1.identifier == abcIdentifier {
                return false
            }
            if $0.enabled != $1.enabled {
                return $0.enabled
            }
            return $0.localizedName < $1.localizedName
        }
        let sources = sortedSources.map { (identifier: $0.identifier, localizedName: $0.localizedName) }
        return sources
    }()
    
    //    @IBOutlet var _window: NSWindow!
    
    func boolToButtonState(_ value: Bool) -> NSButton.StateValue {
        return value ? .on : .off
    }
    
    func loadShortcutValues() {
        if let key = configuration.inputModeExchangeKey {
            inputModeExchangeShortcutView.shortcutValue = MASShortcut(keyCode: key.0.rawValue, modifierFlags: key.1)
        } else {
            inputModeExchangeShortcutView.shortcutValue = nil
        }
        
        if let key = configuration.inputModeHanjaKey {
            inputModeHanjaShortcutView.shortcutValue = MASShortcut(keyCode: key.0.rawValue, modifierFlags: key.1)
        } else {
            inputModeHanjaShortcutView.shortcutValue = nil
        }
        
        if let key = configuration.inputModeEnglishKey {
            inputModeEnglishShortcutView.shortcutValue = MASShortcut(keyCode: key.0.rawValue, modifierFlags: key.1)
        } else {
            inputModeEnglishShortcutView.shortcutValue = nil
        }
        
        if let key = configuration.inputModeKoreanKey {
            inputModeKoreanShortcutView.shortcutValue = MASShortcut(keyCode: key.0.rawValue, modifierFlags: key.1)
        } else {
            inputModeKoreanShortcutView.shortcutValue = nil
        }
    }
    
    func setupShortcutViewValueChangeEvents() {
        func masShortcutToShortcut(_ mas: MASShortcut?) -> Configuration.Shortcut? {
            guard let mas = mas, let keyCode = KeyCode(rawValue: mas.keyCode) else { return nil }
            return (keyCode, mas.modifierFlags)
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
        
        overridingKeyboardNameComboBox.reloadData()
        if let selectedIndex = inputSources.firstIndex(where: { $0.identifier == configuration.overridingKeyboardName }) {
            overridingKeyboardNameComboBox.selectItem(at: selectedIndex)
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
    
    func numberOfItems(in _: NSComboBox) -> Int {
        return inputSources.count
    }
    
    func comboBox(_: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return inputSources[index].localizedName
    }
    
    func comboBox(_: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return inputSources.firstIndex(where: { $0.localizedName == string }) ?? NSNotFound
    }
    
    func comboBox(_: NSComboBox, completedString string: String) -> String? {
        for source in inputSources {
            if source.localizedName.starts(with: string) {
                return source.localizedName
            }
        }
        overridingKeyboardNameComboBox.stringValue = ""
        return ""
    }
    
    @IBAction func overridingKeyboardNameComboBoxValueChanged(_ sender: NSComboBox) {
        guard sender.indexOfSelectedItem != NSNotFound else {
            return
        }
        configuration.overridingKeyboardName = inputSources[sender.indexOfSelectedItem].identifier
    }
    
    @IBAction func romanModeByEscapeKeyValueChanged(_ sender: NSButton) {
        configuration.romanModeByEscapeKey = sender.state == .on
    }
    
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
        guard (modifiers.rawValue & NSEvent.ModifierFlags.shift.rawValue) > 0 else {
            return false
        }
        guard let key = KeyCode(rawValue: keyCode) else { return false }
        return !key.isKeyMappable || [.return, .tab, .space].contains(key)
    }
    
    override func isShortcut(_: MASShortcut!, alreadyTakenIn _: NSMenu!, explanation _: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        return false
    }
}

// pod으로 설치하면 정상적으로 불러와지지 않는다
extension TISInputSource {
    class func sources(withProperties properties: NSDictionary, includeAllInstalled: Bool) -> [TISInputSource]? {
        guard let unmanaged = TISCreateInputSourceList(properties, includeAllInstalled) else {
            return nil
        }
        return unmanaged.takeRetainedValue() as? [TISInputSource]
    }
    
    func property(forKey key: String) -> Any? {
        guard let unmanaged = TISGetInputSourceProperty(self, key as CFString) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(unmanaged).takeUnretainedValue()
    }
    
    var enabled: Bool {
        return property(forKey: kTISPropertyInputSourceIsEnabled as String) as! Bool
    }
    
    var identifier: String {
        return property(forKey: kTISPropertyInputSourceID as String) as! String
    }
    
    var localizedName: String {
        return property(forKey: kTISPropertyLocalizedName as String) as! String
    }
}
