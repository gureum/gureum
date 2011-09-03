//
//  HGCharacter.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 2..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief  See hangul.h and hangulctype.c to see related libhangul functions

    libhangul의 ctype 함수를 Apple Coding Guideline에 따라 재명명. 연관된 함수를 확인하려면 hangul/hangul.h 와 hangul/hangulctype.c 를 확인한다.
*/

#include "libhangul/hangul/hangul.h"

//! @brief  libhangul 의 글자 단위인 ucschar의 alias
typedef ucschar HGUCSChar;

//! @ref hangul_is_choseong
BOOL HGCharacterIsChoseong(HGUCSChar character);
//! @ref hangul_is_jungseong
BOOL HGCharacterIsJungseong(HGUCSChar character);
//! @ref hangul_is_jongseong
BOOL HGCharacterIsJongseong(HGUCSChar character);
//! @ref hangul_is_choseong_conjoinable
BOOL HGCharacterIsChoseongConjoinable(HGUCSChar character);
//! @ref hangul_is_jungseong_conjoinable
BOOL HGCharacterIsJungseongConjoinable(HGUCSChar character);
//! @ref hangul_is_jongseong_conjoinable
BOOL HGCharacterIsJongseongConjoinable(HGUCSChar character);
//! @ref hangul_is_syllable
BOOL HGCharacterIsSyllable(HGUCSChar character);
//! @ref hangul_is_jamo
BOOL HGCharacterIsJamo(HGUCSChar character);
//! @ref hangul_is_cjamo
BOOL HGCharacterIsCompatibleJamo(HGUCSChar character);

//! @ref hangul_jamo_to_cjamo
HGUCSChar HGCompatibleJamoFromJamo(HGUCSChar character);

//! @ref hangul_choseong_to_jongseong
HGUCSChar HGJongseongFromChoseong(HGUCSChar character);
//! @ref hangul_jongseong_to_choseong
HGUCSChar HGChoseongFromJongseong(HGUCSChar character);
//! @ref hangul_jongseong_dicompose
void HGGetDecomposedCharactersFromJongseong(HGUCSChar character,
                                            HGUCSChar* jongseong,
                                            HGUCSChar* choseong);

//! @ref hangul_syllable_iterator_prev
const HGUCSChar* HGPreviousSyllableInJamoString(const HGUCSChar* jamoString,
                                                const HGUCSChar* begin);
//! @ref hangul_syllable_iterator_next
const HGUCSChar* HGNextSyllableInJamoString(const HGUCSChar* jamoString,
                                            const HGUCSChar* end);

//! @ref hangul_syllable_len
NSInteger HGSyllableLength(const HGUCSChar *string, NSInteger maxLength); // jamoString?
//! @ref hangul_jamo_to_syllable
HGUCSChar HGSyllableFromJamo(HGUCSChar choseong, HGUCSChar jungseong, 
                             HGUCSChar jongseong);
//! @ref hangul_syllable_to_jamo
void HGGetJamoFromSyllable(HGUCSChar syllable, HGUCSChar *choseong, 
                           HGUCSChar *jungseong, HGUCSChar *jongseong);
//! @ref hangul_jamos_to_syllables
NSInteger HGGetSyllablesFromJamos(const HGUCSChar* jamos, NSInteger jamosLength,
                                  HGUCSChar* syllables, NSInteger syllablesLength);
