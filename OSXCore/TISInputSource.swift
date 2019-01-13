//
//  TISInputSource.swift
//  OSXCore
//
//  Created by Jeong YunWon on 13/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import CoreFoundation

extension TISInputSource {
    class func currentKeyboard() -> TISInputSource? {
        guard let unmanaged = TISCopyCurrentKeyboardInputSource() else {
            return nil
        }
        return unmanaged.takeRetainedValue()
    }

    class func currentKeyboardLayout() -> TISInputSource? {
        guard let unmanaged = TISCopyCurrentKeyboardLayoutInputSource() else {
            return nil
        }
        return unmanaged.takeRetainedValue()
    }
}
