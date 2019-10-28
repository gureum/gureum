//
//  SearchComposer.swift
//  OSXCore
//
//  Created by Presto on 29/09/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Fuse
import Hangul

let DEBUG_SEARCH_COMPOSER = true

// MARK: - HGHanjaList 클래스 확장

extension HGHanjaList: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

// MARK: - SearchComposer 클래스

/// 문자를 검색하여 입력하는 합성기 오브젝트.
///
/// 한자 및 이모지 합성기의 동작을 구현한다.
final class SearchComposer: Composer {
    /// 문자를 검색하여 입력하는 합성기가 의존하는 합성기의 종류를 정의한 열거형.
    enum DependentComposerType {
        case hangul
        case roman
    }

    private let _dependentComposerType: SearchComposer.DependentComposerType

    // MARK: 공통 프로퍼티

    private var _candidates: [NSAttributedString]?
    private var _bufferedString = ""
    private var _composedString = ""
    private var _commitString = ""

    // 검색을 위한 백그라운드 스레드
    private var _searchWorkItem: DispatchWorkItem = DispatchWorkItem {}
    private var _searchQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)

    var showsCandidateWindow = true

    // MARK: 한자 전용 프로퍼티

    private var _lastString = ""

    // MARK: 이모지 전용 프로퍼티

    private var _selectedCandidate: NSAttributedString?

    /// 오브젝트가 의존하는 합성기의 종류.
    ///
    /// 한자 합성은 한글 합성기에 의존하고, 이모지 합성은 한글 및 로마자 합성기에 의존한다.
    var dependentComposerType: SearchComposer.DependentComposerType {
        return _dependentComposerType
    }

    init(dependentComposerType: SearchComposer.DependentComposerType) {
        _dependentComposerType = dependentComposerType
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var composedString: String {
        return _composedString
    }

    // 한자 합성의 경우 현재 진행 중인 조합 + 한글 입력기가 지금까지 완료한 조합.
    var originalString: String {
        switch dependentComposerType {
        case .hangul:
            return _bufferedString + delegate.composedString
        case .roman:
            return _bufferedString
        }
    }

    var commitString: String {
        return _commitString
    }

    var candidates: [NSAttributedString]? {
        switch dependentComposerType {
        case .hangul:
            if _lastString != originalString {
                _candidates = buildHanjaCandidates()
                _lastString = originalString
            }
            return _candidates
        case .roman:
            return _candidates
        }
    }

    var hasCandidates: Bool {
        return !(candidates?.isEmpty ?? true)
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
        delegate.cancelComposition()
        delegate.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    func clearCompositionContext() {
        switch dependentComposerType {
        case .hangul:
            delegate.clearCompositionContext()
        case .roman:
            _commitString = ""
        }
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 1, DelegatedComposer.candidateSelected(_:) function called")
        guard let word = candidateString.string.components(separatedBy: ":").first else { return }
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 2, DelegatedComposer.candidateSelected(_:) value == %@", word)
        _bufferedString = ""
        _composedString = ""
        _commitString = word
        delegate.cancelComposition()
        delegate.dequeueCommitString()
        if dependentComposerType == .hangul {
            prepareHanjaCandidates()
        }
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        if dependentComposerType == .roman {
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
        // 한자의 경우 위아래 화살표에 대한 처리 선행
        if dependentComposerType == .hangul {
            switch keyCode {
            case .upArrow, .downArrow:
                return InputResult(processed: false, action: .candidatesEvent(keyCode))
            default:
                break
            }
        }

        var result = delegate.input(text: text, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        case .delete:
            if result == .notProcessed {
                if !originalString.isEmpty {
                    // 조합 중인 글자가 없을 때 backspace가 들어오면 조합이 완료된 글자 중 마지막 글자를 지운다.
                    dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 1, DelegateComposer.input(text:key:modifiers:client:) before (%@)", _bufferedString)
                    _bufferedString.removeLast()
                    dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 2, DelegateComposer.input(text:key:modifiers:client:) after (%@)", _bufferedString)
                    _composedString = originalString
                    result = .processed
                } else {
                    showsCandidateWindow = false
                }
            }
        case .space:
            if dependentComposerType == .hangul {
                // 강제로 조합 중인 문자 추출
                delegate.cancelComposition()
                _bufferedString.append(delegate.dequeueCommitString())
            }
            // 단어 뜻 검색을 위해 공백 문자도 후보 검색에 포함한다.
            if !_bufferedString.isEmpty {
                _bufferedString.append(" ")
                result = .processed
            } else {
                result = InputResult(processed: false, action: .commit)
            }
        case .escape:
            exitComposer()
            return InputResult(processed: false, action: .commit)
        case .return:
            if dependentComposerType == .roman {
                candidateSelected(_selectedCandidate ?? NSAttributedString(string: composedString))
            }
        default:
            if dependentComposerType == .roman {
                if result == .notProcessed, let text = text, keyCode.isKeyMappable {
                    _bufferedString.append(text)
                    result = .processed
                }
            }
        }

        switch dependentComposerType {
        case .hangul:
            prepareHanjaCandidates()
        case .roman:
            updateEmojiCandidates()
        }

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

// MARK: - SearchComposer 공통 메소드

extension SearchComposer {
    func update(client sender: IMKTextInput) {
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 1, DelegatedComposer.update(client:) function called")
        let markedRange = sender.markedRange()
        let selectedRange = sender.selectedRange()
        let isInvalidMarkedRage = markedRange.length == 0 || markedRange.location == NSNotFound
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 2, DelegatedComposer.update(client:) DEBUG POINT 1")
        if isInvalidMarkedRage, selectedRange.location != NSNotFound, selectedRange.length > 0 {
            let selectedString = sender.attributedSubstring(from: selectedRange).string
            sender.setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_SEARCH_COMPOSER,
                 "DEBUG 3, DelegatedComposer.update(client:) marking: %@ / selected: %@",
                 NSStringFromRange(sender.markedRange()),
                 NSStringFromRange(sender.selectedRange()))
            _bufferedString = selectedString
            dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 4, DelegatedComposer.update(client:) %@", _bufferedString)
            if dependentComposerType == .hangul {
                showsCandidateWindow = false
            }
        }
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) before update candidates")
        switch dependentComposerType {
        case .hangul:
            prepareHanjaCandidates()
        case .roman:
            updateEmojiCandidates()
        }
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) after update candidates")
    }

    func exitComposer() {
        // 1. 모드 false
        showsCandidateWindow = false
        // 2. 후보 취소
        _candidates = nil
        // 3. 조합 중인 문자를 모두 가져옴
        delegate.cancelComposition()
        _bufferedString.append(delegate.dequeueCommitString())
        // 4. 그대로 커밋
        _composedString = originalString
        cancelComposition()
    }
}

// MARK: - SearchComposer 한글 합성기 의존시 전용 메소드

private extension SearchComposer {
    /// 한자 입력을 위한 후보를 생성할 준비를 수행한다.
    func prepareHanjaCandidates() {
        guard dependentComposerType == .hangul else {
            dlog(DEBUG_SEARCH_COMPOSER, "INVALID: prepareHanjaCandidates() at emoji mode!")
            return
        }

        dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.prepareHanjaCandidates()")
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        let hangulString = delegate.dequeueCommitString()
        dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step1")
        _bufferedString.append(hangulString)
        // step 2: 일단 화면에 한글이 표시되도록 조정
        dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step2")
        _composedString = originalString
        // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
        dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step3")
    }

    /// 한자 입력을 위한 후보를 만든다.
    ///
    /// - Returns: 한자 후보의 문자열 배열. `nil`을 반환할 수 있다.
    func buildHanjaCandidates() -> [NSAttributedString]? {
        guard dependentComposerType == .hangul else {
            dlog(DEBUG_SEARCH_COMPOSER, "INVALID: buildHanjaCandidates() at emoji mode!")
            return nil
        }

        let keyword = originalString.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else {
            dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.buildHanjaCandidates() has no keywords")
            return nil
        }

        dlog(DEBUG_SEARCH_COMPOSER, "DelegatedComposer.buildHanjaCandidates() has candidates")

        let pool = keyword.count == 1
            ? SearchSourceConst.koreanSingle : SearchSourceConst.korean

        return pool.search(keyword)
    }
}

// MARK: - SearchComposer 로마자 합성기 의존시 전용 메소드

private extension SearchComposer {
    func updateEmojiCandidates() {
        guard dependentComposerType == .roman else {
            dlog(DEBUG_SEARCH_COMPOSER, "INVALID: updateEmojiCandidates() at hanja mode!")
            return
        }

        // Step 1: 의존 합성기로부터 문자열 가져오기
        let dequeued = delegate.dequeueCommitString()
        // Step 2: 문자열 보여주기
        _bufferedString.append(dequeued)
        _bufferedString.append(delegate.composedString)
        let originalString = _bufferedString
        _composedString = originalString
        let keyword = originalString

        dlog(DEBUG_SEARCH_COMPOSER, "Candidates before search, %@", _candidates ?? "nil")
        if !_searchWorkItem.isCancelled {
            _searchWorkItem.cancel()
        }
        _candidates = [NSAttributedString(string: "Searching...")] // default candidates

        _searchWorkItem = DispatchWorkItem {
            self._candidates = SearchSourceConst.emoji.search(keyword)
            DispatchQueue.main.async {
                InputMethodServer.shared.candidates.update()
            }
        }

        if keyword.isEmpty {
            _candidates = nil
        } else {
            _searchQueue.async(execute: _searchWorkItem)
        }
        dlog(DEBUG_SEARCH_COMPOSER, "Candidates after search, %@", _candidates ?? "nil")
    }
}
