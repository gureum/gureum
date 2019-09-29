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
import Fuse

let DEBUG_EMOTICON = false

/// 이모티콘 합성기.
final class EmoticonComposer: Composer {
    /// 이모티콘 후보 문자열 배열.
    private var _candidates: [NSAttributedString]?
    /// 선택된 이모티콘 후보 문자열.
    private var _selectedCandidate: NSAttributedString?
    /// 임시 저장한 문자열.
    private var _bufferedString: String = ""
    /// 합성 중인 문자열.
    private var _composedString: String = ""
    /// 합성을 완료한 문자열.
    private var _commitString: String = ""

    var mode: Bool = true
    var romanComposer: Composer {
        return delegate
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var composedString: String {
        return _composedString
    }

    var originalString: String {
        return _bufferedString
    }

    var commitString: String {
        return _commitString
    }

    var candidates: [NSAttributedString]? {
        return _candidates
    }

    var hasCandidates: Bool {
        guard let candidates = _candidates else { return false }
        return !candidates.isEmpty
    }

    func dequeueCommitString() -> String {
        let result = _commitString
        if !result.isEmpty {
            _bufferedString = ""
            _commitString = ""
        }
        return result
    }

    func cancelComposition() {
        romanComposer.cancelComposition()
        romanComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    func clearCompositionContext() {
        _commitString = ""
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [candidateSelected] MSG: function called")
        let value: String = candidateString.string.components(separatedBy: ":")[0]
        dlog(DEBUG_EMOTICON, "DEBUG 2, [candidateSelected] MSG: value == %@", value)
        _bufferedString = ""
        _composedString = ""
        _commitString = value
        romanComposer.cancelComposition()
        romanComposer.dequeueCommitString()
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        if candidateString.length == 0 {
            _selectedCandidate = nil
        } else {
            let emoticon = candidateString.string.components(separatedBy: ":").first!
            _selectedCandidate = NSAttributedString(string: emoticon)
        }
    }

    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [inputController] MSG: %@, [[%d]]", string!, keyCode.rawValue)
        var result = delegate.input(text: string, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        // BackSpace
        case .delete:
            if result == .notProcessed {
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
        case .space:
            if !_bufferedString.isEmpty {
                _bufferedString.append(" ")
                result = .processed
            } else {
                result = InputResult(processed: false, action: .commit)
            }
        // ESC
        case .escape:
            exitComposer()
            return InputResult(processed: false, action: .commit)
        // Enter
        case .return:
            candidateSelected(_selectedCandidate ?? NSAttributedString(string: composedString))
        default:
            dlog(DEBUG_EMOTICON, "DEBUG 4, [inputController] MSG: %@", string!)
            if result == .notProcessed, string != nil, keyCode.isKeyMappable {
                _bufferedString.append(string!)
                result = .processed
            }
        }

        dlog(DEBUG_EMOTICON, "DEBUG 2, [inputController] MSG: %@", string!)
        updateEmoticonCandidates()

        dlog(DEBUG_EMOTICON, "DEBUG 3, [inputController] MSG: %@", string!)

        if !result.processed, result.action == .commit {
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

extension EmoticonComposer {
    func update(client sender: IMKTextInput) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [update] MSG: function called")
        let markedRange: NSRange = sender.markedRange()
        let selectedRange: NSRange = sender.selectedRange()

        let isInvalidMarkedRange: Bool = markedRange.length == 0 || markedRange.location == NSNotFound

        dlog(DEBUG_EMOTICON, "DEBUG 2, [update] MSG: DEBUG POINT 1")
        if isInvalidMarkedRange, selectedRange.location != NSNotFound, selectedRange.length > 0 {
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

    private func exitComposer() {
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

    private func updateEmoticonCandidates() {
        // Step 1: Get string from romanComposer
        let dequeued: String = romanComposer.dequeueCommitString()
        // Step 2: Show the string
        _bufferedString.append(dequeued)
        _bufferedString.append(romanComposer.composedString)
        let originalString = _bufferedString
        _composedString = originalString
        let keyword = originalString

        dlog(DEBUG_EMOTICON, "DEBUG 1, [updateEmoticonCandidates] MSG: %@", originalString)
        if keyword.isEmpty {
            _candidates = nil
        } else {
            let loweredKeyword = keyword.lowercased() // case insensitive searching
            _candidates = []
            let fuse = Fuse()
            for table in [HanjaTable.emoji] {
                dlog(DEBUG_EMOTICON, "DEBUG 3, [updateEmoticonCandidates] MSG: before hanjasByPrefixSearching")
                dlog(DEBUG_EMOTICON, "DEBUG 4, [updateEmoticonCandidates] MSG: [keyword: %@]", loweredKeyword)
                dlog(DEBUG_EMOTICON, "DEBUG 14, [updateEmoticonCandidates] MSG: %@", HanjaTable.emoji.debugDescription)
                let searchResult = fuse.search(keyword, in: table)
                // change searchResult(index, score, ranges) to candidate(emoticon, comment)
                dlog(DEBUG_EMOTICON, "DEBUG 5, [updateEmoticonCandidates] MSG: after hanjasByPrefixSearching")
                if searchResult.count <= 0 {
                    break
                }
                for result in searchResult {
                    let emoticonLine: String = table[result.index]
                    let emoticon: String = String(emoticonLine.split(separator: ":")[1])
                    let comment: String = String(emoticonLine.split(separator: ":")[0])
                    _candidates!.append(NSAttributedString(string: emoticon + ": " + comment))
                }
            }
        }
        dlog(DEBUG_EMOTICON, "DEBUG 2, [updateEmoticonCandidates] MSG: %@", _candidates ?? [])
    }
}
