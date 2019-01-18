//
//  EmoticonComposer.swift
//  OSX
//
//  Created by Jim Jeon on 30/08/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Hangul

let DEBUG_EMOTICON = false

class EmoticonComposer: DelegatedComposer {
    static let emoticonTable: HGHanjaTable = HGHanjaTable(contentOfFile: Bundle(for: HGKeyboard.self).path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")!)!

    var _candidates: [NSAttributedString]?
    var _bufferedString: String = ""
    var _composedString: String = ""
    var _commitString: String = ""
    var mode: Bool = true

    var _selectedCandidate: NSAttributedString?

    var romanComposer: ComposerDelegate {
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
        let result = _commitString
        if !result.isEmpty {
            _bufferedString = ""
            _commitString = ""
        }
        return result
    }

    override func cancelComposition() {
        romanComposer.cancelComposition()
        _ = romanComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    override func clearContext() {
        _commitString = ""
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
        _bufferedString = ""
        _composedString = ""
        _commitString = value
        romanComposer.cancelComposition()
        _ = romanComposer.dequeueCommitString()
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        if candidateString.length == 0 {
            _selectedCandidate = nil
        } else {
            let value: String = candidateString.string.components(separatedBy: ":")[0]
            _selectedCandidate = NSAttributedString(string: value)
        }
    }

    func exitComposer() {
        // step 1. mode false
        mode = false
        // step 2. cancel candidates
        _candidates = nil
        // step 3. get all composing characters
        romanComposer.cancelComposition()
        _bufferedString.append(romanComposer.dequeueCommitString())
        // step 4. commit all
        _composedString = originalString
        cancelComposition()
    }

    func updateEmoticonCandidates() {
        // Step 1: Get string from romanComposer
        let dequeued: String = romanComposer.dequeueCommitString()
        // Step 2: Show the string
        _bufferedString.append(dequeued)
        _bufferedString.append(romanComposer.composedString)
        let originalString: String = _bufferedString
        _composedString = originalString
        let keyword: String = originalString

        dlog(DEBUG_EMOTICON, "DEBUG 1, [updateEmoticonCandidates] MSG: %@", originalString)
        if keyword.isEmpty {
            _candidates = nil
        } else {
            let loweredKeyword = keyword.lowercased() // case insensitive searching
            _candidates = []
            for table: HGHanjaTable in [EmoticonComposer.emoticonTable] {
                dlog(DEBUG_EMOTICON, "DEBUG 3, [updateEmoticonCandidates] MSG: before hanjasByPrefixSearching")
                dlog(DEBUG_EMOTICON, "DEBUG 4, [updateEmoticonCandidates] MSG: [keyword: %@]", loweredKeyword)
                dlog(DEBUG_EMOTICON, "DEBUG 14, [updateEmoticonCandidates] MSG: %@", EmoticonComposer.emoticonTable.debugDescription)
                let list: HGHanjaList = table.hanjas(byPrefixSearching: loweredKeyword) ?? HGHanjaList()
                dlog(DEBUG_EMOTICON, "DEBUG 5, [updateEmoticonCandidates] MSG: after hanjasByPrefixSearching")

                dlog(DEBUG_EMOTICON, "DEBUG 9, [updateEmoticonCandidates] MSG: count is %d", list.count)
                if list.count > 0 {
                    for idx in 0 ... list.count - 1 {
                        let emoticon = list.hanja(at: idx)
                        dlog(DEBUG_EMOTICON, "DEBUG 6, [updateEmoticonCandidates] MSG: %@ %@ %@", list.hanja(at: idx).comment, list.hanja(at: idx).key, list.hanja(at: idx).value)
                        _candidates!.append(
                            NSAttributedString(string: emoticon.value as String + ": " + emoticon.comment as String)
                        )
                    }
                }
            }
        }
        dlog(DEBUG_EMOTICON, "DEBUG 2, [updateEmoticonCandidates] MSG: %@", _candidates ?? [])
    }

    func update(client sender: IMKTextInput) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [update] MSG: function called")
        let markedRange: NSRange = sender.markedRange()
        let selectedRange: NSRange = sender.selectedRange()

        let isInvalidMarkedRange: Bool = markedRange.length == 0 || markedRange.length == NSNotFound

        dlog(DEBUG_EMOTICON, "DEBUG 2, [update] MSG: DEBUG POINT 1")
        if isInvalidMarkedRange, selectedRange.length > 0 {
            let selectedString: String = sender.attributedSubstring(from: selectedRange).string

            sender.setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_EMOTICON, "DEBUG 3, [update] MSG: marking: %@ / selected: %@", NSStringFromRange(sender.markedRange()), NSStringFromRange(sender.selectedRange()))

            _bufferedString = selectedString
            dlog(DEBUG_EMOTICON, "DEBUG 4, [update] MSG: %@", _bufferedString)
        }

        dlog(DEBUG_EMOTICON, "DEBUG 5, [update] MSG: before updateEmoticonCandidates")
        updateEmoticonCandidates()
        dlog(DEBUG_EMOTICON, "DEBUG 6, [update] MSG: after updateEmoticonCandidates")
    }

    override func input(text string: String!, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> InputResult {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [inputController] MSG: %@, [[%d]]", string, keyCode)
        var result = delegate.input(text: string, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        // BackSpace
        case kVK_Delete: if result == .notProcessed {
            if !originalString.isEmpty {
                dlog(DEBUG_EMOTICON, "DEBUG 2, [inputController] MSG: before deletion, buffer (%@)", _bufferedString)
                _bufferedString.removeLast()
                dlog(DEBUG_EMOTICON, "DEBUG 3, [inputController] MSG: after deletion, buffer (%@)", _bufferedString)
                _composedString = originalString
                result = .processed
            } else {
                // 글자를 모두 지우면 이모티콘 모드에서 빠져 나간다.
                mode = false
            }
        }
        // Space
        case kVK_Space:
            if !_bufferedString.isEmpty {
                _bufferedString.append(" ")
                result = .processed
            } else {
                result = InputResult(processed: false, action: .commit)
            }
        // ESC
        case kVK_Escape:
            exitComposer()
            return InputResult(processed: false, action: .commit)
        // Enter
        case kVK_Return:
            candidateSelected(_selectedCandidate ?? NSAttributedString(string: composedString))
        default:
            dlog(DEBUG_EMOTICON, "DEBUG 4, [inputController] MSG: %@", string)
            if result == .notProcessed, string != nil, keyCode < 0x33 {
                _bufferedString.append(string)
                result = .processed
            }
        }

        dlog(DEBUG_EMOTICON, "DEBUG 2, [inputController] MSG: %@", string)
        updateEmoticonCandidates()

        dlog(DEBUG_EMOTICON, "DEBUG 3, [inputController] MSG: %@", string)

        if result == InputResult(processed: false, action: .commit) {
            cancelComposition()
            return result
        }
        if commitString.isEmpty {
            return result == .processed ? .processed : .notProcessed
        } else {
            return InputResult(processed: false, action: .commit)
        }
    }
}
