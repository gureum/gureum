//
//  BaseComposer.swift
//  Gureum
//
//  Created by 김민주 on 2018. 9. 1..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

class BaseComposer {
    func composedString() -> NSString {
        return ""
    }

    func originalString() -> NSString {
        return ""
    }

    func commitString() -> NSString {
        return ""
    }

    func dequeueCommitString() -> String {
        return ""
    }

    func cancelComposition() {}

    func clearContext() {}

    func hasCandidates() -> Bool { return false }

    func candidates() -> NSArray? {
        return nil
    }

    func input(controller _: InputController!, command _: String!, key _: Int, modifier _: NSEvent.ModifierFlags, client _: Any) -> InputResult {
        return .notProcessed
    }
}
