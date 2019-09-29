//
//  CandidateDependentComposer.swift
//  OSXCore
//
//  Created by Presto on 29/09/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Hangul

let DEBUG_CANDIDATE_DEPENDENT = false

enum CandidateDependentComposerType {
    case hanja
    case emoji
}

/// 후보를 선택하는 창을 이용하여 글자를 입력하는 합성기 오브젝트.
///
/// 한자 및 이모지 합성기의 동작을 구현한다.
final class CandidateDependentComposer: Composer {

    private let type: CandidateDependentComposerType

    // 공통
    private var _candidates: [NSAttributedString]?
    private var _bufferedString = ""
    private var _composedString = ""
    private var _commitString = ""
    // 한자
    private var _lastString = ""
    var hanjaComposingMode: HanjaMode = .single
    // 이모지
    private var _selectedCandidate: NSAttributedString?
    var showsCandidateWindow = true

    /// 오브젝트가 의존하는 조합기.
    ///
    /// 한자를 입력하려는 경우 한글 합성기에 의존하고, 이모지를 입력하려는 경우 로마자 합성기에 의존한다.
    var dependentComposer: Composer {
        delegate
        //    switch type {
        //    case .hanja:
        //      return delegate as! HangulComposer
        //    case .emoji:
        //      return delegate
        //    }
    }

    init(type: CandidateDependentComposerType) {
        self.type = type
    }

    // MARK: Composer 프로토콜 구현

    var composedString: String { _composedString }

    var originalString: String {
        switch type {
        case .hanja:
            return _bufferedString + dependentComposer.composedString
        case .emoji:
            return _bufferedString
        }
    }

    var commitString: String { _commitString }

    var candidates: [NSAttributedString]? {
        switch type {
        case .hanja:
            if _lastString != originalString {
                _candidates = buildHanjaCandidates()
                _lastString = originalString
            }
            return _candidates
        case .emoji:
            return _candidates
        }
    }

    var hasCandidates: Bool { !(candidates?.isEmpty ?? true) }

    func dequeueCommitString() -> String {
        let result = _commitString
        if !result.isEmpty {
            _bufferedString = ""
            _commitString = ""
        }
        return result
    }

    func cancelComposition() {
        dependentComposer.cancelComposition()
        dependentComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    func clearCompositionContext() {
        switch type {
        case .hanja:
            break
        case .emoji:
            _commitString = ""
        }
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_EMOTICON, "DEBUG 1, [candidateSelected] MSG: function called")
        guard let word = candidateString.string.components(separatedBy: ":").first else { return }
        dlog(DEBUG_EMOTICON, "DEBUG 2, [candidateSelected] MSG: value == %@", word)
        _bufferedString = ""
        _composedString = ""
        _commitString = word
        dependentComposer.cancelComposition()
        dependentComposer.dequeueCommitString()
        switch type {
        case .hanja:
            prepareHanjaCandidates()
        case .emoji:
            break
        }
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        switch type {
        case .hanja:
            break
        case .emoji:
            if candidateString.length == 0 {
                _selectedCandidate = nil
            } else {
                guard let emoji = candidateString.string.components(separatedBy: ":").first else { return }
                _selectedCandidate = NSAttributedString(string: emoji)
            }
        }
    }

    func input(text: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        
    }
}

extension CandidateDependentComposer {

