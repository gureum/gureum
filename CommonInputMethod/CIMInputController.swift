//
//  CIMInputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

let DEBUG_LOGGING = false
let DEBUG_INPUTCONTROLLER = false

extension CIMInputController {
    
    @objc open var composer: CIMComposer {
        return self.receiver.composer
    }
    
    @IBAction func showStandardAboutPanel(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(sender)
    }
}

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
extension CIMInputController { // IMKServerInputHandleEvent
    // Receiving Events Directly from the Text Services Manager

    open override func handle(_ event: NSEvent, client sender: Any!) -> Bool {
        if event.type == .keyDown {
            let bundleIdentifier: String = self.client()!.bundleIdentifier()
            dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController KEYDOWN -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, event.keyCode, event.modifierFlags.rawValue, event.characters ?? "(empty)", event.charactersIgnoringModifiers ?? "(empty)", bundleIdentifier)
            let processed = self.receiver.input(controller: self, inputText: event.characters, key: Int(event.keyCode), modifiers:event.modifierFlags, client: sender).rawValue > CIMInputTextProcessResult.notProcessed.rawValue
            dlog(DEBUG_LOGGING, "LOGGING::PROCESSED::%d", processed)
            return processed
        } else if event.type == .flagsChanged {
            var modifierFlags = event.modifierFlags
            if self.ioConnect.capsLockState {
                modifierFlags.formUnion(.capsLock)
            }

            // Handle caps lock events
            if modifierFlags.contains(.capsLock) {
                if (self.capsLockPressed) {
                    self.capsLockPressed = false
                    dlog(DEBUG_LOGGING, "modifierFlags by IOKit: %lx", modifierFlags.rawValue);
                    // dlog(DEBUG_INPUTCONTROLLER, @"** CIMInputController FLAGCHANGED -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@", event, -1, modifierFlags, nil, nil, [[self client] bundleIdentifier]);
                    let _ = self.receiver.input(controller: self, inputText: nil, key: CIMInputControllerSpecialKeyCode.capsLockPressed.rawValue, modifiers: modifierFlags, client: sender)
                } else {
                    dlog(DEBUG_INPUTCONTROLLER, "flagsChanged: context: %@, modifierFlags: %lx", self, modifierFlags.rawValue);
                    let _ = self.receiver.input(controller: self, inputText: nil, key: CIMInputControllerSpecialKeyCode.capsLockFlagsChanged.rawValue, modifiers: modifierFlags, client: sender)
                }
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
extension CIMInputController {  // IMKServerInputTextData
    open override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any!) -> Bool {
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -inputText:key:modifiers:client  with string: %@ / keyCode: %ld / modifier flags: %lu / client: %@", string, keyCode, flags, self.client()?.bundleIdentifier() ?? "nil");
        let processed = self.receiver.input(controller: self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: UInt(flags)), client: sender).rawValue > CIMInputTextProcessResult.notProcessed.rawValue;
        return processed
    }
}
*/
/*
extension CIMInputController {  // IMKServerInputKeyBinding
    open override func inputText(_ string: String!, client sender: Any!) -> Bool {
        // dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -inputText:client: with string: %@ / client: %@", string, sender);
        return false
    }
    
    open override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
        // dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -didCommandBySelector: with selector: %@", aSelector);
        return false
    }
}
*/

extension CIMInputController {  // IMKStateSetting
    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    open override func recognizedEvents(_ sender: Any!) -> Int {
        return self.receiver.recognizedEvents(sender)
    }

    //! @brief 자판 전환을 감지한다.
    open override func setValue(_ value: Any!, forTag tag: Int, client sender: Any!) {
        self.receiver.setValue(value, forTag: tag, client: sender, controller: self)
    }
}

extension CIMInputController {  // IMKMouseHandling
    /*!
     @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
     */
    open override func mouseDown(onCharacterIndex index: Int, coordinate point: NSPoint, withModifier flags: Int, continueTracking keepTracking: UnsafeMutablePointer<ObjCBool>!, client sender: Any!) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::MOUSEDOWN");
        let _ = self.receiver.commitCompositionEvent(sender, controller: self)
        return false
    }
}

extension CIMInputController {  // IMKCustomCommands
    open override func menu() -> NSMenu! {
        return (NSApplication.shared.delegate! as! CIMApplicationDelegate).menu
    }
}

extension CIMInputController {  // IMKServerInput
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    open override func commitComposition(_ sender: Any!) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT-RAW?");
        let _ = self.receiver.commitCompositionEvent(sender, controller: self)
        //[super commitComposition:sender];
    }
    
    open override func updateComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE-RAW?");
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -updateComposition");
        self.receiver.updateCompositionEvent(self)
        super.updateComposition()
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -updateComposition ended");
    }
    
    open override func cancelComposition() {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-RAW?")
        self.receiver.cancelCompositionEvent(self)
        super.cancelComposition()
    }
    
    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    open override func composedString(_ sender: Any!) -> Any! {
        return self.receiver.composedString(sender, controller: self)
    }
    open override func originalString(_ sender: Any!) -> NSAttributedString! {
        return self.receiver.originalString(sender, controller: self)
    }
    
    open override func candidates(_ sender: Any!) -> [Any]! {
        return self.receiver.candidates(sender, controller: self)
    }

    open override func candidateSelected(_ candidateString: NSAttributedString!) {
        self.receiver.candidateSelected(candidateString, controller: self)
    }
    
    open override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        self.receiver.candidateSelectionChanged(candidateString, controller: self)
    }
}


@objcMembers class CIMMockInputController: CIMInputController {
    @objc var _receiver: CIMInputReceiver!
    
    @objc override init(server: IMKServer, delegate: Any!, client: Any!) {
        super.init()
        self._receiver = CIMInputReceiver(server: server, delegate: delegate, client: client, controller: self)
    }
    
    @objc func repoduceTextLog(_ text: String) throws {
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
    
    //    Implemented in objc file
    //    @objc override func client() -> (IMKTextInput & NSObjectProtocol)! {
    //        return self._receiver.inputClient
    //    }
    //
    @objc override var composer: CIMComposer {
        return self._receiver.composer
    }
    
    @objc override func selectionRange() -> NSRange {
        return (self._receiver.inputClient as AnyObject).selectedRange
    }
}

extension CIMMockInputController {
    @objc override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any!) -> Bool {
        let client = self.client() as AnyObject
        print("** CIMInputController -inputText:key:modifiers:client  with string: \(string ?? "(nil)") / keyCode: \(keyCode) / modifier flags: \(flags) / client: \(String(describing: client.bundleIdentifier)) client class: \(String(describing: client.class))")
        let v1 = (self._receiver.input(controller: self, inputText: string, key: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: NSEvent.ModifierFlags.RawValue(flags)), client: sender).rawValue)
        let v2 = (CIMInputTextProcessResult.notProcessed.rawValue)
        let processed: Bool = v1 > v2
        if !processed {
            //[self cancelComposition];
        }
        return processed
    }
    
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    @objc override func commitComposition(_ sender: Any) {
        self._receiver.commitCompositionEvent(sender, controller: self)
        // COMMIT triggered
    }
}
