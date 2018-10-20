//
//  CIMInputManager.swift
//  OSX
//
//  Created by yuaming on 2018. 9. 20..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

/*!
 @brief  공통적인 OSX의 입력기 구조를 다룬다.
 
 InputManager는 @ref CIMInputController 또는 테스트코드에 해당하는 외부에서 입력을 받아 입력기에서 처리 후 결과 값을 보관한다. 처리 후 그 결과를 확인하는 것은 사용자의 몫이다.
 
 IMKServer나 클라이언트와 무관하게 입력 값에 대해 출력 값을 생성해 내는 입력기. 입력 뿐만 아니라 여러 키보드 간 전환이나 입력기에 관한 단축키 등 입력기에 관한 모든 기능을 다룬다.
 
 @coclass    IMKServer CIMInputHandler CIMComposer
 */
@objcMembers public class CIMInputManager: NSObject, CIMInputTextDelegate {
    //! @brief  현재 입력중인 서버
    private var _server: IMKServer
    //! @property
    private var _candidates: IMKCandidates
    //! @property
    public var configuration: GureumConfiguration
    //! @brief  공용 입력 핸들러
    public var handler: CIMInputHandler!
    //! @brief  입력기가 inputText: 문맥에 있는지 여부를 저장
    public var inputting: Bool = false
    
    public var server: IMKServer! {
        return self._server
    }
    
    public var candidates: IMKCandidates! {
        return self._candidates
    }

    override init() {
        #if DEBUG
        print("** CharmInputManager Init")
        #endif

        self.configuration = GureumConfiguration.shared()
        let mainBundle = Bundle.main
        let connectionName = mainBundle.infoDictionary!["InputMethodConnectionName"] as! String
        self._server = IMKServer(name: connectionName, bundleIdentifier: mainBundle.bundleIdentifier)
        self._candidates = IMKCandidates(server: _server, panelType: kIMKSingleColumnScrollingCandidatePanel)

        super.init()

        self.handler = CIMInputHandler(manager: self)

        #if DEBUG
        print("\tserver: \(String(describing: self._server)) / candidates: \(String(describing: self._candidates)) / handler: \(String(describing: self.handler))")
        #endif
    }

    public override var description: String {
        return """
        <%@ server: "\(String(describing: self._server))" candidates: "\(String(describing: self._candidates))" handler: "\(String(describing: self.handler))" configuration: \(String(describing: self.configuration))>
        """
    }
    
    // MARK: - IMKServerInputTextData
    
    // 일단 받은 입력은 모두 핸들러로 넘겨준다.
    public func inputController(_ controller: CIMInputController, inputText string: String?, key keyCode: Int, modifiers flag: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        assert(controller.className.hasSuffix("InputController"))
        let handled = self.handler.inputController(controller, inputText: string, key: keyCode, modifiers: flag, client: sender)
        return handled
    }
}
