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

let DEBUG_SEARCH_COMPOSER = false

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
    enum SourceType {
        case unknown
        case hangul
        case roman
    }

    // MARK: 공통 프로퍼티

    init() {}

    // 검색할 소스
    var sourceType: SearchComposer.SourceType? {
        guard let delegate = delegate else {
            return nil
        }
        if delegate is HangulComposer {
            return .hangul
        }
        if delegate is RomanComposer {
            return .roman
        }
        assert(false)
        return nil
    }

    public private(set) var candidates: [NSAttributedString]?
    private var _bufferedString = ""
    public private(set) var composedString = ""
    public private(set) var commitString = ""

    // 검색을 위한 백그라운드 스레드
    private var _searchWorkItem: DispatchWorkItem = DispatchWorkItem {}
    private var _searchQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    private let _searchLock = NSLock()

    var showsCandidateWindow = true

    // MARK: Composer 프로토콜 구현

    public var delegate: Composer!

    // 한자 합성의 경우 현재 진행 중인 조합 + 한글 입력기가 지금까지 완료한 조합.
    var originalString: String {
        _bufferedString + delegate.composedString
    }

    var hasCandidates: Bool {
        !(candidates?.isEmpty ?? true)
    }

    func dequeueCommitString() -> String {
        let result = commitString
        if !result.isEmpty {
            _bufferedString = ""
            commitString = ""
        }
        return result
    }

    func cancelComposition() {
        delegate.cancelComposition()
        delegate.dequeueCommitString()
        commitString.append(composedString)
        _bufferedString = ""
        composedString = ""
    }

    func clearCompositionContext() {
        delegate?.clearCompositionContext()
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 1, DelegatedComposer.candidateSelected(_:) function called")
        let components = candidateString.string.components(separatedBy: ":")
        guard components.count >= 2 else {
            return
        }
        let candidate = components.first!
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 2, DelegatedComposer.candidateSelected(_:) value == %@", candidate)
        _bufferedString = ""
        composedString = ""
        commitString = candidate
        delegate.cancelComposition()
        delegate.dequeueCommitString()

        updateCandidates()
    }

    func candidateSelectionChanged(_: NSAttributedString) {
        // nothing to do
    }

    func updateCandidates() {
        switch sourceType {
        case .hangul:
            updateHanjaCandidates()
        case .roman:
            updateEmojiCandidates()
        case .unknown:
            // TODO: both
            break
        case nil:
            assert(false)
        }
    }

    func input(text: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult
    {
        // 위아래 화살표에 대한 처리 선행
        switch keyCode {
        case .upArrow, .downArrow:
            return InputResult(processed: false, action: .candidatesEvent(keyCode))
        default:
            break
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
                    composedString = originalString
                    result = .processed
                } else {
                    showsCandidateWindow = false
                }
            }
        case .space:
            if sourceType == .hangul {
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
            return InputResult(processed: false, action: .candidatesEvent(keyCode))
        default:
            if sourceType == .roman {
                if result == .notProcessed, let text = text, keyCode.isKeyMappable {
                    _bufferedString.append(text)
                    result = .processed
                }
            }
        }

        updateCandidates()

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
            if sourceType == .hangul {
                showsCandidateWindow = false
            }
        }
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) before update candidates")
        updateCandidates()
        dlog(DEBUG_SEARCH_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) after update candidates")
    }

    func exitComposer() {
        // 1. 모드 false
        showsCandidateWindow = false
        // 2. 후보 취소
        if !_searchWorkItem.isCancelled {
            _searchWorkItem.cancel()
        }
        _searchLock.lock()
        candidates = nil
        _searchLock.unlock()

        InputMethodServer.shared.candidates.hide()

        // 3. 조합 중인 문자를 모두 가져옴
        delegate.cancelComposition()
        _bufferedString.append(delegate.dequeueCommitString())
        // 4. 그대로 커밋
        composedString = originalString
        cancelComposition()
    }

    func searchWorkItem(keyword: String, in source: SearchSource) -> DispatchWorkItem {
        var workItem: DispatchWorkItem!
        workItem = DispatchWorkItem {
            let newCandidates = source.search(keyword, workItem: workItem)
            guard !workItem.isCancelled else { return }

            self._searchLock.lock()
            self.candidates = newCandidates
            if workItem.isCancelled {
                self._searchLock.unlock()
                return
            }
            DispatchQueue.main.async {
                defer { self._searchLock.unlock() }
                guard self.delegate != nil else {
                    return
                }
                guard !workItem.isCancelled else {
                    return
                }
                InputMethodServer.shared.showOrHideCandidates(composer: self)
            }
        }
        return workItem
    }

    /// 한자 입력을 위한 후보를 만든다.
    func updateHanjaCandidates() {
        assert(delegate != nil)
        assert(sourceType == .hangul)

        dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates()")
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        let hangulString = delegate.dequeueCommitString()
        dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates() step1")
        _bufferedString.append(hangulString)
        // step 2: 일단 화면에 한글이 표시되도록 조정
        dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates() step2")
        composedString = originalString
        // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
        dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates() step3")

        let keyword = originalString.trimmingCharacters(in: .whitespaces)
        if !_searchWorkItem.isCancelled {
            _searchWorkItem.cancel()
        }
        candidates = [NSAttributedString(string: "검색 중...")] // default candidates

        guard !keyword.isEmpty else {
            dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates() has no keywords")
            _searchLock.lock()
            candidates = nil
            _searchLock.unlock()
            return
        }

        dlog(DEBUG_SEARCH_COMPOSER, "SearchComposer.updateHanjaCandidates() has candidates")

        let pool = keyword.count == 1
            ? SearchSourceConst.koreanSingle : SearchSourceConst.korean

        _searchWorkItem = searchWorkItem(keyword: keyword, in: pool)
        _searchQueue.async(execute: _searchWorkItem)
    }

    func updateEmojiCandidates() {
        assert(sourceType == .roman)

        // Step 1: 의존 합성기로부터 문자열 가져오기
        let dequeued = delegate.dequeueCommitString()
        // Step 2: 문자열 보여주기
        _bufferedString.append(dequeued)
        _bufferedString.append(delegate.composedString)
        let originalString = _bufferedString
        composedString = originalString
        let keyword = originalString

        dlog(DEBUG_SEARCH_COMPOSER, "Candidates before search, %@", candidates ?? "nil")
        if !_searchWorkItem.isCancelled {
            _searchWorkItem.cancel()
        }
        candidates = [NSAttributedString(string: "Searching...")] // default candidates
        let pool = SearchSourceConst.emoji

        _searchWorkItem = searchWorkItem(keyword: keyword, in: pool)

        if keyword.isEmpty {
            _searchLock.lock()
            candidates = nil
            _searchLock.unlock()
        } else {
            _searchQueue.async(execute: _searchWorkItem)
        }
        dlog(DEBUG_SEARCH_COMPOSER, "Candidates after search, %@", candidates ?? "nil")
    }
}
