//
//  DelegatedComposer.swift
//  OSXCore
//
//  Created by Presto on 29/09/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Carbon
import Cocoa
import Hangul

let DEBUG_SEARCHING_COMPOSER = false

// MARK: - HGHanjaList 클래스 확장

extension HGHanjaList: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

// MARK: - HanjaTable 열거형

/// 한자 테이블을 정리한 열거형.
enum HanjaTable {
    private static let hangulBundle = Bundle(for: HGKeyboard.self)
    /// 한자 문자를 모아 놓은 테이블.
    static let character = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjac", ofType: "txt", inDirectory: "hanja")!)!
    /// 한자 단어를 모아 놓은 테이블.
    static let word = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjaw", ofType: "txt", inDirectory: "hanja")!)!
    static let reversed = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjar", ofType: "txt", inDirectory: "hanja")!)!
    static let msSymbol = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "mssymbol", ofType: "txt", inDirectory: "hanja")!)!
    /// 한국어로 연결되는 이모지를 모아 놓은 테이블.
    static let emojiKorean = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "emoji_ko", ofType: "txt", inDirectory: "hanja")!)!
    /// 로마자로 연결되는 이모지를 모아 놓은 테이블.
    static let emoji = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")!)!
}

// MARK: - SearchingComposer 클래스

/// 문자를 검색하여 입력하는 합성기 오브젝트.
///
/// 한자 및 이모지 합성기의 동작을 구현한다.
final class SearchingComposer: Composer {
    /// 문자를 검색하여 입력하는 합성기의 종류를 정의한 구조체.
    struct ComposerType: OptionSet {
        let rawValue: Int

        static let hanja = ComposerType(rawValue: 1 << 0)
        static let emoji = ComposerType(rawValue: 1 << 1)
    }

    /// 한자를 조합하는 모드를 정의한 열거형.
    enum HanjaComposingMode {
        /// 하나의 문자.
        case single
        /// 두 개 이상의 문자 조합 - 단어.
        case continuous
    }

    private let _type: SearchingComposer.ComposerType

    // MARK: 공통 프로퍼티

    private var _candidates: [NSAttributedString]?
    private var _bufferedString = ""
    private var _composedString = ""
    private var _commitString = ""

    // MARK: 한자 전용 프로퍼티

    private var _lastString = ""
    var hanjaComposingMode: HanjaComposingMode = .single

    // MARK: 이모지 전용 프로퍼티

    private var _selectedCandidate: NSAttributedString?
    var isInEmojiMode = true

    /// 오브젝트가 의존하는 조합기.
    ///
    /// 한자 합성은 한글 합성기에 의존하고, 이모지 합성은 한글 및 로마자 합성기에 의존한다.
    var dependentComposer: Composer {
        return delegate
    }

    /// 오브젝트가 입력할 수 있는 문자의 종류.
    var type: SearchingComposer.ComposerType {
        return _type
    }

    init(type: SearchingComposer.ComposerType) {
        _type = type
    }

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var composedString: String {
        return _composedString
    }

    // 한자 합성의 경우 현재 진행 중인 조합 + 한글 입력기가 지금까지 완료한 조합.
    var originalString: String {
        switch type {
        case [.hanja, .emoji]:
            return _bufferedString + dependentComposer.composedString
        case .emoji:
            return _bufferedString
        default:
            return ""
        }
    }

    var commitString: String {
        return _commitString
    }

