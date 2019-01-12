//
//  CIMInputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation

let DEBUG_LOGGING = false
let DEBUG_INPUTCONTROLLER = false

/*!
 @enum
 @brief  최종적으로 CIMInputController가 처리할 결과
 */
enum CIMInputTextProcessResult: Int {
    case notProcessedAndNeedsCommit = -2
    case notProcessedAndNeedsCancel = -1
    case notProcessed = 0
    case processed = 1
}

enum CIMInputControllerSpecialKeyCode: Int {
    case capsLockPressed = -1
    case capsLockFlagsChanged = -2
}

@objc(CIMInputController)
class CIMInputController: IMKInputController {
    var receiver: CIMInputReceiver!

    override init!(server: IMKServer, delegate: Any, client inputClient: Any) {
        super.init(server: server, delegate: delegate, client: inputClient)
        dlog(DEBUG_INPUTCONTROLLER, "**** NEW INPUT CONTROLLER INIT **** WITH SERVER: \(server) / DELEGATE: \(delegate) / CLIENT: \(inputClient)")

//        guard inputClient is IMKTextInput else {
//            return
//        }
        receiver = CIMInputReceiver(server: server, delegate: delegate, client: inputClient, controller: self)
    }

    #if DEBUG
        override init() {
            super.init()
        }
    #endif
}

extension CIMInputController {
    @objc var composer: CIMComposer {
        return receiver.composer
    }

    @IBAction func showStandardAboutPanel(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(sender)
    }
}

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
extension CIMInputController { // IMKServerInputHandleEvent
    // Receiving Events Directly from the Text Services Manager

    override func handle(_ event: NSEvent, client sender: Any) -> Bool {
        let imkCandidtes = composer.server.candidates
        let keys = imkCandidtes.selectionKeys() as! [NSNumber]
        if imkCandidtes.isVisible(), keys.contains(NSNumber(value: event.keyCode)) {
            imkCandidtes.interpretKeyEvents([event])
            return true
        }
        if event.type == .keyDown {
            let bundleIdentifier: String = client()!.bundleIdentifier()
            dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController KEYDOWN -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, event.keyCode, event.modifierFlags.rawValue, event.characters ?? "(empty)", event.charactersIgnoringModifiers ?? "(empty)", bundleIdentifier)
            let processed = receiver.input(controller: self, inputText: event.characters, key: Int(event.keyCode), modifiers: event.modifierFlags, client: sender).rawValue > CIMInputTextProcessResult.notProcessed.rawValue
            dlog(DEBUG_LOGGING, "LOGGING::PROCESSED::%d", processed)
            return processed
        } else if event.type == .flagsChanged {
            var modifierFlags = event.modifierFlags
            if composer.server.io.testAndClearCapsLockState() {
                dlog(DEBUG_IOKIT_EVENT, "controller detected capslock")
                modifierFlags.formUnion(.capsLock)

                dlog(DEBUG_IOKIT_EVENT, "modifierFlags by IOKit: %lx", modifierFlags.rawValue)
                // dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController FLAGCHANGED -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, -1, modifierFlags, nil, nil, [[self client] bundleIdentifier])
                _ = receiver.input(controller: self, inputText: nil, key: CIMInputControllerSpecialKeyCode.capsLockPressed.rawValue, modifiers: modifierFlags, client: sender)
                return false
            }

            dlog(DEBUG_LOGGING, "LOGGING::UNHANDLED::%@/%@", event, sender as! NSObject)
            dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -handleEvent:client: with event: %@ / sender: %@", event, sender as! NSObject)
            return false
        }
        return false
    }
}

/*
extension CIMInputController { // IMKServerInputTextData
    override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any) -> Bool {
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@", string, keyCode, flags, client()?.bundleIdentifier() ?? "nil")
        let processed = receiver.input(controller: self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: UInt(flags)), client: sender).rawValue > CIMInputTextProcessResult.notProcessed.rawValue
        return processed
    }
}
*/
/*
extension CIMInputController { // IMKServerInputKeyBinding
    override func inputText(_: String!, client _: Any) -> Bool {
        // dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -inputText:client: with string: %@ / client: %@", string, sender)
        return false
    }

    override func didCommand(by _: Selector!, client _: Any) -> Bool {
        // dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -didCommandBySelector: with selector: %@", aSelector)
        return false
    }
}
*/

