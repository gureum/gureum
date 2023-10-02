//
//  Composer.swift
//  OSXCore
//
//  Created by Jeong YunWon on 20/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation
import InputMethodKit

/// 입력을 처리하는 클래스에 관한 공통 형식을 정의한 프로토콜.
///
/// `TextData` 형식으로 `IMKServerInput`을 처리할 클래스의 공통 인터페이스.
/// 입력 값을 보고 처리하는 모든 클래스는 이 프로토콜을 구헌한다.
protocol InputTextDelegate {
    /// 입력을 수행한다.
    ///
    /// 기본적으로 델리게이트 객체의 `input(text:key:modifiers:client)` 메소드를 호출한다.
    ///
    /// - Parameters:
    ///   - text: 문자열로 표현된 입력 값.
    ///   - key: 입력된 키의 key code.
    ///   - modifiers: 입력된 modifier flag.
    ///   - client: 입력 값을 전달한 외부 오브젝트.
    ///
    /// - Returns: 입력 결과.
    ///
    /// - Note: 반환 값의 `processed`가 `true`이면 이미 처리된 입력으로 보고, `false`이면 외부에서 입력을 다시 처리한다.
    func input(text: String?,
               key: KeyCode,
               modifiers: NSEvent.ModifierFlags,
               client: IMKTextInput & IMKUnicodeTextInput) -> InputResult
}

/// 문자를 합성하는 합성기의 프로토콜.
///
/// 입력기 전체의 상태에 영향을 끼치는 처리를 마친 후 출력할 글자를 조합하기 위해 `DelegatedComposer`로 입력을 전달한다.
/// 기본적으로 자판마다 하나씩 구현하게 된다.
protocol Composer: InputTextDelegate {
    /// 델리게이트 객체.
    ///
    /// 기본값은 `nil`이다.
    var delegate: Composer! { get }

    /// 합성 중인 문자로 보여줄 문자열.
    ///
    /// 기본적으로 델리게이트 객체의 `composedString`을 반환한다.
    var composedString: String { get }

    /// 합성을 취소하면 사용할 문자열.
    ///
    /// 기본적으로 델리게이트 객체의 `originalString`을 반환한다.
    var originalString: String { get }

    /// 합성이 완료된 문자열.
    ///
    /// 기본적으로 델리게이트 객체의 `commitString`을 반환한다.
    var commitString: String { get }

    /// 변환 후보 문자열 리스트.
    ///
    /// 기본적으로 델리게이트 객체의 `candidates`를 반환한다.
    var candidates: [NSAttributedString]? { get }

    /// 변환 후보 문자열 존재 여부.
    ///
    /// 기본적으로 델리게이트 객체의 `hasCandidates`를 반환한다.
    var hasCandidates: Bool { get }

    /// 초기화 작업을 수행한다.
    ///
    /// 기본적으로 아무 동작도 하지 않는다.
    func clear()

    /// 합성이 완료된 문자열(`commitString`)을 반환하며 비운다.
    ///
    /// 기본적으로 델리게이트 객체의 `dequeueCommitString()` 메소드의 실행 결과를 반환한다.
    ///
    /// - Returns: 합성이 완료된 문자열.
    @discardableResult
    func dequeueCommitString() -> String

    /// 조합을 취소한다.
    ///
    /// 기본적으로 델리게이트 객체의 `cancelComposition()` 메소드를 호출한다.
    func cancelComposition()

    /// 조합 문맥을 초기화한다.
    ///
    /// 기본적으로 델리게이트 객체의 `clearCompositionContext()` 메소드를 호출한다.
    func clearCompositionContext()

    /// 입력기가 선택되었을 때 수행할 작업을 정의한다.
    ///
    /// 기본적으로 아무 동작도 하지 않는다.
    func composerSelected()

    /// 변환 후보 문자열이 선택된 후 수행할 작업을 정의한다.
    ///
    /// 기본적으로 델리게이트 객체의 `candidateSelected(_:)` 메소드를 호출한다.
    ///
    /// - Parameter candidateString: 선택된 후보 문자열.
    func candidateSelected(_ candidateString: NSAttributedString)

    /// 변환 후보 문자열이 변경된 후 수행할 작업을 정의한다.
    ///
    /// 기본적으로 델리게이트 객체의 `candidateSelectionChanged(_:)` 메소드를 호출한다.
    ///
    /// - Parameter candidateString: 선택된 후보 문자열.
    func candidateSelectionChanged(_ candidateString: NSAttributedString)
}

// MARK: - Composer 프로토콜 초기 구현

extension Composer {
    var delegate: Composer! {
        return nil
    }

    var composedString: String {
        return delegate.composedString
    }

    var originalString: String {
        return delegate.originalString
    }

    var commitString: String {
        return delegate.commitString
    }

    var candidates: [NSAttributedString]? {
        return delegate.candidates
    }

    var hasCandidates: Bool {
        return delegate.hasCandidates
    }

    func clear() {}

    func dequeueCommitString() -> String {
        return delegate.dequeueCommitString()
    }

    func cancelComposition() {
        delegate.cancelComposition()
    }

    func clearCompositionContext() {
        delegate.clearCompositionContext()
    }

    func composerSelected() {}

    func candidateSelected(_ candidateString: NSAttributedString) {
        assert(delegate != nil)
        delegate.candidateSelected(candidateString)
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        assert(delegate != nil)
        delegate.candidateSelectionChanged(candidateString)
    }

    // MARK: InputTextDelegate

    func input(text: String?,
               key: KeyCode,
               modifiers: NSEvent.ModifierFlags,
               client: IMKTextInput & IMKUnicodeTextInput) -> InputResult
    {
        return delegate.input(text: text, key: key, modifiers: modifiers, client: client)
    }
}
