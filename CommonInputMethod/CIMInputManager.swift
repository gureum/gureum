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
    // MARK: - sharedComposer에서 Delegate 생성하기 위해 형 변환을 위해 사용
    private weak var _cimAppDelegate: CIMApplicationDelegate!
    //! @brief  현재 입력중인 서버
    private var _server: IMKServer!
    //! @property
    private var _candidates: IMKCandidates!
    //! @property
    public var configuration: GureumConfiguration!
    //! @brief  공용 입력 핸들러
    public var handler: CIMInputHandler!
    //! @brief  공용 합성기
    public var sharedComposer: CIMComposer!
    //! @brief  입력기가 inputText: 문맥에 있는지 여부를 저장
    public var inputting: Bool = false
    //! @brief  입력기가 가짜 입력 중인 문자열이 필요한 지 여부를 저장
    public var needsFakeComposedString: Bool = false
    
    public var server: IMKServer! {
        return self._server
    }
    
    public var candidates: IMKCandidates! {
        return self._candidates
    }
    
    override init() {
        super.init()
        
        #if DEBUG
        print("** CharmInputManager Init: \(self)")
        #endif
        
        let mainBundle = Bundle.main
        let connectionName = mainBundle.infoDictionary!["InputMethodConnectionName"] as! String
        self._server = IMKServer(name: connectionName, bundleIdentifier: mainBundle.bundleIdentifier)
        self._candidates = IMKCandidates(server: _server, panelType: kIMKSingleColumnScrollingCandidatePanel)
        self.handler = CIMInputHandler(manager: self)
        self.configuration = GureumConfiguration.shared()
        self._cimAppDelegate = NSApplication.shared.delegate as? CIMApplicationDelegate
        self.sharedComposer = _cimAppDelegate.composer(server: nil, client: nil)
        
        #if DEBUG
        print("\tserver: \(String(describing: self._server)) / candidates: \(String(describing: self._candidates ?? nil)) / handler: \(String(describing: self.handler))")
        #endif
    }
    
    public override var description: String {
        return """
        <%@ server: "\(String(describing: self._server))" candidates: "\(String(describing: self._candidates))" handler: "\(String(describing: self.handler))" configuration: \(String(describing: self.configuration))>
        """
    }
    
    // MARK: - IMKServerInputTextData
    
    // 일단 받은 입력은 모두 핸들러로 넘겨준다.
    public func inputController(_ controller: CIMInputController, inputText string: String, key keyCode: Int, modifiers flag: NSEvent.ModifierFlags, client sender: Any) -> CIMInputTextProcessResult {
        assert(controller.className.hasSuffix("InputController"))
        self.needsFakeComposedString = false
        let handled = self.handler.inputController(controller, inputText: string, key: keyCode, modifiers: flag, client: sender)
        return handled
    }
}