extension CIMInputController { // IMKStateSetting
    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    override func recognizedEvents(_ sender: Any!) -> Int {
        return receiver.recognizedEvents(sender)
    }

    //! @brief 자판 전환을 감지한다.
    override func setValue(_ value: Any, forTag tag: Int, client sender: Any) {
        receiver.setValue(value, forTag: tag, client: sender, controller: self)
    }

    override func activateServer(_: Any!) {
        dlog(DEBUG_INPUTCONTROLLER, "server activated")
    }

    override func deactivateServer(_ sender: Any!) {
        dlog(DEBUG_INPUTCONTROLLER, "server deactivated")
        receiver.commitComposition(sender, controller: self)
    }
}

extension CIMInputController { // IMKMouseHandling
    /*!
     @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
     */
    override func mouseDown(onCharacterIndex _: Int, coordinate _: NSPoint, withModifier _: Int, continueTracking _: UnsafeMutablePointer<ObjCBool>!, client sender: Any) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::MOUSEDOWN")
        _ = receiver.commitCompositionEvent(sender, controller: self)
        return false
    }
}

extension CIMInputController { // IMKCustomCommands
    override func menu() -> NSMenu! {
        return (NSApplication.shared.delegate! as! CIMApplicationDelegate).menu
    }
}

extension CIMInputController { // IMKServerInput
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    override func commitComposition(_ sender: Any!) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT-RAW?")
        _ = receiver.commitCompositionEvent(sender, controller: self)
        // [super commitComposition:sender]
    }

    override func updateComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE-RAW?")
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -updateComposition")
        receiver.updateCompositionEvent(self)
        super.updateComposition()
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -updateComposition ended")
    }

    override func cancelComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-RAW?")
        receiver.cancelCompositionEvent(self)
        super.cancelComposition()
    }

    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    override func composedString(_ sender: Any!) -> Any! {
        return receiver.composedString(sender, controller: self)
    }

    override func originalString(_ sender: Any!) -> NSAttributedString! {
        return receiver.originalString(sender, controller: self)
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        return receiver.candidates(sender, controller: self)
    }

    override func candidateSelected(_ candidateString: NSAttributedString!) {
        receiver.candidateSelected(candidateString, controller: self)
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        receiver.candidateSelectionChanged(candidateString, controller: self)
    }
}

@objcMembers class CIMMockInputController: CIMInputController {
    var _receiver: CIMInputReceiver!

    override init(server: IMKServer, delegate: Any, client: Any) {
        super.init()
        _receiver = CIMInputReceiver(server: server, delegate: delegate, client: client, controller: self)
    }

    func repoduceTextLog(_ text: String) throws {
        for row in text.components(separatedBy: "\n") {
            guard let regex = try? NSRegularExpression(pattern: "LOGGING::([A-Z]+)::(.*)", options: []) else {
                throw NSException(name: NSExceptionName("CIMMockInputControllerLogParserError"), reason: "Log is not readable format", userInfo: nil) as! Error
            }
            let matches = regex.matches(in: row, options: [], range: NSRangeFromString(row))
            let type = matches[1]
            let data = matches[2]
            print("test: \(type) \(data)")
        }
    }

    override func client() -> (IMKTextInput & NSObjectProtocol)! {
        return _receiver?.inputClient as? (IMKTextInput & NSObjectProtocol)
    }

    override var composer: CIMComposer {
        return _receiver.composer
    }

    override func selectionRange() -> NSRange {
        return client().selectedRange()
    }
}

extension CIMMockInputController {
    override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any) -> Bool {
        let client = self.client() as AnyObject
        print("** CIMInputController -inputText:key:modifiers:client  with string: \(string ?? "(nil)") / keyCode: \(keyCode) / modifier flags: \(flags) / client: \(String(describing: client.bundleIdentifier)) client class: \(String(describing: client.class))")
        let v1 = (_receiver.input(controller: self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: NSEvent.ModifierFlags.RawValue(flags)), client: sender).rawValue)
        let v2 = (CIMInputTextProcessResult.notProcessed.rawValue)
        let processed: Bool = v1 > v2
        if !processed {
            // [self cancelComposition]
        }
        return processed
    }

    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    override func commitComposition(_ sender: Any) {
        _receiver.commitCompositionEvent(sender, controller: self)
        // COMMIT triggered
    }
}
