//
//  CIMInputManager.swift
//  OSX
//
//  Created by yuaming on 2018. 9. 20..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

let DEBUG_INPUTHANDLER = false

let CIMKeyMapLower = [
    "a", "s", "d", "f", "h", "g", "z", "x",
    "c", "v", nil, "b", "q", "w", "e", "r",
    "y", "t", "1", "2", "3", "4", "6", "5",
    "=", "9", "7", "-", "8", "0", "]", "o",
    "u", "[", "i", "p", nil, "l", "j", "'",
    "k", ";","\\", ",", "/", "n", "m", ".",
    nil, nil, "`",
]
//assert(keyMapLower.count == CIMKeyMapSize)

let CIMKeyMapUpper = [
    "A", "S", "D", "F", "H", "G", "Z", "X",
    "C", "V", nil, "B", "Q", "W", "E", "R",
    "Y", "T", "!", "@", "#", "$", "^", "%",
    "+", "(", "&", "_", "*", ")", "}", "O",
    "U", "{", "I", "P", nil, "L", "J", "'",
    "K", ":", "|", "<", "?", "N", "M", ">",
    nil, nil, "~",
]


/*!
 @brief  공통적인 OSX의 입력기 구조를 다룬다.
 
 InputManager는 @ref CIMInputController 또는 테스트코드에 해당하는 외부에서 입력을 받아 입력기에서 처리 후 결과 값을 보관한다. 처리 후 그 결과를 확인하는 것은 사용자의 몫이다.
 
 IMKServer나 클라이언트와 무관하게 입력 값에 대해 출력 값을 생성해 내는 입력기. 입력 뿐만 아니라 여러 키보드 간 전환이나 입력기에 관한 단축키 등 입력기에 관한 모든 기능을 다룬다.
 
 @coclass    IMKServer CIMComposer
 */
@objcMembers public class CIMInputManager: NSObject, CIMInputTextDelegate {
    //! @brief  현재 입력중인 서버
    private var _server: IMKServer
    //! @property
    private var _candidates: IMKCandidates
    //! @brief  입력기가 inputText: 문맥에 있는지 여부를 저장
    public var inputting: Bool = false
    
    public var server: IMKServer! {
        return self._server
    }
    
    public var candidates: IMKCandidates! {
        return self._candidates
    }

    override init() {
        dlog(true, "** CharmInputManager Init")

        let mainBundle = Bundle.main
        var connectionName = mainBundle.infoDictionary!["InputMethodConnectionName"] as! String
        #if DEBUG
        connectionName += "_Debug"
        #endif
        self._server = IMKServer(name: connectionName, bundleIdentifier: mainBundle.bundleIdentifier)
        self._candidates = IMKCandidates(server: _server, panelType: kIMKSingleColumnScrollingCandidatePanel)

        super.init()

        dlog(true, "\t%@", self.description)
    }

    public override var description: String {
        return """
        <%@ server: "\(String(describing: self._server))" candidates: "\(String(describing: self._candidates))">
        """
    }
    
    // MARK: - IMKServerInputTextData
    
    // 일단 받은 입력은 모두 핸들러로 넘겨준다.
    public func input(controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flags: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        assert(controller.className.hasSuffix("InputController"))

        // 입력기용 특수 커맨드 처리
        var result = controller.composer.input(controller: controller, command:string, key:keyCode, modifiers:flags, client:sender)
        if result == .notProcessedAndNeedsCommit {
            return result
        }
        if result != .processed {
            // 옵션 키 변환 처리
            var string = string
            if flags.contains(.option) {
                let configuration = GureumConfiguration.shared
                dlog(DEBUG_INPUTHANDLER, "option key: %ld", configuration.optionKeyBehavior);
                switch configuration.optionKeyBehavior {
                case 0:
                    // default
                    dlog(DEBUG_INPUTHANDLER, " ** ESCAPE from option-key default behavior");
                    return .notProcessedAndNeedsCommit;
                case 1:
                    // ignore
                    if keyCode < 0x33 {
                        if flags.contains(.capsLock) || flags.contains(.shift) {
                            string = CIMKeyMapUpper[keyCode] ?? string
                        } else {
                            string = CIMKeyMapLower[keyCode] ?? string
                        }
                    }
                default:
                    assert(false)
                }
            } else {
                if (keyCode < 0x33) {
                    if flags.contains(.shift) {
                        string = CIMKeyMapUpper[keyCode] ?? string
                    } else {
                        string = CIMKeyMapLower[keyCode] ?? string
                    }
                }
            }

            // 특정 애플리케이션에서 커맨드/옵션/컨트롤 키 입력을 선점하지 못하는 문제를 회피한다
            if flags.contains(.command) || flags.contains(.option) || flags.contains(.control) {
                dlog(true, "-- CIMInputHandler -inputText: Command/Option key input / returned NO")
                return .notProcessedAndNeedsCommit;
            }

            if string == nil {
                return .notProcessedAndNeedsCommit;
            }

            result = controller.composer.input(controller: controller, inputText:string, key:keyCode, modifiers:flags, client:sender)
        }

        dlog(false, "******* FINAL STATE: %d", result.rawValue);
        // 합성 후보가 있다면 보여준다
        if controller.composer.hasCandidates {
            let candidates = self.candidates!
            candidates.update()
            candidates.show(kIMKLocateCandidatesLeftHint)
        }
        return result;
    }
}
