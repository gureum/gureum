//
//  GureumShortcutValidator.swift
//  Preferences
//
//  Created by Presto on 04/10/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation

import MASShortcut

final class GureumShortcutValidator: MASShortcutValidator {
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
