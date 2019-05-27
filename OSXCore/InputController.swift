//
//  InputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import InputMethodKit

let DEBUG_LOGGING = false
let DEBUG_INPUTCONTROLLER = false
let DEBUG_SPYING = true

/*!
 @enum
 @brief  최종적으로 InputController가 처리할 결과
 */

public enum InputAction: Equatable {
    case none
    case commit
    case cancel
    case layout(String)
    case candidatesEvent(Int) // keyCode
}

struct InputResult: Equatable {
    let processed: Bool
    let action: InputAction

    static let processed = InputResult(processed: true, action: .none)
    static let notProcessed = InputResult(processed: false, action: .none)
}

enum ChangeLayout {
    case toggle
    case toggleByCapsLock
    case hangul
    case roman
    case hanja
}

enum InputEvent {
    case changeLayout(ChangeLayout)
}

@objc(GureumInputController)
public class InputController: IMKInputController {
    var receiver: InputReceiver!
    var lastFlags: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)
    var updating = false

    override init!(server: IMKServer, delegate: Any!, client inputClient: Any) {
        super.init(server: server, delegate: delegate, client: inputClient)
        guard let inputClient = inputClient as? (IMKTextInput & IMKUnicodeTextInput) else {
            return nil
        }
        dlog(DEBUG_INPUTCONTROLLER, "**** NEW INPUT CONTROLLER INIT **** WITH SERVER: \(server) / DELEGATE: \(String(describing: delegate)) / CLIENT: \(inputClient) \(inputClient.bundleIdentifier() ?? "nil")")
        assert(InputMethodServer.shared.server === server)
        receiver = InputReceiver(server: server, delegate: delegate, client: inputClient, controller: self)
    }

    override init() {
        super.init()
    }

    public override func inputControllerWillClose() {
        super.inputControllerWillClose()
    }

    func asClient(_ sender: Any) -> IMKTextInput & IMKUnicodeTextInput {
        #if DEBUG
            return sender as! (IMKTextInput & IMKUnicodeTextInput)
        #else
            guard let sender = sender as? (IMKTextInput & IMKUnicodeTextInput) else {
                return client() as! (IMKTextInput & IMKUnicodeTextInput)
            }
            return sender
        #endif
    }

    #if DEBUG
        public override func responds(to aSelector: Selector) -> Bool {
            let r = super.responds(to: aSelector)
            dlog(DEBUG_SPYING, "controller responds to: \(aSelector) \(r)")
            return r
        }

        public override func modes(_ sender: Any!) -> [AnyHashable: Any]! {
            let modes = super.modes(sender)
            dlog(DEBUG_SPYING, "modes: \(modes)")
            return modes
        }

        public override func value(forTag tag: Int, client _: Any!) -> Any! {
            let v = super.value(forTag: tag, client: client)
            dlog(DEBUG_SPYING, "value: \(v) for tag: \(tag)")
            return v
        }
    #endif
}

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
public extension InputController { // IMKServerInputHandleEvent
    // Receiving Events Directly from the Text Services Manager

