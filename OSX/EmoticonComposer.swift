//
//  EmoticonComposer.swift
//  OSX
//
//  Created by Jim Jeon on 30/08/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Hangul

let DEBUG_EMOTICON = false

class EmoticonComposer: CIMComposer {
    static let emoticonTable: HGHanjaTable = HGHanjaTable(contentOfFile: Bundle.main.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")!)!

    var _candidates: [NSAttributedString]?
    var _bufferedString: String = ""
    var _composedString: String = ""
    var _commitString: String = ""
    var mode: Bool = true

    var _selectedCandidate: NSAttributedString? = nil

    var romanComposer: CIMComposerDelegate {
        return self.delegate
    }

    override var candidates: [NSAttributedString]? {
        return _candidates
    }

    override var composedString: String {
        return _composedString
    }

    override var commitString: String {
        return _commitString
    }

    override var originalString: String {
        return _bufferedString
    }

    override func dequeueCommitString() -> String {
        let result = self._commitString
        if !result.isEmpty {
            self._bufferedString = ""
            self._commitString = ""
        }
        return result
    }

    override func cancelComposition() {
        self.romanComposer.cancelComposition()
        let _ = self.romanComposer.dequeueCommitString()
        self._commitString.append(self._composedString)
        self._bufferedString = ""
        self._composedString = ""
    }

    override func clearContext() {
        self._commitString = ""
    }

    override var hasCandidates: Bool {
        guard let candidates = self._candidates else {
            return false
        }
        return candidates.count > 0 ? true : false
    }

    override func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [candidateSelected] MSG: function called")
        let value: String = candidateString.string.components(separatedBy: ":")[0]
        dlog(DEBUG_EMOTICON, "DEBUG 2, [candidateSelected] MSG: value == %@", value)
        self._bufferedString = ""
        self._composedString = ""
        self._commitString = value
        self.romanComposer.cancelComposition()
        let _ = self.romanComposer.dequeueCommitString()
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        if candidateString.length == 0 {
            self._selectedCandidate = nil
        } else {
            let value: String = candidateString.string.components(separatedBy: ":")[0]
            self._selectedCandidate = NSAttributedString(string: value)
        }
    }

    func exitComposer() {
        // step 1. mode false
        self.mode = false
        // step 2. cancel candidates
        self._candidates = nil
        // step 3. get all composing characters
        self.romanComposer.cancelComposition()
        self._bufferedString.append(self.romanComposer.dequeueCommitString())
        // step 4. commit all
        self._composedString = self.originalString
        self.cancelComposition()
    }

    func updateEmoticonCandidates() {
        // Step 1: Get string from romanComposer
        let dequeued: String = self.romanComposer.dequeueCommitString()
        // Step 2: Show the string
        self._bufferedString.append(dequeued)
        self._bufferedString.append(self.romanComposer.composedString)
        let originalString: String = self._bufferedString
        self._composedString = originalString
        let keyword: String = originalString

        dlog(DEBUG_EMOTICON, "DEBUG 1, [updateEmoticonCandidates] MSG: %@", originalString)
        if keyword.isEmpty {
            self._candidates = nil
        } else {
            let loweredKeyword = keyword.lowercased() // case insensitive searching
            self._candidates = []
            for table: HGHanjaTable in [EmoticonComposer.emoticonTable] {
                dlog(DEBUG_EMOTICON, "DEBUG 3, [updateEmoticonCandidates] MSG: before hanjasByPrefixSearching")
                dlog(DEBUG_EMOTICON, "DEBUG 4, [updateEmoticonCandidates] MSG: [keyword: %@]", loweredKeyword)
                dlog(DEBUG_EMOTICON, "DEBUG 14, [updateEmoticonCandidates] MSG: %@", EmoticonComposer.emoticonTable.debugDescription)
                let list: HGHanjaList = table.hanjas(byPrefixSearching: loweredKeyword) ?? HGHanjaList()
                dlog(DEBUG_EMOTICON, "DEBUG 5, [updateEmoticonCandidates] MSG: after hanjasByPrefixSearching")

                dlog(DEBUG_EMOTICON, "DEBUG 9, [updateEmoticonCandidates] MSG: count is %d", list.count)
                if list.count > 0 {
                    for idx in 0...list.count-1 {
                        let emoticon = list.hanja(at: idx)
                        dlog(DEBUG_EMOTICON, "DEBUG 6, [updateEmoticonCandidates] MSG: %@ %@ %@", list.hanja(at: idx).comment, list.hanja(at: idx).key, list.hanja(at: idx).value)
                        self._candidates!.append(
                            NSAttributedString(string: emoticon.value as String + ": " + emoticon.comment as String))
                    }
                }
            }
        }
        dlog(DEBUG_EMOTICON, "DEBUG 2, [updateEmoticonCandidates] MSG: %@", self._candidates ?? [])
    }

