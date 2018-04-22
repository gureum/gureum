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

/*
 define_preference_key(CIMLastHangulInputMode);

 define_preference_key(CIMLeftCommandKeyShortcutBehavior);
 define_preference_key(CIMLeftOptionKeyShortcutBehavior);
 define_preference_key(CIMLeftControlKeyShortcutBehavior);
 define_preference_key(CIMRightCommandKeyShortcutBehavior);
 define_preference_key(CIMRightOptionKeyShortcutBehavior);
 define_preference_key(CIMRightControlKeyShortcutBehavior);
 define_preference_key(CIMInputModeExchangeKeyModifier);
 define_preference_key(CIMInputModeExchangeKeyCode);
 define_preference_key(CIMInputModeHanjaKeyModifier);
 define_preference_key(CIMInputModeHanjaKeyCode);
 define_preference_key(CIMInputModeEnglishKeyModifier);
 define_preference_key(CIMInputModeEnglishKeyCode);
 define_preference_key(CIMInputModeKoreanKeyModifier);
 define_preference_key(CIMInputModeKoreanKeyCode);
 define_preference_key(CIMOptionKeyBehavior);
 define_preference_key(CIMHangulCombinationModeComposing);
 define_preference_key(CIMHangulCombinationModeCommiting);

 define_preference_key(CIMSharedInputManager);
 define_preference_key(CIMAutosaveDefaultInputMode);
 define_preference_key(CIMRomanModeByEscapeKey);
 define_preference_key(CIMShowsInputForHanjaCandidates);
 */

class GureumPreferencePane: NSPreferencePane {
    // @IBOutlet var _window: UIWindow  documented in NSPreferencePane but not automatically supported by IB
    @IBOutlet var capslockCheckbox: NSButton!

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
            print(output.stringValue)
        }
    }

}
