//
//  HGCharacter.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 2..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#include <hangul.h>
#import "HGCharacter.h"

inline BOOL HGCharacterIsChoseong(HGUCSChar character) {
    return (BOOL)hangul_is_choseong(character);
}

inline BOOL HGCharacterIsJungseong(HGUCSChar character) {
    return (BOOL)hangul_is_jungseong(character);
}

inline BOOL HGCharacterIsJongseong(HGUCSChar character) {
    return (BOOL)hangul_is_jongseong(character);
}

inline BOOL HGCharacterIsChoseongConjoinable(HGUCSChar character) {
    return (BOOL)hangul_is_choseong_conjoinable(character);
}

inline BOOL HGCharacterIsJungseongConjoinable(HGUCSChar character) {
    return (BOOL)hangul_is_jungseong_conjoinable(character);
}

inline BOOL HGCharacterIsJongseongConjoinable(HGUCSChar character) {
    return (BOOL)hangul_is_jongseong_conjoinable(character);
}

inline BOOL HGCharacterIsSyllable(HGUCSChar character) {
    return (BOOL)hangul_is_syllable(character);
}

inline BOOL HGCharacterIsJamo(HGUCSChar character) {
    return (BOOL)hangul_is_jamo(character);
}

inline BOOL HGCharacterIsCompatibleJamo(HGUCSChar character) {
    return (BOOL)hangul_is_cjamo(character);
}

inline HGUCSChar HGCompatibleJamoFromJamo(HGUCSChar character) {
    return hangul_jamo_to_cjamo(character);
}

inline HGUCSChar HGJongseongFromChoseong(HGUCSChar character) {
    return hangul_choseong_to_jongseong(character);
}

inline HGUCSChar HGChoseongFromJongseong(HGUCSChar character) {
    return hangul_jongseong_to_choseong(character);
}

inline void HGGetDecomposedCharactersFromJongseong(HGUCSChar character,
                                                   HGUCSChar* jongseong, 
                                                   HGUCSChar* choseong) {
    return hangul_jongseong_dicompose(character, jongseong, choseong);
}

inline const HGUCSChar* HGPreviousSyllableInJamoString(const HGUCSChar* jamoString,
                                                       const HGUCSChar* begin) {
    return hangul_syllable_iterator_prev(jamoString, begin);
}

inline const HGUCSChar* HGNextSyllableInJamoString(const HGUCSChar* jamoString,
                                                   const HGUCSChar* end) {
    return hangul_syllable_iterator_next(jamoString, end);
}

inline NSInteger HGSyllableLength(const HGUCSChar *string, NSInteger maxLength) {
    return (NSInteger)hangul_syllable_len(string, (int)maxLength);
}

inline HGUCSChar HGSyllableFromJamo(HGUCSChar choseong, HGUCSChar jungseong, 
                                    HGUCSChar jongseong) {
    return hangul_jamo_to_syllable(choseong, jungseong, jongseong);
}

inline void HGGetJamoFromSyllable(HGUCSChar syllable, HGUCSChar *choseong, 
                                  HGUCSChar *jungseong, HGUCSChar *jongseong) {
    return hangul_syllable_to_jamo(syllable, choseong, jungseong, jongseong);
}

inline NSInteger HGGetSyllablesFromJamos(const HGUCSChar* jamos, NSInteger jamosLength,
                                         HGUCSChar* syllables, NSInteger syllablesLength) {
    return (NSInteger)hangul_jamos_to_syllables(syllables, (int)syllablesLength, jamos, (int)jamosLength);
}
