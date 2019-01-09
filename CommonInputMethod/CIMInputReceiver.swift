//
//  CIMInputReceiver.swift
//  OSX
//
//  Created by Jeong YunWon on 21/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import Cocoa


@objcMembers class CIMInputReceiver: NSObject, CIMInputTextDelegate {
    var inputClient: Any
    var composer: CIMComposer
    var controller: CIMInputController
    
    var hasSelectionRange: Bool = false
    
    init(server: IMKServer, delegate: Any!, client: Any!, controller: CIMInputController) {
        dlog(DEBUG_INPUTCONTROLLER, "**** NEW INPUT CONTROLLER INIT **** WITH SERVER: %@ / DELEGATE: %@ / CLIENT: %@", server, (delegate as? NSObject) ?? "(nil)", (client as? NSObject) ?? "(nil)")
        self.composer = GureumComposer()
        self.composer.manager = CIMInputManager.shared
        self.inputClient = client
        self.controller = controller
    }
    
    // IMKServerInput 프로토콜에 대한 공용 핸들러
    public func input(controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any!) -> CIMInputTextProcessResult {
        dlog(DEBUG_LOGGING, "LOGGING::KEY::(%@)(%ld)(%lu)", string?.replacingOccurrences(of: "\n", with: "\\n") ?? "(nil)", keyCode, flags.rawValue)
        
        let hadComposedString = !self._internalComposedString.isEmpty
        let handled = self.composer.manager.input(controller: controller, inputText:string, key:keyCode, modifiers:flags, client:sender)
        
        self.composer.manager.inputting = true
        
        switch handled {
        case .notProcessed:
            break
        case .processed:
            break
        case .notProcessedAndNeedsCancel:
            self.cancelComposition(controller)
        case .notProcessedAndNeedsCommit:
            self.cancelComposition(controller)
            self.commitComposition(sender, controller:controller)
            return handled
        default:
            dlog(true, "WRONG RESULT: %d", handled.rawValue)
            assert(false)
        }
        
        let commited = self.commitComposition(sender, controller:controller) // 조합 된 문자 반영
        let hasComposedString = !self._internalComposedString.isEmpty
        let selectionRange = controller.selectionRange()
        self.hasSelectionRange = selectionRange.location != NSNotFound && selectionRange.length > 0
        if (commited || controller.selectionRange().length > 0 || hadComposedString || hasComposedString) {
            self.updateComposition(controller) // 조합 중인 문자 반영
        }
        
        self.composer.manager.inputting = false
        
        dlog(DEBUG_INPUTCONTROLLER, "*** End of Input handling ***")
        return handled
    }
}

extension CIMInputReceiver { // IMKServerInput
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    func commitComposition(_ sender: Any!, controller: CIMInputController) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT-INTERNAL")
        return self.commitCompositionEvent(sender, controller:controller)
    }

    func updateComposition(_ controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE-INTERNAL")
        controller.updateComposition()
    }
    
    func cancelComposition(_ controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-INTERNAL")
        controller.cancelComposition()
    }
    
    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    func commitCompositionEvent(_ sender: Any!, controller: CIMInputController) -> Bool {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::COMMIT")
        if (!self.composer.manager.inputting) {
            // 입력기 외부에서 들어오는 커밋 요청에 대해서는 편집 중인 글자도 커밋한다.
            dlog(DEBUG_INPUTCONTROLLER, "-- CANCEL composition because of external commit request from %@", sender as! NSObject)
            dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL-INTERNAL")
            self.cancelCompositionEvent(controller)
        }
        // 왠지는 모르겠지만 프로그램마다 동작이 달라서 조합을 반드시 마쳐주어야 한다
        // 터미널과 같이 조합중에 리턴키 먹는 프로그램은 조합 중인 문자가 없고 보통은 있다
        let commitString = self.composer.dequeueCommitString()
        
        // 커밋할 문자가 없으면 중단
        if commitString.isEmpty {
            return false
        }

        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -commitComposition: with sender: %@ / strings: %@", sender as! NSObject, commitString)
        let range = controller.selectionRange()
        dlog(DEBUG_LOGGING, "LOGGING::COMMIT::%lu:%lu:%@", range.location, range.length, commitString)
        if range.length > 0 {
            controller.client().insertText(commitString, replacementRange: range)
        } else {
            controller.client().insertText(commitString, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        }

        self.composer.manager.controllerDidCommit(controller)

        return true
    }
    
    func updateCompositionEvent(_ controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::UPDATE")
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -updateComposition")
    }
    
    func cancelCompositionEvent(_ controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CANCEL")
        self.composer.cancelComposition()
    }
    
    var _internalComposedString: String {
        return self.composer.composedString
    }
    
    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    func composedString(_ sender: Any, controller: CIMInputController) -> String {
        let string = self._internalComposedString
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::COMPOSEDSTRING::(%@)", string)
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -composedString: with return: '%@'", string)
        return string
    }
    
    func originalString(_ sender: Any!, controller: CIMInputController) -> NSAttributedString! {
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -originalString:")
        let s = NSAttributedString(string: self.composer.originalString)
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::ORIGINALSTRING::%@", s.string)
        return s
    }
    
    func candidates(_ sender: Any!, controller: CIMInputController) -> [Any]! {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATES")
        return self.composer.candidates
    }
    
    func candidateSelected(_ candidateString: NSAttributedString, controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATESELECTED::%@", candidateString)
        self.composer.manager.inputting = true
        self.composer.candidateSelected(candidateString)
        self.commitComposition(self.inputClient, controller: controller)
        self.composer.manager.inputting = false
    }
    
    func candidateSelectionChanged(_ candidateString: NSAttributedString, controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::CANDIDATESELECTIONCHANGED::%@", candidateString)
        self.composer.candidateSelectionChanged(candidateString)
        self.updateComposition(controller)
    }
}

