//
//  InputReceiver.swift
//  OSX
//
//  Created by Jeong YunWon on 21/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import InputMethodKit

let DEBUG_INPUT_RECEIVER = false

public class InputReceiver: InputTextDelegate {
    var inputClient: IMKTextInput & IMKUnicodeTextInput
    var composer = GureumComposer()
    weak var controller: InputController!
    var inputting: Bool = false
    var hasSelectionRange: Bool = false

    init(server: IMKServer, delegate: Any!, client: IMKTextInput & IMKUnicodeTextInput, controller: InputController) {
        dlog(DEBUG_INPUT_RECEIVER, "**** NEW INPUT CONTROLLER INIT **** WITH SERVER: %@ / DELEGATE: %@ / CLIENT: %@", server, (delegate as? NSObject) ?? "(nil)", (client as? NSObject) ?? "(nil)")
        inputClient = client
        self.controller = controller
    }

    // MARK: - IMKServerInputTextData

    func input2(text string: String?, keyCode: KeyCode, modifiers flags: NSEvent.ModifierFlags, client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        // 옵션 키 변환 처리
        var string = string
        if flags.contains(.option) {
            let configuration = Configuration.shared
            dlog(DEBUG_INPUT_RECEIVER, "option key: %ld", configuration.optionKeyBehavior)
            switch configuration.optionKeyBehavior {
            case 0:
                // default
                dlog(DEBUG_INPUT_RECEIVER, " ** ESCAPE from option-key default behavior")
                return InputResult(processed: false, action: .commit)
            case 1:
                // ignore
                if keyCode.isKeyMappable {
                    if flags.contains(.capsLock) || flags.contains(.shift) {
                        string = KeyMapUpper[keyCode.rawValue] ?? string
                    } else {
                        string = KeyMapLower[keyCode.rawValue] ?? string
                    }
                }
            default:
                assert(false)
            }
        }

        // 특정 애플리케이션에서 커맨드/옵션/컨트롤 키 입력을 선점하지 못하는 문제를 회피한다
        if flags.contains(.command) || flags.contains(.option) || flags.contains(.control) {
            dlog(DEBUG_INPUT_RECEIVER, "-- InputReceiver -inputText: Command/Option key input / returned NO")
            return InputResult(processed: false, action: .commit)
        }

        if string == nil {
            return InputResult(processed: false, action: .commit)
        }

        let result = controller.receiver.composer.input(text: string, key: keyCode, modifiers: flags, client: sender)

        return result
    }

    // MARK: InputTextDelegate 프로토콜 구현

    // IMKServerInput 프로토콜에 대한 공용 핸들러
    func input(text string: String?,
               key keyCode: KeyCode,
               modifiers flags: NSEvent.ModifierFlags,
               client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult
    {
        let selected = sender.selectedRange()
        let marked = sender.markedRange()
        if selected.location != marked.location {
//            dlog(DEBUG_LOGGING, "MISMATCHING: \(selected) \(marked)")
//            cancelComposition()
//            sender.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: selected.location, length: 0))
//
//            // commitComposition(sender)
//            marked = selected
        }

        // 입력기용 특수 커맨드 처리
        if let command = composer.filterCommand(keyCode: keyCode, modifiers: flags, client: sender) {
            let result = input(event: command, client: sender)
            if result.processed {
                return result
            }
        }

        dlog(DEBUG_LOGGING, "LOGGING::KEY::(%@)(%ld)(%lu)", string?.replacingOccurrences(of: "\n", with: "\\n") ?? "(nil)", keyCode.rawValue, flags.rawValue)

        let hadComposedString = !_internalComposedString.isEmpty
        let result = input2(text: string, keyCode: keyCode, modifiers: flags, client: sender)

        // 합성 후보가 있다면 보여준다
        InputMethodServer.shared.showOrHideCandidates(controller: controller)

        inputting = true

        if result.action != .none {
            cancelComposition()
        }

        let commited = commitCompositionEvent(sender) // 조합 된 문자 반영
        if result.action == .commit {
            return result
        }
        let hasComposedString = !_internalComposedString.isEmpty
        let selectionRange = controller.selectionRange()
        hasSelectionRange = selectionRange.location != NSNotFound && selectionRange.length > 0
        if commited || controller.selectionRange().length > 0 || hadComposedString || hasComposedString {
            updateComposition() // 조합 중인 문자 반영
        }

        inputting = false

        dlog(DEBUG_INPUT_RECEIVER, "*** End of Input handling ***")
        return result
    }

    func input(event: InputEvent, client sender: IMKTextInput & IMKUnicodeTextInput) -> InputResult {
        switch event {
        case let .changeLayout(layout, processed):
            let innerLayout = layout == .toggleByCapsLock || layout == .toggleByRightKey ? .toggle : layout
            let result = composer.changeLayout(innerLayout, client: sender)
            // 합성 후보가 있다면 보여준다
            InputMethodServer.shared.showOrHideCandidates(controller: controller)

            inputting = true

            if result.action != .none {
                cancelComposition()
                if result.action != .cancel {
                    commitCompositionEvent(sender)
                    if case let .layout(mode) = result.action, layout != .toggleByCapsLock {
                        (sender as IMKTextInput).selectMode(mode)
                    }
                } else {
                    updateComposition() // 조합 중인 문자 반영
                }
            }

            inputting = false

            return processed ? .processed : .notProcessed
        }
    }
}

extension InputReceiver { // IMKServerInput
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    func commitComposition(_ sender: IMKTextInput & IMKUnicodeTextInput) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT-INTERNAL")
        commitCompositionEvent(sender)
    }