    func update(client sender: IMKTextInput) {
        dlog(DEBUG_CANDIDATE_DEPENDENT, "DEBUG 1, [update] MSG: function called")
        let markedRange = sender.markedRange()
        let selectedRange = sender.selectedRange()
        let isInvalidMarkedRage = markedRange.length == 0 || markedRange.location == NSNotFound
        dlog(DEBUG_CANDIDATE_DEPENDENT, "DEBUG 2, [update] MSG: DEBUG POINT 1")
        if isInvalidMarkedRage, selectedRange.location != NSNotFound, selectedRange.length > 0 {
            let selectedString = sender.attributedSubstring(from: selectedRange).string
            sender.setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_EMOTICON, "DEBUG 3, [update] MSG: marking: %@ / selected: %@", NSStringFromRange(sender.markedRange()), NSStringFromRange(sender.selectedRange()))
            _bufferedString = selectedString
            dlog(DEBUG_CANDIDATE_DEPENDENT, "DEBUG 4, [update] MSG: %@", _bufferedString)
            switch type {
            case .hanja:
                hanjaComposingMode = .single
            case .emoji:
                break
            }
        }
        dlog(DEBUG_CANDIDATE_DEPENDENT, "DEBUG 5, [update] MSG: before update candidates")
        switch type {
        case .hanja:
            prepareHanjaCandidates()
        case .emoji:
            updateEmoticonCandidates()
        }
        dlog(DEBUG_CANDIDATE_DEPENDENT, "DEBUG 5, [update] MSG: after update candidates")
    }

    func

    // MARK: 한자


    /// 한자 입력을 위한 후보를 생성할 준비를 수행한다.
    private func prepareHanjaCandidates() {
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates")
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        let hangulString = dependentComposer.dequeueCommitString()
        //        let hangulString = hangulComposer.dequeueCommitString()
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step1")
        _bufferedString.append(hangulString)
        // step 2: 일단 화면에 한글이 표시되도록 조정
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step2")
        _composedString = originalString
        // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates step3")
    }

    /// 한자 입력을 위한 후보를 만든다.
    ///
    /// - Returns: 한자 후보의 문자열 배열. `nil`을 반환할 수 있다.
    private func buildHanjaCandidates() -> [NSAttributedString]? {
        let keyword = originalString.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else {
            dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates no keywords")
            return nil
        }

        // dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates candidates")
        var candidates = [String]()
        if keyword.count == 1 {
            for table in [HanjaTable.msSymbol, HanjaTable.character] {
                let tableCandidates = searchCandidates(fromTable: table, byPrefixSearching: keyword)
                candidates.append(contentsOf: tableCandidates)
            }
        }
        for table in [HanjaTable.word, HanjaTable.reversed, HanjaTable.emojiKorean] {
            let tableCandidates = searchCandidates(fromTable: table, byPrefixSearching: keyword)
            candidates.append(contentsOf: tableCandidates)
        }
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates candidating")
        if !candidates.isEmpty, Configuration.shared.showsInputForHanjaCandidates {
            candidates.insert(keyword, at: 0)
        }
        return candidates.map { NSAttributedString(string: $0) }
    }

    /// 한자 입력을 위한 후보를 검색한다.
    ///
    /// - Parameters:
    ///   - table: 검색 소스가 위치한 테이블.
    ///   - keyword: prefix search의 쿼리로 사용될 키워드.
    ///
    /// - Returns: 검색한 후보의 문자열 배열.
    private func searchCandidates(fromTable table: HGHanjaTable, byPrefixSearching keyword: String) -> [String] {
        var candidates = [String]()
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -searchCandidates getting list for table: %@", table)
        guard let list = table.hanjas(byPrefixSearching: keyword) else { return [] }
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

    // MARK: 이모지


    private func exitComposer() {
        // step 1. mode false
        showsCandidateWindow = false
        // step 2. cancel candidates
        _candidates = nil
        // step 3. get all composing characters
        dependentComposer.cancelComposition()
        _bufferedString.append(dependentComposer.dequeueCommitString())
        //        romanComposer.cancelComposition()
        //        _bufferedString.append(romanComposer.dequeueCommitString())
        // step 4. commit all
        _composedString = originalString
        cancelComposition()
    }

    private func updateEmoticonCandidates() {
        // Step 1: Get string from romanComposer
        let dequeued = dependentComposer.dequeueCommitString()
        //        let dequeued: String = romanComposer.dequeueCommitString()
        // Step 2: Show the string
        _bufferedString.append(dequeued)
        _bufferedString.append(dependentComposer.composedString)
        //        _bufferedString.append(romanComposer.composedString)
        let originalString = _bufferedString
        _composedString = originalString
        let keyword = originalString

        dlog(DEBUG_EMOTICON, "DEBUG 1, [updateEmoticonCandidates] MSG: %@", originalString)
        if keyword.isEmpty {
            _candidates = nil
        } else {
            let loweredKeyword = keyword.lowercased() // case insensitive searching
            _candidates = []
            for table: HGHanjaTable in [HanjaTable.emoji] {
                dlog(DEBUG_EMOTICON, "DEBUG 3, [updateEmoticonCandidates] MSG: before hanjasByPrefixSearching")
                dlog(DEBUG_EMOTICON, "DEBUG 4, [updateEmoticonCandidates] MSG: [keyword: %@]", loweredKeyword)
                dlog(DEBUG_EMOTICON, "DEBUG 14, [updateEmoticonCandidates] MSG: %@", HanjaTable.emoji.debugDescription)
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
}