    func update(fromController controller: CIMInputController) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [update] MSG: function called")
        let markedRange: NSRange = controller.client().markedRange()
        let selectedRange: NSRange = controller.client().selectedRange()

        let isInvalidMarkedRange: Bool = markedRange.length == 0 || markedRange.length == NSNotFound

        dlog(DEBUG_EMOTICON, "DEBUG 2, [update] MSG: DEBUG POINT 1")
        if isInvalidMarkedRange && selectedRange.length > 0 {
            let selectedString: String = controller.client().attributedSubstring(from: selectedRange).string

            controller.client().setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_EMOTICON, "DEBUG 3, [update] MSG: marking: %@ / selected: %@", NSStringFromRange(controller.client().markedRange()), NSStringFromRange(controller.client().selectedRange()))

            self._bufferedString = selectedString
            dlog(DEBUG_EMOTICON, "DEBUG 4, [update] MSG: %@", self._bufferedString)
        }

        dlog(DEBUG_EMOTICON, "DEBUG 5, [update] MSG: before updateEmoticonCandidates")
        self.updateEmoticonCandidates()
        dlog(DEBUG_EMOTICON, "DEBUG 6, [update] MSG: after updateEmoticonCandidates")
    }

    override func input(controller: CIMInputController, inputText string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [inputController] MSG: %@, [[%d]]", string, keyCode)
        var result: CIMInputTextProcessResult = self.delegate.input(controller: controller, inputText: string, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        // BackSpace
        case kVK_Delete: if result == .notProcessed {
            if !self.originalString.isEmpty {
                dlog(DEBUG_EMOTICON, "DEBUG 2, [inputController] MSG: before deletion, buffer (%@)", self._bufferedString)
                self._bufferedString.removeLast()
                dlog(DEBUG_EMOTICON, "DEBUG 3, [inputController] MSG: after deletion, buffer (%@)", self._bufferedString)
                self._composedString = self.originalString
                result = .processed
            } else {
                // 글자를 모두 지우면 이모티콘 모드에서 빠져 나간다.
                self.mode = false
            }
        }
        // Space
        case kVK_Space:
            if !self._bufferedString.isEmpty {
                self._bufferedString.append(" ")
                result = .processed
            } else {
                result = .notProcessedAndNeedsCommit
            }
        // ESC
        case kVK_Escape:
            self.exitComposer()
            return .notProcessedAndNeedsCommit
        // Enter
        case kVK_Return:
            self.candidateSelected(self._selectedCandidate ?? NSAttributedString(string: self.composedString))
        default:
            dlog(DEBUG_EMOTICON, "DEBUG 4, [inputController] MSG: %@", string)
            if result == .notProcessed && string != nil && keyCode < 0x33 {
                self._bufferedString.append(string)
                result = .processed
            }
        }

        dlog(DEBUG_EMOTICON, "DEBUG 2, [inputController] MSG: %@", string)
        self.updateEmoticonCandidates()

        dlog(DEBUG_EMOTICON, "DEBUG 3, [inputController] MSG: %@", string)

        if result == .notProcessedAndNeedsCommit {
            self.cancelComposition()
            return result
        }
        if self.commitString.isEmpty {
            return result == .processed ? .processed : .notProcessed
        } else {
            return .notProcessedAndNeedsCommit
        }
    }
}
