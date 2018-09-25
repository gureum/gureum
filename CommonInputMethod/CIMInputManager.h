//
//  CIMInputManager.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 15..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief  입출력 환경을 제외한 입력기를 다룬다.
*/

#import <Foundation/Foundation.h>
#import <InputMethodKit/InputMethodKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CIMInputHandler;
@class CIMComposer;
@class GureumConfiguration;

/*!
    @brief  공통적인 OSX의 입력기 구조를 다룬다.
 
    InputManager는 @ref CIMInputController 또는 테스트코드에 해당하는 외부에서 입력을 받아 입력기에서 처리 후 결과 값을 보관한다. 처리 후 그 결과를 확인하는 것은 사용자의 몫이다.
 
    IMKServer나 클라이언트와 무관하게 입력 값에 대해 출력 값을 생성해 내는 입력기. 입력 뿐만 아니라 여러 키보드 간 전환이나 입력기에 관한 단축키 등 입력기에 관한 모든 기능을 다룬다.
 
    @coclass    IMKServer CIMInputHandler CIMComposer
*/
@interface CIMInputManager : NSObject<CIMInputTextDelegate> {
@private
    IMKServer *server;
    IMKCandidates *candidates;
    CIMInputHandler *handler;
    GureumConfiguration *configuration;
    CIMComposer *sharedComposer;
    
    BOOL inputting;
}

//! @brief  현재 입력중인 서버
@property(nonatomic,readonly) IMKServer *server;
//! @property
@property(nonatomic,readonly) IMKCandidates *candidates;
//! @property
@property(nonatomic,retain) GureumConfiguration *configuration;
//! @brief  공용 입력 핸들러
@property(nonatomic,retain) CIMInputHandler *handler;
//! @brief  공용 합성기
@property(nonatomic,retain) CIMComposer *sharedComposer;
//! @brief  입력기가 inputText: 문맥에 있는지 여부를 저장
@property(nonatomic,assign, getter = isInputting) BOOL inputting;
//! @brief  입력기가 가짜 입력 중인 문자열이 필요한 지 여부를 저장
@property(nonatomic,assign) BOOL needsFakeComposedString;

@end

/*!
 @protocol
 @brief  manager의 하위 요소가 manager에 접근 가능하게 함
 */
@protocol CIMInputManagerUnit
@required
- (instancetype)initWithManager:(CIMInputManager *)manager;
- (void)setManager:(CIMInputManager *)manager;
@property(nonatomic, readonly)  CIMInputManager *manager;

@end

NS_ASSUME_NONNULL_END
