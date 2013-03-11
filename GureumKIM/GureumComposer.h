//
//  GureumComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 16..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMComposer.h"

FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierQwerty;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierDvorak;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierDvorakQwertyCommand;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierColemak;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierColemakQwertyCommand;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan2;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan2Classic;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3Final;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan390;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3NoShift;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3Classic;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3_2011;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3_2012;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHan3Layout2;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHanAhnmatae;
FOUNDATION_EXTERN NSString *kGureumInputSourceIdentifierHanRoman;

@class HangulComposer;
@class HanjaComposer;
/*!
    @brief  구름 입력기의 합성기
 
    입력 모드에 따라 libhangul을 이용하여 문자를 합성해 준다.
*/
@interface GureumComposer : CIMComposer {
@private
    CIMBaseComposer *romanComposer;
    HangulComposer *hangulComposer;
    HanjaComposer *hanjaComposer;
}

@end
