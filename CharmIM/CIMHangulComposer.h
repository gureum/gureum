//
//  CIMHangulComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMComposer.h"
@class HGInputContext;

/*!
    @brief  libhangul을 사용하는 합성기
 
    libhangul의 input context를 사용하는 합성기이다. 기본 생성자로는 두벌식 합성기가 설정된다.
 
    @coclass HGInputContext
*/
@interface CIMHangulComposer : NSObject<CIMComposer> {
@private
    HGInputContext *inputContext;
}

/*!
    @brief  libhangul의 input context를 사용하는 합성기를 초기화한다.
    @param  identifier  libhangul의 @ref hangul_ic_select_keyboard 를 참고한다.
*/
- (id)initWithKeyboardIdentifier:(NSString *)identifier;
/*!
    @brief  현재 context의 배열을 바꾼다.
    @param  identifier  libhangul의 @ref hangul_ic_select_keyboard 를 참고한다.
*/
- (void)setKeyboardWithIdentifier:(NSString *)identifier;

@end
