//
//  SearchPool.swift
//  OSXCore
//
//  Created by Presto on 06/10/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Hangul

/// 후보 검색 풀을 추상화한 프로토콜.
protocol SearchPool {
    func candidates(matching: String) -> (candidates: [String], score: Int)
}

/// `HGHanjaTable`을 검색하는 클래스.
final class HanjaTableSearchPool: SearchPool {
    enum Method {
        case exact

        case prefix
    }

    private let tables: [HGHanjaTable]

    private let method: HanjaTableSearchPool.Method

    init(tables: [HGHanjaTable], method: HanjaTableSearchPool.Method) {
        self.tables = tables
        self.method = method
    }

    /// 입력할 후보를 검색한다.
    ///
    /// - Parameter keyword: 검색 키워드.
    ///
    /// - Returns: 후보 문자열과 검색 점수로 이루어진 튜플.
    func candidates(matching keyword: String) -> (candidates: [String], score: Int) {
        let score: Int = {
            switch method {
            case .exact:
                return 10
            case .prefix:
                return 8
            }
        }()
        var candidates = [String]()
        for table in tables {
            let _list: HGHanjaList?
            switch method {
            case .exact:
                _list = table.hanjasByExact(matching: keyword)
            case .prefix:
                // hanjasByPrefix(matching:) 동작 안함
                _list = table.hanjas(byPrefixSearching: keyword)
            }
            guard let list = _list else { continue }
            for _hanja in list {
                let hanja = _hanja as! HGHanja
                if hanja.comment.isEmpty {
                    candidates.append("\(hanja.value)")
                } else {
                    candidates.append("\(hanja.value): \(hanja.comment)")
                }
            }
        }
        return (candidates, score)
    }
}
