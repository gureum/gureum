//
//  EmoticonComposer.swift
//  OSX
//
//  Created by Jim Jeon on 30/08/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation


class EmojiComposer: CIMComposer {
    // FIXME: How can i use static with _sharedEmojiTable?
    var _sharedEmojiTable: HGHanjaTable? = nil

    // ???: commit string is the final output of Composer
    // ???: How about nullable?
    var _commitString: String = ""
    // ???: candidates are searched emoticon list of given keyword
    // ???: How about nullable?
    var _candidates: [String]? = nil
    // ???: composed string is for the Korean
    var _composedString: String = ""
    // ???: _buffered string for storing the given input
    var _bufferedString: String = ""
    // ???: where is original string?

    // ???: What is mode for?
    var mode: Bool = true

    // ???: Main composer, How to use both roman and hangul
    var romanComposer: CIMComposerDelegate {
        return self.delegate
    }

    // ???: Why wrap composedString?
    override var composedString: String! {
        get {
            return self._composedString
        }
        set(newValue) {
            self._composedString = newValue
        }
    }

    // ???: Why there is no setter?
    override var originalString: String! {
        get {
            return self._commitString
        }
    }

    // ???: Why wrapped and do this need setter?
    override var commitString: String! {
        get {
            return self._commitString
        }
        set(newValue) {
            self._commitString = newValue
        }
    }

    // ???: use commit string
    override func dequeueCommitString() -> String! {
        let dequeued = self._commitString
        self._commitString = ""
        return dequeued
    }

    // ???: remove the given chars while composing
    override func cancelComposition() {
    }

    // ???: remove all commit string
    override func clearContext() {
        self._commitString = ""
    }

    override var hasCandidates: Bool {
        get {
            let candidates = self._candidates ?? []
            return candidates.count > 0 ? true : false
        }
    }

    // ???: Why wrap candidates????
    override var candidates: [String]! {
        get {
            return self._candidates
        }
        set(newValue) {
            self._candidates = newValue
        }
    }

    override func candidateSelected(_ candidateString: NSAttributedString!) {
        NSLog("DEBUG 1, [candidateSelected] MSG: function called")
        let value: String? = candidateString.string.components(separatedBy: ":")[0]
        NSLog("DEBUG 2, [candidateSelected] MSG: value == %@", value ?? "")
        self.composedString = ""
        self.commitString = value ?? ""
        self.romanComposer.cancelComposition()
        self.romanComposer.dequeueCommitString()
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        NSLog("DEBUG 1, [candidateSelectionChanged] MSG: function called")
        NSLog("DEBUG 2, [candidateSelectionChanged] MSG: candidateString.length == %d", candidateString.length)
        if candidateString.length == 0 {
            self.composedString = self.originalString
        } else {
            let value: String = candidateString.string.components(separatedBy: ":")[0]
            self.composedString = value
        }
        NSLog("DEBUG 3, [candidateSelectionChanged] MSG: composedString == %@", self.composedString)
    }

    func updateEmojiCandidates() {
        // Step 1: Get string from romanComposer
        let x: String = self.romanComposer.dequeueCommitString()
        // Step 2: Show the string
        self._bufferedString.append(x)
        self._bufferedString.append(self.romanComposer.composedString)
        let originalString: String = self._bufferedString
        self.composedString = originalString
        let keyword: String = originalString

        NSLog("DEBUG 1, [updateEmojiCandidates] MSG: %@", originalString)
        if keyword.count == 0 {
            self._candidates = nil
        } else {
            self._candidates = []
            for table: HGHanjaTable in [emojiTable()!] {
                NSLog("DEBUG 3, [updateEmojiCandidates] MSG: before hanjasByPrefixSearching")
                NSLog("DEBUG 4, [updateEmojiCandidates] MSG: [keyword: %@]", keyword)
                NSLog("DEBUG 14, [updateEmojiCandidates] MSG: %@", self._sharedEmojiTable.debugDescription)
                let list: HGHanjaList = table.hanjas(byPrefixSearching: keyword) ?? HGHanjaList()
                NSLog("DEBUG 5, [updateEmojiCandidates] MSG: after hanjasByPrefixSearching")

                NSLog("DEBUG 9, [updateEmojiCandidates] MSG: count is %d", list.count)
                if list.count > 0 {
                    for idx in 0...list.count-1 {
                        let emoji = list.hanja(at: idx)
                        if emoji == nil {
                            NSLog("DEBUG 7, [updateEmojiCandidates] MSG: hanja is nil!")
                        }
                        NSLog("DEBUG 6, [updateEmojiCandidates] MSG: %@ %@ %@", list.hanja(at: idx).comment, list.hanja(at: idx).key, list.hanja(at: idx).value)
                        self._candidates!.append(emoji!.value as String + ": " + emoji!.comment as String)
                    }
                }
            }
        }
        NSLog("DEBUG 2, [updateEmojiCandidates] MSG: %@", self.candidates)
    }

    func updateFromController(_ controller: CIMInputController) {
        let markedRange: NSRange = controller.client().markedRange()
        let selectedRange: NSRange = controller.client().selectedRange()

        let isInvalidMarkedRange: Bool = markedRange.length == 0 || markedRange.length == NSNotFound

        if isInvalidMarkedRange && selectedRange.length > 0 {
            let selectedString: String = controller.client().attributedSubstring(from: selectedRange).string

            controller.client().setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)

            self._bufferedString = selectedString

            self.mode = false
        }

        self.updateEmojiCandidates()
    }

    func emojiTable() -> HGHanjaTable? {
        if self._sharedEmojiTable == nil {
            let bundle: Bundle = Bundle.main
            let path: String? = bundle.path(forResource: "emoticonr", ofType: "txt", inDirectory: "hanja")

            self._sharedEmojiTable = HGHanjaTable.init(contentOfFile: path)
        }
        return self._sharedEmojiTable
    }

    override func inputController(_ controller: CIMInputController!, inputText string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        NSLog("DEBUG 1, [inputController] MSG: %@, [[%d]]", string, keyCode)
        var result: CIMInputTextProcessResult = self.delegate.inputController(controller, inputText: string, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        // BackSpace
        case 51:
            if result == CIMInputTextProcessResult.notProcessed {
                if self.originalString.count > 0 {
                    self._bufferedString.remove(at: self._bufferedString.endIndex)
                    self.composedString = self.originalString
                    result = CIMInputTextProcessResult.processed
                } else {
                    self.mode = false
                }
            }
            break
        // Space
        case 49:
            self.romanComposer.cancelComposition()
            self._bufferedString.append(self.romanComposer.dequeueCommitString())
            if self._bufferedString.count > 0 {
                self._bufferedString.append(" ")
                result = CIMInputTextProcessResult.processed
            } else {
                result = CIMInputTextProcessResult.notProcessedAndNeedsCommit
            }
            break
        default:
            break
        }

        NSLog("DEBUG 2, [inputController] MSG: %@", string)
        // switch for some keyCodes
        // updateEmojiCandidates
        self.updateEmojiCandidates()

        NSLog("DEBUG 3, [inputController] MSG: %@", string)

        if result == CIMInputTextProcessResult.notProcessedAndNeedsCommit {
            self.cancelComposition()
            return result
        }
        if self.commitString.count == 0 {
            return CIMInputTextProcessResult.processed
        } else {
            return CIMInputTextProcessResult.notProcessedAndNeedsCommit
        }
    }
}
