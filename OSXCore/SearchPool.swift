//
//  SearchPool.swift
//  OSXCore
//
//  Created by Presto on 06/10/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Fuse
import Hangul

struct Candidate: Hashable {
  var value: String
  var description: String
}

/// 후보 검색 풀을 추상화한 프로토콜.
protocol SearchSource {
  typealias ScoredCandidate = (candidate: Candidate, score: Double)
  func collect(_ keyword: String, workItem: DispatchWorkItem!) -> [ScoredCandidate]
  func search(_ keyword: String, workItem: DispatchWorkItem!) -> [NSAttributedString]
}

extension SearchSource {
  func search(_ keyword: String, workItem: DispatchWorkItem!) -> [NSAttributedString] {
    collect(keyword, workItem: workItem).sorted(by: { $0.score < $1.score }).map {
      #if DEBUG
        let s = "\($0.candidate.value): \($0.candidate.description) (\($0.score))"
      #else
        let s = "\($0.candidate.value): \($0.candidate.description)"
      #endif
      return NSAttributedString(string: s)
    }
  }
}

enum SearchSourceConst {
  static let hanjaCharacter = HanjaTableSearchSource(
    table: HanjaTableConst.character, method: .exact)
  static let msSymbol = HanjaTableSearchSource(table: HanjaTableConst.msSymbol, method: .exact)

  static let hanjaWord = HanjaTableSearchSource(table: HanjaTableConst.word, method: .prefix)
  static let hanjaReversed = FuseSearchSource(
    path: hangulBundle.path(forResource: "hanjar", ofType: "txt", inDirectory: "hanja")!,
    threshold: 0.15)
  static let emoji = FuseSearchSource(
    path: hangulBundle.path(forResource: "emoji", ofType: "txt", inDirectory: "hanja")!,
    threshold: 0.15)
  static let emojiKorean = FuseSearchSource(
    path: hangulBundle.path(forResource: "emoji_ko", ofType: "txt", inDirectory: "hanja")!,
    threshold: 0.15)

  static let korean = SearchPool(sources: [
    SearchSourceConst.hanjaWord, SearchSourceConst.hanjaReversed, SearchSourceConst.emojiKorean,
  ])
  static let koreanSingle = SearchPool(
    sources: [SearchSourceConst.msSymbol, SearchSourceConst.hanjaCharacter]
      + SearchSourceConst.korean.sources)
}

struct SearchPool: SearchSource {
  let sources: [SearchSource]

  func collect(_ keyword: String, workItem: DispatchWorkItem!) -> [ScoredCandidate] {
    var candidates: [Candidate: (Double, Int)] = [:]
    var results: [ScoredCandidate] = []
    for source in sources {
      guard !workItem.isCancelled else {
        break
      }
      for item in source.collect(keyword, workItem: workItem) {
        if let (score, index) = candidates[item.candidate] {
          if item.score < score {
            candidates[item.candidate] = (item.score, index)
            results[index] = item
          }
        } else {
          candidates[item.candidate] = (item.score, results.count)
          results.append(item)
        }
      }
    }
    return results
  }
}

/// `HGHanjaTable`을 검색하는 풀을 나타내는 클래스.
final class HanjaTableSearchSource: SearchSource {
  enum Method {
    case exact
    case prefix
  }

  private let table: HGHanjaTable
  private let method: HanjaTableSearchSource.Method

  init(table: HGHanjaTable, method: HanjaTableSearchSource.Method) {
    self.table = table
    self.method = method
  }

  /// 키워드를 기준으로 입력할 후보를 검색한다.
  ///
  /// - Parameter keyword: 검색 키워드.
  ///
  /// - Returns: 후보 문자열과 검색 점수로 이루어진 튜플.
  func collect(_ keyword: String, workItem: DispatchWorkItem!) -> [ScoredCandidate] {
    guard
      let list: HGHanjaList = {
        switch method {
        case .exact:
          return table.hanjasByExact(matching: keyword)
        case .prefix:
          // hanjasByPrefix(matching:) 동작 안함
          return table.hanjas(byPrefixSearching: keyword)
        }
      }()
    else {
      return []
    }

    var results: [ScoredCandidate] = []
    for hanja in list {
      guard !workItem.isCancelled else {
        break
      }
      let hanja = hanja as! HGHanja
      let score: Double
      if method == .exact || keyword == hanja.comment {
        score = 0.0
      } else {
        score = 0.025 * Double(hanja.comment.count)
      }
      let candidate: Candidate = {
        if hanja.comment.isEmpty {
          return Candidate(value: hanja.value, description: "")
        } else {
          return Candidate(value: hanja.value, description: hanja.comment)
        }
      }()
      results.append((candidate: candidate, score: score))
    }
    return results
  }
}

final class FuseSearchSource: SearchSource {
  struct Word {
    let completion: String
    let description: String
  }

  private let fuse: Fuse
  private let source: [Word]
  private let strings: [String]

  init(source: [Word], threshold: Double) {
    fuse = Fuse(threshold: threshold)
    self.source = source
    strings = source.map { $0.description }
  }

  convenience init(path: String, threshold: Double) {
    let rawData = try! String(contentsOfFile: path, encoding: .utf8)
    let rows: [String] = rawData.components(separatedBy: .newlines)
    let source: [Word] = rows.compactMap {
      guard let first = $0.first else {
        return nil
      }
      guard first != "#" else {
        return nil
      }
      let items = $0.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
      return Word(completion: String(items[1]), description: String(items[0]))
    }
    self.init(source: source, threshold: threshold)
  }

  func collect(_ keyword: String, workItem: DispatchWorkItem!) -> [ScoredCandidate] {
    dlog(
      debugSearchComposer,
      "DEBUG 3, DelegatedComposer.updateEmojiCandidates() before hanjasByPrefixSearching")
    dlog(
      debugSearchComposer, "DEBUG 4, DelegatedComposer.updateEmojiCandidates() [keyword: %@]",
      keyword)
    dlog(
      debugSearchComposer, "DEBUG 14, DelegatedComposer.updateEmojiCandidates() %@",
      source.debugDescription)
    let searchResult = fuse.search(keyword, in: strings)
    dlog(
      debugSearchComposer,
      "DEBUG 5, DelegatedComposer.updateEmojiCandidates() after hanjasByPrefixSearching")

    guard !workItem.isCancelled else {
      return []
    }
    return searchResult.map {
      result in
      let word = source[result.index]
      let candidate = Candidate(value: word.completion, description: word.description)
      return (candidate: candidate, score: result.score + 0.0085 * Double(word.description.count))
    }
  }
}

private let hangulBundle = Bundle(for: HGKeyboard.self)

// MARK: - HanjaTable 열거형

/// 한자 테이블을 정리한 열거형.
enum HanjaTableConst {
  /// 한자 문자를 모아 놓은 테이블.
  static let character = HGHanjaTable(
    contentOfFile: hangulBundle.path(forResource: "hanjac", ofType: "txt", inDirectory: "hanja")!)!
  /// 한자 단어를 모아 놓은 테이블.
  static let word = HGHanjaTable(
    contentOfFile: hangulBundle.path(forResource: "hanjaw", ofType: "txt", inDirectory: "hanja")!)!
  static let msSymbol = HGHanjaTable(
    contentOfFile: hangulBundle.path(forResource: "mssymbol", ofType: "txt", inDirectory: "hanja")!)!
}
