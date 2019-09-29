//
//  InputMethodServer.swift
//  OSX
//
//  Created by yuaming on 2018. 9. 20..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import InputMethodKit
import SwiftIOKit

let DEBUG_INPUT_SERVER = false
let DEBUG_IOKIT_EVENT = false

let KeyMapLower = [
    "a", "s", "d", "f", "h", "g", "z", "x",
    "c", "v", nil, "b", "q", "w", "e", "r",
    "y", "t", "1", "2", "3", "4", "6", "5",
    "=", "9", "7", "-", "8", "0", "]", "o",
    "u", "[", "i", "p", nil, "l", "j", "'",
    "k", ";", "\\", ",", "/", "n", "m", ".",
    nil, nil, "`",
]
// assert(keyMapLower.count == KeyMapSize)

let KeyMapUpper = [
    "A", "S", "D", "F", "H", "G", "Z", "X",
    "C", "V", nil, "B", "Q", "W", "E", "R",
    "Y", "T", "!", "@", "#", "$", "^", "%",
    "+", "(", "&", "_", "*", ")", "}", "O",
    "U", "{", "I", "P", nil, "L", "J", "\"",
    "K", ":", "|", "<", "?", "N", "M", ">",
    nil, nil, "~",
]

extension IMKServer {
    convenience init?(bundle: Bundle) {
        guard let connectionName = bundle.infoDictionary!["InputMethodConnectionName"] as? String else {
            return nil
        }
        self.init(name: connectionName, bundleIdentifier: bundle.bundleIdentifier)
    }
}

class IOKitty {
    let service: SIOService
    let connect: SIOConnect
    let manager: IOHIDManager
    private var defaultCapsLockState: Bool = false
    var capsLockDate: Date?
    var rollback: (() -> Void)?

    init?() {
        guard let _service = SIOService(name: kIOHIDSystemClass) else {
            return nil
        }
        service = _service
        guard let _connect = try? service.open(owningTask: mach_task_self_, type: kIOHIDParamConnectType).get() else {
            return nil
        }
        connect = _connect

        defaultCapsLockState = (try? connect.getModifierLock(selector: .capsLock).get()) ?? false

        manager = IOHIDManager.create()
        manager.setDeviceMatching(page: kHIDPage_GenericDesktop, usage: kHIDUsage_GD_Keyboard)
        manager.setInputValueMatching(min: kHIDUsage_KeyboardCapsLock, max: kHIDUsage_KeyboardCapsLock)

        let _self = Unmanaged.passUnretained(self)
        // Set input value callback
        manager.registerInputValueCallback({
            inContext, _, _, value in
            guard Configuration.shared.enableCapslockToToggleInputMode else {
                return
            }
            guard let inContext = inContext else {
                dlog(true, "IOKit callback inContext is nil - impossible")
                return
            }

            let pressed = value.integerValue > 0
            dlog(DEBUG_IOKIT_EVENT, "caps lock pressed: \(pressed)")
            let _self = Unmanaged<IOKitty>.fromOpaque(inContext).takeUnretainedValue()
            if pressed {
                _self.capsLockDate = Date()
                dlog(DEBUG_IOKIT_EVENT, "caps lock pressed set in context")
            } else {
                if _self.defaultCapsLockState || (_self.capsLockDate != nil && !_self.capsLockTriggered) {
                    // long pressed
                    _self.defaultCapsLockState = !_self.defaultCapsLockState
                    _self.rollback?()
                    _self.rollback = nil
                } else {
                    // short pressed
                    _ = _self.connect.setModifierLock(selector: .capsLock, state: _self.defaultCapsLockState)
                    _self.capsLockDate = nil
                }
            }
            // NSEvent.otherEvent(with: .applicationDefined, location: .zero, modifierFlags: .capsLock, timestamp: 0, windowNumber: 0, context: nil, subtype: 0, data1: 0, data2: 0)!
        }, context: _self.toOpaque())

        manager.schedule(runloop: .current, mode: .default)
        let r = manager.open()
        if r != kIOReturnSuccess {
            dlog(DEBUG_IOKIT_EVENT, "IOHIDManagerOpen failed")
        }
    }

    deinit {
        manager.unschedule(runloop: .current, mode: .default)
        manager.unregisterInputValueCallback()
        let r = manager.close()
        assert(r == 0)
    }

    var capsLockTriggered: Bool {
        dlog(DEBUG_IOKIT_EVENT, "  triggered: date \(String(describing: capsLockDate))")
        guard let capsLockDate = capsLockDate else {
            return false
        }
        let interval = Date().timeIntervalSince(capsLockDate)
        dlog(DEBUG_IOKIT_EVENT, "  triggered: interval \(interval)")
        return interval < 0.5
    }
}

/*!
 @brief  공통적인 OSX의 입력기 구조를 다룬다.

 InputManager는 @ref InputController 또는 테스트코드에 해당하는 외부에서 입력을 받아 입력기에서 처리 후 결과 값을 보관한다. 처리 후 그 결과를 확인하는 것은 사용자의 몫이다.

 IMKServer나 클라이언트와 무관하게 입력 값에 대해 출력 값을 생성해 내는 입력기. 입력 뿐만 아니라 여러 키보드 간 전환이나 입력기에 관한 단축키 등 입력기에 관한 모든 기능을 다룬다.

 @coclass    IMKServer DelegatedComposer
 */
// TODO: InputTextDelegate를 제거하고 서버만 관리하도록 한다
public class InputMethodServer {
    public static let shared = InputMethodServer()
    //! @brief  현재 입력중인 서버
    let server: IMKServer
    //! @property
    let candidates: IMKCandidates
    //! @brief  입력기가 inputText: 문맥에 있는지 여부를 저장
    let io: IOKitty

    convenience init() {
        let bundle = Bundle.main
        var name = bundle.infoDictionary!["InputMethodConnectionName"] as! String
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                name += "_Test" + String(describing: Int.random(in: 0 ..< 0x10000))
            } else {
                name += "_Debug"
            }
        #endif

        self.init(name: name)
    }

    init(name: String) {
        dlog(DEBUG_INPUT_SERVER, "** InputMethodServer Init")

        server = IMKServer(name: name, bundleIdentifier: Bundle.main.bundleIdentifier)
        candidates = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
        // candidates.setSelectionKeysKeylayout(TISInputSource.currentKeyboardLayout())

        io = IOKitty()!
        dlog(DEBUG_INPUT_SERVER, "\t%@", description)
    }

    var description: String {
        return """
        <InputMethodServer server: "\(String(describing: server))" candidates: "\(String(describing: candidates))">
        """
    }

    func showOrHideCandidates(controller: InputController) {
        if controller.receiver.composer.hasCandidates {
            candidates.update()
            candidates.show(kIMKLocateCandidatesLeftHint)
        } else if candidates.isVisible() {
            candidates.hide()
        }
    }
}
