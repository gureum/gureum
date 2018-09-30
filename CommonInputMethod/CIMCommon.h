//
//  CIMCommon.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 2..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief  CharmIM에서 범위 없이 널리 쓰이는 코드를 모아둔다.
*/

@import Foundation;
@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

static const int CIMKeyMapSize = 0x33;
FOUNDATION_EXTERN const char CIMKeyMapLower[CIMKeyMapSize];
FOUNDATION_EXTERN const char CIMKeyMapUpper[CIMKeyMapSize];

@class CIMInputController;

/*!
    @enum
    @brief  최종적으로 CIMInputController가 처리할 결과
*/
typedef NS_ENUM(int, CIMInputTextProcessResult) {
    CIMInputTextProcessResultNotProcessedAndNeedsCommit = -2,
    CIMInputTextProcessResultNotProcessedAndNeedsCancel = -1,
    CIMInputTextProcessResultNotProcessed = 0,
    CIMInputTextProcessResultProcessed = 1,
};

/*!
    @protocol
    @brief  입력을 처리하는 클래스의 관한 공통 형식
    @discussion TextData형식으로 @ref IMKServerInput 을 처리할 클래스의 공통 인터페이스. CharmIM에서 입력 값을 보고 처리하는 모든 클래스는 이 프로토콜을 구현한다.
*/
@protocol CIMInputTextDelegate
@required
/*!
    @method
    @param  controller  서버에서 입력을 받은 컨트롤러
    @param  string  문자열로 표현된 입력 값
    @param  keyCode 입력된 raw key code
    @param  flags   입력된 modifier flag
    @param  sender  입력 값을 전달한 외부 오브젝트
    @return 입력 처리 여부. YES를 반환하면 이미 처리된 입력으로 보고 NO를 반환하면 외부에서 입력을 다시 처리한다.
    @see    IMKServerInput
*/
- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(nullable NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender;
@end

NS_ASSUME_NONNULL_END
