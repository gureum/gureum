//
//  HGInputContext.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief  See hangul.h and hangulinputcontext.c to see related libhangul functions
 
    libhangul의 hangul input context 코드를 Objective-C 객체 모델로 감싼다. 관련 libhangul 함수를 보기 위해서 hangul/hangul.h와 hangul/hangulinputcontext.c 를 본다.
*/

#import <Foundation/Foundation.h>
#import <Hangul/HGCharacter.h>

@class HGHangulCombination;

/*!
    @brief  @ref HangulKeyboard 를 감싼다.
 
    @ref HGInputContext 를 위해 새 데이터를 만들때는 -init 을, 원래의 HangulKeyboard 데이터를 변환하기 위해서는 -initWithKeyboardData:freeWhenDone: 과 -keyboardWithKeyboardData:freeWhenDone: 을 사용한다.
*/
@interface HGKeyboard : NSObject {
@private
    HangulKeyboard *data;
    
    struct {
        unsigned freeWhenDone:1;
    } flags;
}
/*! @property
    @brief  미구현 기능을 위해 HangulKeyboard 객체에 접근할 때 사용한다.
*/
@property(nonatomic, readonly) HangulKeyboard *data;

//! @brief  HangulKeyboard 데이터를 기반으로 객체 생성
- (id)initWithKeyboardData:(HangulKeyboard *)data freeWhenDone:(BOOL)YesOrNo;
//! @brief  HangulKeyboard 데이터를 기반으로 객체 생성
+ (id)keyboardWithKeyboardData:(HangulKeyboard *)data freeWhenDone:(BOOL)YesOrNo;

//! @brief @ref hangul_keyboard_set_value
- (void)setValue:(HGUCSChar)value forKey:(int)key;
//! @brief @ref hangul_keyboard_set_type
- (void)setType:(int)type;

@end

/*!
    @brief  출력 형태에 관한 상수
*/
typedef enum {
    HGOutputModeSyllable = HANGUL_OUTPUT_SYLLABLE,
    HGOutputModeJamo = HANGUL_OUTPUT_JAMO,
}   HGOutputMode;

/*!
    @brief  @ref HangulInputContext 를 감싼다.
 
    @ref HangulInputContext 의 기능에 대한 Objective-C의 객체 모델을 제공한다. 객체 모델이 지원하지 않는 기능에 대해서는 -context 로 libhangul의 컨텍스트에 직접 접근하여 사용할 수 있다.
*/
@interface HGInputContext : NSObject {
@private
    HangulInputContext *context;
}

//! @brief  미구현 기능을 이용하기 위해 HangulInputContext 에 직접 접근
@property(nonatomic, readonly) HangulInputContext *context;

//! @brief  @ref hangul_ic_new @ref hangul_ic_delete
- (id)initWithKeyboardIdentifier:(NSString *)code;
//! @brief  @ref hangul_ic_process
- (BOOL)process:(int)ascii;
//! @brief  @ref hangul_ic_reset
- (void)reset;
//! @brief  @ref hangul_ic_backspace
- (BOOL)backspace;

//! @brief  @ref hangul_ic_is_empty
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;
//! @brief  @ref hangul_ic_has_choseong
@property(nonatomic, readonly) BOOL hasChoseong;
//! @brief  @ref hangul_ic_has_jungseong
@property(nonatomic, readonly) BOOL hasJungseong;
//! @brief  @ref hangul_ic_has_jongseong
@property(nonatomic, readonly) BOOL hasJongseong;
//! @brief  @ref hangul_ic_is_transliteration
@property(nonatomic, readonly, getter=isTransliteration) BOOL transliteration;
/*!
    @brief  @ref hangul_ic_preedit_string
    @ref IMKInputController 의 -composedString 과 대응한다.
*/
@property(nonatomic, readonly) NSString *preeditString;
//! @brief  @ref hangul_ic_commit_string
@property(nonatomic, readonly) NSString *commitString;
/*! @brief  @ref hangul_ic_flush
    @discussion     현재 조합 중인 글자의 조합을 완료하고 @ref preeditString 을 결과로 돌려준다.
*/
- (NSString *)flushString; // unclear naming...

//! @brief  @ref hangul_ic_set_output_mode 
- (void)setOutputMode:(HGOutputMode)mode;
//! @brief  @ref hangul_ic_set_keyboard
- (void)setKeyboard:(HGKeyboard *)aKeyboard;
//! @brief  @ref hangul_ic_set_keyboard
- (void)setKeyboardWithData:(HangulKeyboard *)keyboardData;
//! @brief  @ref hangul_ic_select_keyboard
- (void)setKeyboardWithIdentifier:(NSString *)identifier;
//! @brief  @ref hangul_ic_set_combination
- (void)setCombination:(HangulCombination *)aCombination;

/* out of use, out of mind
void hangul_ic_connect_callback(HangulInputContext* hic, const char* event,
                                void* callback, void* user_data);

*/
@end

/* out of use, out of mind
unsigned    hangul_ic_get_n_keyboards();
*/
//! @brief  @ref hangul_ic_get_keyboard_id 
NSString *HGKeyboardIdentifierAtIndex(NSUInteger index);
//! @brief  @ref hangul_ic_get_keyboard_name
NSString *HGKeyboardNameAtIndex(NSUInteger index);


/*!
    @brief  HGUSCChar - NSString 변환
 
    libhangul의 ucschar 문자열을 NSString 으로 변환하는 생성자 카테고리이다.
*/
@interface NSString (HGUCS)

//! @brief  HGUCSChar 문자열로 NSString을 생성 (UTF-32LE)
- (id)initWithHGUCSString:(const HGUCSChar *)ucsString;
//! @brief  HGUCSChar 문자열로 NSString을 생성 (UTF-32LE)
+ (id)stringWithHGUCSString:(const HGUCSChar *)ucsString;

@end