    var candidates: [NSAttributedString]? {
        switch type {
        case [.hanja, .emoji]:
            if _lastString != originalString {
                _candidates = buildHanjaCandidates()
                _lastString = originalString
            }
            return _candidates
        case .emoji:
            return _candidates
        default:
            return nil
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
        dependentComposer.cancelComposition()
        dependentComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    func clearCompositionContext() {
        if type == .emoji {
            _commitString = ""
        }
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 1, DelegatedComposer.candidateSelected(_:) function called")
        guard let word = candidateString.string.components(separatedBy: ":").first else { return }
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 2, DelegatedComposer.candidateSelected(_:) value == %@", word)
        _bufferedString = ""
        _composedString = ""
        _commitString = word
        dependentComposer.cancelComposition()
        dependentComposer.dequeueCommitString()
        if type == [.hanja, .emoji] {
            prepareHanjaCandidates()
        }
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        if type == .emoji {
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
        if type == [.hanja, .emoji] {
            switch keyCode {
            case .upArrow, .downArrow:
                return InputResult(processed: false, action: .candidatesEvent(keyCode))
            default:
                break
            }
        }

        var result = dependentComposer.input(text: text, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        case .delete:
            if result == .notProcessed {
                if !originalString.isEmpty {
                    // 조합 중인 글자가 없을 때 backspace가 들어오면 조합이 완료된 글자 중 마지막 글자를 지운다.
                    dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 1, DelegateComposer.input(text:key:modifiers:client:) before (%@)", _bufferedString)
                    _bufferedString.removeLast()
                    dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 2, DelegateComposer.input(text:key:modifiers:client:) after (%@)", _bufferedString)
                    _composedString = originalString
                    result = .processed
                } else {
                    switch type {
                    case [.hanja, .emoji]:
                        // 글자를 모두 지우면 한자 모드에서 빠져 나간다.
                        hanjaComposingMode = .single
                    case .emoji:
                        // 글자를 모두 지우면 이모티콘 모드에서 빠져 나간다.
                        isInEmojiMode = false
                    default:
                        break
                    }
                }
            }
        case .space:
            if type == [.hanja, .emoji] {
                // 강제로 조합 중인 문자 추출
                dependentComposer.cancelComposition()
                _bufferedString.append(dependentComposer.dequeueCommitString())
            }
            // 단어 뜻 검색을 위해 공백 문자도 후보 검색에 포함한다.
            if !_bufferedString.isEmpty {
                _bufferedString.append(" ")
                result = .processed
            } else {
                result = InputResult(processed: false, action: .commit)
            }
        case .escape:
            switch type {
            case [.hanja, .emoji]:
                hanjaComposingMode = .single
                // step 1. 조합 중인 한글을 모두 가져옴
                dependentComposer.cancelComposition()
                _bufferedString.append(dependentComposer.dequeueCommitString())
                // step 2. 한글을 그대로 커밋
                _composedString = originalString
                cancelComposition()
                // step 3. 한자 후보 취소
                _candidates = nil
            case .emoji:
                exitComposer()
            default:
                break
            }
            return InputResult(processed: false, action: .commit)
        case .return:
            if type == .emoji {
                candidateSelected(_selectedCandidate ?? NSAttributedString(string: composedString))
            }
        default:
            if type == .emoji {
                if result == .notProcessed, let text = text, keyCode.isKeyMappable {
                    _bufferedString.append(text)
                    result = .processed
                }
            }
        }

        switch type {
        case [.hanja, .emoji]:
            prepareHanjaCandidates()
        case .emoji:
            updateEmojiCandidates()
        default:
            break
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

// MARK: - SearchingComposer 공통 메소드

extension SearchingComposer {
    func update(client sender: IMKTextInput) {
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 1, DelegatedComposer.update(client:) function called")
        let markedRange = sender.markedRange()
        let selectedRange = sender.selectedRange()
        let isInvalidMarkedRage = markedRange.length == 0 || markedRange.location == NSNotFound
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 2, DelegatedComposer.update(client:) DEBUG POINT 1")
        if isInvalidMarkedRage, selectedRange.location != NSNotFound, selectedRange.length > 0 {
            let selectedString = sender.attributedSubstring(from: selectedRange).string
            sender.setMarkedText(selectedString, selectionRange: selectedRange, replacementRange: selectedRange)
            dlog(DEBUG_SEARCHING_COMPOSER,
                 "DEBUG 3, DelegatedComposer.update(client:) marking: %@ / selected: %@",
                 NSStringFromRange(sender.markedRange()),
                 NSStringFromRange(sender.selectedRange()))
            _bufferedString = selectedString
            dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 4, DelegatedComposer.update(client:) %@", _bufferedString)
            if type == [.hanja, .emoji] {
                hanjaComposingMode = .single
            }
        }
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) before update candidates")
        switch type {
        case [.hanja, .emoji]:
            prepareHanjaCandidates()
        case .emoji:
            updateEmojiCandidates()
        default:
            break
        }
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 5, DelegatedComposer.update(client:) after update candidates")
    }
}

// MARK: - SearchingComposer 한자 모드 전용 메소드

private extension SearchingComposer {
    /// 한자 입력을 위한 후보를 생성할 준비를 수행한다.
    func prepareHanjaCandidates() {
        guard type == [.hanja, .emoji] else {
            dlog(DEBUG_SEARCHING_COMPOSER, "INVALID: prepareHanjaCandidates() at emoji mode!")
            return
        }

        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.prepareHanjaCandidates()")
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        let hangulString = dependentComposer.dequeueCommitString()
        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step1")
        _bufferedString.append(hangulString)
        // step 2: 일단 화면에 한글이 표시되도록 조정
        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step2")
        _composedString = originalString
        // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.prepareHanjaCandidates() step3")
    }

    /// 한자 입력을 위한 후보를 만든다.
    ///
    /// - Returns: 한자 후보의 문자열 배열. `nil`을 반환할 수 있다.
    func buildHanjaCandidates() -> [NSAttributedString]? {
        guard type == [.hanja, .emoji] else {
            dlog(DEBUG_SEARCHING_COMPOSER, "INVALID: buildHanjaCandidates() at emoji mode!")
            return nil
        }

        let keyword = originalString.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else {
            dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.buildHanjaCandidates() has no keywords")
            return nil
        }

        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.buildHanjaCandidates() has candidates")
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
        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.buildHanjaCandidates() candidating")
        if !candidates.isEmpty {
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
    func searchCandidates(fromTable table: HGHanjaTable, byPrefixSearching keyword: String) -> [String] {
        guard type == [.hanja, .emoji] else {
            dlog(DEBUG_SEARCHING_COMPOSER, "INVALID: searchCandidates(fromTable:byPrefixSearching:) at emoji mode!")
            return []
        }

        var candidates = [String]()
        dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.searchCandidates(fromTable:byPrefixSearching:) getting list for table: %@", table)
        guard let list = table.hanjas(byPrefixSearching: keyword) else { return [] }
        for _hanja in list {
            let hanja = _hanja as! HGHanja
            dlog(DEBUG_SEARCHING_COMPOSER, "DelegatedComposer.searchCandidates(fromTable:byPrefixSearching:) hanja: %@", hanja)
            if hanja.comment.isEmpty {
                candidates.append("\(hanja.value)")
            } else {
                candidates.append("\(hanja.value): \(hanja.comment)")
            }
        }
        return candidates
    }
}

// MARK: - SearchingComposer 이모지 모드 전용 메소드

private extension SearchingComposer {
    func exitComposer() {
        guard type == .emoji else {
            dlog(DEBUG_SEARCHING_COMPOSER, "INVALID: exitComposer() at hanja mode!")
            return
        }

        // step 1. mode false
        isInEmojiMode = false
        // step 2. cancel candidates
        _candidates = nil
        // step 3. get all composing characters
        dependentComposer.cancelComposition()
        _bufferedString.append(dependentComposer.dequeueCommitString())
        // step 4. commit all
        _composedString = originalString
        cancelComposition()
    }

    func updateEmojiCandidates() {
        guard type == .emoji else {
            dlog(DEBUG_SEARCHING_COMPOSER, "INVALID: updateEmojiCandidates() at hanja mode!")
            return
        }

        // Step 1: 의존 합성기로부터 문자열 가져오기
        let dequeued = dependentComposer.dequeueCommitString()
        // Step 2: 문자열 보여주기
        _bufferedString.append(dequeued)
        _bufferedString.append(dependentComposer.composedString)
        let originalString = _bufferedString
        _composedString = originalString
        let keyword = originalString

        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 1, DelegatedComposer.updateCmojiCandidates() %@", originalString)
        if keyword.isEmpty {
            _candidates = nil
        } else {
            let loweredKeyword = keyword.lowercased() // case insensitive searching
            _candidates = []
            for table in [HanjaTable.emoji] {
                dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 3, DelegatedComposer.updateCmojiCandidates() before hanjasByPrefixSearching")
                dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 4, DelegatedComposer.updateCmojiCandidates() [keyword: %@]", loweredKeyword)
                dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 14, DelegatedComposer.updateCmojiCandidates() %@", HanjaTable.emoji.debugDescription)
                let list: HGHanjaList = table.hanjas(byPrefixSearching: loweredKeyword) ?? HGHanjaList()
                dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 5, DelegatedComposer.updateCmojiCandidates() after hanjasByPrefixSearching")

                dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 9, DelegatedComposer.updateCmojiCandidates() count is %d", list.count)
                for index in 0 ..< list.count {
                    let emoticon = list.hanja(at: index)
                    dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 6, DelegatedComposer.updateCmojiCandidates() %@ %@ %@", list.hanja(at: index).comment, list.hanja(at: index).key, list.hanja(at: index).value)
                    _candidates!.append(
                        NSAttributedString(string: emoticon.value as String + ": " + emoticon.comment as String)
                    )
                }
            }
        }
        dlog(DEBUG_SEARCHING_COMPOSER, "DEBUG 2, DelegatedComposer.updateCmojiCandidates() %@", _candidates ?? [])
    }
}
