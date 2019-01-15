//
//  DelegatedComposer.swift
//  OSX
//
//  Created by Jeong YunWon on 20/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

/*!
 @protocol
 @brief  입력을 처리하는 클래스의 관한 공통 형식
 @discussion TextData형식으로 @ref IMKServerInput 을 처리할 클래스의 공통 인터페이스. 입력 값을 보고 처리하는 모든 클래스는 이 프로토콜을 구현한다.
 */
protocol InputTextDelegate {
    /*!
     @method
     @param  controller  서버에서 입력을 받은 컨트롤러
     @param  string  문자열로 표현된 입력 값
     @param  keyCode 입력된 raw key code
     @param  flags   입력된 modifier flag
     @param  sender  입력 값을 전달한 외부 오브젝트
     @return 입력 처리 여부. YES를 반환하면 이미 처리된 입력으로 보고 NO를 반환하면 외부에서 입력을 다시 처리한다.
     @see    IMKServerInput
     */
    func input(text: String?, key: Int, modifiers: NSEvent.ModifierFlags, client: Any) -> InputResult
}

/*!
 @brief 실제로 문자를 합성하는 합성기의 프로토콜
 @discussion 입력기 전체의 상태에 영향을 끼치는 처리를 마친 후 출력할 글자를 조합하기 위해 DelegatedComposer로 입력을 전달한다. 기본적으로 자판마다 하나씩 구현하게 된다.
 */

protocol ComposerDelegate: InputTextDelegate {
    //! @brief  입력기가 선택 됨
    func composerSelected(_ sender: Any!)

    //! @brief  합성 중인 문자로 보여줄 문자열
    var composedString: String { get }
    //! @brief  합성을 취소하면 사용할 문자열
    var originalString: String { get }
    //! @brief  합성이 완료된 문자열
    var commitString: String { get }
    //! @brief  -commitString 을 반환하며 비움
    func dequeueCommitString() -> String
    //! @brief  조합을 중지
    func cancelComposition()
    //! @brief  조합 문맥 초기화
    func clearContext()

    //! @brief  변환 후보 문자열 존재 여부
    var hasCandidates: Bool { get }

    //! @brief  변환 후보 문자열 리스트
    var candidates: [NSAttributedString]? { get }
    //! @brief  변환 후보 문자열 선택
    func candidateSelected(_ candidateString: NSAttributedString)
    //! @brief  변환 후보 문자열 변경
    func candidateSelectionChanged(_ candidateString: NSAttributedString)
}

/*!
 @brief  일반적인 합성기 구조

 @warning    이 자체로는 동작하지 않는다. 상속하여 동작을 구현하거나 @ref BaseComposer 를 사용한다.
 */
class DelegatedComposer: ComposerDelegate {
    func composerSelected(_: Any!) {}

    var delegate: ComposerDelegate!
    var inputMode: String = ""

    var composedString: String {
        return delegate.composedString
    }

    var originalString: String {
        return delegate.originalString
    }

    var commitString: String {
        return delegate.commitString
    }

    func dequeueCommitString() -> String {
        return delegate.dequeueCommitString()
    }

    func cancelComposition() {
        delegate.cancelComposition()
    }

    func clearContext() {
        delegate.clearContext()
    }

    var hasCandidates: Bool {
        return delegate.hasCandidates
    }

    var candidates: [NSAttributedString]? {
        return delegate.candidates ?? nil
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        return delegate.candidateSelected(candidateString)
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        return delegate.candidateSelectionChanged(candidateString)
    }

    func input(text string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> InputResult {
        return delegate.input(text: string, key: keyCode, modifiers: flags, client: sender)
    }
}
