//
//  GureumComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 16..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMComposer.h"

ICEXTERN NSString *kGureumInputSourceIdentifierQwerty;
ICEXTERN NSString *kGureumInputSourceIdentifierDvorak;
ICEXTERN NSString *kGureumInputSourceIdentifierDvorakQwertyCommand;
ICEXTERN NSString *kGureumInputSourceIdentifierColemak;
ICEXTERN NSString *kGureumInputSourceIdentifierColemakQwertyCommand;
ICEXTERN NSString *kGureumInputSourceIdentifierHan2;
ICEXTERN NSString *kGureumInputSourceIdentifierHan2Classic;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Final;
ICEXTERN NSString *kGureumInputSourceIdentifierHan390;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3NoShift;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Classic;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Layout2;
ICEXTERN NSString *kGureumInputSourceIdentifierHanAhnmatae;
ICEXTERN NSString *kGureumInputSourceIdentifierHanRoman;

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