    override func handle(_ event: NSEvent, client sender: Any) -> Bool {
        // dlog(DEBUG_INPUTCONTROLLER, "event: \(event)")
        // sender is (IMKTextInput & IMKUnicodeTextInput & IMTSMSupport)
        let client = asClient(sender)
        let imkCandidtes = InputMethodServer.shared.candidates
        let keys = imkCandidtes.selectionKeys() as! [NSNumber]
        if event.type == .keyDown, imkCandidtes.isVisible(), keys.contains(NSNumber(value: event.keyCode)) {
            imkCandidtes.interpretKeyEvents([event])
            return true
        }
        switch event.type {
        case .keyDown:
            dlog(DEBUG_INPUTCONTROLLER, "** InputController KEYDOWN -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, event.keyCode, event.modifierFlags.rawValue, event.characters ?? "(empty)", event.charactersIgnoringModifiers ?? "(empty)", client.bundleIdentifier())
            let result = receiver.input(text: event.characters, key: Int(event.keyCode), modifiers: event.modifierFlags, client: client)
            dlog(DEBUG_LOGGING, "LOGGING::PROCESSED::\(result)")
            return result.processed
        case .flagsChanged:
            // dlog(DEBUG_INPUTCONTROLLER, @"** InputController FLAGCHANGED -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, -1, modifierFlags, nil, nil, [[self client] bundleIdentifier])
            let changed = lastFlags.symmetricDifference(event.modifierFlags)
            lastFlags = event.modifierFlags

            if changed.contains(.capsLock), Configuration.shared.enableCapslockToToggleInputMode {
                if InputMethodServer.shared.io.capsLockTriggered {
                    dlog(DEBUG_IOKIT_EVENT, "controller detected capslock")
                    _ = receiver.input(event: .changeLayout(.toggleByCapsLock), client: client)
                } else {
                    (sender as! IMKTextInput).selectMode(receiver.composer.inputMode)
                }
            }

            dlog(DEBUG_LOGGING, "LOGGING::UNHANDLED::%@/%@", event, sender as! NSObject)
            dlog(DEBUG_INPUTCONTROLLER, "** InputController -handleEvent:client: with event: %@ / sender: %@", event, sender as! NSObject)
            return false
        case .leftMouseDown, .leftMouseUp, .leftMouseDragged, .rightMouseDown, .rightMouseUp, .rightMouseDragged:
            commitComposition(sender)
        default:
            dlog(DEBUG_SPYING, "unhandled event: \(event)")
        }
        return false
    }
}

/*
 extension InputController { // IMKServerInputTextData
 override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any) -> Bool {
 dlog(DEBUG_INPUTCONTROLLER, "** InputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@", string, keyCode, flags, client()?.bundleIdentifier() ?? "nil")
 let processed = receiver.input(controller: self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: UInt(flags)), client: sender).rawValue > CIMInputTextProcessResult.notProcessed.rawValue
 return processed
 }
 }
 */
/*
 extension InputController { // IMKServerInputKeyBinding
 override func inputText(_: String!, client _: Any) -> Bool {
 // dlog(DEBUG_INPUTCONTROLLER, "** InputController -inputText:client: with string: %@ / client: %@", string, sender)
 return false
 }

 override func didCommand(by _: Selector!, client _: Any) -> Bool {
 // dlog(DEBUG_INPUTCONTROLLER, "** InputController -didCommandBySelector: with selector: %@", aSelector)
 return false
 }
 }
 */

public extension InputController { // IMKStateSetting
    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    override func recognizedEvents(_ sender: Any!) -> Int {
        let client = asClient(sender)
        return Int(receiver.recognizedEvents(client).rawValue)
    }

    //! @brief 자판 전환을 감지한다.
    override func setValue(_ value: Any, forTag tag: Int, client sender: Any) {
        let client = asClient(sender)
        receiver.setValue(value, forTag: tag, client: client)
    }

    override func activateServer(_ sender: Any!) {
        dlog(true, "server activated")
        let client = asClient(sender)
        super.activateServer(client)
    }

    override func deactivateServer(_ sender: Any!) {
        dlog(true, "server deactivating")
        commitComposition(sender)
        let client = asClient(sender)
        super.deactivateServer(client)
    }
}

public extension InputController { // IMKMouseHandling
    /*!
     @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
     */
    override func mouseDown(onCharacterIndex _: Int, coordinate _: NSPoint, withModifier _: Int, continueTracking _: UnsafeMutablePointer<ObjCBool>!, client sender: Any) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::MOUSEDOWN")
        commitComposition(sender)
        return false
    }
}

public extension InputController { // IMKCustomCommands
    override func menu() -> NSMenu! {
        return (NSApplication.shared.delegate! as! GureumApplicationDelegate).menu
    }
}

public extension InputController { // IMKServerInput
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    @objc override func commitComposition(_ sender: Any!) {
        let client = asClient(sender)
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT-RAW?")
        _ = receiver.commitCompositionEvent(client)
        // super.commitComposition(sender)
    }

    @objc override func updateComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE-RAW?")
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -updateComposition")
        receiver.updateCompositionEvent()
        super.updateComposition()
        dlog(DEBUG_INPUTCONTROLLER, "** InputController -updateComposition ended")
    }

    @objc override func cancelComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-RAW?")
        receiver.cancelCompositionEvent()
        super.cancelComposition()
    }

    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    @objc override func composedString(_ sender: Any!) -> Any {
        let client = asClient(sender)
        return receiver.composedString(client)
    }

    @objc override func originalString(_ sender: Any!) -> NSAttributedString {
        let client = asClient(sender)
        return receiver.originalString(client)
    }

    @objc override func candidates(_ sender: Any!) -> [Any]! {
        let client = asClient(sender)
        return receiver.candidates(client)
    }

    @objc override func candidateSelected(_ candidateString: NSAttributedString!) {
        receiver.candidateSelected(candidateString)
    }

    @objc override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        receiver.candidateSelectionChanged(candidateString)
    }
}