    func updateComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE-INTERNAL")
        controller.updateComposition()
    }

    func cancelComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-INTERNAL")
        controller.cancelComposition()
    }

    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    @discardableResult
    func commitCompositionEvent(_ sender: IMKTextInput & IMKUnicodeTextInput) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT")
        if !inputting {
            // 입력기 외부에서 들어오는 커밋 요청에 대해서는 편집 중인 글자도 커밋한다.
            dlog(DEBUG_INPUTCONTROLLER, "-- CANCEL composition because of external commit request from %@", sender as! NSObject)
            dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-INTERNAL")
            cancelCompositionEvent()
        }
        // 왠지는 모르겠지만 프로그램마다 동작이 달라서 조합을 반드시 마쳐주어야 한다
        // 터미널과 같이 조합중에 리턴키 먹는 프로그램은 조합 중인 문자가 없고 보통은 있다
        let commitString = composer.dequeueCommitString()

        // 커밋할 문자가 없으면 중단
        if commitString.isEmpty {
            return false
        }

        dlog(DEBUG_INPUT_RECEIVER, "** InputController -commitComposition: with sender: %@ / strings: %@", sender as! NSObject, commitString)
        var range = controller.selectionRange()
        dlog(DEBUG_LOGGING, "LOGGING::COMMIT::%lu:%lu:%@", range.location, range.length, commitString)
        // NSLog("range1 \(range)")글
        if range.length == 0 {
            range = sender.selectedRange()
        }
        // NSLog("range2 \(range)")
        if range.length == 0 {
            // 일부 프로그램이 길이가 0인 치환을 잘 처리하지 못하므로 특별히 처리한다
            range = NSRange(location: NSNotFound, length: 0)
        }
        // NSLog("commit \(commitString) to \(range)")
        controller.client().insertText(commitString, replacementRange: range)

        InputMethodServer.shared.showOrHideCandidates(controller: controller)

        return true
    }

    func updateCompositionEvent() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE")
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -updateComposition")
    }

    func cancelCompositionEvent() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL")
        composer.cancelComposition()
    }

    var _internalComposedString: String {
        return composer.composedString
    }

    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    func composedString(_: IMKTextInput & IMKUnicodeTextInput) -> String {
        let string = _internalComposedString
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::COMPOSEDSTRING::(%@)", string)
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -composedString: with return: '%@'", string)
        return string
    }

    func originalString(_: IMKTextInput & IMKUnicodeTextInput) -> NSAttributedString {
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -originalString:")
        let s = NSAttributedString(string: composer.originalString)
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::ORIGINALSTRING::%@", s.string)
        return s
    }

    func candidates(_: IMKTextInput & IMKUnicodeTextInput) -> [Any]! {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATES")
        return composer.candidates
    }

    func candidateSelected(_ candidateString: NSAttributedString) {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATESELECTED::%@", candidateString)
        inputting = true
        composer.candidateSelected(candidateString)
        commitCompositionEvent(inputClient)
        inputting = false
    }

    func candidateSelectionChanged(_ candidateString: NSAttributedString) {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATESELECTIONCHANGED::%@", candidateString)
        composer.candidateSelectionChanged(candidateString)
        updateComposition()
    }
}

extension InputReceiver { // IMKStateSetting
    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    func recognizedEvents(_: IMKTextInput & IMKUnicodeTextInput) -> NSEvent.EventTypeMask {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::RECOGNIZEDEVENTS")
        // NSFlagsChangeMask는 -handleEvent: 에서만 동작
        return NSEvent.EventTypeMask(arrayLiteral: .keyDown, .flagsChanged, .leftMouseUp, .rightMouseUp, .leftMouseDown, .rightMouseDown, .leftMouseDragged, .rightMouseDragged, .appKitDefined, .applicationDefined, .systemDefined)
    }

    //! @brief 자판 전환을 감지한다.
    func setValue(_ value: Any, forTag tag: Int, client sender: IMKTextInput & IMKUnicodeTextInput) {
        InputMethodServer.shared.io.capsLockDate = nil
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CHANGE-%lu-%@", tag, value as? String ?? "(nonstring)")
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -setValue:forTag:client: with value: %@ / tag: %lx / client: %@", value as? String ?? "(nonstring)", tag, String(describing: controller.client as AnyObject))
        sender.overrideKeyboard(withKeyboardNamed: Configuration.shared.overridingKeyboardName)
        switch tag {
        case kTextServiceInputModePropertyTag:
            guard let value = value as? String else {
                NSLog("Failed to change keyboard layout")
                assert(false)
                break
            }
            if value != composer.inputMode {
                commitComposition(sender)
                composer.inputMode = value
            }
        default:
            dlog(true, "**** UNKNOWN TAG %ld !!! ****", tag)
        }
    }
}
