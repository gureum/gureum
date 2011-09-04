//
//  CIMInputManager.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief  입출력 환경을 제외한 입력기를 다룬다.
*/

#import <Foundation/Foundation.h>
#import <InputMethodKit/InputMethodKit.h>

#import "CIMComposer.h"

@class CIMConfiguration;
@class CIMInputHandler;

/*!
    @define
    @brief  @ref CIMInputManager 의 공용 오브젝트에 대한 단축
    
    대부분 CIMInputManager는 하나의 객체만 사용될 것이므로 공용 객체를 싱글턴으로 보고 접근할 수 있는 인터페이스를 단축으로 제공한다.
*/
#define CIMManager [CIMInputManager sharedManager]
/*!
    @brief  OS 입출력 환경에 독립적인 입력기
    
    InputManager는 CharmIM에서는 @ref CIMInputController 또는 테스트코드에 해당하는 외부에서 입력을 받아 입력기에서 처리 후 결과 값을 보관한다. 처리 후 그 결과를 확인하는 것은 사용자의 몫이다.
 
    IMKServer나 클라이언트와 무관하게 입력 값에 대해 출력 값을 생성해 내는 입력기. 입력 뿐만 아니라 여러 키보드 간 전환이나 입력기에 관한 단축키 등 입력기에 관한 모든 기능을 다룬다.
 
    @coclass    IMKServer CIMInputHandler CIMComposer
*/
@interface CIMInputManager : NSObject<IMKServerInputTextData> {
@private
    IMKServer *server;
    IMKCandidates *candidates;
    CIMConfiguration *configuration;
    CIMInputHandler *handler;
    NSMutableDictionary *composers;
    
    NSObject<CIMComposer> *currentComposer;
}

//! @brief  현재 입력중인 서버
@property(nonatomic, readonly) IMKServer *server;
//! @property
@property(nonatomic, readonly) IMKCandidates *candidates;
//! @property
@property(nonatomic, readonly) CIMConfiguration *configuration;
//! @brief  공용 입력 핸들러
@property(nonatomic, readonly) CIMInputHandler *handler;
//! @brief  입력기가 현재 선택한 합성기
@property(nonatomic, readonly) NSObject<CIMComposer> *currentComposer;

@end

/*!
    @brief  CIMInputManager의 공용 객체에 대한 인터페이스
    
    일반적으로 단일 객체가 사용될 것으로 예상되기 때문에 사용 편의를 위하여 공유 객체 인터페이스를 미리 선언해 둔다.
 
    하지만 구현은 외부 환경에 의존적이기 때문에 미리 되어있지는 않다. CharmIM에서는 @ref CIMAppDelegate 에 생성한 객체를 공유객체로 사용하도록 구현되어 있다.
*/
@interface CIMInputManager (SharedObject)
//! @brief  CIMInputManager 의 공용 오브젝트
+ (CIMInputManager *)sharedManager;

@end
