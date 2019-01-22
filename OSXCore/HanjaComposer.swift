//
//  HanjaComposer.swift
//  Gureum
//
//  Created by youknowone on 18. 10. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Hangul

let DEBUG_HANJACOMPOSER = false

extension HGHanjaList: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

enum HanjaMode {
    case single
    case continuous
}

private let hangulBundle = Bundle(for: HGKeyboard.self)

class HanjaComposer: DelegatedComposer {
    static let characterTable: HGHanjaTable = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjac", ofType: "txt", inDirectory: "hanja")!)!
    static let wordTable: HGHanjaTable = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjaw", ofType: "txt", inDirectory: "hanja")!)!
    static let reversedTable: HGHanjaTable = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjar", ofType: "txt", inDirectory: "hanja")!)!
    static let msSymbolTable: HGHanjaTable = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "mssymbol", ofType: "txt", inDirectory: "hanja")!)!
    static let emojiTable: HGHanjaTable = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "emoji_ko", ofType: "txt", inDirectory: "hanja")!)!

    var _candidates: [NSAttributedString]?
    var _bufferedString: String = ""
    var _composedString: String = ""
    var _commitString: String = ""
    var _lastString: String = ""
    var mode: HanjaMode = .single

    override var candidates: [NSAttributedString]? {
        let changed = self._lastString != self.originalString
        if changed {
            self._candidates = self.buildHanjaCandidates()
            self._lastString = self.originalString
        }
        return self._candidates
    }

    override var composedString: String {
        return _composedString
    }

    override var commitString: String {
        return _commitString
    }

    // 한글 입력기가 지금까지 완료한 조합 + 현재 진행 중인 조합
    override var originalString: String {
        return self._bufferedString + self.hangulComposer.composedString
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
        hangulComposer.cancelComposition()
        _ = hangulComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    override func composerSelected() {
        _bufferedString = ""
        _commitString = ""
        _lastString = ""
    }

    override var hasCandidates: Bool {
        return !(self.candidates?.isEmpty ?? true)
    }

    override func candidateSelected(_ candidateString: NSAttributedString) {
        let value = candidateString.string.components(separatedBy: ":")[0]
        _bufferedString = ""
        _composedString = ""
        _commitString = value
        hangulComposer.cancelComposition()
        hangulComposer.dequeueCommitString()
        prepareHanjaCandidates()
    }

    override func candidateSelectionChanged(_: NSAttributedString) {
        // TODO: 설정 추가
//        if (candidateString.length == 0) {
//            self._composedString = self.originalString
//        } else {
//            self._composedString = candidateString.string.components(separatedBy: ":")[0]
//        }
    }

    override func input(text string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        switch keyCode {
        // Arrow
        case kVK_DownArrow, kVK_UpArrow:
            return InputResult(processed: false, action: .candidatesEvent(keyCode))
        default:
            break
        }
        var result = delegate.input(text: string, key: keyCode, modifiers: flags, client: sender)
        switch keyCode {
        // backspace
        case kVK_Delete: if result == InputResult.notProcessed {
            if !originalString.isEmpty {
                // 조합 중인 글자가 없을 때 backspace가 들어오면 조합이 완료된 글자 중 마지막 글자를 지운다.
                dlog(DEBUG_HANJACOMPOSER, "DEBUG 1, [hanja] MSG: before (%@)", _bufferedString)
                _bufferedString.removeLast()
                dlog(DEBUG_HANJACOMPOSER, "DEBUG 2, [hanja] MSG: after (%@)", _bufferedString)
                _composedString = originalString
                result = .processed
            } else {
                // 글자를 모두 지우면 한자 모드에서 빠져 나간다.
                mode = .single
            }
        }
        // space
        case kVK_Space:
            hangulComposer.cancelComposition() // 강제로 조합중인 문자 추출
            _bufferedString.append(hangulComposer.dequeueCommitString())
            // 단어 뜻 검색을 위해 공백 문자도 후보 검색에 포함한다.
            if !_bufferedString.isEmpty {
                _bufferedString.append(" ")
                result = .processed
            } else {
                result = InputResult(processed: false, action: .commit)
            }
        // esc
        case kVK_Escape:
            mode = .single
            // step 1: 조합중인 한글을 모두 가져옴
            hangulComposer.cancelComposition()
            _bufferedString.append(hangulComposer.dequeueCommitString())
            // step 2: 한글을 그대로 커밋
            _composedString = originalString
            cancelComposition()
            // step 3: 한자 후보 취소
            _candidates = nil // 후보 취소
            return InputResult(processed: false, action: .commit)
        default:
            break
        }
        prepareHanjaCandidates()
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

    var hangulComposer: HangulComposer {
        return delegate as! HangulComposer
    }

    func prepareHanjaCandidates() {
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates")
        let dequeued = hangulComposer.dequeueCommitString()
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step1")
        _bufferedString.append(dequeued)
        // step 2: 일단 화면에 한글이 표시되도록 조정
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step2")
        _composedString = originalString
        // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step3")
    }

    func buildHanjaCandidates() -> [NSAttributedString]? {
        let keyword = originalString
        guard !keyword.isEmpty else {
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates no keywords")
            return nil
        }

        // dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates candidates")
        var candidates: [String] = []
        if keyword.count == 1 {
            for table in [HanjaComposer.msSymbolTable, HanjaComposer.characterTable] {
                let tableCandidates = searchCandidates(fromTable: table, byPrefixSearching: keyword)
                candidates.append(contentsOf: tableCandidates)
            }
        }
        for table in [HanjaComposer.wordTable, HanjaComposer.reversedTable, HanjaComposer.emojiTable] {
            let tableCandidates = searchCandidates(fromTable: table, byPrefixSearching: keyword)
            candidates.append(contentsOf: tableCandidates)
        }
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates candidating")
        if candidates.count > 0, Configuration.shared.showsInputForHanjaCandidates {
            candidates.insert(keyword, at: 0)
        }
        return candidates.map({ s in NSAttributedString(string: s) })
    }

    func searchCandidates(fromTable table: HGHanjaTable, byPrefixSearching keyword: String) -> [String] {
        var candidates: [String] = []
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -searchCandidates getting list for table: %@", table)
        guard let list: HGHanjaList = table.hanjas(byPrefixSearching: keyword) else {
            return candidates
        }
        for _hanja in list {
            let hanja = _hanja as! HGHanja
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -searchCandidates hanja: %@", hanja)
            if hanja.comment.isEmpty {
                candidates.append("\(hanja.value)")
            } else {
                candidates.append("\(hanja.value): \(hanja.comment)")
            }
        }
        return candidates
    }

    func update(client: IMKTextInput) {
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer updateFromController:")
        let markedRange: NSRange = client.markedRange()
        let selectedRange: NSRange = client.selectedRange()
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateFromController: marked: %@ selected: %@", NSStringFromRange(markedRange), NSStringFromRange(selectedRange))
        if markedRange.length == 0 || markedRange.length == NSNotFound, selectedRange.length > 0 {
            let selectedString = client.attributedSubstring(from: selectedRange).string
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateFromController: selected string: %@", selectedString)
            client.setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateFromController: try marking: %@ / selected: %@", NSStringFromRange(client.markedRange()), NSStringFromRange(client.selectedRange()))
            _bufferedString = selectedString
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateFromController: so buffer is: %@", _bufferedString)
            mode = .single
        }
        prepareHanjaCandidates()
    }
}