#if DEBUG
    @objcMembers public class MockInputController: InputController {
        public override init(server: IMKServer, delegate: Any!, client: Any) {
            super.init()
            receiver = InputReceiver(server: server, delegate: delegate, client: client as! (IMKTextInput & IMKUnicodeTextInput), controller: self)
        }

        func repoduceTextLog(_ text: String) throws {
            for row in text.components(separatedBy: "\n") {
                guard let regex = try? NSRegularExpression(pattern: "LOGGING::([A-Z]+)::(.*)", options: []) else {
                    throw NSException(name: NSExceptionName("MockInputControllerLogParserError"), reason: "Log is not readable format", userInfo: nil) as! Error
                }
                let matches = regex.matches(in: row, options: [], range: NSRangeFromString(row))
                let type = matches[1]
                let data = matches[2]
                print("test: \(type) \(data)")
            }
        }

        public override func client() -> (IMKTextInput & NSObjectProtocol)! {
            return receiver.inputClient as? (IMKTextInput & NSObjectProtocol)
        }

        public override func selectionRange() -> NSRange {
            return client().selectedRange()
        }
    }

    public extension MockInputController { // IMKServerInputTextData
        func inputFlags(_: Int, client sender: Any) -> Bool {
            let client = asClient(sender)
            let result = receiver.input(event: .changeLayout(.toggle), client: client)
            if !result.processed {
                // [self cancelComposition]
            }
            return result.processed
        }

        override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any) -> Bool {
            let client = asClient(sender)
            print("** InputController -inputText:key:modifiers:client  with string: \(string ?? "(nil)") / keyCode: \(keyCode) / modifier flags: \(flags) / client: \(String(describing: client))")
            let result = receiver.input(text: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: UInt(flags)), client: client)
            if !result.processed {
                // [self cancelComposition]
            }
            return result.processed
        }

        // Committing a Composition
        // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
        @objc override func commitComposition(_ sender: Any) {
            let client = asClient(sender)
            receiver.commitCompositionEvent(client)
            // COMMIT triggered
        }

        override func updateComposition() {
            receiver.updateCompositionEvent()

            let client = receiver.inputClient
            let composed = composedString(client) as! String
            let markedRange = client.markedRange()
            let view = receiver.inputClient as! NSTextView
            view.setMarkedText(composed, selectedRange: NSRange(location: 0, length: composed.count), replacementRange: markedRange)
        }

        override func cancelComposition() {
            receiver.cancelCompositionEvent()

            let client = receiver.inputClient
            let view = receiver.inputClient as! NSTextView
            let markedRange = client.markedRange()
            view.setMarkedText("", selectedRange: NSRange(location: markedRange.location, length: 0), replacementRange: markedRange)
        }

        // Getting Input Strings and Candidates
        // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
        override func composedString(_ sender: Any) -> Any {
            let client = asClient(sender)
            return receiver.composedString(client)
        }

        override func originalString(_ sender: Any) -> NSAttributedString {
            let client = asClient(sender)
            return receiver.originalString(client)
        }

        override func candidates(_ sender: Any) -> [Any]? {
            let client = asClient(sender)
            return receiver.candidates(client)
        }

        override func candidateSelected(_ candidateString: NSAttributedString!) {
            receiver.candidateSelected(candidateString)
        }

        override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
            receiver.candidateSelectionChanged(candidateString)
        }
    }

    public extension MockInputController { // IMKStateSetting
        //! @brief  마우스 이벤트를 잡을 수 있게 한다.
        override func recognizedEvents(_ sender: Any) -> Int {
            let client = asClient(sender)
            return Int(receiver.recognizedEvents(client).rawValue)
        }

        //! @brief 자판 전환을 감지한다.
        override func setValue(_ value: Any, forTag tag: Int, client sender: Any) {
            let client = asClient(sender)
            receiver.setValue(value, forTag: tag, client: client)
        }
    }
#endif
