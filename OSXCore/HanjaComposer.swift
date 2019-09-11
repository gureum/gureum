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

/// 한자를 조합하는 모드를 정의한 열거형.
enum HanjaMode {
    /// 하나의 문자.
    case single
    /// 두 개 이상의 문자 조합 - 단어.
    case continuous
}

private let hangulBundle = Bundle(for: HGKeyboard.self)

/// 한자 합성기 오브젝트.
///
/// 입력된 한글 단어가 한자로 변환되어야 하므로, 한글 합성기를 참조하는 구조를 갖는다.
final class HanjaComposer: Composer {
    /// 한자 테이블 상수 정의.
    private enum HanjaTable {
        /// 한자 문자를 모아 놓은 테이블.
        static let character = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjac", ofType: "txt", inDirectory: "hanja")!)!
        /// 한자 단어를 모아 놓은 테이블.
        static let word = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjaw", ofType: "txt", inDirectory: "hanja")!)!
        static let reversed = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "hanjar", ofType: "txt", inDirectory: "hanja")!)!
        static let msSymbol = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "mssymbol", ofType: "txt", inDirectory: "hanja")!)!
        /// 한국어로 연결되는 이모지를 모아 놓은 테이블.
        static let emoji = HGHanjaTable(contentOfFile: hangulBundle.path(forResource: "emoji_ko", ofType: "txt", inDirectory: "hanja")!)!
    }

    /// 한자 후보 문자열 배열.
    private var _candidates: [NSAttributedString]?
    /// 임시 저장한 문자열.
    private var _bufferedString: String = ""
    /// 합성 중인 문자열.
    private var _composedString: String = ""
    /// 합성을 완료한 문자열.
    private var _commitString: String = ""
    /// 마지막 문자열.
    private var _lastString: String = ""

    /// 한글 조합기.
    var hangulComposer: HangulComposer {
        return delegate as! HangulComposer
    }

    /// 한자 조합 모드.
    var mode: HanjaMode = .single

    // MARK: Composer 프로토콜 구현

    var delegate: Composer!

    var composedString: String {
        return _composedString
    }

    /// 현재 진행 중인 조합 + 한글 입력기가 지금까지 완료한 조합.
    var originalString: String {
        return _bufferedString + hangulComposer.composedString
    }

    var commitString: String {
        return _commitString
    }

    var candidates: [NSAttributedString]? {
        let changed = _lastString != originalString
        if changed {
            _candidates = buildHanjaCandidates()
            _lastString = originalString
        }
        return _candidates
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
        hangulComposer.cancelComposition()
        hangulComposer.dequeueCommitString()
        _commitString.append(_composedString)
        _bufferedString = ""
        _composedString = ""
    }

    func composerSelected() {
        _bufferedString = ""
        _commitString = ""
        _lastString = ""
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        let hanjaWord = candidateString.string.components(separatedBy: ":").first!
        _bufferedString = ""
        _composedString = ""
        _commitString = hanjaWord
        hangulComposer.cancelComposition()
        hangulComposer.dequeueCommitString()
        prepareHanjaCandidates()
    }

    func candidateSelectionChanged(_: NSAttributedString) {
        // TODO: 설정 추가
        //        if (candidateString.length == 0) {
        //            self._composedString = self.originalString
        //        } else {
        //            self._composedString = candidateString.string.components(separatedBy: ":")[0]
        //        }
    }

    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        switch keyCode {
        // Arrow
        case .upArrow, .downArrow:
            return InputResult(processed: false, action: .candidatesEvent(keyCode))
        default:
            break
        }

        var result = hangulComposer.input(text: string, key: keyCode, modifiers: flags, client: sender)

        switch keyCode {
        // backspace
        case .delete:
            if result == .notProcessed {
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
        case .space:
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
        case .escape:
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

extension HanjaComposer {
    ///
    func update(client: IMKTextInput) {
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer updateFromController:")
        let markedRange: NSRange = client.markedRange()
        let selectedRange: NSRange = client.selectedRange()
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateFromController: marked: %@ selected: %@", NSStringFromRange(markedRange), NSStringFromRange(selectedRange))
        if markedRange.length == 0 || markedRange.location == NSNotFound, selectedRange.location != NSNotFound, selectedRange.length > 0 {
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

private extension HanjaComposer {
    /// 한자 입력을 위한 후보를 생성할 준비를 수행한다.
    func prepareHanjaCandidates() {
        dlog(DEBUG_HANJACOMPOSER, "HanjaComposer -updateHanjaCandidates")
        // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
        let hangulString = hangulComposer.dequeueCommitString()
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
    func buildHanjaCandidates() -> [NSAttributedString]? {
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
        for table in [HanjaTable.word, HanjaTable.reversed, HanjaTable.emoji] {
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
    func searchCandidates(fromTable table: HGHanjaTable, byPrefixSearching keyword: String) -> [String] {
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
}