extension CIMInputReceiver { // IMKStateSetting

    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    open func recognizedEvents(_ sender: Any!) -> Int {
        dlog(DEBUG_LOGGING, "LOGGING::CHECK::RECOGNIZEDEVENTS")
        // NSFlagsChangeMask는 -handleEvent: 에서만 동작
        
        return Int(NSEvent.EventTypeMask.keyDown.rawValue | NSEvent.EventTypeMask.flagsChanged.rawValue | NSEvent.EventTypeMask.leftMouseDown.rawValue | NSEvent.EventTypeMask.rightMouseDown.rawValue | NSEvent.EventTypeMask.leftMouseDragged.rawValue | NSEvent.EventTypeMask.rightMouseDragged.rawValue)
    }
    
    //! @brief 자판 전환을 감지한다.
    open func setValue(_ value: Any!, forTag tag: Int, client sender: Any!, controller: CIMInputController) {
        dlog(DEBUG_LOGGING, "LOGGING::EVENT::CHANGE-%lu-%@", tag, value as? String ?? "(nonstring)")
        dlog(DEBUG_INPUTCONTROLLER, "** CIMInputController -setValue:forTag:client: with value: %@ / tag: %lx / client: %@", value as? String ?? "(nonstring)", tag, String(describing: controller.client as AnyObject))
        switch tag {
            case kTextServiceInputModePropertyTag:
                guard let value = value as? String else {
                    NSLog("Failed to change keyboard layout")
                    assert(false)
                    break
                }
                if value != self.composer.inputMode {
                    assert(sender != nil)
                    self.commitComposition(sender, controller:controller)
                    self.composer.inputMode = value
                }
            default:
                dlog(true, "**** UNKNOWN TAG %ld !!! ****", tag)
        }
        
        dlog(true, "==== source")
        return
        
        // 미국자판으로 기본자판 잡는 것도 임시로 포기
        /*
        TISInputSource *mainSource = _USSource();
        NSString *mainSourceID = mainSource.identifier;
        TISInputSource *currentSource = [TISInputSource currentSource];
        dlog(1, @"current source: %@", currentSource);
        
        [TISInputSource setInputMethodKeyboardLayoutOverride:mainSource];
        
        TISInputSource *override = [TISInputSource inputMethodKeyboardLayoutOverride];
        if (override == nil) {
            dlog(1, @"override fail");
            TISInputSource *currentASCIISource = [TISInputSource currentASCIICapableLayoutSource];
            dlog(1, @"ascii: %@", currentASCIISource);
            id ASCIISourceID = currentASCIISource.identifier;
            if (![ASCIISourceID isEqualToString:mainSourceID]) {
                dlog(1, @"id: %@ != %@", ASCIISourceID, mainSourceID);
                BOOL mainSourceIsEnabled = mainSource.enabled;
                //if (!mainSourceIsEnabled) {
                //    [mainSource enable];
                //}
                if (mainSourceIsEnabled) {
                    [mainSource select];
                    [currentSource select];
                }
                //if (!mainSourceIsEnabled) {
                //    [mainSource disable];
                //}
            }
        } else {
            dlog(1, @"overrided");
        }
         */
    }
}
